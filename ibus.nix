{
  flake.nixosModules.ibus =
    { config, pkgs, ... }:
    {
      i18n.inputMethod = {
        enable = true;
        type = "ibus";

        # 引擎全部命中 aarch64 二进制缓存（ibus / ibus-libpinyin / ibus-rime /
        # ibus-table 都查过 cache.nixos.org）。
        # ibus-with-plugins 只是 buildEnv [ ibus ] ++ plugins，不会像
        # fcitx5-with-addons 那样强制带 Qt GUI 配置工具 —— 后者才是
        # pyside6 → qtwebengine/qt3d 那一整棵未缓存 Qt6 树的来源。
        ibus.engines = with pkgs.ibus-engines; [
          rime
          libpinyin
          table
        ];

        # waylandFrontend 在 niri（wlroots）上表现通常不如默认值：
        # 保持默认时模块会设置 GTK_IM_MODULE/QT_IM_MODULE=ibus 与
        # XMODIFIERS=@im=ibus，覆盖各 toolkit 的输入法插件路径。
      };

      # 显式把 ibus 本体（含引擎软链）放进系统闭包，rootfs 里直接可用：
      # ibus-daemon / ibus engine / ibus list-engine / ibus-setup。
      environment.systemPackages = [ config.i18n.inputMethod.package ];

      # ibus 需要 dconf（nixpkgs 的 ibus 模块会自动打开 programs.dconf.enable）。
    };
}
