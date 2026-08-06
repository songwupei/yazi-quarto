#!/bin/bash
# ============================================================
# quarto-slides-render.sh — Yazi quarto-render 幻灯片脚本
#
# 基于 quarto，无扩展依赖：
#   .md / .qmd → quarto render → pptx / beamer PDF
#
# Usage: quarto-slides-render.sh <file_path> <pptx|beamer>
# ============================================================
set -euo pipefail

RED='\033[0;31m'
YELLOW='\033[1;33m'
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

# Validate format
case "$FORMAT" in
    pptx|beamer) ;;
    *)
        echo -e "${RED}❌ 不支持的格式: $FORMAT (仅支持 pptx, beamer)${NC}" >&2
        exit 1
        ;;
esac

INPUT_FILENAME=$(basename "$INPUT_FILE")
INPUT_BASENAME="${INPUT_FILENAME%.*}"
ORIG_DIR=$(realpath "$(dirname "$INPUT_FILE")")

echo "📄 输入文件: $INPUT_FILENAME"
echo "🎯 目标格式: $FORMAT"

# Check quarto
if ! command -v quarto &>/dev/null; then
    echo -e "${RED}❌ 未安装 quarto${NC}" >&2
    exit 1
fi

# Auto-detect format prefix (zhanshi-pptx, zhanshi-beamer, or raw pptx/beamer)
_detect_format_prefix() {
    local file="$1"
    local base_fmt="$2"
    if [ -f "$file" ]; then
        # Check if YAML has zhanshi-<fmt> for this specific format
        if sed -n '/^---$/,/^---$/p' "$file" | grep -qE "zhanshi-${base_fmt}"; then
            echo "zhanshi-${base_fmt}"
            return
        fi
    fi
    echo "$base_fmt"
}

TO_FORMAT=$(_detect_format_prefix "$INPUT_FILE" "$FORMAT")
echo "🔧 渲染格式: $TO_FORMAT"

# Render
cd "$ORIG_DIR"
echo "🖨️  quarto render --to $TO_FORMAT ..."
if ! quarto render "$INPUT_FILENAME" --to "$TO_FORMAT" 2>&1; then
    echo -e "${RED}❌ 渲染失败${NC}" >&2
    exit 1
fi

# Report output
case "$FORMAT" in
    pptx)
        OUTPUT="$ORIG_DIR/${INPUT_BASENAME}.pptx"
        if [ -f "$OUTPUT" ]; then
            echo "📤 PPTX → $OUTPUT"
        fi
        ;;
    beamer)
        OUTPUT="$ORIG_DIR/${INPUT_BASENAME}.pdf"
        if [ -f "$OUTPUT" ]; then
            echo "📤 PDF → $OUTPUT"
        fi
        ;;
esac

echo "✅ 完成!"
