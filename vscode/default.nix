{ inputs, ... }:
{
  flake.nixosModules.vscode =
    {
      config,
      pkgs,
      username,
      ...
    }:

    {
      hjem.users.${username} = {
        # 软链接到 Nix store 中的配置
        xdg.config.files = {
          "Code/User".source = ./config;
          # "Code/User/snippets/nix.code-snippets".source = "${configPath}/snippets/nix.code-snippets";
        };

        files = {
          ".vscode/argv.json".source = ./config/argv.json;
        };
      };
    };
}
