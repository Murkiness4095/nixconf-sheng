{ inputs, self, ... }: {
  flake.nixosModules.noctalia =
    {
      config,
      username,
      ...
    }:
    let
      configDir = "${config.users.users.${username}.home}/sheng/features/noctalia/config";
    in
    {
      hjem = {
        extraModules = [
          inputs.noctalia.hjemModules.default
        ];

        users.${username} = {
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
