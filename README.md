# yazi-quarto

Yazi 插件：在文件管理器中选中 `.md` 或 `.qmd` 文件，一键渲染为 GB/T 9704 格式的 PDF + DOCX。

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

### 1. 克隆项目

```bash
git clone ssh://git@codeberg.org/songwupei/yazi-quarto.git ~/NutstoreFiles/projects/yazi-quarto
```

### 2. 安装 Yazi 插件

```bash
# 方式 A：直接运行安装脚本
bash ~/NutstoreFiles/projects/yazi-quarto/install.sh

# 方式 B：手动创建符号链接
ln -s ~/NutstoreFiles/projects/yazi-quarto/quarto-render.yazi ~/.config/yazi/plugins/
```

### 3. 添加快捷键

编辑 `~/.config/yazi/keymap.toml`，在 `[mgr]` 下添加：

```toml
[[mgr.prepend_keymap]]
on = ["R"]
run = "plugin quarto-render"
desc = "Forge render .md/.qmd → gbt9704-pdf + gbt9704-docx"
```

### 4. 配置（可选）

```bash
# 指定渲染脚本路径
export FORGE_RENDER_SCRIPT=/path/to/forge-render.sh

# 指定 PrettyDoc 项目路径
export PRETTYDOC_DIR=/path/to/PrettyDoc
```

## 使用

在 Yazi 中，将光标放在 `.md` 或 `.qmd` 文件上，按 **`R`**（大写 R，即 `Shift+r`）。

| 文件类型 | 渲染路径 |
|----------|----------|
| `.md` | forge 管线 → `content.qmd` → quarto render |
| `.qmd` | 直接 quarto render |

生成的 `.pdf` 和 `.docx` 输出在源文件同目录。

> 脚本会自动创建以下工作目录（无需手动创建）：
> - `reports/zflow/` — 临时 .md/.qmd 文件
> - `_output/zflow/` — forge 管线输出
> - `_output/reports/zflow/` — quarto 管线输出

### 命令行直接调用

```bash
~/NutstoreFiles/projects/yazi-quarto/forge-render.sh /path/to/document.md
~/NutstoreFiles/projects/yazi-quarto/forge-render.sh /path/to/document.qmd
```

## 项目结构

```
yazi-quarto/
├── forge-render.sh           # 核心渲染脚本（自动创建工作目录，.md → forge, .qmd → quarto）
├── install.sh                # 一键安装符号链接
├── quarto-render.yazi/       # Yazi 插件目录
│   └── main.lua              # 插件入口（快捷键触发 → 调用 forge-render.sh）
├── skills/                   # Claude Code 技能定义
│   └── forge-render-md/
│       └── SKILL.md
└── src/                      # 预留源码目录
```

## 依赖

| 依赖 | 说明 |
|------|------|
| [Yazi](https://yazi-rs.github.io/) | 终端文件管理器 |
| [PrettyDoc](https://codeberg.org/songwupei/PrettyDoc) | 文档排版项目（含 forge、gbt9704 扩展） |
| [QuartoForge](https://codeberg.org/songwupei/QuartoForge) | 管线引擎 |
| quarto + pandoc | 文档渲染 |
| doctyler | 样式管理 |
| micromamba | 环境管理（quarto 环境） |

## 快捷键

| 按键 | 功能 |
|------|------|
| `R` | 渲染当前文件 |
| `w` | 查看 Yazi 任务进度 |

## 许可证

MIT
