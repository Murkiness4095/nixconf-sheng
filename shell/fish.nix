{
  flake.nixosModules.fish =
    { pkgs, username, ... }:

    let
      fishConfig = ''
        if status is-interactive
          # 1. 去除欢迎语
          set -g fish_greeting

          # 2. 原生快速设置 Guix 路径
          fish_add_path -g -p ~/.config/guix/current/bin ~/.guix-profile/bin

          # 3. 手动定义必要的 Guix 环境变量（跳过 fenv/Bash 开销）
          set -gx GUIX_PROFILE "$HOME/.guix-profile"
          if test -f "$GUIX_PROFILE/etc/profile"
            set -gx SSL_CERT_DIR "$GUIX_PROFILE/etc/ssl/certs"
            set -gx SSL_CERT_FILE "$GUIX_PROFILE/etc/ssl/certs/ca-certificates.crt"
            set -gx GIT_SSL_CAINFO "$GUIX_PROFILE/etc/ssl/certs/ca-certificates.crt"
          end

          # 4. Starship 初始化
          if type -q starship
            starship init fish | source
          end
        end
      '';
    in
    {
      programs.fish.enable = true;
      users.users.${username}.shell = pkgs.fish;

      hjem.users.${username} = {
        packages = with pkgs; [
          fish
          fishPlugins.foreign-env
        ];

        files.".config/fish/config.fish".text = fishConfig;
      };
    };
}
