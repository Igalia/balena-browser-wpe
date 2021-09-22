include recipes-core/images/core-image-minimal.bb

IMAGE_FSTYPES = "tar.gz"

IMAGE_INSTALL_append += " \
    cog \
    fontconfig \
    fontconfig-utils \
    ttf-bitstream-vera \
    tzdata tzdata-misc tzdata-posix tzdata-right tzdata-africa \
    tzdata-americas tzdata-antarctica tzdata-arctic tzdata-asia \
    tzdata-atlantic tzdata-australia tzdata-europe tzdata-pacific \
    wpebackend-fdo wpewebkit \
    "

REQUIRED_DISTRO_FEATURES = "opengl egl wayland pulseaudio"

VIRTUAL-RUNTIME_init_manager="busybox"
