# yazi-quarto · 一键中国公文排版 · One-Key GB/T 9704 Typesetting

[![Version](https://img.shields.io/badge/version-0.4.1-blue)](https://github.com/songwupei/yazi-quarto)
[![Yazi](https://img.shields.io/badge/Yazi-%E2%89%A5%2025.5.31-orange)](https://yazi-rs.github.io/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Hover on `.typ` / `.md` / `.qmd` in Yazi, press `R` — out comes a GB/T 9704-formatted PDF + more. Zero config.

在 Yazi 中选中 `.typ` / `.md` / `.qmd`，按 `R` — GB/T 9704 格式 PDF 直接生成。零配置。

## Highlights · 亮点

| | |
|---|---|
| 🔌 **零配置** | 首次运行自动创建 `~/.yazi-quarto/`、自动安装格式扩展 |
| 🔤 **Typst + Quarto 双引擎** | `.typ` → typst compile，`.md/.qmd` → quarto render，自动识别分流 |
| 🧩 **全套自研** | [typst-gbt9704](https://codeberg.org/songwupei/typst-gbt9704) + [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704) 格式扩展，全部自研 |
| ⚡ **一键多文件** | 按 `R` 根据文件类型自动选择引擎输出 |
| 🧹 **干净无残留** | Typst 零中间文件；Quarto 渲染后仅保留 `_extensions/`，其余自动清除 |
| 📋 **filter 中间件** | `.gbt9704.md` 保存 filter 处理后的中间 markdown，可复现可 diff |

## Pipeline · 管线

### Typst

```
.typ file
  │
  ▼
typst compile
  ├─ → .pdf  (native)
  └─ → .png  (single or multi-page)
```

No temp files, no cleanup needed. Output goes to source directory.

无临时文件，无需清理。输出到源文件目录。

### Quarto

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
  output: .pdf + .docx + .html + .png + .gbt9704.md → source dir
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

Hover on a `.typ`, `.md`, or `.qmd` file in Yazi, press **`R`** (`Shift+r`).

在 Yazi 中选中 `.typ`、`.md` 或 `.qmd` 文件，按 **`R`**。

| File type | Engine | Output |
|---|---|---|
| `.typ` | typst | PDF + PNG |
| `.md` | quarto | PDF + DOCX + HTML + PNG |
| `.qmd` | quarto | PDF + DOCX + HTML + PNG |

Output files appear in the same directory as the source file.

## Config · 配置

### Typst

```bash
# PNG output mode: multi (default, per-page) | single (first page only)
export TYPST_PNG_MODE=multi

# PNG resolution (default 300)
export TYPST_PNG_PPI=300
```

### Quarto

```bash
# Override render script path
export FORGE_RENDER_SCRIPT=/path/to/quarto-render.sh
```

## Keymap · 快捷键

```toml
[[mgr.prepend_keymap]]
on = ["R"]
run = "plugin quarto-render"
desc = "Render .typ/.md/.qmd → GB/T 9704 PDF + more"
```

## Dependencies · 依赖

| Dependency | Note |
|---|---|
| [Yazi](https://yazi-rs.github.io/) | Terminal file manager（≥ 25.5.31） |
| [typst](https://typst.app/) | Typst compiler (for `.typ` files) |
| [typst-gbt9704](https://codeberg.org/songwupei/typst-gbt9704) | GB/T 9704 Typst package ≥ v0.2.0 |
| [quarto](https://quarto.org/docs/get-started/) | Document rendering engine (for `.md`/`.qmd` files) |
| [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704) | GB/T 9704 format extension ≥ v0.5.1 (auto-installed) |

## License · 许可证

MIT — see [LICENSE](LICENSE)
