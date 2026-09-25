{
  inputs,
  self,
  lib,
  ...
}:
{
  flake.nixosConfigurations.sheng = inputs.nixos-sheng.lib.aarch64-linux.mkShengSystem [
    self.nixosModules.core
    # 用户软件：core-pkgs 与 sheng-programs 合并后，只剩这一个包模块入口
    self.nixosModules.pkgs
    self.nixosModules.ssh
    self.nixosModules.user
    self.nixosModules.noctalia
    self.nixosModules.niri
    self.nixosModules.thunar

    self.nixosModules.fcitx5
    # self.nixosModules.ibus
    self.nixosModules.fuzzel
    self.nixosModules.alacritty
    self.nixosModules.kitty
    self.nixosModules.theme
    # pd-maps 已并入 nixos-sheng 平台层（hardware.nix，随下面的 input 切换生效），
    # 本地这份删掉即可：既避免重复，也因为旧实现依赖固件包里的 *.jsn.zst，
    # 而新版 sheng-firmware 里是明文 *.jsn，再留着会构建失败。
    self.nixosModules.vscode
    self.nixosModules.zed

    self.nixosModules.power

    # proxy
    self.nixosModules.mihomo

    ({ pkgs, lib, ... }: {
      # 网络与时区 (使用 mkForce 强行覆盖上游硬件库中设置的默认值)
      networking.hostName = pkgs.lib.mkForce "sheng";
      time.timeZone = pkgs.lib.mkForce "Asia/Shanghai";
      i18n.defaultLocale = pkgs.lib.mkForce "zh_CN.UTF-8";

      # 输入法改为 ibus 后，原先为 fcitx5-configtool 加的
      # qt6Packages/fcitx5-with-addons overlay 已不再需要（fzx5 整条链已移除），
      # 故删除，避免留一个无作用的 overlay。

      # Keep the public image self-contained: UI, Chinese, monospace, symbols,
      # emoji, and document fonts all have an explicit fallback.
      fonts = {
        packages = with pkgs; [
          noto-fonts
          noto-fonts-cjk-sans
          noto-fonts-cjk-serif

          source-code-pro
          hack-font
          # jetbrains-mono

          nerd-fonts.comic-shanns-mono
          lxgw-wenkai-screen # 霞鹜文楷 屏幕阅读版

          font-awesome
          material-design-icons
          nerd-fonts.jetbrains-mono
          nerd-fonts.hack
          nerd-fonts.fira-code
          nerd-fonts.symbols-only
        ];

        # 简单配置一下 fontconfig 字体顺序，以免 fallback 到不想要的字体
        fontconfig = {
          defaultFonts = {
            emoji = [ "Noto Color Emoji" ];
            monospace = [
              "LXGW WenKai Screen"
              "ComicShannsMono Nerd Font"
              "JetBrainsMono Nerd Font"
              "Font Awesome 6 Free"
              "Material Design Icons"
              "Noto Sans Mono CJK SC"
              "Sarasa Mono SC"
              "DejaVu Sans Mono"
            ];
            sansSerif = [
              "LXGW WenKai Screen"
              "ComicShannsMono Nerd Font"
              "JetBrainsMono Nerd Font"
              "Font Awesome 6 Free"
              "Material Design Icons"
              "Noto Sans CJK SC"
              "Source Han Sans SC"
              "DejaVu Sans"
            ];
            serif = [
              "Noto Serif CJK SC"
              "Source Han Serif SC"
              "DejaVu Serif"
            ];
          };
        };
      };

      # nixos-sheng v0.1.4 ships the sheng UCM package but does not link its
      # /share/alsa payload into the system profile.
      environment.pathsToLink = [ "/share/alsa" ];

      # 全局系统包 (这里只装最底层的必备工具，应用软件建议丢进 home.nix)
      environment.systemPackages = with pkgs; [
        git
        vim
        wget
        curl
        htop
        nh
        nix-output-monitor
      ];

      # Keep ADB's root shell from resolving ~ to the stale /root clone. Home
      # Manager must run as dot so its profile and generated files keep ownership.
      # environment.shellAliases = {
      #   nrs = "nixos-rebuild switch --flake /home/dot/dotfiles-sheng#sheng";
      #   nrs-niri = "nixos-rebuild switch --flake /home/dot/dotfiles-sheng#sheng-niri";
      #   hms = "${pkgs.util-linux}/bin/runuser -u dot -- ${pkgs.coreutils}/bin/env HOME=/home/dot USER=dot ${pkgs.nh}/bin/nh home switch /home/dot/dotfiles-sheng -c dot@sheng";
      # };

      # 在 sheng 上先关闭自动 GC。移动端 rootfs 一旦带 ext4 错误启动，
      # 开机补跑 GC 很容易把 /nix/store 写入压力放大成 emergency read-only。
      nix.gc.automatic = pkgs.lib.mkForce false;

      # === 彻底隐藏上游的默认配置 ===
      # 为了不破坏上游 Home Manager 的构建逻辑（它需要 /home/luser），
      # 我们强行保留它的家目录，但把它降级为系统底层账户（非普通用户），
      # 这样它就会被彻底踢出图形登录界面！
      # users.users.luser.isNormalUser = pkgs.lib.mkForce false;
      # users.users.luser.isSystemUser = true;
      # users.users.luser.group = "luser";
      # users.groups.luser = { };
      # users.users.luser.home = pkgs.lib.mkForce "/home/luser";

      # 1. 启用 fish 作为系统 shell
      programs.fish.enable = true;

      # 2. 创建你专属的 dot 账号，密码设为 1
      # users.users.fall_dust = {
      #   isNormalUser = true;
      #   description = "fall_dust";
      #   extraGroups = [
      #     "wheel"
      #     "networkmanager"
      #     "audio"
      #     "video"
      #     "input"
      #     "render"
      #   ];
      #   password = "1";
      #   shell = pkgs.fish;
      # };
      # --- 开启自定义模块 ---
      my.base.user = {
        enable = true;
        name = "fall_dust";
        hashedPassword = "$6$4W.SQiUcbZlEzn27$7mJVzEWZWtwRELuR/VBImj2hDUQTFMo3ZkMZ4yI4YQ9hlDqPXwslAASB7fmauTAfi3Cnj08Zz0N2yBlVCu9Hb0";

        extraGroups = [
          "wheel"
          "networkmanager"
          "audio"
          "video"
          "input"
          "render"
        ];

        keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpr2d4l3Qr9w0DK/jgVPBnCWfT9rPYnBNFr6Rw/86ov"
        ];

        rootKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpr2d4l3Qr9w0DK/jgVPBnCWfT9rPYnBNFr6Rw/86ov"
        ];
      };

      # === 平板触控与传感器优化 ===
      # 开启陀螺仪与重力传感器，以支持屏幕自动旋转 (GNOME, Plasma, Phosh 均可调用)
      hardware.sensor.iio.enable = true;

      # 你还可以在这里添加其他系统级的服务
      # 比如 SSH、Docker、Tailscale 等
      # services.openssh.enable = true;

      # === ZRAM 内存压缩 ===
      # 将空闲的内存进行压缩，变相增加可用内存容量（大幅缓解 8GB/12GB 设备开机内存占用压力）
      zramSwap = {
        enable = true;
        memoryPercent = pkgs.lib.mkForce 50; # 最多使用 50% 内存作为 zram (强制覆盖上游默认的 25%)
      };

      # === 分配 Swap (虚拟内存) ===
      # 为了防止跑大型重度应用（比如带一堆 Mod 的 Minecraft）时内存爆满闪退
      # 这里在系统盘分配 8GB 的动态 Swap 文件
      swapDevices = [
        {
          device = "/var/lib/swapfile";
          size = 8192; # 8192 MB = 8 GB
        }
      ];

      nix.settings = {
        trusted-users = [ "fall_dust" ];

        # substituters = [
        #   "https://nixos-sheng.cachix.org"
        # ];

        # trusted-public-keys = [
        #   "nixos-sheng.cachix.org-1:+YoR5YC34UBI/uTCq9XRSMyQa0vAD2IarGtvwKKgv1Q="
        # ];
      };
    })
  ];

}
