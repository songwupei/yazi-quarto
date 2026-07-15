#!/usr/bin/env bash
# ============================================================
# install.sh — yazi-quarto 跨电脑一键安装脚本
#
# 功能:
#   1. 自动检测项目根目录（支持任意用户/任意路径）
#   2. 创建 Yazi 插件符号链接
#   3. 自动补丁 main.lua 中的脚本路径
#   4. 自动查找/配置 PrettyDoc 路径（写入 forge-render.sh）
#   5. 可选：自动添加快捷键到 keymap.toml
#   6. 安装后自检并给出彩色摘要
#
# 用法:
#   bash install.sh                   # 交互模式
#   bash install.sh --prettydoc DIR   # 手动指定 PrettyDoc 路径
#   bash install.sh --no-keymap       # 跳过快捷键配置
#   bash install.sh --yes             # 全部自动确认（非交互）
# ============================================================
set -euo pipefail

# ─── 颜色 ───
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

# ─── 全局状态 ───
WARNINGS=()
ERRORS=()
TODO=()
INSTALLED_COMPONENTS=()

# ─── 参数解析 ───
PRETTYDOC_ARG=""
SKIP_KEYMAP=false
AUTO_YES=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        --prettydoc)
            shift
            PRETTYDOC_ARG="$1"
            shift
            ;;
        --no-keymap)
            SKIP_KEYMAP=true
            shift
            ;;
        --yes|-y)
            AUTO_YES=true
            shift
            ;;
        --help|-h)
            echo "用法: $0 [选项]"
            echo ""
            echo "选项:"
            echo "  --prettydoc DIR   手动指定 PrettyDoc 项目路径"
            echo "  --no-keymap       跳过快捷键配置"
            echo "  --yes, -y         全部自动确认（非交互模式）"
            echo "  --help, -h        显示帮助"
            exit 0
            ;;
        *)
            echo -e "${RED}未知参数: $1${NC}（使用 --help 查看帮助）"
            exit 1
            ;;
    esac
done

# ─── 辅助函数 ───
_confirm() {
    local prompt="$1"
    if $AUTO_YES; then
        echo -e "  ${YELLOW}⚡ 自动确认: $prompt${NC}"
        return 0
    fi
    echo -ne "  ${CYAN}? $prompt [y/N] ${NC}"
    read -r REPLY
    case "$REPLY" in
        [Yy]*) return 0 ;;
        *)     return 1 ;;
    esac
}

_step() {
    echo -e "\n${BOLD}${CYAN}── $1 ──${NC}"
}

_success() {
    echo -e "  ${GREEN}✓${NC} $1"
    INSTALLED_COMPONENTS+=("$1")
}

_info() {
    echo -e "  ${CYAN}ℹ${NC} $1"
}

_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    WARNINGS+=("$1")
}

_error() {
    echo -e "  ${RED}❌${NC} $1"
    ERRORS+=("$1")
}

_check_cmd() {
    if ! command -v "$1" &>/dev/null; then
        _error "$1 未安装"
        TODO+=("安装 $1")
        return 1
    fi
    return 0
}

# ════════════════════════════════════════════════════════════
# 步骤 0: 检测项目根目录 & 环境
# ════════════════════════════════════════════════════════════
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
PLUGIN_SRC="$PROJECT_DIR/quarto-render.yazi"
FORGE_SCRIPT="$PROJECT_DIR/forge-render.sh"
MAIN_LUA="$PLUGIN_SRC/main.lua"

YAZI_CONFIG="${YAZI_CONFIG_HOME:-$HOME/.config/yazi}"
PLUGIN_DST="$YAZI_CONFIG/plugins/quarto-render.yazi"
KEYMAP_FILE="$YAZI_CONFIG/keymap.toml"

echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║     yazi-quarto  跨电脑安装              ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""
_info "项目目录 : ${GREEN}$PROJECT_DIR${NC}"
_info "用户配置  : ${GREEN}$YAZI_CONFIG${NC}"

# 校验项目完整性
for f in "$PLUGIN_SRC/main.lua" "$FORGE_SCRIPT"; do
    if [ ! -f "$f" ]; then
        _error "项目文件缺失: $f（请确保在完整的 git 仓库中运行）"
        exit 1
    fi
done

# 检测 yazi
_check_cmd "yazi"

# ════════════════════════════════════════════════════════════
# 步骤 1: 安装 Yazi 插件符号链接
# ════════════════════════════════════════════════════════════
_step "安装 Yazi 插件"

mkdir -p "$YAZI_CONFIG/plugins"

if [ -L "$PLUGIN_DST" ]; then
    current_target="$(readlink -f "$PLUGIN_DST" 2>/dev/null || readlink "$PLUGIN_DST")"
    if [ "$current_target" = "$PLUGIN_SRC" ]; then
        _success "插件链接已正确安装"
    else
        _warn "已有链接指向: $current_target"
        if _confirm "替换指向当前项目 ($PLUGIN_SRC)？"; then
            rm "$PLUGIN_DST"
            ln -s "$PLUGIN_SRC" "$PLUGIN_DST"
            _success "已更新插件链接 → $PLUGIN_SRC"
        fi
    fi
