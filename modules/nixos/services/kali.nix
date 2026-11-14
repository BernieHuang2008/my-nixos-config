# Kali Linux 容器：可选开关。启用后安装 `kali` 与 `kali-image-build`，
# 首次运行 `kali` 时会基于官方 rolling 镜像构建带全套工具的本地镜像。
{ config, lib, pkgs, ... }:

let
  cfg = config.my.services.kali;

  dockerfile = pkgs.writeText "Dockerfile" ''
    FROM ${cfg.baseImage}

    ENV DEBIAN_FRONTEND=noninteractive

    RUN apt-get update \
     && apt-get -y full-upgrade \
     && apt-get -y install --no-install-recommends \
          ${lib.concatStringsSep " " cfg.packages} \
     && apt-get clean \
     && rm -rf /var/lib/apt/lists/*

    WORKDIR /root
    CMD ["/bin/bash"]
  '';

  dockerContext = pkgs.runCommand "kali-docker-context" { } ''
    mkdir -p $out
    cp ${dockerfile} $out/Dockerfile
  '';

  kaliImageBuild = pkgs.writeShellApplication {
    name = "kali-image-build";
    runtimeInputs = [ pkgs.docker ];
    text = ''
      exec docker build --tag ${lib.escapeShellArg cfg.image} ${dockerContext}
    '';
  };

  kali = pkgs.writeShellApplication {
    name = "kali";
    runtimeInputs = [ pkgs.coreutils pkgs.docker ];
    text = ''
      if ! docker image inspect ${lib.escapeShellArg cfg.image} >/dev/null 2>&1; then
        echo "Kali 镜像 ${cfg.image} 尚不存在，开始构建（首次会安装全套工具，耗时较长）..." >&2
        ${kaliImageBuild}/bin/kali-image-build
      fi

      ${lib.optionalString cfg.mountHome ''
        mkdir -p "$HOME/.kali"
      ''}

      exec docker run --rm -it \
        --hostname kali \
        --network ${lib.escapeShellArg cfg.network} \
        --cap-add NET_ADMIN \
        --cap-add NET_RAW \
        ${lib.optionalString cfg.mountHome ''--volume "$HOME/.kali:/root"''} \
        ${lib.escapeShellArgs cfg.extraArgs} \
        ${lib.escapeShellArg cfg.image} "$@"
    '';
  };
in
{
  options.my.services.kali = {
    enable = lib.mkEnableOption "Kali Linux Docker image and runner";

    baseImage = lib.mkOption {
      type = lib.types.str;
      default = "kalilinux/kali-rolling:latest";
      description = "Kali 官方基础镜像。";
    };

    image = lib.mkOption {
      type = lib.types.str;
      default = "kali-full:latest";
      description = "构建出的本地镜像名。";
    };

    packages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "kali-linux-everything" ];
      description = ''
        要安装的 Kali 元包。`kali-linux-everything` 包含几乎全部工具，
        镜像会非常大；也可以改成 `kali-linux-headless` 或 `kali-linux-default`。
      '';
    };

    network = lib.mkOption {
      type = lib.types.str;
      default = "host";
      description = "容器的 Docker 网络模式；默认使用 host 方便抓包和扫描。";
    };

    mountHome = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "是否把宿主机的 ~/.kali 挂载到容器的 /root，以便保存配置和文件。";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "额外传给 `docker run` 的参数。";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ kali kaliImageBuild ];
  };
}
