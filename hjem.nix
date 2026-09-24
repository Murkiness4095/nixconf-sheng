{ inputs, ... }: {
  flake.nixosModules.hjem = { username, ... }: {
    imports = [
      inputs.hjem.nixosModules.default
    ];

    hjem.users.${username} = {
      user = username; # this is the name of the user
      directory = "/home/${username}"; # where the user's $HOME resides
      clobberFiles = true;
    };
  };
}
