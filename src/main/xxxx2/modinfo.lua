name = "【野火警告】Wildfire Warning"
description = [[
    建议下方选择仅提示野火, 而不是默认的引燃也提示。



    It is recommended to select only prompt for wildfire below, rather than the default prompt for ignition.
]]
author = "冰汽"
version = "0.0.1"
forumthread = "/"
api_version = 10
icon_atlas = "modicon.xml"
icon = "modicon.tex"
all_clients_require_mod = false
client_only_mod = true
dst_compatible = true

configuration_options ={
    {
        name = "tips",
        label = "提示 TIPS",
        hover = "建议仅野火",
        options = {
            {description = "All", data = true, hover = "全部都提示"},
            {description = "Only Wildfire", data = false, hover = "仅野火"},
        },
        default = true,
    }
}