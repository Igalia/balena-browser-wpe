include recipes-core/images/core-image-minimal.bb

IMAGE_FSTYPES = "tar.gz"

IMAGE_INSTALL_append += " \
	fontconfig \
	fontconfig-utils \
	tslib-calibrate \
	tslib-tests \
	ttf-bitstream-vera \
	tzdata tzdata-misc tzdata-posix tzdata-right tzdata-africa \
	tzdata-americas tzdata-antarctica tzdata-arctic tzdata-asia \
	tzdata-atlantic tzdata-australia tzdata-europe tzdata-pacific \
    wpewebkit wpebackend-fdo cog \
	"

REQUIRED_DISTRO_FEATURES = "opengl egl wayland"

VIRTUAL-RUNTIME_init_manager="busybox"
