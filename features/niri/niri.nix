{ inputs, ... }:
{
  flake.nixosModules.niri =
    {
      config,
      lib,
      pkgs,
      user,
      ...
    }:
    let
      configDir = "${config.users.users.${user}.home}/sheng/features/niri/config";
    in
    {
      programs.niri = {
        enable = true;
      };

      # niri 默认文件选择是 nautilus，如果用其它文件管理器这里需要改成 gtk
      # https://github.com/YaLTeR/niri/wiki/Important-Software#portals
      xdg.portal.config.niri."org.freedesktop.impl.portal.FileChooser" = "gtk";

      # polkit agent
      security.soteria.enable = true;

      environment.systemPackages = with pkgs; [
        kanshi
        wpaperd

        # swaybg
        # waypaper
        # hyprlock
        swaylock-effects
        swayidle
        wlogout
        # wlsunset
        # fuzzel
        # waybar
        uwsm
        xwayland-satellite
        file-roller
        adwaita-icon-theme
        gnome-themes-extra
      ];

      hjem.users.${user} = {
        xdg.config.files = {
          # 替代 dconf prefer-dark
          "gtk-3.0/settings.ini".text = ''
            [Settings]
            gtk-application-prefer-dark-theme=1
          '';
          "gtk-4.0/settings.ini".text = ''
            [Settings]
            gtk-application-prefer-dark-theme=1
          '';

          "niri".source = configDir;
        };
      };

      services.greetd = {
        enable = true;
        settings = {
          default_session = {
            command = "${lib.getExe pkgs.tuigreet} --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions --time --time-format '%Y-%m-%d %H:%M' --asterisks --remember --remember-session";
          };
        };
      };

      # 确保 greetd 服务在 multi-user.target 之后启动
      # 避免在图形环境完全准备就绪前过早启动导致问题
      systemd.services.greetd = {
        after = [ "multi-user.target" ];
      };
    };
}
