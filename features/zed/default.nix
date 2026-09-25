{
  flake.nixosModules.zed =
    {
      config,
      pkgs,
      user,
      ...
    }:
    let
      configDir = "${config.my.base.repoDir}/features/zed/config";
    in
    {
      hjem.users.${user} = {
        packages = with pkgs; [
          zed-editor
        ];

        xdg.config.files."zed" = {
          type = "symlink";
          source = configDir;
        };
      };
    };
}
