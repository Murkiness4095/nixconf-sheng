{
  flake.nixosModules.fuzzel =
    { pkgs, username, ... }:

    let
      # 1. 使用 pkgs.formats.ini 生成 INI 格式的配置文件
      iniFormat = pkgs.formats.ini { };

      fuzzelConfig = {
        main = {
          font = "monospace:size=12";
          terminal = "${pkgs.foot}/bin/foot";
          prompt = "'❯ '";
          layer = "overlay";
        };
        # 暗色主题配色（Tokyo Night 风格）
        colors = {
          background = "1a1b26cc";
          text = "c0caf5ff";
          match = "7aa2f7ff";
          selection = "33467cff";
          selection-text = "c0caf5ff";
          border = "7aa2f7ff";
        };
        border = {
          width = 2;
          radius = 8;
        };
      };
    in
    {
      hjem.users.${username} = {
        # 2. 安装 fuzzel 软件包
        packages = [ pkgs.fuzzel ];

        # 3. 将生成好的配置写入 ~/.config/fuzzel/fuzzel.ini
        files = {
          ".config/fuzzel/fuzzel.ini".source = iniFormat.generate "fuzzel.ini" fuzzelConfig;
        };
      };
    };
}
