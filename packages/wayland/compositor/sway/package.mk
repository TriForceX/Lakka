# SPDX-License-Identifier: GPL-2.0
# Copyright (C) 2021-present Team LibreELEC (https://libreelec.tv)

PKG_NAME="sway"
PKG_VERSION="1.9"
PKG_SHA256="b6e4e8d74af744278201792bcc4447470fcb91e15bbda475c647d475bf8e7b0b"
PKG_LICENSE="MIT"
PKG_SITE="https://swaywm.org/"
PKG_URL="https://github.com/swaywm/sway/archive/${PKG_VERSION}.tar.gz"
PKG_DEPENDS_TARGET="toolchain wayland wayland-protocols libdrm libxkbcommon libinput cairo pango libjpeg-turbo dbus json-c wlroots gdk-pixbuf swaybg foot bemenu"
PKG_LONGDESC="i3-compatible Wayland compositor"

PKG_MESON_OPTS_TARGET="-Ddefault-wallpaper=false \
                       -Dzsh-completions=false \
                       -Dbash-completions=false \
                       -Dfish-completions=false \
                       -Dswaybar=true \
                       -Dswaynag=true \
                       -Dxwayland=disabled \
                       -Dtray=disabled \
                       -Dgdk-pixbuf=enabled \
                       -Dman-pages=disabled \
                       -Dsd-bus-provider=auto"

pre_configure_target() {
  # sway does not build without -Wno flags as all warnings being treated as errors
  export TARGET_CFLAGS=$(echo "${TARGET_CFLAGS} -Wno-unused-variable")
}

post_makeinstall_target() {
  mkdir -p ${INSTALL}/usr/lib/sway
    cp ${PKG_DIR}/scripts/sway.sh     ${INSTALL}/usr/bin
    cp ${PKG_DIR}/scripts/sway-config ${INSTALL}/usr/lib/sway

  # install config & wallpaper
  mkdir -p ${INSTALL}/usr/share/sway
    cp ${PKG_DIR}/config/* ${INSTALL}/usr/share/sway
    find_file_path "splash/splash-2160.png" && cp ${FOUND_PATH} ${INSTALL}/usr/share/sway/libreelec-wallpaper-2160.png

  # clean up
  safe_remove ${INSTALL}/etc
  safe_remove ${INSTALL}/usr/share/wayland-sessions
}

post_install() {
  if [ "${DISTRO}" = "Lakka" ]; then
    sed -i ${INSTALL}/usr/lib/systemd/system/sway.service \
        -e "s|kodi\.service|retroarch.service|g"
  fi
  enable_service sway.service
}
