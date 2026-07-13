--- forge-render.yazi (quarto-render.yazi)
--- Yazi 插件：快捷键触发 .md/.qmd → gbt9704-pdf + gbt9704-docx 双格式渲染
---
--- .md 文件走 forge (QuartoForge) 管线：content.md → content.qmd → render
--- .qmd 文件直接 quarto render
---
--- 安装: ln -s /path/to/yazi-quarto/quarto-render.yazi ~/.config/yazi/plugins/
--- 快捷键: 在 keymap.toml 中添加 [[mgr.prepend_keymap]] on=["R"] run="plugin quarto-render"

local M = {}

-- 脚本路径: 优先环境变量，否则默认路径
local SCRIPT = os.getenv("FORGE_RENDER_SCRIPT")
    or "/home/song/NutstoreFiles/projects/yazi-quarto/forge-render.sh"

local function run_render(file_path)
    local output, err_code = Command("bash")
        :arg(SCRIPT)
        :arg(file_path)
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :output()

    if err_code ~= nil then
        ya.notify({
            title = "Forge Render",
            content = "Failed to run script (exit: " .. tostring(err_code) .. ")",
            timeout = 5.0,
            level = "error",
        })
        return
    end

    if not output.status.success then
        ya.notify({
            title = "Forge Render Failed",
            content = output.stderr and output.stderr:sub(1, 300) or "Unknown error",
            timeout = 8.0,
            level = "error",
        })
        return
    end

    -- 显示最后几行输出作为成功摘要
    local summary = output.stdout or ""
    local lines = {}
    for line in summary:gmatch("[^\r\n]+") do
        table.insert(lines, line)
    end
    local brief = table.concat(lines, "\n", math.max(1, #lines - 3))

    ya.notify({
        title = "Forge Render ✓",
        content = brief ~= "" and brief or "Done!",
        timeout = 5.0,
        level = "info",
    })
end

local get_hovered = ya.sync(function()
    local h = cx.active.current.hovered
    if not h then
        return nil
    end
    return tostring(h.url)
end)

function M:entry(_)
    local file_path = get_hovered()

    if not file_path then
        ya.notify({
            title = "Forge Render",
            content = "No file hovered",
            timeout = 3.0,
            level = "warn",
        })
        return
    end

    if not file_path:match("%.md$") and not file_path:match("%.qmd$") then
        ya.notify({
            title = "Forge Render",
            content = "仅支持 .md / .qmd:\n" .. file_path,
            timeout = 4.0,
            level = "warn",
        })
        return
    end

    run_render(file_path)
end

return M
