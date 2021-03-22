_llvm_distributions = {
    # 9.0.0
    "clang+llvm-9.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz": "a23b082b30c128c9831dbdd96edad26b43f56624d0ad0ea9edec506f5385038d",

    # 10.0.0
    "clang+llvm-10.0.0-x86_64-linux-gnu-ubuntu-18.04.tar.xz": "b25f592a0c00686f03e3b7db68ca6dc87418f681f4ead4df4745a01d9be63843",

    # 11.0.0
    "clang+llvm-11.0.0-x86_64-linux-gnu-ubuntu-20.04.tar.xz": "829f5fb0ebda1d8716464394f97d5475d465ddc7bea2879c0601316b611ff6db",
}

_llvm_distributions_base_url = {
    "9.0.0": "https://releases.llvm.org/",
    "10.0.0": "https://github.com/llvm/llvm-project/releases/download/llvmorg-",
    "11.0.0": "https://github.com/llvm/llvm-project/releases/download/llvmorg-",
}

def _python(rctx):
    # Get path of the python interpreter.

    python3 = rctx.which("python3")
    python = rctx.which("python")
    python2 = rctx.which("python2")
    if python3:
        return python3
    elif python:
        return python
    elif python2:
        return python2
    else:
        fail("python not found")

def download_llvm_preconfigured(rctx):
    llvm_version = rctx.attr.llvm_version

    mirror_base = []
    if rctx.attr.llvm_mirror:
        mirror_base += [rctx.attr.llvm_mirror]

    if rctx.attr.distribution == "auto":
        exec_result = rctx.execute([
            _python(rctx),
            rctx.path(rctx.attr._llvm_release_name),
            llvm_version,
        ])
        if exec_result.return_code:
            fail("Failed to detect host OS version: \n%s\n%s" % (exec_result.stdout, exec_result.stderr))
        if exec_result.stderr:
            print(exec_result.stderr)
        basename = exec_result.stdout.strip()
    else:
        basename = rctx.attr.distribution

    if basename not in _llvm_distributions:
        fail("Unknown LLVM release: %s\nPlease ensure file name is correct." % basename)

    url_suffix = "{0}/{1}".format(llvm_version, basename).replace("+", "%2B")
    urls = [
        "{0}{1}".format(_llvm_distributions_base_url[llvm_version], url_suffix),
    ]
    urls += [
        "{0}/{1}".format(base, url_suffix)
        for base in mirror_base
    ]

    rctx.download_and_extract(
        urls,
        sha256 = _llvm_distributions[basename],
        stripPrefix = basename[:(len(basename) - len(".tar.xz"))],
    )

def download_llvm(rctx):
    if rctx.os.name == "linux":
        urls = rctx.attr.urls.get("linux", default = [])
        sha256 = rctx.attr.sha256.get("linux", default = "")
        prefix = rctx.attr.strip_prefix.get("linux", default = "")
    else:
        fail("Unsupported OS: " + rctx.os.name)

    if not urls:
        return False

    rctx.download_and_extract(urls, sha256 = sha256, stripPrefix = prefix)
    return True
