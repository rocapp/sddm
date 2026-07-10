{
  description = "SDDM — Simple Desktop Display Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          sddm = pkgs.stdenv.mkDerivation {
            pname = "sddm";
            version = "0.19.0";

            src = self;

            nativeBuildInputs = with pkgs; [
              cmake
              kdePackages.extra-cmake-modules
              pkg-config
              qt5.wrapQtAppsHook
            ];

            buildInputs = with pkgs; [
              qt5.qtbase
              qt5.qtdeclarative
              qt5.qttools
              pam
              libxcb
              systemd
            ];

            cmakeFlags = [
              "-DBUILD_MAN_PAGES=OFF"
              "-DENABLE_JOURNALD=ON"
              "-DENABLE_PAM=ON"
              "-DUID_MIN=1000"
              "-DUID_MAX=65000"
            ];

            dontWrapQtApps = true;

            doCheck = true;
            preCheck = ''
              export QT_PLUGIN_PATH="${pkgs.qt5.qtbase}/lib/qt-5.15.19/plugins"
              export QML2_IMPORT_PATH="${pkgs.qt5.qtdeclarative}/lib/qt-5.15.19/qml"
            '';
            checkPhase = ''
              runHook preCheck
              ctest --output-on-failure
              runHook postCheck
            '';

            meta = with pkgs.lib; {
              description = "Simple Desktop Display Manager";
              homepage = "https://github.com/sddm/sddm";
              license = licenses.gpl2Plus;
              platforms = platforms.linux;
              maintainers = [ ];
            };
          };
        in
        {
          default = sddm;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.default ];

            packages = with pkgs; [
              ninja
              gdb
            ];

            QT_PLUGIN_PATH = "${pkgs.qt5.qtbase}/lib/qt-5.15.19/plugins";
            QML2_IMPORT_PATH = "${pkgs.qt5.qtdeclarative}/lib/qt-5.15.19/qml";

            shellHook = ''
              echo "SDDM dev shell — run 'nix develop' to enter"
              echo "  ./scripts/build.sh — execute script to build SDDM."
            '';
          };
        }
      );

      checks = forAllSystems (system: {
        sddm = self.packages.${system}.default;
      });
    };
}
