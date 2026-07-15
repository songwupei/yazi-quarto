# quarto-render.yazi · 一键 GB/T 9704 排版

[![Version](https://img.shields.io/badge/version-0.1.0-blue)](https://codeberg.org/songwupei/yazi-quarto)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

A Yazi plugin to render `.md` / `.qmd` files into **GB/T 9704** format (PDF + DOCX) with a single keypress.

Yazi 插件：一键将 `.md` / `.qmd` 文件渲染为 **GB/T 9704** 格式的 PDF + DOCX。

## Install · 安装

### A: ya pkg (recommended · 推荐, Yazi ≥ 25.5.31)

```sh
ya pkg add songwupei/yazi-quarto:quarto-render
```

Then add a keymap (see below). 然后添加快捷键。

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
| `.md` | forge → `content.qmd` → quarto render |
| `.qmd` | direct quarto render · 直接渲染 |

Output `.pdf` and `.docx` are placed next to the source file.

输出 `.pdf` / `.docx` 生成在源文件同目录。

## Dependencies · 依赖

- [Yazi](https://yazi-rs.github.io/) ≥ 25.5.31
- [PrettyDoc](https://codeberg.org/songwupei/PrettyDoc) — typesetting engine with forge + gbt9704 extension · 排版引擎
- quarto + pandoc
- micromamba (quarto environment · 环境管理)

## Config · 配置

```bash
# Override render script path · 覆盖渲染脚本路径
export FORGE_RENDER_SCRIPT=/path/to/forge-render.sh

# Override PrettyDoc path · 覆盖 PrettyDoc 路径
export PRETTYDOC_DIR=/path/to/PrettyDoc
```

## License · 许可证

MIT — see [LICENSE](LICENSE)
