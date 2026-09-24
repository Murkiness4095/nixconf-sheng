{
  flake.nixosModules.power =
    { congig, pkgs, ... }:

    {
      services.upower.enable = true; # 电池与电源管理
      services.power-profiles-daemon.enable = true; # 性能模式切换

      services.tlp = {
        enable = false;
        settings = {
          CPU_SCALING_GOVERNOR_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        };
      };
    };
}
