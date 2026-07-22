#!/bin/bash
# ============================================================
# uninstall.sh — 彻底卸载 yazi-quarto 插件
#
# 清理内容：
#   1. ~/.config/yazi/plugins/quarto-render.yazi/  插件目录
#   2. ~/.config/yazi/keymap.toml                  中 quarto-render 快捷键
#   3. ~/.yazi-quarto/                              工作目录（扩展缓存）
#
# 用法：
#   bash uninstall.sh              # 交互模式
#   bash uninstall.sh --yes        # 跳过确认
# ============================================================
set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m'

AUTO_YES=false
[[ "${1:-}" == "--yes" || "${1:-}" == "-y" ]] && AUTO_YES=true

_confirm() {
    $AUTO_YES && return 0
    echo -ne "  ${CYAN}? $1 [y/N] ${NC}"
    read -r REPLY
    case "$REPLY" in
        [Yy]*) return 0 ;;
        *)     return 1 ;;
    esac
}

_done()  { echo -e "  ${GREEN}✓${NC} $1"; }
_skip()  { echo -e "  ${YELLOW}−${NC} $1"; }
_info()  { echo -e "  ${CYAN}ℹ${NC} $1"; }

YAZI_CONFIG="${YAZI_CONFIG_HOME:-$HOME/.config/yazi}"
PLUGIN_DIR="$YAZI_CONFIG/plugins/quarto-render.yazi"
KEYMAP_FILE="$YAZI_CONFIG/keymap.toml"
WORK_DIR="$HOME/.yazi-quarto"

echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════╗${NC}"
echo -e "${BOLD}${CYAN}║     yazi-quarto  卸载                    ║${NC}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════╝${NC}"
echo ""

# ─── 1. 删除插件目录 ───
echo -e "${BOLD}1. 插件目录${NC}"
if [ -e "$PLUGIN_DIR" ]; then
    _info "目标: $PLUGIN_DIR"
    if _confirm "删除插件目录？"; then
        rm -rf "$PLUGIN_DIR"
        _done "已删除"
    else
        _skip "跳过"
    fi
else
    _skip "不存在"
fi

# ─── 2. 清理快捷键 ───
echo ""
echo -e "${BOLD}2. 快捷键${NC}"
if [ -f "$KEYMAP_FILE" ] && grep -q "quarto-render" "$KEYMAP_FILE"; then
    _info "目标: $KEYMAP_FILE 中的 quarto-render 条目"
    if _confirm "删除快捷键配置？"; then
        # 删除包含 "quarto-render" 的行及其上下的空行/注释
        sed -i '/\[\[mgr.prepend_keymap\]\]/,/run = "plugin quarto-render"/{
            /quarto-render/d
            /\[\[mgr.prepend_keymap\]\]/d
            /desc = "Render/d
        }' "$KEYMAP_FILE"
        # 清理连续空行
        sed -i '/^$/{ N; /^\n$/d; }' "$KEYMAP_FILE"
        _done "已清理"
    else
        _skip "跳过"
    fi
else
    _skip "无 quarto-render 快捷键"
fi

# ─── 3. 删除工作目录 ───
echo ""
echo -e "${BOLD}3. 工作目录${NC}"
if [ -d "$WORK_DIR" ]; then
    _info "目标: $WORK_DIR（含 quarto-gbt9704 扩展缓存）"
    if _confirm "删除工作目录？"; then
        rm -rf "$WORK_DIR"
        _done "已删除"
    else
        _skip "跳过"
    fi
else
    _skip "不存在"
fi

echo ""
echo -e "${GREEN}${BOLD}卸载完成！${NC}"
echo "  如需重新安装，运行: bash install.sh"
