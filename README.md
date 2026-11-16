# antigravity-ide-zh-cn
自用，Linux和Windows都能用的Agy IDE汉化，来自https://github.com/QingniaoDawn/Antigravity-YiJianHanHua.git

# Antigravity & Antigravity IDE 双平台一键汉化（Windows + Arch Linux）

同时支持 **Antigravity 主程序** 与 **Antigravity IDE 右侧 `agy` 面板** 的中文汉化工具。

## 目录文件说明

- `一键汉化_Windows.bat`：Windows 一键汉化启动脚本（双击运行）
- `一键汉化_Linux.sh`：Arch Linux / Linux 一键汉化启动脚本
- `localize.py`：跨平台核心汉化与还原脚本（内置纯 Python `asar` 读写器）
- `engine.js`：前端 DOM 实时汉化引擎
- `zh_data.json`：汉化词典与正则规则库
- `AI专用提示词.md`：专门给 AI 助手使用的架构说明与提示词模板

## 使用方法

### Windows
双击运行 `一键汉化_Windows.bat`，按菜单选择：
- `1` 一键汉化（同时处理 Antigravity 主程序和 Antigravity IDE 右侧面板）
- `2` 恢复官方英文原版
- `3` 查看当前汉化状态

### Arch Linux / Linux
在终端进入本目录并赋予执行权限：
```bash
chmod +x 一键汉化_Linux.sh
./一键汉化_Linux.sh
```
- 如未安装 Python 3.8+，在 Arch Linux 上执行：`sudo pacman -S python`
- 若安装路径位于 `/opt` 或 `/usr/lib` 等系统目录，脚本会自动调用 `sudo -E` 请求管理员权限。
- 也可直接传参运行：
  - `./一键汉化_Linux.sh apply --yes`
  - `./一键汉化_Linux.sh status`
  - `./一键汉化_Linux.sh restore --yes`
  - `./一键汉化_Linux.sh apply --path /你的/antigravity路径`
