--- quarto-render.yazi v0.3.1
--- Yazi plugin: one-key render .md/.qmd → gbt9704-pdf + gbt9704-docx + gbt9704-html + PNG
--- 快捷键触发 .md / .qmd → quarto + gbt9704 → PDF + DOCX + HTML + PNG
---
--- 依赖: quarto (quarto.org), quarto-gbt9704 扩展 (自动安装)
--- 工作目录: ~/.yazi-quarto/
---
--- Keymap / 快捷键:
---   [[mgr.prepend_keymap]] on=["R"] run="plugin quarto-render"

local M = {}

-- Script path: env var first, fallback to the script bundled in this plugin
-- 脚本路径：优先环境变量，否则回退到插件自带的 forge-render.sh
local SCRIPT = os.getenv("FORGE_RENDER_SCRIPT")
    or (function()
        local cfg = os.getenv("XDG_CONFIG_HOME") or (os.getenv("HOME") .. "/.config")
        return cfg .. "/yazi/plugins/quarto-render.yazi/assets/forge-render.sh"
    end)()

local function extract_error(stderr)
    -- Extract meaningful error lines (skip ANSI/empty, keep last lines)
    local lines = {}
    for line in (stderr or ""):gmatch("[^\r\n]+") do
        local clean = line:gsub("\27%[[0-9;]*[a-zA-Z]", ""):match("^%s*(.-)%s*$")
        if clean and #clean > 0 then
            lines[#lines + 1] = clean
        end
    end
    if #lines == 0 then
        return "Unknown error"
    end
    -- Take last 5 meaningful lines
    local start = math.max(1, #lines - 4)
    local result = {}
    for i = start, #lines do
        result[#result + 1] = lines[i]
    end
    return table.concat(result, "\n")
end

local function extract_summary(stdout)
    local lines = {}
    for line in (stdout or ""):gmatch("[^\r\n]+") do
        local clean = line:gsub("\27%[[0-9;]*[a-zA-Z]", "")
        if #clean > 0 then
            lines[#lines + 1] = clean
        end
    end
    local start = math.max(1, #lines - 3)
    local result = {}
    for i = start, #lines do
        result[#result + 1] = lines[i]
    end
    return #result > 0 and table.concat(result, "\n") or "Done!"
end

local function run_render(file_path)
    local output, err_code = Command("bash")
        :arg(SCRIPT)
        :arg(file_path)
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :output()

    if err_code ~= nil then
        ya.notify({
            title = "Quarto Render ✗",
            content = "Script execution failed: " .. tostring(err_code),
            timeout = 6.0,
            level = "error",
        })
        return
    end

    if not output.status.success then
        ya.notify({
            title = "Quarto Render ✗",
            content = extract_error(output.stderr),
            timeout = 8.0,
            level = "error",
        })
        return
    end

    ya.notify({
        title = "Quarto Render ✓",
        content = extract_summary(output.stdout),
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
            title = "Quarto Render",
            content = "No file hovered · 未选中文件",
            timeout = 3.0,
            level = "warn",
        })
        return
    end

    if not file_path:match("%.md$") and not file_path:match("%.qmd$") then
        ya.notify({
            title = "Quarto Render",
            content = "仅支持 .md / .qmd:\n" .. file_path,
            timeout = 4.0,
            level = "warn",
        })
        return
    end

    -- Show progress notification before blocking call
    ya.notify({
        title = "Quarto Render",
        content = "⏳ 渲染中...\n" .. file_path:match("[^/]+$"),
        timeout = 2.0,
        level = "info",
    })

    run_render(file_path)
end

return M
