{
  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"

      "https://noctalia.cachix.org"

      "https://nixos-sheng.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

      "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="

      "nixos-sheng.cachix.org-1:+YoR5YC34UBI/uTCq9XRSMyQa0vAD2IarGtvwKKgv1Q="
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";

    # impermanence.url = "github:nix-community/impermanence";
    # persist-retro.url = "github:Geometer1729/persist-retro";
    # disko = {
    #   url = "github:nix-community/disko/latest";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };

    hjem = {
      url = "github:feel-co/hjem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    # nix-darwin = {
    #   url = "github:nix-darwin/nix-darwin";
    #   inputs.nixpkgs.follows = "nixpkgs-darwin";
    # };
    # 上游还没包含 pd-mapper 的固件可见性修复（firmware 被 nixpkgs 压缩成
    # .jsn.zst 后，pd-mapper 枚举不到服务映射，每 5 秒重启并连带打断键盘认证）。
    # 切到本项目仓库的分支：该修复与其它设备侧改动都在那里。
    nixos-sheng = {
      # url = "github:DotRedstone/nixos-sheng?dir=nixos";
      url = "github:Murkiness4095/nixos-sheng?dir=nixos&ref=feat/niri-noctalia-image";
    };

    wrapper-modules.url = "github:nix-community/nix-wrapper-modules";
    nixpak = {
      url = "github:nixpak/nixpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia/cachix";
    };
    # umbriel.url = "git+https://github.com/noctalia-dev/umbriel";
    # codex-desktop-linux.url = "github:ilysenko/codex-desktop-linux";
    # omp.url = "github:can1357/oh-my-pi";
    # daeuniverse.url = "github:daeuniverse/flake.nix";
    # helium-flake = {
    #   url = "github:oxcl/nix-flake-helium-browser";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    # nix-gaming.url = "github:fufexan/nix-gaming";
  };

  # Import all .nix files from current directory except flake.nix recursively
  outputs =
    inputs:
    let
      inherit (inputs.nixpkgs) lib;
      inherit (lib.fileset) toList fileFilter;

      isNixModule = file: file.hasExt "nix" && file.name != "flake.nix" && !lib.hasPrefix "_" file.name;

      importTree = path: toList (fileFilter isNixModule path);

      mkFlake = inputs.flake-parts.lib.mkFlake { inherit inputs; };
    in
    mkFlake { imports = importTree ./.; };
}
