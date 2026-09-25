{ inputs, ... }:
{
  perSystem =
    { system, ... }:
    let
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      mkNixPak = inputs.nixpak.lib.nixpak {
        inherit pkgs;
        inherit (pkgs) lib;
      };

      appId = "com.tencent.QQ";

      wrapped = mkNixPak {
        config =
          { sloth, ... }:
          {
            # 使用 nixpkgs 官方 qq 包（稳定、已缓存）
            app.package = pkgs.qq;
            app.binPath = "bin/qq"; # 官方包的实际可执行路径

            # Flatpak-like ID，用于桌面集成
            flatpak.appId = appId;

            # 禁用 nixpak 自带字体，使用系统字体
            fonts.enable = false;

            dbus.enable = true;
            dbus.policies = {
              # 写 "portal.*" 会导致 qq 越权，必须手动指定 portal 权限
              # "org.freedesktop.portal.*" = "talk"; # 文件选择、截屏、通知等
              "org.freedesktop.portal.Notification" = "talk";
              "org.freedesktop.portal.Settings" = "talk";
              "org.freedesktop.portal.Screenshot" = "talk";
              "org.freedesktop.Notifications" = "talk";
              "ca.desrt.dconf" = "talk"; # 设置存储
              "org.kde.StatusNotifierWatcher" = "talk"; # 注册系统托盘项
              "org.freedesktop.StatusNotifierHost" = "own"; # 作为 Host 发通知
            };

            etc.sslCertificates.enable = true; # HTTPS 网络

            gpu.enable = true;
            gpu.provider = "bundle"; # Electron GPU 加速

            bubblewrap = {
              network = true; # qq 需要联网

              env = {
                # 修复qq中文输入法
                GTK_IM_MODULE = "ibus";
                QT_IM_MODULE = "ibus";
                XMODIFIERS = "@im=ibus";

                ELECTRON_OZONE_PLATFORM_HINT = "wayland";
              };

              bind.dev = [
                "/dev/dri" # GPU 渲染
                "/dev/snd" # 音频（语音消息、视频通话）
                "/dev/shm" # 共享内存
                "/dev/video0" # 摄像头（视频通话，可选）
              ];

              bind.rw = with sloth; [
                (sloth.concat [
                  sloth.runtimeDir
                  "/"
                  (sloth.envOr "WAYLAND_DISPLAY" "no")
                ])
                (sloth.concat' sloth.runtimeDir "/at-spi/bus")
                (sloth.concat' sloth.runtimeDir "/gvfsd")
                (sloth.concat' sloth.runtimeDir "/dconf")

                (sloth.concat' sloth.xdgCacheHome "/fontconfig")
                (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache")
                (sloth.concat' sloth.xdgCacheHome "/mesa_shader_cache_db")
                (sloth.concat' sloth.xdgCacheHome "/radv_builtin_shaders")

                (sloth.env "XDG_RUNTIME_DIR")
                (sloth.mkdir "/tmp/QQ")

                (sloth.concat' sloth.runtimeDir "/doc") # 从 ro 移到 rw

                # --- 自定义持久化映射 [ "宿主机物理路径" "应用以为的沙盒路径" ] ---

                # qq配置和数据
                [
                  (sloth.mkdir (sloth.concat' sloth.homeDir "/data/Programs/Chat/qq/config"))
                  (sloth.concat' sloth.homeDir "/.config/QQ")
                ]

                # qq下载文件
                [
                  (sloth.mkdir (sloth.concat' sloth.homeDir "/data/Soft_tmp/Chat/qq/Downloads"))
                  (sloth.concat' sloth.homeDir "/Downloads")
                ]
              ];

              bind.ro = [
                # (sloth.concat' sloth.runtimeDir "/doc")
                (sloth.concat' sloth.xdgConfigHome "/kdeglobals")
                (sloth.concat' sloth.xdgConfigHome "/gtk-2.0")
                (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
                (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
                (sloth.concat' sloth.xdgConfigHome "/fontconfig")
                (sloth.concat' sloth.xdgConfigHome "/dconf")

                # Use system font settings instead
                "/etc/fonts"
                "/etc/localtime"

                # Fix: libEGL warning: egl: failed to create dri2 screen
                "/etc/egl"
                "/etc/static/egl"

                # 修复qq播放视频消息无声音
                "/etc/static/alsa"
                "/etc/alsa"

                # 修复qq文件选择器图标
                "/run/current-system/sw/share/mime"
                "/run/current-system/sw/share/icons"
                "/run/current-system/sw/share/applications"
                # 系统字体
                "/run/current-system/sw/share/fonts"
              ];

              sockets = {
                wayland = true;
                x11 = false;
                pipewire = true; # 语音/视频通话音频支持
              };
            };
          };
      };

      exePath = pkgs.lib.getExe wrapped.config.script;
    in
    {
      packages.qq = pkgs.buildEnv {
        inherit (wrapped.config.script) name meta passthru;
        paths = [
          wrapped.config.script
          (pkgs.makeDesktopItem {
            name = appId;
            desktopName = "QQ";
            genericName = "QQ";
            comment = "Tencent QQ";
            exec = "${exePath} %U";
            startupNotify = true;
            terminal = false;
            icon = "${pkgs.qq}/share/icons/hicolor/512x512/apps/qq.png";
            type = "Application";
            categories = [
              "InstantMessaging"
              "Network"
            ];
            extraConfig = {
              X-Flatpak = appId;
            };
          })
        ];
      };
    };
}
