{
  flake.nixosModules.mihomo =
    {
      config,
      pkgs,
      user,
      ...
    }:
    {
      services.mihomo = {
        enable = true;
        tunMode = true;
        # webui = pkgs.metacubexd;
        webui = pkgs.zashboard;
        configFile = "${config.users.users.${user}.home}/data/Tool/proxy/mihomo/config.yaml";
      };
    };
}
