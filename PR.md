# quarto-render.yazi PR 素材

> 复制粘贴到 https://github.com/yazi-rs/yazi-rs.github.io 的 PR 中使用

---

## Commit message

```
Add quarto-render.yazi to resources

一键中国公文排版 · One-key GB/T 9704 typesetting
quarto-gbt9704 + quarto-render.yazi，零配置，全套自研
```

## PR description

````
## ✨ quarto-render.yazi — 一键中国公文排版 · One-Key GB/T 9704 Typesetting

Add [quarto-render.yazi](https://github.com/songwupei/yazi-quarto/tree/main/quarto-render.yazi) to the resources page.

---

Hover on `.md` / `.qmd` in Yazi, press `R` — out comes a GB/T 9704-formatted PDF + DOCX alongside the source. Zero config.

在 Yazi 中选中 `.md` / `.qmd` 文件，按 `R`，GB/T 9704 格式的 PDF + DOCX 直接生成在源文件旁边。无需任何配置。

### Highlights · 亮点

| | |
|---|---|
| 🔌 **Zero-config** | First run auto-creates `~/.yazi-quarto/` and installs the format extension |
| 🔌 **零配置** | 首次运行自动创建工作目录、自动安装格式扩展 |
| 🧩 **Self-built** | Both [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704) (the GB/T 9704 Quarto extension) and this plugin are built from scratch |
| 🧩 **全套自研** | [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704) 格式扩展 + quarto-render.yazi 插件，全部自研 |
| ⚡ **One key, two formats** | Single `R` press → PDF + DOCX |
| ⚡ **一键双格式** | 按一次 `R`，同时输出 PDF + DOCX |
| 🧹 **Clean workspace** | Only `_extensions/` persists between renders |
| 🧹 **干净无残留** | 渲染后仅保留 `_extensions/`，其余自动清除 |

### Dependencies · 依赖

- Yazi ≥ 25.5.31
- [quarto](https://quarto.org)

### Install · 安装

```sh
ya pkg add songwupei/yazi-quarto:quarto-render
```
````

## 资源页条目（添加到 File actions 区域，pandoc.yazi 附近）

```
*   [quarto-render.yazi](https://github.com/songwupei/yazi-quarto/tree/main/quarto-render.yazi) - Render `.md` / `.qmd` files to GB/T 9704 format (PDF + DOCX) with a single keypress, powered by quarto and [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704).
```
