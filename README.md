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
- `oc`  — 启动 opencode（沙箱版）

## Niri 配置

`config/niri/` 由 `modules/home/xdg.nix` 整目录链接到 `~/.config/niri`：

- `config.kdl`       — 输入、布局、启动项与 include。
- `binds.kdl`        — 所有快捷键。
- `window-rules.kdl` — 窗口规则。
- `monitors.kdl`     — Monique 生成的显示器配置，请勿手改。

## Phoenix STT

语音输入 daemon 来自独立的 flake 输入 `github:BernieHuang2008/phoenix-stt`：

- 包：`inputs.phoenix-stt.packages.${pkgs.system}.default`
- 启动：niri `spawn-at-startup "phoenix-stt" "daemon"`
- 快捷键：`Alt+Alt_R`（右 Alt，开始/停止录音）
- 配置：`config/phoenix-ai/stt.toml` → `~/.config/phoenix-ai/config/stt.toml`
- 密钥：`~/.config/phoenix-ai/secrets/models.json`（手动管理，权限 600，不纳入仓库）
- whisper 模型：`~/.local/share/phoenix-ai/models/ggml-small-q5_1.bin`

模型下载地址：

```bash
mkdir -p ~/.local/share/phoenix-ai/models
curl -L -o ~/.local/share/phoenix-ai/models/ggml-small-q5_1.bin \
  https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-small-q5_1.bin
```

## 抓包（Wireshark / mitmproxy）

- Wireshark 由 `modules/nixos/apps/wireshark.nix` 系统级安装，`bernie` 已在
  `wireshark` 组中，可直接抓包，无需 sudo。
- mitmproxy 由 `modules/home/apps/mitmproxy.nix` 安装，用于解密 HTTPS。

首次使用 mitmproxy 前，生成 CA 并把公钥证书纳入系统信任库：

```bash
mitm-ca-setup
cd ~/dotfiles
git add modules/nixos/core/mitmproxy-ca-cert.pem
git commit -m "add mitmproxy CA"
nrs
```

`mitm-ca-setup` 把 CA 私钥留在 `~/.mitmproxy/`，只把公钥证书复制进仓库；
请把 `~/.mitmproxy/` 追加到 `~/SECRET_PATHS.txt`。之后用 mitmproxy 代理流量，
即可在 Wireshark 中通过该 CA 解密 HTTPS。

## Chromium 书签固化

`modules/nixos/apps/chromium.nix` 通过 `ManagedBookmarks` 策略下发书签。它们会出现在
Chromium 的“受管理的书签”文件夹中，用户无法删除或修改；修改该文件后重新构建即可更新。

## Kali 容器（可选）

Kali 由 `modules/nixos/services/kali.nix` 管理，开关是 `my.services.kali.enable`
（`hosts/bh-laptop-1/default.nix` 中已打开）。首次运行：

```bash
kali
```

如果本地镜像不存在，会先用 `kalilinux/kali-rolling:latest` 构建 `kali-full:latest`，
默认安装 `kali-linux-everything`（几乎全部工具，镜像非常大，首次构建耗时较长）。
可手动执行 `kali-image-build` 重建，或在模块里把 `packages` 改成
`kali-linux-headless` / `kali-linux-default` 以减小体积。

## KVM 与 Windows 11

`modules/nixos/services/libvirt.nix` 启用 KVM、libvirt、TPM 2.0、SPICE 和 virt-manager，
并自动定义 libvirt 的 `default` NAT 网络。把 Windows 11 ISO 准备好后执行：

```bash
win11-vm-create /path/to/Win11.iso
```

默认创建 4 vCPU、8 GiB 内存、64 GiB 磁盘的虚拟机，使用 UEFI Secure Boot 和 TPM 2.0。
为了安装阶段免驱，默认磁盘为 SATA、网卡为 e1000e；virtio-win 驱动 ISO 已挂载为第二张
光盘（`/etc/virtio-win.iso`）。装好系统后可在 Windows 中安装 virtio 驱动，再用
virt-manager 把磁盘/网卡改成 virtio 以获得更好性能。磁盘/网卡可通过环境变量覆盖：

```bash
VM_DISK_BUS=virtio VM_NIC_MODEL=virtio win11-vm-create /path/to/Win11.iso
```

虚拟机管理使用 `virt-manager`。如果 `win11-vm-create` 提示没有 KVM，请在 BIOS 中开启
Intel VT-x / AMD-V。

## 添加新软件

- **系统级**：在 `modules/nixos/<领域>/` 下新建 `xxx.nix`，加入该领域 `default.nix` 的 `imports`。
- **用户级**：在 `modules/home/<领域>/` 下新建 `xxx.nix`，加入该领域 `default.nix` 的 `imports`。

## 私密文件清单（SECRET_PATHS.txt）

本仓库只存放可公开的配置，任何密钥、密码、令牌或凭据都**不得提交进仓库**。
所有私密文件的绝对路径集中记录在主目录的 `~/SECRET_PATHS.txt`，由用户手动管理。

> [!IMPORTANT]
> 今后新增任何不能公开的文件（密钥、密码 hash、API token、凭据等），
> 都必须把其绝对路径追加到 `~/SECRET_PATHS.txt`，并且不要提交进本仓库。

## opencode 沙箱

`modules/home/editors/opencode.nix` 把 opencode 包进 bubblewrap，在文件系统层面
屏蔽 `~/SECRET_PATHS.txt` 里的所有路径，对 opencode 及其**所有子进程**生效：

- 目录被空 tmpfs 覆盖，文件被 `/dev/null` 覆盖（读取返回 permission denied）。
- 沙箱隔离 USER/PID/IPC/UTS 命名空间，`/proc/*/root` 也无法绕过；无 CAP_SYS_ADMIN。
- `~/SECRET_PATHS.txt` 本身以只读方式挂载，沙箱内无法篡改清单。
- `programs.opencode.settings.permission` 另在工具层拒绝读取已知私密路径。
- 全局提示词写入 `~/.config/opencode/AGENTS.md`，要求遇到受限路径时先询问。

可用命令：

- `opencode` — 默认，屏蔽密钥，保留正常读写。
- `opencode-ro` — 同上，但除自身数据目录与 `/tmp` 外全盘只读。

修改 `~/SECRET_PATHS.txt` 后，**下次启动** opencode 才会应用新的屏蔽列表。
需要临时完全不受限时，直接运行 `${pkgs.opencode}/bin/opencode`（不推荐）。
