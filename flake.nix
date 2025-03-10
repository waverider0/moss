{
    description = "moss";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
        flake-utils.url = "github:numtide/flake-utils";
    };

    outputs = { self, nixpkgs, flake-utils }:
        flake-utils.lib.eachDefaultSystem (system:
            let
                pkgs = import nixpkgs {
                    inherit system;
                    config.allowUnfree = true;
                };
            in
            {
                devShell = pkgs.mkShell {
                    buildInputs = with pkgs;
                    [
                        docker # `dockerd` to start daemon
                        nodejs_23
                        supabase-cli
                    ];
                };
            }
        );
}

