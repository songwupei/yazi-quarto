---
name: forge-render-md
description: 将 Markdown/QMD 文件通过 forge+gbt9704 管线渲染为 GB/T 9704 格式的 PDF 和 DOCX
triggers:
  - forge.*render.*md
  - render.*md.*gbt9704
  - .*md.*转.*pdf
  - .*md.*转.*docx
  - gbt9704.*渲染
  - zflow.*渲染
  - yazi.*render
argument-hint: "<.md 或 .qmd 文件路径>"
---

# forge-render-md — Markdown/QMD → GB/T 9704 PDF + DOCX

一键将 `.md` 或 `.qmd` 文件渲染为符合 **GB/T 9704** 公文格式的 PDF 和 DOCX。

## 管线

```
.md 文件                           .qmd 文件
    │                                  │
    ▼                                  │
 forge (QuartoForge)                   │
 ├─ 标题提取 (content.md → title)     │
 ├─ YAML frontmatter 生成              │
 ├─ gbt9704 扩展 + Lua 过滤器          │
 └─ content.qmd                        │
    │                                  │
    └────────────┬─────────────────────┘
                 ▼
         quarto render
         ├─ --to gbt9704-pdf  (xelatex)
         └─ --to gbt9704-docx
                 │
                 ▼
         输出: .pdf + .docx → 原始目录
```

## 使用方式

### Yazi 快捷键

在 Yazi 中，选中 `.md` 或 `.qmd` 文件，按 **`R`** 即可触发渲染。
输出文件生成在原文件同目录。

### 命令行

```bash
# .md → forge 管线
forge-render-md.sh /path/to/document.md

# .qmd → 直接 quarto render
forge-render-md.sh /path/to/document.qmd
```

## 路径约定

| 路径 | 说明 |
|------|------|
| `~/NutstoreFiles/projects/PrettyDoc/` | 项目根，含 forge、_extensions/ |
| `reports/zflow/` | 临时工作区（每次渲染后自动清空） |
| `_output/zflow/` | forge 输出 (.md) |
| `_output/reports/zflow/` | quarto 输出 (.qmd) |

## 依赖

- `forge` (QuartoForge) — 通过 `QUARTOFORGE_PATH` 或相对路径找到
- `quarto` + `pandoc`
- `doctyler` (Python)
- `micromamba` (quarto 环境)
- gbt9704 扩展 (`_extensions/gbt9704/`)

## 相关文件

- `~/NutstoreFiles/scripts/1-yazi/quarto-render-gbt9704.sh` — 渲染脚本
- `~/.config/yazi/plugins/quarto-render.yazi/main.lua` — Yazi 插件
- `~/.config/yazi/keymap.toml` — 快捷键 `R`
- `~/NutstoreFiles/projects/PrettyDoc/forge` — QuartoForge 启动器
