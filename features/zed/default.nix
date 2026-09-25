{
  flake.nixosModules.zed =
    {
      config,
      pkgs,
      user,
      ...
    }:
    let
      configDir = "${config.users.users.${user}.home}/sheng/features/zed/config";
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
