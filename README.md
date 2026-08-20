# DSH 鲸鱼娘启动器（可迁移便携版）

一个桌面快捷方式 + 便携脚本，双击即可完成：
1. 自动清理 dsh* 残留插件目录（修复“安装插件后 DSH 启动报错”的问题）
2. 启动 DSH Web（直接用 Node 运行入口，不依赖 .ps1 文件关联）
3. 端口就绪后自动打开浏览器

兼容两类用户：
- 没装插件：清理步骤自动跳过，直接启动。
- 装了插件：启动前删除损坏的 dsh* 目录，保证能正常启动。

## 环境要求
- Windows 10/11（自带 Windows PowerShell 5.1）
- Node.js（DSH 依赖）
- 已安装 DSH：在命令行执行 npm install -g @deepseek-ai/dsh

## 快速开始
1. 双击 install.bat，桌面上生成“DSH 鲸鱼娘”快捷方式（带鲸鱼娘图标）。
2. 双击该快捷方式即可启动 DSH。

也可以手动运行：
powershell -NoProfile -ExecutionPolicy Bypass -File install.ps1

## 文件说明
- launch-dsh.ps1  启动主脚本（清理 + 启动 + 打开浏览器）
- install.ps1     安装桌面快捷方式
- install.bat     install.ps1 的双击入口
- uninstall.ps1   移除桌面快捷方式
- whale-girl.ico  鲸鱼娘图标
- README.md       本说明

## 配置（编辑 launch-dsh.ps1 顶部）
- $CleanBrokenPlugins  默认 $true：启动前删除 dsh* 残留目录；若确认某插件可正常使用并想保留，改为 $false。
- $DshUrl              默认 http://127.0.0.1:3080
- $OpenBrowser         默认 $true：启动后自动打开浏览器

脚本遵循环境变量 DSH_HOME（未设置时用用户目录下的 .dsh）。

## 迁移到其它电脑 / 用户
1. 把整个 DSH-WhaleGirl-Launcher 文件夹拷到目标机器（任意位置）。
2. 双击 install.bat 重新生成快捷方式（路径会自动指向新位置）。
3. 若移动了文件夹，重新运行一次 install.bat 即可。

## 排查
- 运行日志：用户目录下的 .dsh/launcher.log
- 每次冷启动会记录：清理了哪些目录、启动命令、是否在 20 秒内就绪。
- 未安装 DSH 时会弹窗提示。

## 图标版权
角色「溟月」原创：上善无形；DeepSeek 元素二创：ZipZipPipe；改进版修复：QYQCAMIAO。
协议 CC BY-NC-SA 4.0（署名-非商用-相同方式共享），仅限个人非商业使用。
