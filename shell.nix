{
  pkgs ? import ./nix/pkgs.nix
}:

let
  qtCustom = (with pkgs.qt515_8;
    # TODO:check the required modules
    env "qt-custom-${qtbase.version}" ([
      qtbase
      qtdeclarative
      qtquickcontrols
      qtquickcontrols2
      qtsvg
      qtmultimedia
      qtwebview
      qttools
      qtwebchannel
      qtgraphicaleffects
      qtwebengine
      qtlocation
  ]));

in pkgs.mkShell {
  name = "status-desktop-build-shell";

  # TODO:check the required packages
  buildInputs = with pkgs; [
    linuxdeployqt
    libglvnd # TODO: Qt 5.15.2 fix, review after upgrade
    curl wget git file unzip jq lsb-release
    cmake_3_19 gnumake pkg-config gnugrep qtCustom
    pcre nss pcsclite extra-cmake-modules
    xorg.libxcb xorg.libX11 libxkbcommon
    which go_1_20 cacert
    appimagekit gnupg
  ] ++ (with gst_all_1; [
    gst-libav gstreamer
    gst-plugins-bad  gst-plugins-base
    gst-plugins-good gst-plugins-ugly
  ]);

  # Avoid terminal issues.
  TERM = "xterm";
  LANG = "en_US.UTF-8";
  LANGUAGE = "en_US.UTF-8";

  QTDIR = qtCustom;
  # TODO: still needed?
  # https://github.com/NixOS/nixpkgs/pull/109649
  QT_INSTALL_PLUGINS = "${qtCustom}/${pkgs.qt515.qtbase.qtPluginPrefix}";

  shellHook = ''
    export PATH="${pkgs.lddWrapped}/bin:$PATH"
  '';

  LIBKRB5_PATH = pkgs.libkrb5;
  QTWEBENGINE_PATH = pkgs.qt515.qtwebengine.out;
  GSTREAMER_PATH = pkgs.gst_all_1.gstreamer;
  NSS_PATH = pkgs.nss;
  #QT_INSTALL_LIBEXECS = "${pkgs.qt515.qtwebengine.out}/libexec";
  #QT_INSTALL_DATA = "${pkgs.qt515.qtwebengine.out}/libexec";
  #QT_INSTALL_TRANSLATIONS = "${pkgs.qt515.qtwebengine.out}/translations";

  # Used for linuxdeployqt
  # TODO:check which deps are needed
  LD_LIBRARY_PATH = with pkgs; lib.makeLibraryPath (
  [
    alsaLib
    expat
    fontconfig
    freetype
    gcc-unwrapped
    glib
    gmp
    harfbuzz
    libglvnd
    libkrb5
    libpng
    libpulseaudio
    libxkbcommon
    p11-kit
    zlib
  ] ++ (with xorg; [
    libICE
    libSM
    libX11
    libXrender
    libxcb
    xcbutil
    xcbutilimage
    xcbutilkeysyms
    xcbutilrenderutil
    xcbutilwm
  ]) ++ (with gst_all_1; [
    gst-plugins-base
    gst-plugins-good
    gst-plugins-bad
    gst-plugins-ugly
    gstreamer
  ]));
}
