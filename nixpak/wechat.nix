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

      appId = "com.tencent.WeChat";

      wrapped = mkNixPak {
        config =
          { sloth, ... }:
          {
            # 使用 nixpkgs 自带的 wechat（稳定、已缓存）
            app.package = pkgs.wechat;
            app.binPath = "bin/wechat"; # 官方包的实际可执行路径

            # Flatpak-like ID，用于桌面集成
            flatpak.appId = appId;

            dbus.enable = true;
            dbus.policies = {
              "org.freedesktop.portal.*" = "talk"; # 文件选择、截屏等
              "org.freedesktop.Notifications" = "talk";
              "ca.desrt.dconf" = "talk"; # 设置存储
              "org.kde.StatusNotifierWatcher" = "talk"; # 注册系统托盘项
              "org.kde.*" = "own"; # 修复托盘图标
              "org.freedesktop.StatusNotifierHost" = "own"; # 作为 Host 发通知
            };

            etc.sslCertificates.enable = true; # 网络 HTTPS

            gpu.enable = true;
            gpu.provider = "bundle"; # Electron GPU 加速

            bubblewrap = {
              network = true;

              env = {
                # 修复wechat中文输入法
                GTK_IM_MODULE = "ibus";
                QT_IM_MODULE = "ibus";
                XMODIFIERS = "@im=ibus";

                ELECTRON_OZONE_PLATFORM_HINT = "wayland";
                NIXOS_XDG_OPEN_USE_PORTAL = "1"; # 让wechat用系统默认浏览器打开链接
                GTK_USE_PORTAL = "1"; # 防止文件选择器沙箱逃逸
              };

              bind.dev = [
                "/dev/dri" # GPU
                "/dev/snd" # 音频（语音通话）
                "/dev/shm" # 共享内存
                "/dev/video0" # 摄像头（视频通话，可选删掉如果不用）
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
                (sloth.mkdir "/tmp/wechat")

                # --- 自定义持久化映射 [ "宿主机物理路径" "应用以为的沙盒路径" ] ---

                # 微信配置和数据
                [
                  (sloth.mkdir (sloth.concat' sloth.homeDir "/data/Programs/Chat/wechat/xwechat"))
                  (sloth.concat' sloth.homeDir "/.xwechat")
                ]

                # 微信下载文件
                # 首次使用需在微信 设置→通用→存储位置 手动选择沙盒内的 /Downloads 目录
                [
                  (sloth.mkdir (sloth.concat' sloth.homeDir "/data/Soft_tmp/Chat/wechat/Downloads"))
                  (sloth.concat' sloth.homeDir "/Downloads")
                ]
              ];

              bind.ro = [
                # hyprland兼容，待测
                # Manually bind X11 socket to avoid nixpak's XAUTHORITY panic
                "/tmp/.X11-unix"

                (sloth.concat' sloth.runtimeDir "/doc")
                (sloth.concat' sloth.xdgConfigHome "/kdeglobals")
                (sloth.concat' sloth.xdgConfigHome "/gtk-2-0")
                (sloth.concat' sloth.xdgConfigHome "/gtk-3.0")
                (sloth.concat' sloth.xdgConfigHome "/gtk-4.0")
                (sloth.concat' sloth.xdgConfigHome "/fontconfig")
                (sloth.concat' sloth.xdgConfigHome "/dconf")

                # (sloth.concat' sloth.homeDir "/Downloads")

                # Use system font settings instead
                "/etc/fonts"
                "/etc/localtime"

                # Fix: libEGL warning: egl: failed to create dri2 screen
                "/etc/egl"
                "/etc/static/egl"

                # 提供硬件信息和用户身份映射（防止沙箱内崩溃）
                # "/sys"
                "/sys/dev"
                "/sys/devices"
                "/etc/passwd"
                "/etc/group"
                "/etc/machine-id"
              ];

              sockets = {
                wayland = true;
                x11 = false;
                pipewire = true;
              };
            };
          };
      };

      exePath = pkgs.lib.getExe wrapped.config.script;
    in
    {
      packages.wechat = pkgs.buildEnv {
        inherit (wrapped.config.script) name meta passthru;
        paths = [
          wrapped.config.script
          (pkgs.makeDesktopItem {
            name = appId;
            desktopName = "WeChat";
            genericName = "WeChat";
            comment = "Tencent WeChat";
            exec = "${exePath} %U";
            startupNotify = true;
            terminal = false;
            icon = "${pkgs.wechat}/share/icons/hicolor/256x256/apps/wechat.png";
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
