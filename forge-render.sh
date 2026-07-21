#!/bin/bash
# ============================================================
# forge-render.sh — Yazi quarto-render 插件配套脚本 (v0.3.2)
#
# 基于 quarto + quarto-gbt9704 扩展，无 PrettyDoc 依赖：
#
#   .md / .qmd → quarto render → gbt9704-pdf + gbt9704-docx + gbt9704-html + PNG
#
# 工作流：
#   1. 确保 ~/.yazi-quarto/ 存在并已安装 quarto-gbt9704 扩展
#   2. 复制输入文件到 ~/.yazi-quarto/
#   3. quarto render --to gbt9704-pdf + gbt9704-docx + gbt9704-html
#   4. 浏览器截图 HTML → PNG
#   5. 复制输出回原始目录，清理临时文件
#
# Usage: forge-render.sh <file_path>
# ============================================================
set -euo pipefail

# ─── 颜色 ───
RED='\033[0;31m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# ─── 路径 ───
WORK_DIR="$HOME/.yazi-quarto"
EXT_NAME="songwupei/quarto-gbt9704"

# ─── 参数检查 ───
if [ $# -lt 1 ]; then
    echo -e "${RED}❌ 用法: $0 <file_path>${NC}" >&2
    exit 1
fi

INPUT_FILE="$1"

if [ ! -f "$INPUT_FILE" ]; then
    echo -e "${RED}❌ 文件不存在: $INPUT_FILE${NC}" >&2
    exit 1
fi

INPUT_FILENAME=$(basename "$INPUT_FILE")
INPUT_BASENAME="${INPUT_FILENAME%.*}"
INPUT_EXT="${INPUT_FILENAME##*.}"
ORIG_DIR=$(realpath "$(dirname "$INPUT_FILE")")

echo "📄 输入文件: $INPUT_FILENAME  (.${INPUT_EXT})"
echo "📁 原始目录: $ORIG_DIR"

# ─── 检查 quarto ───
if ! command -v quarto &>/dev/null; then
    echo -e "${RED}❌ 未安装 quarto${NC}" >&2
    echo "   安装方法: https://quarto.org/docs/get-started/" >&2
    exit 1
fi
echo "✅ quarto: $(quarto --version 2>/dev/null || echo 'ok')"

# ─── 初始化工作目录 ───
_init_workdir() {
    # 创建目录
    if ! mkdir -p "$WORK_DIR" 2>/dev/null; then
        echo -e "${RED}❌ 无法创建 $WORK_DIR（权限不足？）${NC}" >&2
        exit 1
    fi

    # 安装/更新 quarto-gbt9704 扩展
    echo "🔧 检查 quarto-gbt9704 扩展 ..."
    cd "$WORK_DIR"

    if [ ! -f "_extensions/songwupei/gbt9704/_extension.yml" ]; then
        echo "📦 安装 $EXT_NAME ..."
        if ! quarto add "$EXT_NAME" --no-prompt 2>&1; then
            echo -e "${RED}❌ 扩展安装失败: $EXT_NAME${NC}" >&2
            echo "   请检查网络连接，或手动运行:" >&2
            echo "   cd $WORK_DIR && quarto add $EXT_NAME" >&2
            exit 1
        fi
        echo "✅ 扩展已安装"
    else
        echo "✅ 扩展已就绪"
        # 尝试更新（失败则忽略）
        quarto add "$EXT_NAME" --no-prompt 2>/dev/null || true
    fi
}

# ─── 清理 ───
_cleanup() {
    rm -f "$WORK_DIR/$INPUT_FILENAME" 2>/dev/null || true
    rm -f "$WORK_DIR/${INPUT_BASENAME}"_files/* 2>/dev/null || true
    rmdir "$WORK_DIR/${INPUT_BASENAME}"_files 2>/dev/null || true
    rm -f "$WORK_DIR/${INPUT_BASENAME}.pdf" 2>/dev/null || true
    rm -f "$WORK_DIR/${INPUT_BASENAME}.docx" 2>/dev/null || true
    rm -f "$WORK_DIR/${INPUT_BASENAME}.html" 2>/dev/null || true
    rm -f "$WORK_DIR/${INPUT_BASENAME}.png" 2>/dev/null || true
    rm -f "$WORK_DIR/${INPUT_BASENAME}.qmd" 2>/dev/null || true
    rm -f "$WORK_DIR/${INPUT_BASENAME}.tex" 2>/dev/null || true
    rm -f "$WORK_DIR/gbt9704.cls" 2>/dev/null || true
    rm -f "$WORK_DIR/zhlineskip.sty" 2>/dev/null || true
}

# ─── 浏览器检测 ───
_detect_browser() {
    if command -v google-chrome-stable &>/dev/null; then
        echo "google-chrome-stable"
    elif command -v chromium &>/dev/null; then
        echo "chromium"
    else
        echo ""
    fi
}

_init_workdir

# ─── 复制输入文件到工作目录 ───
cp "$INPUT_FILE" "$WORK_DIR/$INPUT_FILENAME"
echo "📋 已复制 → $WORK_DIR/$INPUT_FILENAME"

cd "$WORK_DIR"

# ─── quarto render ───
echo ""
echo "🖨️  quarto render --to gbt9704-pdf ..."
if ! quarto render "$INPUT_FILENAME" --to gbt9704-pdf 2>&1; then
    echo -e "${RED}❌ PDF 渲染失败${NC}" >&2
    _cleanup
    exit 1
fi
echo "   ✓ PDF 完成"

echo "🖨️  quarto render --to gbt9704-docx ..."
if ! quarto render "$INPUT_FILENAME" --to gbt9704-docx 2>&1; then
    echo -e "${RED}❌ DOCX 渲染失败${NC}" >&2
    _cleanup
    exit 1
fi
echo "   ✓ DOCX 完成"

echo "🖨️  quarto render --to gbt9704-html ..."
if quarto render "$INPUT_FILENAME" --to gbt9704-html 2>&1; then
    echo "   ✓ HTML 完成"

    # ─── HTML → PNG 截图 ───
    BROWSER=$(_detect_browser)
    if [ -n "$BROWSER" ] && [ -f "$WORK_DIR/${INPUT_BASENAME}.html" ]; then
        echo "📸 $BROWSER 截图 → PNG ..."
        PNG_WIDTH=900
        if "$BROWSER" \
            --headless --disable-gpu --no-sandbox \
            --screenshot="$WORK_DIR/${INPUT_BASENAME}.png" \
            --window-size="${PNG_WIDTH},24000" \
            --default-background-color=ffffff \
            --hide-scrollbars \
            --virtual-time-budget=10000 \
            "file://${WORK_DIR}/${INPUT_BASENAME}.html" 2>/dev/null; then

            # ─── 裁白边 + 加边距（如果 ImageMagick 可用）───
            PNG_FILE="$WORK_DIR/${INPUT_BASENAME}.png"
            if [ -f "$PNG_FILE" ]; then
                MAGICK_CMD=""
                command -v magick &>/dev/null && MAGICK_CMD="magick" || {
                    command -v convert &>/dev/null && MAGICK_CMD="convert"
                }
                if [ -n "$MAGICK_CMD" ]; then
                    "$MAGICK_CMD" "$PNG_FILE" -trim +repage -bordercolor white -border 20x20 "$PNG_FILE" 2>/dev/null || true
                fi
                echo "   ✓ PNG 完成 ($(du -h "$PNG_FILE" | cut -f1))"
            fi
        else
            echo -e "  ${YELLOW}⚠  PNG 截图失败（HTML 保留）${NC}"
        fi
    elif [ -z "$BROWSER" ]; then
        echo -e "  ${YELLOW}⚠  未检测到浏览器（chrome/chromium），跳过 PNG 截图${NC}"
        echo "   💡 安装: sudo pacman -S google-chrome  或  sudo pacman -S chromium"
    fi
else
    echo -e "${YELLOW}⚠  HTML 渲染失败（可能需要 quarto-gbt9704 ≥ v0.3.1）${NC}"
fi

# ─── 复制输出回原目录 ───
COPIED=""
COPY_FMT=""
if [ -f "$WORK_DIR/${INPUT_BASENAME}.pdf" ]; then
    cp "$WORK_DIR/${INPUT_BASENAME}.pdf" "$ORIG_DIR/"
    COPIED="${COPIED}pdf "
    COPY_FMT="${COPY_FMT}PDF "
fi
if [ -f "$WORK_DIR/${INPUT_BASENAME}.docx" ]; then
    cp "$WORK_DIR/${INPUT_BASENAME}.docx" "$ORIG_DIR/"
    COPIED="${COPIED}docx "
    COPY_FMT="${COPY_FMT}DOCX "
fi
if [ -f "$WORK_DIR/${INPUT_BASENAME}.html" ]; then
    cp "$WORK_DIR/${INPUT_BASENAME}.html" "$ORIG_DIR/"
    COPIED="${COPIED}html "
    COPY_FMT="${COPY_FMT}HTML "
fi
if [ -f "$WORK_DIR/${INPUT_BASENAME}.png" ]; then
    cp "$WORK_DIR/${INPUT_BASENAME}.png" "$ORIG_DIR/"
    COPIED="${COPIED}png "
    COPY_FMT="${COPY_FMT}PNG "
fi

if [ -z "$COPIED" ]; then
    echo -e "${YELLOW}⚠️  警告: 没有找到输出文件${NC}"
    _cleanup
    exit 1
fi

echo "📤 ${COPY_FMT}→ ${ORIG_DIR}"

# ─── 清理 ───
_cleanup
echo "🧹 已清理临时文件"
echo "✅ 完成!"
