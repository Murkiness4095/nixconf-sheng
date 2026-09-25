{ self, ... }: {
  flake.nixosModules.pkgs =
    {
      pkgs,
      username,
      ...
    }:
    let
      selfpkgs = self.packages."${pkgs.stdenv.hostPlatform.system}";
    in
    {
      # 设备侧用户软件集合：原来分成 core-pkgs（pkgs.nix）与 sheng-pkgs
      # （sheng-programs.nix）两个模块，现在合并为一份列表，只被
      # configuration.nix 引用一次。
      hjem.users.${username}.packages = with pkgs; [
        # ── 基础工具 ──
        just

        fastfetch
        microfetch
        gh
        btop
        wlr-randr
        tree

        # nix 工具链
        nh
        nix-output-monitor
        nvd
        nix-tree

        nil
        nixfmt
        nixpkgs-fmt

        tmux
        yazi
        go-musicfox

        # ── 浏览器 ──
        selfpkgs.librewolf

        # 名字里带 "-" 与能否 rebuild 无关：brave-origin 在 aarch64-linux 上有包、
        # 未标记 broken，求值后就是 /nix/store/…-brave-origin-1.95.104。
        # 平板真正卡住的是网络：设备侧 nixos-rebuild 只能 substitute 已有缓存
        # （或已在设备 store 里的包）；没缓存就得在设备上现场构建，而它依赖的
        # arm64 .deb 托管在 github.com——平板 HTTPS 访问 github.com 直接超时
        # （ping 通、cache.nixos.org 正常），于是 rebuild 在下载阶段就被打断。
        # brave 之所以一直能用，是因为它随 niri rootfs 烧进设备、早就在 store 里。
        # 当前 lock 下 brave-origin 的 aarch64 产物及其 .deb 都已在 cache.nixos.org，
        # 设备端只用 substitute、不会再碰 github.com。
        brave-origin
        brave
        # firefox: 会拉入 ffmpeg-7.1.4，而该版本所有输出都不在 cache.nixos.org，
        # 每次重建都要现场编译一整套 ffmpeg（数十分钟）。需要浏览器时用 brave。
        # firefox

        # ── 聊天 ──
        telegram-desktop
        selfpkgs.qq
        selfpkgs.wechat

        # ── 媒体 ──
        kazumi
        celluloid # video
        imv # image
        ffmpegthumbnailer
        poppler
        libopenraw
        libgsf

        # ── 工具 ──
        localsend

        # 剪贴板
        wl-clipboard
        cliphist

        # 截图
        grim
        slurp
        satty # 截图编辑标注

        file-roller # 解压工具

        bazaar # flatpak的图形化管理工具
        warehouse

        nwg-look # 设置gtk主题

        # Vibe Coding
        mcp-nixos
      ];
    };

}
