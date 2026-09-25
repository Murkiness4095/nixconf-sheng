{ self, ... }: {
  flake.nixosModules.fastfetch =
    {
      config,
      pkgs,
      username,
      ...
    }:
    let
      configDir = "${config.users.users.${username}.home}/sheng/features/fastfetch/config";
    in
    {
      hjem.users.${username} = {
        packages = [
          pkgs.fastfetch
        ];

        xdg.config.files."fastfetch" = {
          type = "symlink";
          source = configDir;
        };
      };
    };
}
