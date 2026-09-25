# base 模块的一部分：账号身份（用户名、密码哈希、SSH 公钥与附加组）。
{
  flake.nixosModules.base =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    let
      cfg = config.my.base.user;
    in
    {
      options.my.base.user = {
        enable = lib.mkEnableOption "primary user configuration";

        name = lib.mkOption {
          type = lib.types.str;
          default = "fall_dust";
          description = "Primary user name for this host";
        };

        hashedPassword = lib.mkOption {
          type = lib.types.str;
          default = "$6$4W.SQiUcbZlEzn27$7mJVzEWZWtwRELuR/VBImj2hDUQTFMo3ZkMZ4yI4YQ9hlDqPXwslAASB7fmauTAfi3Cnj08Zz0N2yBlVCu9Hb0";
        };

        extraGroups = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "wheel"
            "networkmanager"
            "input"
            "podman"
            "libvirtd"
            "kvm"
          ];
        };

        keys = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpr2d4l3Qr9w0DK/jgVPBnCWfT9rPYnBNFr6Rw/86ov"
          ];
        };

        rootKeys = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHpr2d4l3Qr9w0DK/jgVPBnCWfT9rPYnBNFr6Rw/86ov"
          ];
        };
      };

      options.my.base.repoDir = lib.mkOption {
        type = lib.types.str;
        default = "${config.users.users.${cfg.name}.home}/dotfiles-sheng";
        description = ''
          本仓库在设备上的检出目录。各模块的 configDir 软链基于它拼接
          （如 <repoDir>/features/niri/config），仓库改名或换检出位置时
          只改这一处默认值。
        '';
      };

      config = lib.mkMerge [
        {
          # 核心逻辑：把账号名导出为 _module.args.user，供 hjem 等功能模块直接引用
          _module.args.user = cfg.name;
        }
        (lib.mkIf cfg.enable {
          users.mutableUsers = false;
          security.sudo.wheelNeedsPassword = false;

          users.users.${cfg.name} = {
            isNormalUser = true;
            hashedPassword = cfg.hashedPassword;
            extraGroups = cfg.extraGroups;
            openssh.authorizedKeys.keys = cfg.keys;
          };

          users.users.root = {
            openssh.authorizedKeys.keys = cfg.rootKeys;
          };
        })
      ];
    };
}
