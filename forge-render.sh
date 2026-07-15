#!/bin/bash
# ============================================================
# forge-render.sh — Yazi 插件配套脚本
# 自动识别文件类型，走不同渲染管线：
#
#   .md  → forge (QuartoForge) 管线:
#           content.md → content.qmd (gbt9704 扩展 + Lua 过滤器)
#           → quarto render → PDF + DOCX
#   .qmd → 直接 quarto render:
#           quarto render --to gbt9704-pdf + gbt9704-docx
#
# 以 PrettyDoc 的 reports/zflow/ 作为临时工作区
#
# Usage: forge-render.sh <file_path>
# ============================================================
set -euo pipefail

# ─── 可配置路径 ───
# install.sh 执行时会自动将下方的占位符替换为实际路径
PRETTYDOC_DIR="${PRETTYDOC_DIR:-__PRETTYDOC_DIR__}"
ZFLOW_DIR="${PRETTYDOC_DIR}/reports/zflow"

# --- 确保工作目录存在 ---
mkdir -p "$ZFLOW_DIR"
mkdir -p "${PRETTYDOC_DIR}/_output/zflow"
mkdir -p "${PRETTYDOC_DIR}/_output/reports/zflow"

# --- 参数检查 ---
if [ $# -lt 1 ]; then
    echo "❌ 用法: $0 <file_path>" >&2
    exit 1
fi

INPUT_FILE="$1"

if [ ! -f "$INPUT_FILE" ]; then
    echo "❌ 文件不存在: $INPUT_FILE" >&2
    exit 1
fi

INPUT_FILENAME=$(basename "$INPUT_FILE")
INPUT_BASENAME="${INPUT_FILENAME%.*}"
INPUT_EXT="${INPUT_FILENAME##*.}"
ORIG_DIR=$(dirname "$INPUT_FILE")

echo "📄 输入文件: $INPUT_FILENAME  (.${INPUT_EXT})"
echo "📁 原始目录: $ORIG_DIR"

# --- 清理 zflow 残留 ---
_cleanup() {
    rm -f "${ZFLOW_DIR}/"*.md "${ZFLOW_DIR}/"*.qmd 2>/dev/null || true
    rm -f "${ZFLOW_DIR}/"*.cls "${ZFLOW_DIR}/"*.sty "${ZFLOW_DIR}/"*.tex 2>/dev/null || true
    rm -f "${PRETTYDOC_DIR}/_output/zflow/"*.* 2>/dev/null || true
    rm -f "${PRETTYDOC_DIR}/_output/reports/zflow/"*.* 2>/dev/null || true
}

_cleanup

# --- 初始化 micromamba ---
echo "🔧 激活 quarto 环境 ..."
eval "$(micromamba shell hook --shell bash)"
micromamba activate quarto

cd "$PRETTYDOC_DIR"

# ================================================================
# 路径 A: .md → forge 管线
# ================================================================
if [ "$INPUT_EXT" = "md" ]; then
    echo "📝 检测到 .md 文件 → 使用 forge 管线"
    echo ""

    # 1. 复制到 zflow 作为 content.md（forge 约定）
    cp "$INPUT_FILE" "${ZFLOW_DIR}/content.md"
    echo "📋 已复制 → reports/zflow/content.md"

    # 2. forge: docx
    echo "🖨️  forge → docx ..."
    ./forge zflow --format docx
    if [ -f "${PRETTYDOC_DIR}/_output/zflow/content.docx" ]; then
        cp "${PRETTYDOC_DIR}/_output/zflow/content.docx" "${ORIG_DIR}/${INPUT_BASENAME}.docx"
        echo "   📤 ${INPUT_BASENAME}.docx → $ORIG_DIR"
    else
        echo "   ⚠️  docx 未生成"
    fi

    # 3. forge: pdf (gbt9704-pdf, xelatex)
    echo "🖨️  forge → pdf ..."
    ./forge zflow --format pdf
    if [ -f "${PRETTYDOC_DIR}/_output/zflow/content-latex.pdf" ]; then
        cp "${PRETTYDOC_DIR}/_output/zflow/content-latex.pdf" "${ORIG_DIR}/${INPUT_BASENAME}.pdf"
        echo "   📤 ${INPUT_BASENAME}.pdf → $ORIG_DIR"
    elif [ -f "${PRETTYDOC_DIR}/_output/zflow/content.pdf" ]; then
        cp "${PRETTYDOC_DIR}/_output/zflow/content.pdf" "${ORIG_DIR}/${INPUT_BASENAME}.pdf"
        echo "   📤 ${INPUT_BASENAME}.pdf → $ORIG_DIR"
    else
        echo "   ⚠️  pdf 未生成"
    fi

# ================================================================
# 路径 B: .qmd → 直接 quarto render
# ================================================================
elif [ "$INPUT_EXT" = "qmd" ]; then
    echo "📝 检测到 .qmd 文件 → 直接 quarto render"
    echo ""

    # 1. 复制到 zflow
    cp "$INPUT_FILE" "${ZFLOW_DIR}/${INPUT_FILENAME}"
    echo "📋 已复制 → reports/zflow/${INPUT_FILENAME}"

    # 2. quarto render: gbt9704-pdf
    echo "🖨️  quarto render --to gbt9704-pdf ..."
    quarto render "reports/zflow/${INPUT_FILENAME}" --to gbt9704-pdf
    echo "   ✓ PDF 完成"

    # 3. quarto render: gbt9704-docx
    echo "🖨️  quarto render --to gbt9704-docx ..."
    quarto render "reports/zflow/${INPUT_FILENAME}" --to gbt9704-docx
    echo "   ✓ DOCX 完成"

    # 4. 复制输出回原目录
    OUTPUT_SUBDIR="${PRETTYDOC_DIR}/_output/reports/zflow"
    COPIED=""
    if [ -f "${OUTPUT_SUBDIR}/${INPUT_BASENAME}.pdf" ]; then
        cp "${OUTPUT_SUBDIR}/${INPUT_BASENAME}.pdf" "${ORIG_DIR}/"
        echo "   📤 ${INPUT_BASENAME}.pdf → $ORIG_DIR"
        COPIED="${COPIED}pdf "
    fi
    if [ -f "${OUTPUT_SUBDIR}/${INPUT_BASENAME}.docx" ]; then
        cp "${OUTPUT_SUBDIR}/${INPUT_BASENAME}.docx" "${ORIG_DIR}/"
        echo "   📤 ${INPUT_BASENAME}.docx → $ORIG_DIR"
        COPIED="${COPIED}docx "
    fi
    if [ -z "$COPIED" ]; then
        echo "   ⚠️  警告: 没有找到输出文件"
    fi
else
    echo "❌ 不支持的文件类型: .${INPUT_EXT}（仅支持 .md 和 .qmd）" >&2
    exit 1
fi

# --- 清理 ---
_cleanup
echo "🧹 已清理 zflow 临时文件"
echo "✅ 完成!"
