{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    chromium
  ];

  programs.chromium = {
    enable = true;
    extensions = [
      "dbepggeogbaibhgnhhndojpepiihcmeb"  # Vimium
      "dhdgffkkebhmkfjojejmpbldmpobfkfo"  # Temper Monkey
      "nfmmmhanepmpifddlkkmihkalkoekpfd"  # m3u8 sniffer
    ];

    extraOpts = {
      # 使用 ExtensionSettings 策略为 Vimium 单独配置权限
      ExtensionSettings = {
        "dbepggeogbaibhgnhhndojpepiihcmeb" = {
          file_url_navigation_allowed = true;  # 允许扩展访问 file:// URL
          incognito = true;   # 允许扩展在无痕模式下运行
        };
      };

      # 由系统策略下发的书签会显示在“受管理的书签”文件夹中，
      # 用户无法删除或修改；这正是“固化”书签的方式。
      ManagedBookmarks = [
        {
          name = "PaddleOCR";
          url = "https://aistudio.baidu.com/paddleocr/task/file";
        }
        {
          name = "bh-svr-0";
          children = [
            {
              name = "Home Assistant";
              url = "http://bh-svr-0.local:8123/";
            }
            {
              name = "LLM Wiki";
              url = "http://bh-svr-0.local:5039/";
            }
            {
              name = "X Read";
              url = "http://bh-svr-0.local:5001/";
            }
            {
              name = "AI Workflow";
              url = "http://bh-svr-0.local:5010/";
            }
            {
              name = "webdav";
              url = "http://bh-svr-0.local:5038/webdav/";
            }
          ];
        }
      ];
    };
  };
}
