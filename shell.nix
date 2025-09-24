let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  buildInputs = with pkgs; [
    beamPackages.elixir
    docker
    docker-buildx

    inotify-tools
    watchman
  ];
}
