# Antigravity & Antigravity IDE 双平台汉化 — AI 专用提示词文档

> 本文档专门用于直接投喂给 AI 编程助手（如 Antigravity、Claude Code、Gemini CLI、Cursor 等），让 AI 在 **Windows** 或 **Arch Linux** 环境下准确理解本汉化工具的架构、一键执行汉化/还原/状态检查、排查右侧 `agy` 面板未汉化问题，或增补词条与适配新版本。

---

## 一、快速使用：直接复制给 AI 的提示词模板

### 模板 1：一键执行汉化（Windows / Arch Linux 通用）
```text
请帮我使用当前目录（或指定路径）下的双平台汉化工具完成 Antigravity 主程序和 Antigravity IDE 右侧面板的汉化：
1. 先查看当前系统是 Windows 还是 Arch Linux，检查 Python 3.8+ 是否可用。
2. 运行状态检查：`python3 localize.py status`（Windows 用 `py -3 localize.py status`），确认 `app.asar` 与 `Antigravity IDE/resources/app/out` 路径是否被自动识别。
3. 若提示未找到安装目录，请先搜索本机 `antigravity`（含 `app.asar`）和 `Antigravity IDE`（含 `resources/app/out/main.js`）的实际路径，再用 `--path` 指定主程序路径，或补充 `find_ide_out()` 候选路径。
4. 执行 `apply` 完成汉化，并再次运行 `status` 验证主程序和 Antigravity IDE 右侧面板均为「已汉化」。
5. 注意：不要修改 `Antigravity IDE/resources/app/out/main.js` 的 ESM 模块类型（`package.json` 为 `"type": "module"`），必须使用 `import("./agy-zh-ide.mjs")` 而不是 `require(...)`。
```

