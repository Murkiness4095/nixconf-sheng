{
  flake.nixosModules.core-pkgs =
    {
      pkgs,
      username,
      ...
    }:
    {
      hjem.users.${username}.packages = with pkgs; [
        just

        fastfetch
        microfetch
        gh
        btop
        wlr-randr
        tree

        nh
        nix-output-monitor
        nvd
        nix-tree

        nil
        nixfmt
        nixpkgs-fmt

        mcp-nixos

        go-musicfox

        tmux
        yazi
      ];
    };
}
