{ lib, appimageTools, fetchurl, pkgs }:

let
  pname = "wechat";
  version = "4.1.13";

  src = fetchurl {
    url = "https://dldir1v6.qq.com/weixin/Universal/Linux/WeChatLinux_x86_64.AppImage";
    hash = "sha256-RSYYC8qYASh5FZmvEi/0eVACpXFaUQ9qZUgOK+aHQkQ=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };

  # WeChat 自带 fcitx5 的 Qt 输入法插件，但默认不设置 QT_IM_MODULE；
  # 在 Wayland 下不设置就无法用 fcitx5 输入中文。
  launcher = pkgs.writeShellScript "wechat-launcher" ''
    export QT_IM_MODULE=fcitx
    exec appimage-exec.sh -w ${appimageContents} -- "$@"
  '';
in
appimageTools.wrapAppImage {
  inherit pname version;
  src = appimageContents;

  runScript = launcher;

  meta = {
    description = "Messaging and calling app";
    homepage = "https://www.wechat.com/en/";
    downloadPage = "https://linux.weixin.qq.com/en";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    mainProgram = "wechat";
    platforms = [ "x86_64-linux" ];
  };

  extraInstallCommands = ''
    mkdir -p $out/share/applications
    cp ${appimageContents}/wechat.desktop $out/share/applications/
    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp ${appimageContents}/wechat.png $out/share/icons/hicolor/256x256/apps/

    substituteInPlace $out/share/applications/wechat.desktop \
      --replace-fail AppRun wechat
  '';
}
