# yazi-quarto · 一键 GB/T 9704 排版

[![Version](https://img.shields.io/badge/version-0.1.0-blue)](https://codeberg.org/songwupei/yazi-quarto)
[![Yazi](https://img.shields.io/badge/Yazi-%E2%89%A5%2025.5.31-orange)](https://yazi-rs.github.io/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

A Yazi plugin that renders `.md` / `.qmd` files into **GB/T 9704** format PDF + DOCX with a single keystroke.

Yazi 插件：在文件管理器中选中 `.md` 或 `.qmd` 文件，一键渲染为 **GB/T 9704** 格式的 PDF + DOCX。

## Pipeline · 管线

```
.md file                            .qmd file
    │                                   │
    ▼                                   │
 forge (QuartoForge)                    │
 ├─ title extraction · 标题提取         │
 ├─ YAML frontmatter · 元数据生成       │
 ├─ gbt9704 extension + Lua filter      │
 └─ content.qmd                         │
    │                                   │
    └────────────┬──────────────────────┘
                 ▼
         quarto render
         ├─ --to gbt9704-pdf  (xelatex)
         └─ --to gbt9704-docx
                 │
                 ▼
      output: .pdf + .docx → source dir · 输出至源文件目录
```

## Install · 安装

### A: ya pkg (recommended · 推荐)

```sh
ya pkg add songwupei/yazi-quarto:quarto-render
```

### B: Manual · 手动

```bash
git clone https://codeberg.org/songwupei/yazi-quarto.git /tmp/yazi-quarto
bash /tmp/yazi-quarto/install.sh
```

`install.sh` auto-handles:
- Symlink the Yazi plugin · 创建插件符号链接
- Patch script paths to match the current machine · 补丁脚本路径适配当前电脑
- Auto-detect and configure PrettyDoc path · 自动查找配置 PrettyDoc
- Optionally add keybinding · 可选添加快捷键

```bash
bash install.sh --yes                  # Fully auto · 全自动
bash install.sh --prettydoc /path/     # Set PrettyDoc · 手动指定
bash install.sh --no-keymap            # Skip keymap · 跳过快捷键
```

## Usage · 使用

Hover on a `.md` or `.qmd` file in Yazi, press **`R`** (`Shift+r`).

在 Yazi 中选中 `.md` 或 `.qmd` 文件，按 **`R`**。

| File type · 文件类型 | Pipeline · 渲染路径 |
|---|---|
| `.md` | forge → `content.qmd` → quarto render |
| `.qmd` | direct quarto render · 直接渲染 |

Output `.pdf` + `.docx` appear in the same directory as the source file.

生成的 `.pdf` 和 `.docx` 输出在源文件同目录。

> Working directories are auto-created; no manual setup needed.
> 工作目录由脚本自动创建，无需手动操作。

### CLI usage · 命令行调用

```bash
./forge-render.sh /path/to/document.md
./forge-render.sh /path/to/document.qmd
```

## Keymap · 快捷键

Edit `~/.config/yazi/keymap.toml`:

```toml
[[mgr.prepend_keymap]]
on = ["R"]
run = "plugin quarto-render"
desc = "Render .md/.qmd → GB/T 9704 PDF + DOCX"
```

| Key · 按键 | Action · 功能 |
|---|---|
| `R` | Render current file · 渲染当前文件 |
| `w` | Show Yazi task progress · 查看任务进度 |

## Config · 配置

```bash
# Override render script (usually not needed — install.sh handles it)
# 覆盖脚本路径（通常不需要，install.sh 已自动配置）
export FORGE_RENDER_SCRIPT=/path/to/forge-render.sh

# Override PrettyDoc path (usually not needed — install.sh auto-detects)
# 覆盖 PrettyDoc 路径（通常不需要，install.sh 已自动查找）
export PRETTYDOC_DIR=/path/to/PrettyDoc
```

## Project structure · 项目结构

```
yazi-quarto/
├── LICENSE                    # MIT
├── README.md                  # Project readme · 项目说明
├── install.sh                 # Cross-machine installer · 跨电脑安装脚本
├── forge-render.sh            # Core render script · 核心渲染脚本
├── quarto-render.yazi/        # Yazi plugin · 插件目录
│   ├── LICENSE
│   ├── README.md
│   └── main.lua               # Plugin entry · 插件入口
└── skills/                    # Claude Code skill definition
    └── forge-render-md/
        └── SKILL.md
```

## Dependencies · 依赖

| Dependency · 依赖 | Note · 说明 |
|---|---|
| [Yazi](https://yazi-rs.github.io/) | Terminal file manager · 终端文件管理器（≥ 25.5.31） |
| [PrettyDoc](https://codeberg.org/songwupei/PrettyDoc) | Typesetting engine with forge + gbt9704 extension · 排版项目 |
| [QuartoForge](https://codeberg.org/songwupei/QuartoForge) | Pipeline engine · 管线引擎 |
| quarto + pandoc | Document rendering · 文档渲染 |
| doctyler | Style management · 样式管理 |
| micromamba | Environment management · 环境管理（quarto 环境） |

## License · 许可证

MIT — see [LICENSE](LICENSE)