elif [ -d "$PLUGIN_DST" ]; then
    _error "目标位置是普通目录（非符号链接）: $PLUGIN_DST"
    _error "请手动删除后重试: rm -rf $PLUGIN_DST"
    exit 1
elif [ -e "$PLUGIN_DST" ]; then
    _error "目标位置已存在文件: $PLUGIN_DST"
    exit 1
else
    ln -s "$PLUGIN_SRC" "$PLUGIN_DST"
    _success "插件链接: $PLUGIN_DST → $PLUGIN_SRC"
fi

# ════════════════════════════════════════════════════════════
# 步骤 2: 补丁 main.lua — 写入项目路径
# ════════════════════════════════════════════════════════════
_step "配置 main.lua 脚本路径"

if grep -q "__YAZI_QUARTO_DIR__" "$MAIN_LUA"; then
    # 需要补丁
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|__YAZI_QUARTO_DIR__|$PROJECT_DIR|g" "$MAIN_LUA"
    else
        sed -i "s|__YAZI_QUARTO_DIR__|$PROJECT_DIR|g" "$MAIN_LUA"
    fi
    _success "已写入项目路径: $PROJECT_DIR"
elif grep -q "$PROJECT_DIR" "$MAIN_LUA"; then
    _success "main.lua 路径已正确（无需修改）"
else
    _warn "main.lua 中未找到占位符，且路径与当前项目不匹配"
    _info "脚本回退路径将使用当前值（可能不正确），可通过环境变量覆盖："
    _info "  export FORGE_RENDER_SCRIPT=$FORGE_SCRIPT"
fi

# ════════════════════════════════════════════════════════════
# 步骤 3: 查找 & 配置 PrettyDoc
# ════════════════════════════════════════════════════════════
_step "配置 PrettyDoc 路径"

if [ -n "$PRETTYDOC_ARG" ]; then
    # 用户通过命令行指定
    PRETTYDOC_DIR="$PRETTYDOC_ARG"
    _info "使用命令行指定的路径: $PRETTYDOC_DIR"
