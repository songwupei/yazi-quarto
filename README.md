# yazi-quarto

[![Version](https://img.shields.io/badge/version-0.1.0-blue)](https://codeberg.org/songwupei/yazi-quarto)
[![Yazi](https://img.shields.io/badge/Yazi-%E2%89%A5%2025.5.31-orange)](https://yazi-rs.github.io/)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

Yazi 插件：在文件管理器中选中 `.md` 或 `.qmd` 文件，一键渲染为 **GB/T 9704** 格式的 PDF + DOCX。

## 管线

```
.md 文件                           .qmd 文件
    │                                  │
    ▼                                  │
 forge (QuartoForge)                   │
 ├─ 标题提取                           │
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

## 安装

### 方式 A：ya pkg（推荐）

```sh
ya pkg add songwupei/yazi-quarto:quarto-render
```

### 方式 B：手动安装

```bash
git clone https://codeberg.org/songwupei/yazi-quarto.git /tmp/yazi-quarto
bash /tmp/yazi-quarto/install.sh
```

`install.sh` 自动完成：
- 创建 Yazi 插件符号链接
- 补丁脚本路径以适配当前电脑
- 查找并配置 PrettyDoc 路径
- 可选：添加键盘快捷键

```bash
bash install.sh --yes                  # 全自动
bash install.sh --prettydoc /path/     # 手动指定 PrettyDoc
bash install.sh --no-keymap            # 跳过快捷键
```

## 使用

在 Yazi 中，将光标放在 `.md` 或 `.qmd` 文件上，按 **`R`**（`Shift+r`）。

| 文件类型 | 渲染路径 |
|----------|----------|
| `.md` | forge 管线 → `content.qmd` → quarto render |
| `.qmd` | 直接 quarto render |

生成的 `.pdf` 和 `.docx` 输出在源文件同目录。

> 工作目录由脚本自动创建，无需手动操作。

### 命令行直接调用

```bash
./forge-render.sh /path/to/document.md
./forge-render.sh /path/to/document.qmd
```

## 快捷键

编辑 `~/.config/yazi/keymap.toml`：

```toml
[[mgr.prepend_keymap]]
on = ["R"]
run = "plugin quarto-render"
desc = "渲染 .md/.qmd → GB/T 9704 PDF + DOCX"
```

| 按键 | 功能 |
|------|------|
| `R` | 渲染当前文件 |
| `w` | 查看 Yazi 任务进度 |

## 配置

```bash
# 覆盖渲染脚本路径（通常不需要，install.sh 已自动配置）
export FORGE_RENDER_SCRIPT=/path/to/forge-render.sh

# 覆盖 PrettyDoc 路径（通常不需要，install.sh 已自动查找）
export PRETTYDOC_DIR=/path/to/PrettyDoc
```

## 项目结构

```
yazi-quarto/
├── LICENSE                    # MIT
├── README.md                  # 项目说明（本文件）
├── install.sh                 # 跨电脑一键安装脚本
├── forge-render.sh            # 核心渲染脚本
├── quarto-render.yazi/        # Yazi 插件目录
│   ├── LICENSE
│   ├── README.md
│   └── main.lua               # 插件入口
└── skills/                    # Claude Code 技能定义
    └── forge-render-md/
        └── SKILL.md
```

## 依赖

| 依赖 | 说明 |
|------|------|
| [Yazi](https://yazi-rs.github.io/) | 终端文件管理器（≥ 25.5.31） |
| [PrettyDoc](https://codeberg.org/songwupei/PrettyDoc) | 文档排版项目（含 forge、gbt9704 扩展） |
| [QuartoForge](https://codeberg.org/songwupei/QuartoForge) | 管线引擎 |
| quarto + pandoc | 文档渲染 |
| doctyler | 样式管理 |
| micromamba | 环境管理（quarto 环境） |

## 许可证

MIT — 详见 [LICENSE](LICENSE)
