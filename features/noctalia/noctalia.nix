{ inputs, self, ... }: {
  flake.nixosModules.noctalia =
    {
      config,
      user,
      ...
    }:
    let
      configDir = "${config.users.users.${user}.home}/dotfiles-sheng/features/noctalia/config";
    in
    {
      hjem = {
        extraModules = [
          inputs.noctalia.hjemModules.default
        ];

        users.${user} = {
          programs.noctalia = {
            enable = true;
            systemd.enable = true;
            # settings = {};
          };

          xdg.config.files."noctalia".source = configDir;
        };
      };
    };
}
