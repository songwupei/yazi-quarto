--- quarto-render.yazi v0.6.4
--- Yazi plugin: one-key render .md/.qmd/.typ → GB/T 9704-formatted output
--- 快捷键触发 → typst compile 或 quarto render → PDF + PNG/DOCX
---
--- 依赖: typst (typst.app) 或 quarto (quarto.org)
---
--- Keymap / 快捷键:
---   [[mgr.prepend_keymap]] on=["R"] run="plugin quarto-render"

local M = {}

-- Auto-detect plugin directory from this file's location
local PLUGIN_DIR = (debug.getinfo(1, "S").source:match("^@(.+/)") or "")
    :gsub("/+$", "")  -- strip trailing slashes

-- Script paths: env var first, fallback to bundled script / 脚本路径
local QUARTO_SCRIPT = os.getenv("FORGE_RENDER_SCRIPT")
    or (PLUGIN_DIR .. "/assets/quarto-render.sh")

local TYPST_SCRIPT = os.getenv("TYPST_RENDER_SCRIPT")
    or (PLUGIN_DIR .. "/assets/typst-render.sh")

local SLIDES_SCRIPT = os.getenv("SLIDES_RENDER_SCRIPT")
    or (PLUGIN_DIR .. "/assets/quarto-slides-render.sh")

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
    -- Extract summary line with 📤
    for line in (stdout or ""):gmatch("[^\r\n]+") do
        local clean = line:gsub("\27%[[0-9;]*[a-zA-Z]", "")
        if clean:match("📤") then
            return clean
        end
    end
    return "Done!"
end

local function run_script(script, file_path, force_fmt)
    local cmd = Command("bash")
        :arg(script)
        :arg(file_path)
    if force_fmt and #force_fmt > 0 then
        cmd = cmd:arg(force_fmt)
    end
    local output, err_code = cmd
        :stdout(Command.PIPED)
        :stderr(Command.PIPED)
        :output()

    if err_code ~= nil then
        ya.notify({
            title = "Render ✗",
            content = "Script execution failed: " .. tostring(err_code),
            timeout = 6.0,
            level = "error",
        })
        return
    end

    if not output.status.success then
        ya.notify({
            title = "Render ✗",
            content = extract_error(output.stderr),
            timeout = 8.0,
            level = "error",
        })
        return
    end

    ya.notify({
        title = "Render ✓",
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

function M:entry(args)
    -- Extract explicit format override from keymap args (e.g. "gbt9704" or "textbook")
    local force_fmt = nil
    if type(args) == "table" and #args > 0 then
        force_fmt = args[1]
    elseif type(args) == "string" and args ~= "" then
        force_fmt = args
    end

    local file_path = get_hovered()

    if not file_path then
        ya.notify({
            title = "Render",
            content = "No file hovered · 未选中文件",
            timeout = 3.0,
            level = "warn",
        })
        return
    end

    -- Detect file type and route / 检测文件类型并分流
    local is_typ = file_path:match("%.typ$")
    local is_md = file_path:match("%.md$")
    local is_qmd = file_path:match("%.qmd$")

    local script = nil
    local engine = nil

    -- Route slides formats (pptx/beamer) to slides script
    if force_fmt == "pptx" or force_fmt == "beamer" then
        if is_md or is_qmd then
            script = SLIDES_SCRIPT
            engine = "Slides"
        else
            ya.notify({
                title = "Slides Render",
                content = "仅支持 .md / .qmd:\n" .. file_path,
                timeout = 4.0,
                level = "warn",
            })
            return
        end
    elseif is_typ then
        script = TYPST_SCRIPT
        engine = "Typst"
    elseif is_md or is_qmd then
        script = QUARTO_SCRIPT
        engine = "Quarto"
    else
        ya.notify({
            title = "Render",
            content = "仅支持 .typ / .md / .qmd:\n" .. file_path,
            timeout = 4.0,
            level = "warn",
        })
        return
    end

    -- Show progress notification / 进度通知
    local fname = file_path:match("[^/]+$")
    ya.notify({
        title = "Render · " .. engine,
        content = "⏳ 渲染中...\n" .. fname,
        timeout = 2.0,
        level = "info",
    })

    run_script(script, file_path, force_fmt)
end

return M