### 模板 2：排查 Antigravity IDE 右侧面板仍为英文
```text
我的 Antigravity 主程序已经汉化，但 Antigravity IDE 右侧的 agy/Agent 面板仍然是英文。请按以下步骤排查并修复：
1. 定位 `Antigravity IDE` 的 `resources/app/out` 目录（Windows 默认 `%LOCALAPPDATA%\Programs\Antigravity IDE\resources\app\out`；Arch Linux 常见 `/opt/antigravity-ide/resources/app/out`、`/usr/lib/antigravity-ide/resources/app/out`、`~/.local/share/antigravity-ide/resources/app/out`）。
2. 检查该目录下是否存在 `agy-zh-ide.mjs`，以及 `out/main.js` 末尾是否包含 `// ===== [AGY_ZH_IDE_START]` 和 `import("./agy-zh-ide.mjs")`（注意不能用 `require()`，因为 `package.json` 声明了 `"type": "module"`）。
3. 检查 `agy-zh-ide.mjs` 是否通过 `node --check` 语法校验。
4. 如果钩子已加载但仍有少数新界面英文词条未翻译，请截图或提取原文，添加到 `zh_data.json` 的 `exact` 或 `regex` 字段中，再重新执行 `localize.py apply`（或调用 `patch_ide_out`）。
```

### 模板 3：Arch Linux（AUR / AppImage / 手动解压）适配与排障
```text
我现在在 Arch Linux 上使用 Antigravity / Antigravity IDE，请帮我完成汉化适配：
1. 检查 `pacman -Ql antigravity` / `pacman -Ql antigravity-ide`（或 `which antigravity`、`find /opt /usr ~/.local -name app.asar 2>/dev/null`）确认实际安装路径。
2. 确保 `一键汉化_Linux.sh` 为 LF 换行符并具备执行权限（`chmod +x 一键汉化_Linux.sh`）。
3. 如果安装在 `/opt` 或 `/usr/lib` 等 root 目录，使用 `sudo -E ./一键汉化_Linux.sh` 保留当前用户环境变量执行，避免 `PermissionError`。
4. 不要盲目 `pkill -f language_server`，`localize.py` 在 Linux 上已通过 `/proc/<pid>/exe` 精确匹配安装目录内进程，确保不会误杀其他编辑器的语言服务器。
```

### 模板 4：新增界面英文词条到词典
```text
我在界面上看到以下未汉化的英文文案：
- "<原文1>"
- "<原文2>"
请帮我：
1. 检查 `zh_data.json` 的 `exact`、`prefix`、`regex` 中是否已有对应词条（注意变量部分如用户名、数字、路径需放入 `regex`）。
2. 将缺失的词条以自然简洁的简体中文补充到 `zh_data.json`（保留专有名词如 Gemini、MCP、Git、URL、代码标识符不强行翻译）。
3. 验证 `zh_data.json` JSON 格式合法后，重新执行汉化部署（`localize.py apply --yes` 或更新 IDE 钩子）。
```

---

## 二、给 AI 的架构与约束说明书（System Context）

当你需要让 AI 修改脚本或深度排障时，可以将以下技术上下文一并提供给 AI：

### 1. 文件结构
- `localize.py`：核心跨平台部署脚本（支持 Windows / Arch Linux / macOS，内置纯 Python `asar` 解包与重打包器，无需强制依赖外部 `npx asar`）。
- `engine.js`：纯 Web API DOM 实时翻译引擎（无 `require`/网络依赖，兼容 Trusted Types、Shadow DOM、SPA 路由，物理隔离 `.monaco-editor`、`.xterm`、代码区与输入框）。
- `zh_data.json`：词典数据（包含 `exact`、`prefix`、`core`、`regex`、`exempt`、`mentionCategories`、`menuMap`、`staticPatches`）。
- `一键汉化_Windows.bat`：Windows 启动器（**必须保持纯 ASCII + CRLF**，避免非中文系统 code page 解析崩溃）。
- `一键汉化_Linux.sh`：Arch Linux / Linux 启动器（**必须保持 LF 换行符**，检测到 `/opt` 或 `/usr` 无写权限时自动 `sudo -E` 提权）。

### 2. 双宿主注入原理（为什么主程序和 IDE 要分开处理）
1. **Antigravity 主程序（Electron）**：
   - 资源包为 `<install>/resources/app.asar`。
   - `patch_all()` 解包后向 `dist/preload.js`、`dist/ideInstall/wizardPreload.js` 注入 `engine.js + zh_data.json`，并修补 `dist/menu.js`、`dist/tray.js`、`dist/updater.js` 与 `staticPatches`。
   - 原版备份保存为 `app.asar.bak`（仅当原版未汉化时创建/刷新，防止官方更新后还原降级）。
2. **Antigravity IDE（独立 VS Code 宿主）**：
   - 资源目录为 `<ide_install>/resources/app/out/`（未打包进 asar）。
   - 左侧 VS Code 工作台由语言包汉化；右侧 `agy` / Agent 面板由内置扩展 `extensions/agy` 通过 Webview + `<iframe>`（`http://127.0.0.1:<port>` / `localhost` / `jetskiAgent`）加载，**不经过主程序 `app.asar` 的 `preload.js`**。
   - `patch_ide_out()` 在 `out/` 下生成 `agy-zh-ide.mjs`，并在 `out/main.js` 末尾（`//# sourceMappingURL=` 之前）注入 `import("./agy-zh-ide.mjs").catch(() => {});`。
   - `agy-zh-ide.mjs` 在 Electron 主进程监听 `app.on('web-contents-created')` -> `wc.on('did-frame-finish-load')`，通过 `webFrameMain.fromId(pid, rid).executeJavaScript(ENGINE_SCRIPT)` 仅对 `127.0.0.1`/`localhost`、`vscode-webview://`、`workbench-jetski-agent.html` / `jetskiAgent` 帧注入引擎，**刻意跳过 `workbench.html`**，防止误译 VS Code 文件树、标签页或终端内容。

### 3. 绝对禁止踩的坑（AI 修改守则）
- **禁止在 `Antigravity IDE/resources/app/out/main.js` 中使用 `require()`**：其同级 `package.json` 设有 `"type": "module"`，必须使用 ESM `import` 和 `.mjs` 文件。
- **禁止在 `一键汉化_Linux.sh` 中写入 CRLF (`\r\n`)**：Windows 环境下编辑后务必转为 LF (`\n`)。
- **禁止在 `一键汉化_Windows.bat` 中写入中文字符**：`cmd.exe` 在非中文代码页下会把双字节字符解析为管道/转义符。
- **禁止在 Linux 上无过滤地 `pkill -f language_server`**：必须通过 `/proc/<pid>/exe` 比对安装目录前缀后再终止进程。
- **任何修改后必须通过校验**：`python3 -m py_compile localize.py`、JSON 解析校验、以及对生成 JS/MJS 的 `node --check`。
