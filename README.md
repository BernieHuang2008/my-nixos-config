# Bernie 的 NixOS 配置

使用 Nix Flakes + Home Manager 管理整台机器，所有配置集中在本仓库。

## 目录结构

- `flake.nix`                 — flake 入口，定义主机与输入。
- `hosts/<hostname>/`         — 每台主机专属的模块导入与 `hardware-configuration.nix`。
- `modules/nixos/`            — 系统级 NixOS 模块，按功能/服务拆成独立文件。
- `modules/home/`             — Home Manager 用户级配置，每个程序独立文件。

## 迁移步骤

1. 把本配置仓库放到 `~/dotfiles`。
2. 将现有 `~/.p10k.zsh` 复制为 `~/dotfiles/modules/home/p10k.zsh`。
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

## 常用别名（已在 `modules/nixos/zsh.nix` 中定义）

- `nrs` — 重建并切换
- `nrt` — 重建并测试
- `nrb` — 重建并等待下次启动
- `ngc` — 清理旧 generation

## 添加新软件

- **系统级**：在 `modules/nixos/` 下新建 `xxx.nix`，并加入 `modules/nixos/default.nix` 的 `imports`。
- **用户级**：在 `modules/home/` 下新建 `xxx.nix`，并加入 `modules/home/default.nix` 的 `imports`。
