def _default_sysroot(rctx):
    return ""

# Return the sysroot path and the label to the files, if sysroot is not a system path.
def sysroot_path(rctx):
    if rctx.os.name == "linux":
        sysroot = rctx.attr.sysroot.get("linux", default = "")
    else:
        fail("Unsupported OS: " + rctx.os.name)

    if not sysroot:
        return (_default_sysroot(rctx), None)

    # If the sysroot is an absolute path, use it as-is. Check for things that
    # start with "/" and not "//" to identify absolute paths, but also support
    # passing the sysroot as "/" to indicate the root directory.
    if sysroot[0] == "/" and (len(sysroot) == 1 or sysroot[1] != "/"):
        return (sysroot, None)

    sysroot = Label(sysroot)
    if sysroot.workspace_root:
        return (sysroot.workspace_root + "/" + sysroot.package, sysroot)
    else:
        return (sysroot.package, sysroot)
