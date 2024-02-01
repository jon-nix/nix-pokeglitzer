{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };


  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
      pkgs = forAllSystems (system: nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (system: 
      let
        syspkgs = pkgs.${system};
      in
      rec {
        pokeglitzer = syspkgs.callPackage ({
          buildDotnetModule,
          fetchFromGitHub,
          dotnetCorePackages,

          libX11,
          libICE,
          libSM,
          gtk3-x11,
          fontconfig,
        }:
        buildDotnetModule rec {
          pname = "pokeglitzer";
          version = "1.3.2";
          src = fetchFromGitHub {
            owner = "E-Sh4rk";
            repo = "PokeGlitzer";
            rev = "v${version}";
            sha256 = "sha256-FT5AJvTcmefYfBVGOoHYIaG+T0yyBYAvIn0q8AlP29s=";
          };

          projectFile = "PokeGlitzer.sln";
          buildType = "Release";
          nugetDeps = ./deps.nix;
          dotnet-sdk = dotnetCorePackages.sdk_8_0;
          dotnet-runtime = dotnetCorePackages.runtime_8_0;
          runtimeDeps = [
            libX11
            libICE
            libSM
            gtk3-x11
            fontconfig
          ];
        }) {};
        default = pokeglitzer;
        fetch-deps = self.packages.${system}.pokeglitzer.passthru.fetch-deps;
      });

      apps = forAllSystems (system: {
        fetch-deps = {
          type = "app";
          program = "${self.packages.${system}.fetch-deps}";

        };
      });

    };
}
