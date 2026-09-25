{
  flake.nixosModules.zed =
    {
      config,
      pkgs,
      username,
      ...
    }:
    let
      configDir = "${config.users.users.${username}.home}/sheng/features/zed/config";
    in
    {
      hjem.users.${username} = {
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
