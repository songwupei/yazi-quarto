# quarto-render.yazi · 一键 GB/T 9704 排版

[![Version](https://img.shields.io/badge/version-0.2.2-blue)](https://github.com/songwupei/yazi-quarto)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

A Yazi plugin to render `.md` / `.qmd` files into **GB/T 9704** format (PDF + DOCX) with a single keypress.

Yazi 插件：一键将 `.md` / `.qmd` 文件渲染为 **GB/T 9704** 格式的 PDF + DOCX。

## Install · 安装

### ya pkg (recommended · 推荐, Yazi ≥ 25.5.31)

```sh
ya pkg add songwupei/yazi-quarto:quarto-render
```

Then add a keymap (see below).

### Manual · 手动

```bash
git clone https://github.com/songwupei/yazi-quarto.git /tmp/yazi-quarto
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

Output `.pdf` and `.docx` are placed next to the source file.

在 Yazi 中选中 `.md` 或 `.qmd` 文件，按 `R` 即可渲染。输出 `.pdf` / `.docx` 生成在源文件同目录。

**First run:** the plugin auto-creates `~/.yazi-quarto/` and installs the [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704) extension. This only happens once.

**首次运行：** 插件会自动创建 `~/.yazi-quarto/` 并安装 [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704) 扩展（仅需一次）。

## Dependencies · 依赖

- [Yazi](https://yazi-rs.github.io/) ≥ 25.5.31
- [quarto](https://quarto.org/docs/get-started/) — document rendering engine
- [quarto-gbt9704](https://github.com/songwupei/quarto-gbt9704) — GB/T 9704 format extension (auto-installed · 自动安装)

## Config · 配置

```bash
# Override render script path · 覆盖渲染脚本路径
export FORGE_RENDER_SCRIPT=/path/to/forge-render.sh
```

## License · 许可证

MIT — see [LICENSE](LICENSE)
