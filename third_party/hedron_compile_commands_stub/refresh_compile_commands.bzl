def refresh_compile_commands(name, **kwargs):
    native.genrule(
        name = name,
        outs = [name + ".txt"],
        cmd = "echo refresh_compile_commands stub > $@",
        visibility = kwargs.pop("visibility", ["//visibility:public"]),
    )
