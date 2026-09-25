{
  flake.nixosModules.mihomo =
    {
      config,
      pkgs,
      username,
      ...
    }:
    {
      services.mihomo = {
        enable = true;
        tunMode = true;
        # webui = pkgs.metacubexd;
        webui = pkgs.zashboard;
        configFile = "${config.users.users.${username}.home}/data/Tool/proxy/mihomo/config.yaml";
      };
    };
}
