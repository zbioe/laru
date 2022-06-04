{
  inputs = rec {
    nixpkgs.url = "github:nixos/nixpkgs/d06103277";
    utils.url = "github:numtide/flake-utils";
    mozillapkgs = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
    naersk = {
      url = "github:nix-community/naersk";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, utils, naersk, mozillapkgs }:
    utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs { inherit system; };
      naersk-lib = naersk.lib."${system}".override {
        cargo = rust;
        rustc = rust;
      };
      mozilla = pkgs.callPackage (mozillapkgs + "/package-set.nix") {};
      rchannel = (mozilla.rustChannelOf {
        date = "2022-05-19";
        channel = "stable";
        sha256 = "oro0HsosbLRAuZx68xd0zfgPl6efNj2AQruKRq3KA2g=";
      });
      rust = rchannel.rust;
      rust-src = rchannel.rust-src;
    in rec {
      # `nix build`
      packages.laru = naersk-lib.buildPackage {
        meta = with pkgs.lib; {
          description = "Bot who interact with Twitter in Selenium";
          homepage = "https://github.com/zbioe/laru";
          license = licenses.wtfpl;
          maintainers = with maintainers; [ zbioe ];
          platforms = with platforms; all;
        };
        cargoBuildOptions = opts: [ "-p 'laru'" ] ++ opts;
        cargoTestOptions = opts: [ "-p 'laru'" ] ++ opts;
        cargoDocOptions = opts: [ "-p 'laru'" ] ++ opts;
        version = "0.0.1";
        name = "laru";
        root = ./.;
        src = ./.;
      };
      defaultPackage = packages.laru;

      # `nix run`
      apps.laru = utils.lib.mkApp {
        drv = packages.laru;
      };
      defaultApp = apps.laru;

      # `nix develop`
      devShell = pkgs.mkShell {
        nativeBuildInputs = with pkgs; [
          rust
          rust-src
          rust-analyzer
          rustracer
        ];
        buildInputs = with pkgs; [
          arion
          docker-compose
          docker
          pkg-config
          openssl
        ];
        shellHook = ''
          export RUST_BIN="${rust.outPath}/bin"
          export RUST_SRC_PATH="${rust-src.outPath}/lib/rustlib/src/rust/library/"
        '';
      };
    });
}
