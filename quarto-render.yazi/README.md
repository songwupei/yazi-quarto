# quarto-render.yazi

[![Version](https://img.shields.io/badge/version-0.1.0-blue)](https://codeberg.org/songwupei/yazi-quarto)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Yazi 插件：一键将 `.md` / `.qmd` 文件渲染为 **GB/T 9704** 格式的 PDF + DOCX。

## 安装

### 方式 A：ya pkg（推荐，Yazi ≥ 25.5.31）

```sh
ya pkg add codeberg.org/songwupei/yazi-quarto:quarto-render
```

然后添加快捷键（见下方）。

### 方式 B：手动安装

```bash
git clone https://codeberg.org/songwupei/yazi-quarto.git /tmp/yazi-quarto
bash /tmp/yazi-quarto/install.sh
```

## 快捷键

编辑 `~/.config/yazi/keymap.toml`，在 `[mgr]` 下添加：

```toml
[[mgr.prepend_keymap]]
on = ["R"]
run = "plugin quarto-render"
desc = "渲染 .md/.qmd → GB/T 9704 PDF + DOCX"
```

## 使用

在 Yazi 中选中 `.md` 或 `.qmd` 文件，按 `R`（即 `Shift+r`）。

| 文件类型 | 渲染管线 |
|----------|----------|
| `.md` | forge 管线 → `content.qmd` → quarto render |
| `.qmd` | 直接 quarto render |

输出 `.pdf` 和 `.docx` 生成在源文件同目录。

## 依赖

- [Yazi](https://yazi-rs.github.io/) ≥ 25.5.31
- [PrettyDoc](https://codeberg.org/songwupei/PrettyDoc) — 排版引擎（含 forge、gbt9704 扩展）
- quarto + pandoc
- micromamba（quarto 环境管理）

## 配置

```bash
# 可选：覆盖渲染脚本路径
export FORGE_RENDER_SCRIPT=/path/to/forge-render.sh

# 可选：覆盖 PrettyDoc 路径
export PRETTYDOC_DIR=/path/to/PrettyDoc
```

## 许可证

MIT — 详见 [LICENSE](LICENSE)
