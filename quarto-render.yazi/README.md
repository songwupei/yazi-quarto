# quarto-render.yazi · 一键 GB/T 9704 排版

[![Version](https://img.shields.io/badge/version-0.3.4-blue)](https://codeberg.org/songwupei/yazi-quarto)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

A Yazi plugin to render `.md` / `.qmd` files into **GB/T 9704** format (PDF + DOCX + HTML + PNG) with a single keypress.

Yazi 插件：一键将 `.md` / `.qmd` 文件渲染为 **GB/T 9704** 格式的 PDF + DOCX + HTML + PNG。

## Install · 安装

### A: ya pkg (recommended · 推荐, Yazi ≥ 25.5.31)

```sh
ya pkg add songwupei/yazi-quarto:quarto-render

# 添加快捷键（在 ~/.config/yazi/keymap.toml 中 [mgr] 段任意位置插入）
cat >> ~/.config/yazi/keymap.toml << 'EOF'
[[mgr.prepend_keymap]]
on = ["R"]
run = "plugin quarto-render"
desc = "Render .md/.qmd → GB/T 9704 PDF + DOCX"
EOF
```

Then restart Yazi or reload config.

### B: Manual · 手动

```bash
git clone https://codeberg.org/songwupei/yazi-quarto.git /tmp/yazi-quarto
bash /tmp/yazi-quarto/install.sh
```

## Keymap · 快捷键

Add to `~/.config/yazi/keymap.toml` under `[mgr]`:

```toml
[[mgr.prepend_keymap]]
on = ["R"]
run = "plugin quarto-render"
desc = "Render .md/.qmd → GB/T 9704 PDF + DOCX"
```

## Usage · 使用

Hover on a `.md` or `.qmd` file in Yazi and press `R` (`Shift+r`).

在 Yazi 中选中 `.md` 或 `.qmd` 文件，按 `R`。

| File type · 文件类型 | Pipeline · 管线 |
|---|---|
| `.md` | copy → quarto render (PDF + DOCX + HTML + PNG) |
| `.qmd` | copy → quarto render (PDF + DOCX + HTML + PNG) |

Output `.pdf`, `.docx`, `.html`, and `.png` are placed next to the source file.

输出 `.pdf` / `.docx` / `.html` / `.png` 生成在源文件同目录。

## Dependencies · 依赖

- [Yazi](https://yazi-rs.github.io/) ≥ 25.5.31
- [quarto](https://quarto.org/) + [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704) ≥ v0.5.1（ConTeXt 已放弃，仅 PDF/DOCX/HTML）
- pandoc
- XeLaTeX (for PDF output)
- Chrome/Chromium (optional, for PNG output)

## Config · 配置

```bash
# Override render script path · 覆盖渲染脚本路径
export FORGE_RENDER_SCRIPT=/path/to/forge-render.sh
```

## Uninstall · 卸载

```sh
# Delete plugin
rm -rf ~/.config/yazi/plugins/quarto-render.yazi

# Remove keymap entry in ~/.config/yazi/keymap.toml
# Delete the [[mgr.prepend_keymap]] block with "plugin quarto-render"

# Remove work directory (optional)
rm -rf ~/.yazi-quarto
```

## License · 许可证

MIT — see [LICENSE](LICENSE)
