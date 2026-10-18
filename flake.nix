{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      formatter = forAllSystems (system: pkgs.${system}.nixfmt-tree);
      packages = forAllSystems (
        system:
        let
          syspkgs = pkgs.${system};
        in
        rec {
          pokeglitzer = syspkgs.callPackage (
            {
              buildDotnetModule,
              fetchFromGitHub,
              dotnetCorePackages,
              wrapGAppsHook3,
              libX11,
              libICE,
              libSM,
              gtk3-x11,
              fontconfig,
            }:
            buildDotnetModule rec {
              pname = "PokeGlitzer";
              version = "1.3.9";
              src = fetchFromGitHub {
                owner = "E-Sh4rk";
                repo = pname;
                rev = "v${version}";
                sha256 = "sha256-M0/mEmA3+PfKZM0A2DdTbGihdrdbmatMyIZoGPWdsF0=";
              };

              projectFile = "PokeGlitzer.sln";
              buildType = "Release";
              nugetDeps = ./deps.json;
              dotnet-sdk = dotnetCorePackages.sdk_8_0;
              dotnet-runtime = dotnetCorePackages.runtime_8_0;
              nativeBuildInputs = [
                wrapGAppsHook3
              ];
              runtimeDeps = [
                libX11
                libICE
                libSM
                gtk3-x11
                fontconfig
              ];
            }
          ) { };
          default = pokeglitzer;
          fetch-deps = self.packages.${system}.pokeglitzer.passthru.fetch-deps;
        }
      );

      apps = forAllSystems (system: {
        fetch-deps = {
          type = "app";
          program = "${self.packages.${system}.fetch-deps}";

        };
      });

    };
}
