let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    beamPackages.elixir
    docker

    inotify-tools
    watchman
  ];
}
