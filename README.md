# yazi-quarto · 一键中国公文排版 · One-Key GB/T 9704 Typesetting

[![Version](https://img.shields.io/badge/version-0.3.2-blue)](https://github.com/songwupei/yazi-quarto)
[![Yazi](https://img.shields.io/badge/Yazi-%E2%89%A5%2025.5.31-orange)](https://yazi-rs.github.io/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Hover on `.md` / `.qmd` in Yazi, press `R` — out comes a GB/T 9704-formatted PDF + DOCX + HTML + PNG. Zero config.

在 Yazi 中选中 `.md` / `.qmd`，按 `R` — GB/T 9704 格式 PDF + DOCX + HTML + PNG 直接生成。零配置。

## Highlights · 亮点

| | |
|---|---|
| 🔌 **零配置** | 首次运行自动创建 `~/.yazi-quarto/`、自动安装格式扩展 |
| 🧩 **全套自研** | [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704) 格式扩展 + 本插件，全部自研 |
| ⚡ **一键四格式** | 按 `R` 同时输出 PDF + DOCX + HTML + PNG |
| 🧹 **干净无残留** | 渲染后仅保留 `_extensions/`，其余自动清除 |

## Pipeline · 管线

```
.md / .qmd file
    │
    ▼
 ~/.yazi-quarto/
 ├─ quarto-gbt9704 extension (auto-installed · 自动安装)
 └─ quarto render
     ├─ --to gbt9704-pdf  (xelatex)
     ├─ --to gbt9704-docx
     └─ --to gbt9704-html → Chrome headless → PNG
         │
         ▼
  output: .pdf + .docx + .html + .png → source dir · 输出至源文件目录
```

## Install · 安装

### ya pkg (recommended · 推荐)

```sh
ya pkg add songwupei/yazi-quarto:quarto-render
```

### Manual · 手动

```bash
git clone https://github.com/songwupei/yazi-quarto.git /tmp/yazi-quarto
bash /tmp/yazi-quarto/install.sh
```

## Usage · 使用

Hover on a `.md` or `.qmd` file in Yazi, press **`R`** (`Shift+r`).

在 Yazi 中选中 `.md` 或 `.qmd` 文件，按 **`R`**。

Output `.pdf` + `.docx` + `.html` + `.png` appear in the same directory as the source file.

**First run:** auto-creates `~/.yazi-quarto/` and installs the [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704) extension.

**首次运行：** 自动创建 `~/.yazi-quarto/` 并安装 quarto-gbt9704 扩展。

## Keymap · 快捷键

```toml
[[mgr.prepend_keymap]]
on = ["R"]
run = "plugin quarto-render"
desc = "Render .md/.qmd → GB/T 9704 PDF + DOCX + HTML + PNG"
```

## Config · 配置

```bash
# Override render script path · 覆盖渲染脚本路径
export FORGE_RENDER_SCRIPT=/path/to/forge-render.sh
```

## Dependencies · 依赖

| Dependency | Note |
|---|---|
| [Yazi](https://yazi-rs.github.io/) | Terminal file manager（≥ 25.5.31） |
| [quarto](https://quarto.org/docs/get-started/) | Document rendering engine |
| [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704) | GB/T 9704 format extension ≥ v0.5.1 (auto-installed; ConTeXt dropped since v0.5.0) |

## License · 许可证

MIT — see [LICENSE](LICENSE)
