#!/bin/bash
# ============================================================
# quarto-slides-render.sh — Yazi quarto-render 幻灯片脚本
#
#   .md / .qmd → quarto render → pptx / beamer PDF
#
# Usage: quarto-slides-render.sh <file_path> <pptx|beamer>
# ============================================================
set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ $# -lt 2 ]; then
    echo -e "${RED}❌ 用法: $0 <file_path> <pptx|beamer>${NC}" >&2
    exit 1
fi

INPUT_FILE="$1"
FORMAT="$2"

if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}❌ 文件不存在: $INPUT_FILE${NC}" >&2
    exit 1
fi

case "$FORMAT" in
    pptx|beamer) ;;
    *) echo -e "${RED}❌ 不支持的格式: $FORMAT${NC}" >&2; exit 1 ;;
esac

INPUT_FILENAME=$(basename "$INPUT_FILE")
INPUT_BASENAME="${INPUT_FILENAME%.*}"
ORIG_DIR=$(realpath "$(dirname "$INPUT_FILE")")

# ─── paths ───
CFG="${XDG_CONFIG_HOME:-$HOME/.config}"
PLUGIN_DIR="${CFG}/yazi/plugins/quarto-render.yazi"
WORK_DIR="$HOME/.yazi-quarto"
EXT_SRC="${PLUGIN_DIR}/assets/extensions/zhanshi"
EXT_DST="$WORK_DIR/_extensions/songwupei/zhanshi"

echo "📄 输入文件: $INPUT_FILENAME"
echo "🎯 目标格式: $FORMAT"

# Check quarto
if ! command -v quarto &>/dev/null; then
    echo -e "${RED}❌ 未安装 quarto${NC}" >&2
    exit 1
fi

# ─── ensure quarto-zhanshi extension ───
_init_extension() {
    mkdir -p "$WORK_DIR"
    if [ -f "$EXT_DST/_extension.yml" ]; then
        return 0  # already installed
    fi
    if [ ! -d "$EXT_SRC" ]; then
        echo -e "${YELLOW}⚠ 扩展源缺失: $EXT_SRC${NC}"
        echo "  尝试 quartz add ..."
        cd "$WORK_DIR"
        quarto add songwupei/quarto-zhanshi --no-prompt 2>&1 || true
        return
    fi
    echo "🔧 安装 quarto-zhanshi → ~/.yazi-quarto/_extensions/ ..."
    mkdir -p "$(dirname "$EXT_DST")"
    cp -r "$EXT_SRC" "$EXT_DST"
    echo "✅ 扩展已安装"
}
_init_extension

# ─── copy input + resources to workdir ───
cp "$INPUT_FILE" "$WORK_DIR/$INPUT_FILENAME"
# Copy images/ if present
[ -d "$ORIG_DIR/images" ] && cp -r "$ORIG_DIR/images" "$WORK_DIR/images" 2>/dev/null || true

cd "$WORK_DIR"

# ─── detect format prefix ───
_detect_format_prefix() {
    local file="$1"
    local base_fmt="$2"
    if [ -f "$file" ]; then
        if sed -n '/^---$/,/^---$/p' "$file" | grep -qE "zhanshi-${base_fmt}"; then
            echo "zhanshi-${base_fmt}"
            return
        fi
    fi
    echo "$base_fmt"
}
TO_FORMAT=$(_detect_format_prefix "$INPUT_FILENAME" "$FORMAT")
echo "🔧 渲染格式: $TO_FORMAT"

# ─── render ───
echo "🖨️  quarto render --to $TO_FORMAT ..."
if ! quarto render "$INPUT_FILENAME" --to "$TO_FORMAT" 2>&1; then
    echo -e "${RED}❌ 渲染失败${NC}" >&2
    # cleanup
    rm -f "$WORK_DIR/$INPUT_FILENAME" 2>/dev/null || true
    exit 1
fi

# ─── copy output back ───
case "$FORMAT" in
    pptx)
        OUT="$WORK_DIR/${INPUT_BASENAME}.pptx"
        if [ -f "$OUT" ]; then
            cp "$OUT" "$ORIG_DIR/"
            echo "📤 PPTX → $ORIG_DIR/${INPUT_BASENAME}.pptx"
        fi
        ;;
    beamer)
        OUT="$WORK_DIR/${INPUT_BASENAME}.pdf"
        if [ -f "$OUT" ]; then
            cp "$OUT" "$ORIG_DIR/"
            echo "📤 PDF → $ORIG_DIR/${INPUT_BASENAME}.pdf"
        fi
        ;;
esac

# ─── cleanup ───
rm -f "$WORK_DIR/$INPUT_FILENAME" 2>/dev/null || true
rm -f "$WORK_DIR/${INPUT_BASENAME}.pptx" 2>/dev/null || true
rm -f "$WORK_DIR/${INPUT_BASENAME}.pdf" 2>/dev/null || true
rm -f "$WORK_DIR/${INPUT_BASENAME}.tex" 2>/dev/null || true
rm -rf "$WORK_DIR/images" 2>/dev/null || true

echo "✅ 完成!"
