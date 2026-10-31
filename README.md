# Bernie 的 NixOS 配置

使用 Nix Flakes + Home Manager 管理整台机器，所有配置集中在本仓库。

> [!IMPORTANT]
> **先提交，再构建。**
> 修改配置后，必须先 `git add` 并提交，再执行 `nix build` / `nixos-rebuild`。
> Flakes 只会把 Git 跟踪的文件纳入构建；未提交或未暂存的改动可能触发 dirty warning，
> 甚至完全不被 Nix 识别。切记：**commit first, build second.**

## 目录结构

- `flake.nix`                     — flake 入口，定义主机与输入。
- `hosts/<hostname>/`             — 每台主机专属的模块导入与 `hardware-configuration.nix`。
- `modules/nixos/`                — 系统级 NixOS 模块，按领域分组：
  - `core/`     — Nix、引导、网络、区域、字体、用户、系统 shell。
  - `desktop/`  — 音频、登录管理器、niri、monique。
  - `hardware/` — 蓝牙、屏幕亮度、指纹识别。
  - `apps/`     — 系统级应用与系统工具。
  - `services/` — Home Manager 接入、容器、代理、远程挂载。
- `modules/home/`                 — Home Manager 用户级配置，按领域分组：
  - `shells/`   — zsh、oh-my-zsh、powerlevel10k 与别名。
  - `desktop/`  — 终端、输入法、启动器、通知、OSD。
  - `editors/`  — neovim、opencode。
  - `apps/`     — lazygit 等用户应用。
  - `games/`    — Minecraft 启动器。
  - `services/` — rclone code-sync 等用户服务。
- `config/`                       — 由 `xdg.nix` 链接到 `~/.config` 的静态配置。
- `pkgs/`                         — 自定义包与 overlay。

`modules/nixos/default.nix` 与 `modules/home/default.nix` 只负责导入各领域目录；
每个领域目录内也有自己的 `default.nix` 汇总该目录下的模块。

## 迁移步骤

1. 把本配置仓库放到 `~/dotfiles`。
2. 将现有 `~/.p10k.zsh` 复制为 `~/dotfiles/modules/home/shells/p10k.zsh`。
3. 复制或重建 `flake.lock`：
   ```bash
   cd ~/dotfiles
   nix flake lock          # 或者直接从 /etc/nixos/flake.lock 复制过来
   ```
4. 用新路径重建系统：
   ```bash
   sudo nixos-rebuild switch --flake ~/dotfiles#bh-laptop-1
   ```
5. 验证一切正常后，可选清理旧 `/etc/nixos`。

## 常用别名（已在 `modules/home/shells/zsh.nix` 中定义）

- `nrs` — 重建并切换
- `nrt` — 重建并测试
- `nrb` — 重建并等待下次启动
- `ngc` — 清理旧 generation

## Niri 配置

`config/niri/` 由 `modules/home/xdg.nix` 整目录链接到 `~/.config/niri`：

- `config.kdl`       — 输入、布局、启动项与 include。
- `binds.kdl`        — 所有快捷键。
- `window-rules.kdl` — 窗口规则。
- `monitors.kdl`     — Monique 生成的显示器配置，请勿手改。

## 添加新软件

- **系统级**：在 `modules/nixos/<领域>/` 下新建 `xxx.nix`，加入该领域 `default.nix` 的 `imports`。
- **用户级**：在 `modules/home/<领域>/` 下新建 `xxx.nix`，加入该领域 `default.nix` 的 `imports`。
