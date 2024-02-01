# nix-pokeglitzer

A flake providing the [PokeGlitzer](https://github.com/E-Sh4rk/PokeGlitzer) program in Nix.

## Updating
- Update the git revision + sha256 hash
- Re-generate the dotnet dependencies with `nix run .#fetch-deps -- deps.nix`
- Optional: Update the nixpkgs version used by the flake.
