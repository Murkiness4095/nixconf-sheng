{ self, ... }: {
  flake.nixosModules.fastfetch =
    {
      config,
      pkgs,
      user,
      ...
    }:
    let
      configDir = "${config.my.base.repoDir}/features/fastfetch/config";
    in
    {
      hjem.users.${user} = {
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
