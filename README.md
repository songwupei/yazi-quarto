# yazi-quarto · 一键中国公文排版 · One-Key GB/T 9704 Typesetting

[![Version](https://img.shields.io/badge/version-0.6.0-blue)](https://github.com/songwupei/yazi-quarto)
[![Yazi](https://img.shields.io/badge/Yazi-%E2%89%A5%2025.5.31-orange)](https://yazi-rs.github.io/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Hover on `.typ` / `.md` / `.qmd` in Yazi, press `R` — auto-detects format from YAML frontmatter, renders to PDF + more. Zero config. Supports GB/T 9704 government docs, textbook layouts, and slides (PPTX + Beamer).

在 Yazi 中选中 `.typ` / `.md` / `.qmd`，按 `R` — 自动检测 YAML 格式、一键生成 PDF。零配置。支持 GB/T 9704 公文、教科书排版和幻灯片（PPTX + Beamer）。

## Highlights · 亮点

| | |
|---|---|
| 🔌 **零配置** | 首次运行自动创建 `~/.yazi-quarto/`、自动安装格式扩展 |
| 🔤 **Typst + Quarto 双引擎** | `.typ` → typst compile，`.md/.qmd` → quarto render，自动识别分流 |
| 🧩 **全套自研** | [typst-gbt9704](https://codeberg.org/songwupei/typst-gbt9704) + [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704) + [quarto-zhanshi](https://github.com/songwupei/quarto-zhanshi) 格式扩展，支持公文、教科书和幻灯片 |
| 🎯 **自动识别格式** | 读取 YAML `format:` 字段，自动选择对应格式 |
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
 ├─ extensions (auto-installed · 自动安装)
 │   ├─ songwupei/gbt9704  → GB/T 9704 公文格式
 │   └─ textbook           → 教科书排版格式
 └─ quarto render
     ├─ auto-detect format from YAML `format:` field
     ├─ gbt9704:  PDF + DOCX + HTML → Chrome headless → PNG
     └─ textbook: PDF only

### Slides (PPTX / Beamer)

```
.md / .qmd file
    │
    ▼
 ~/.yazi-quarto/
 ├─ _extensions/songwupei/zhanshi (auto-installed)
 ├─ copy input → render
 │
 └─ quarto render
     ├─ zhanshi-pptx  → slide-level 2 + reference.pptx
     └─ zhanshi-beamer → 青山绿水 (XeLaTeX, STKaiti, TikZ)
         │
         ▼
  output → source dir
```
         │
         ▼
  output → source dir
```

Format auto-detection: reads `format:` in YAML frontmatter.
- `format: textbook-pdf` → `--to textbook-pdf`
- default → `--to gbt9704-pdf`

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

| File type | Engine | Format Detection | Output |
|---|---|---|
| `.typ` | typst | N/A | PDF + PNG |
| `.md` | quarto | `format:` in YAML | PDF + DOCX + HTML + PNG |
| `.qmd` | quarto | `format:` in YAML | PDF (textbook: PDF only) |


> **Format auto-detection**: `.qmd` with `format: textbook-pdf` → textbook layout (B5, Noto Serif/Sans TC, 14pt, traditional Chinese). Default → gbt9704 (A4, GB/T 9704 government doc).

Output files appear in the same directory as the source file.

## Config · 配置

### Typst

```bash
# Enable/disable PNG output (default true). Set false for PDF only.
export TYPST_PNG=true

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
on = ["R", "g"]
run = "plugin quarto-render gbt9704"
desc = "GB/T 9704 公文格式"

[[mgr.prepend_keymap]]
on = ["R", "t"]
run = "plugin quarto-render textbook"
desc = "教科书排版格式"

[[mgr.prepend_keymap]]
on = ["R", "p"]
run = "plugin quarto-render pptx"
desc = "幻灯片 → PPTX"

[[mgr.prepend_keymap]]
on = ["R", "b"]
run = "plugin quarto-render beamer"
desc = "幻灯片 → Beamer PDF"
```

Press **`R`** to enter format selection, then:
- **`g`** — render as GB/T 9704 government document
- **`t`** — render as textbook layout
- **`p`** — render slides → PPTX (with `zhanshi-pptx` extension if available)
- **`b`** — render slides → Beamer PDF (with `zhanshi-beamer` extension if available)

Yazi will show available keys in the status bar after pressing `R`.

## Dependencies · 依赖

| Dependency | Note |
|---|---|
| [Yazi](https://yazi-rs.github.io/) | Terminal file manager（≥ 25.5.31） |
| [typst](https://typst.app/) | Typst compiler (for `.typ` files) |
| [typst-gbt9704](https://codeberg.org/songwupei/typst-gbt9704) | GB/T 9704 Typst package ≥ v0.2.0 |
| [quarto](https://quarto.org/docs/get-started/) | Document rendering engine (for `.md`/`.qmd` files) |
| [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704) | GB/T 9704 + textbook format extension ≥ v0.6.11 (auto-installed) |

## License · 许可证

MIT — see [LICENSE](LICENSE)
