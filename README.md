# SafeQueue - 泰坦时光服兼容版 / Titan Classic Compatibility Fork

[中文](#中文) | [English](#english)

## 中文

这是 [jordonwow/safequeue](https://github.com/jordonwow/safequeue) 的兼容性 fork，主要用于适配《魔兽世界》最新泰坦时光服客户端。

SafeQueue 是一个轻量级战场排队插件。这个分支保留暴雪原生战场确认框和受保护的“进入战斗”按钮，只调整界面布局与倒计时显示，避免客户端更新后按钮失效。

### 本分支改动

- 兼容泰坦时光服当前客户端接口（`Interface: 38001, 50504`）。
- 使用暴雪原生战场确认按钮，修复点击“进入战斗”没有反应的问题。
- 加高原生确认框并居中显示 SafeQueue 倒计时，避免文字被裁切或溢出。
- 只保留底部“进入战斗”按钮，同时保留右上角最小化按钮。
- 在小地图战场图标上显示排队确认倒计时。
- 最后 10 秒隐藏 SafeQueue 的小地图倒计时，避免与暴雪原生倒计时重叠。
- 兼容 `confirm` 和 `confirmed` 战场确认状态，并动态识别可用的战场队列数量。

### 安装

将插件目录放到泰坦时光服客户端的插件目录：

```text
World of Warcraft/_classic_titan_/Interface/AddOns/SafeQueue
```

进入角色选择界面后，在“插件”列表中启用 SafeQueue。更新插件文件后，可在游戏内执行 `/reload` 重新加载界面。

### 问题排查

如果战场确认框再次出现按钮或倒计时异常，可在确认框显示期间输入：

```text
/sqdebug
```

请将聊天窗口中的调试信息和界面截图附到 [Issue](https://github.com/Zeptol/safequeue/issues) 中。

### 上游项目

- 原项目：[jordonwow/safequeue](https://github.com/jordonwow/safequeue)
- 原作者：Jordon
- 当前兼容版维护仓库：[Zeptol/safequeue](https://github.com/Zeptol/safequeue)

感谢原作者及上游贡献者对 SafeQueue 的长期维护。

## English

This repository is a compatibility fork of [jordonwow/safequeue](https://github.com/jordonwow/safequeue), maintained primarily for the latest World of Warcraft Titan Classic client.

SafeQueue is a lightweight battleground queue addon. This fork keeps Blizzard's native battleground confirmation dialog and protected Enter Battle button, while adjusting the layout and countdown display to remain functional after client updates.

### Changes in This Fork

- Supports the current Titan Classic client interfaces (`Interface: 38001, 50504`).
- Uses Blizzard's native battleground confirmation button to fix Enter Battle clicks that previously had no effect.
- Increases the height of the native confirmation dialog and centers the SafeQueue countdown so the text is not clipped or drawn outside the frame.
- Keeps only the bottom Enter Battle button while preserving the minimize button in the top-right corner.
- Displays the queue confirmation countdown on the minimap battleground icon.
- Hides SafeQueue's minimap countdown during the final 10 seconds to prevent it from overlapping Blizzard's native countdown.
- Handles both `confirm` and `confirmed` battleground states and detects the available queue count dynamically.

### Installation

Place the addon directory in the Titan Classic addon folder:

```text
World of Warcraft/_classic_titan_/Interface/AddOns/SafeQueue
```

Enable SafeQueue from the AddOns list on the character selection screen. After updating the addon files, run `/reload` in game to reload the interface.

### Troubleshooting

If the battleground confirmation dialog, buttons, or countdown stop working correctly, enter the following command while the confirmation dialog is visible:

```text
/sqdebug
```

Attach the debug output from the chat window and a screenshot to a new [Issue](https://github.com/Zeptol/safequeue/issues).

### Upstream

- Original project: [jordonwow/safequeue](https://github.com/jordonwow/safequeue)
- Original author: Jordon
- Current compatibility fork: [Zeptol/safequeue](https://github.com/Zeptol/safequeue)

Thanks to the original author and all upstream contributors for maintaining SafeQueue.
