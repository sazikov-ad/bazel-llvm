def llvm_register_toolchains():
    native.register_toolchains(
        "@%{repo_name}//:cc-toolchain-linux",
    )