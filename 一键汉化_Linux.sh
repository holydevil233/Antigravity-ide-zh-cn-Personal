#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo ""
echo " =============================================================="
echo "   Antigravity & Antigravity IDE 一键汉化 (Arch Linux / Linux)"
echo " =============================================================="
echo ""

if [[ ! -f "localize.py" ]]; then
  echo "[ERROR] 未找到 localize.py，请先完整解压文件夹后再运行。"
  exit 1
fi

if ! command -v python3 >/dev/null 2>&1; then
  echo "[ERROR] 未检测到 python3。"
  echo "  Arch Linux 请先安装：sudo pacman -S python"
  exit 1
fi

if ! python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)'; then
  echo "[ERROR] Python 版本过低，需要 3.8 及以上版本：$(python3 --version)"
  exit 1
fi

# 若安装目录位于 /opt 或 /usr（Arch AUR 默认位置）且当前非 root，自动提权并保留环境变量（-E）
NEEDS_SUDO=0
if [[ $EUID -ne 0 ]]; then
  for d in /opt/antigravity /opt/Antigravity /usr/lib/antigravity /usr/share/antigravity /opt/antigravity-ide "/opt/Antigravity IDE" /usr/lib/antigravity-ide; do
    if [[ -d "$d" && ! -w "$d" ]]; then
      NEEDS_SUDO=1
      break
    fi
  done
fi

if [[ $NEEDS_SUDO -eq 1 ]]; then
  echo "[*] 检测到系统目录安装（如 /opt 或 /usr/lib），需要管理员权限写入汉化补丁..."
  exec sudo -E bash "$0" "$@"
fi

exec python3 "$SCRIPT_DIR/localize.py" "$@"