else
    # 自动搜索常见路径
    CANDIDATES=()

    # 候选 1: 同父目录下
    PARENT_DIR="$(dirname "$PROJECT_DIR")"
    if [ -d "$PARENT_DIR/PrettyDoc" ] && [ -f "$PARENT_DIR/PrettyDoc/forge" ]; then
        CANDIDATES+=("$PARENT_DIR/PrettyDoc")
    fi

    # 候选 2: ~/NutstoreFiles/projects/PrettyDoc (Nutstore 同步场景)
    if [ -d "$HOME/NutstoreFiles/projects/PrettyDoc" ] && [ -f "$HOME/NutstoreFiles/projects/PrettyDoc/forge" ]; then
        CANDIDATES+=("$HOME/NutstoreFiles/projects/PrettyDoc")
    fi

    # 候选 3: ~/projects/PrettyDoc
    if [ -d "$HOME/projects/PrettyDoc" ] && [ -f "$HOME/projects/PrettyDoc/forge" ]; then
        CANDIDATES+=("$HOME/projects/PrettyDoc")
    fi

    # 候选 4: 从环境变量读取
    if [ -n "${PRETTYDOC_DIR:-}" ] && [ -f "${PRETTYDOC_DIR}/forge" ]; then
        CANDIDATES+=("${PRETTYDOC_DIR}")
    fi

    # 去重
    CANDIDATES=($(printf '%s\n' "${CANDIDATES[@]}" | sort -u))

    if [ ${#CANDIDATES[@]} -gt 0 ]; then
        PRETTYDOC_DIR="${CANDIDATES[0]}"
        if [ ${#CANDIDATES[@]} -gt 1 ]; then
            _info "找到多个 PrettyDoc 候选，使用第一个: $PRETTYDOC_DIR"
            for c in "${CANDIDATES[@]}"; do
                _info "  · $c"
            done
        else
            _info "自动找到 PrettyDoc: $PRETTYDOC_DIR"
        fi
    else
        _warn "未找到 PrettyDoc（QuartoForge 排版引擎）"
        _info "你可以稍后设置: export PRETTYDOC_DIR=/path/to/PrettyDoc"
        _info "或重新运行: $0 --prettydoc /path/to/PrettyDoc"
        TODO+=("安装 PrettyDoc: https://codeberg.org/songwupei/PrettyDoc")
    fi
fi

# 补丁 forge-render.sh
if [ -n "${PRETTYDOC_DIR:-}" ]; then
    if [ -f "$PRETTYDOC_DIR/forge" ]; then
        if grep -q "__PRETTYDOC_DIR__" "$FORGE_SCRIPT"; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                sed -i '' "s|__PRETTYDOC_DIR__|$PRETTYDOC_DIR|g" "$FORGE_SCRIPT"
            else
                sed -i "s|__PRETTYDOC_DIR__|$PRETTYDOC_DIR|g" "$FORGE_SCRIPT"
            fi
            _success "已写入 PrettyDoc 路径: $PRETTYDOC_DIR"
        else
            _success "PrettyDoc 路径已配置"
        fi
    else
        _warn "PrettyDoc 路径存在但缺少 forge 可执行文件: $PRETTYDOC_DIR"
        _info "请确认已克隆完整仓库并有执行权限"
    fi
else
    # 未配置 PrettyDoc — 保持占位符，但给出明确警告
    if grep -q "__PRETTYDOC_DIR__" "$FORGE_SCRIPT"; then
        _warn "PrettyDoc 未配置，.md 渲染功能将无法使用（.qmd 不受影响）"
        _info "可通过以下方式配置:"
        _info "  1. 环境变量: export PRETTYDOC_DIR=/path/to/PrettyDoc"
        _info "  2. 重新运行: $0 --prettydoc /path/to/PrettyDoc"
    fi
fi

# ════════════════════════════════════════════════════════════
# 步骤 4: 快捷键配置
# ════════════════════════════════════════════════════════════
_step "快捷键配置"

KEYMAP_ENTRY='[[mgr.prepend_keymap]]
on = ["R"]
run = "plugin quarto-render"
desc = "Forge render .md/.qmd → gbt9704-pdf + gbt9704-docx"'

if $SKIP_KEYMAP; then
    _info "已跳过快捷键配置 (--no-keymap)"
elif [ -f "$KEYMAP_FILE" ]; then
    if grep -q "quarto-render" "$KEYMAP_FILE"; then
        _success "快捷鍵 R 已配置"
    else
        if _confirm "添加快捷键 R（在 keymap.toml 的 [mgr] 中）？"; then
            # 检查是否有 [mgr] section
            if grep -q '^\[mgr\]' "$KEYMAP_FILE"; then
                # 在 [mgr] section 后插入
                echo "" >> "$KEYMAP_FILE"
                echo "$KEYMAP_ENTRY" >> "$KEYMAP_FILE"
            else
                # 追加到文件末尾
                echo "" >> "$KEYMAP_FILE"
                echo "[mgr]" >> "$KEYMAP_FILE"
                echo "$KEYMAP_ENTRY" >> "$KEYMAP_FILE"
            fi
            _success "已添加快捷键 R（重启 yazi 后生效）"
        else
            _info "跳过快捷键配置"
            TODO+=("手动添加 keymap: 编辑 $KEYMAP_FILE，参考 README.md")
        fi
    fi
else
    _warn "$KEYMAP_FILE 不存在（yazi 尚未初始化？）"
    TODO+=("初始化 yazi 后再运行本脚本添加 keymap，或手动编辑 ~/.config/yazi/keymap.toml")
fi

# ════════════════════════════════════════════════════════════
# 安装摘要
# ════════════════════════════════════════════════════════════
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║            安装摘要                      ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BOLD}已安装组件:${NC}"
for c in "${INSTALLED_COMPONENTS[@]}"; do
    echo -e "  ${GREEN}✓${NC} $c"
done

if [ ${#WARNINGS[@]} -gt 0 ]; then
    echo ""
    echo -e "${BOLD}${YELLOW}警告:${NC}"
    for w in "${WARNINGS[@]}"; do
        echo -e "  ${YELLOW}⚠${NC} $w"
    done
fi

if [ ${#ERRORS[@]} -gt 0 ]; then
    echo ""
    echo -e "${BOLD}${RED}错误:${NC}"
    for e in "${ERRORS[@]}"; do
        echo -e "  ${RED}❌${NC} $e"
    done
fi

if [ ${#TODO[@]} -gt 0 ]; then
    echo ""
    echo -e "${BOLD}${CYAN}待完成:${NC}"
    for t in "${TODO[@]}"; do
        echo -e "  ${CYAN}→${NC} $t"
    done
fi

echo ""
echo -e "${BOLD}环境变量（可选）:${NC}"
echo -e "  export FORGE_RENDER_SCRIPT=${FORGE_SCRIPT}"
if [ -n "${PRETTYDOC_DIR:-}" ]; then
    echo -e "  export PRETTYDOC_DIR=${PRETTYDOC_DIR}"
else
    echo -e "  export PRETTYDOC_DIR=/path/to/PrettyDoc"
fi

echo ""
echo -e "${GREEN}${BOLD}安装完成！${NC}"
echo "  在 Yazi 中选中 .md 或 .qmd 文件，按 ${BOLD}R${NC} 渲染。"
echo "  如有问题，运行 ${CYAN}ml4w-diagnosis${NC} 或检查 ~/.config/yazi/"

# 返回码
if [ ${#ERRORS[@]} -gt 0 ]; then
    exit 1
fi
exit 0
