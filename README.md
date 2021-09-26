# balena-wpe

It provides a Web based screen display running on [WPE
WebKit](https://www.igalia.com/wpe/). Contrary to other solutions, this
project runs the browser on the top of a
[Wayland compositor](https://wayland.freedesktop.org/) (Weston).

WPE WebKit allows embedders to create simple and performant systems
based on Web platform technologies. It is a WebKit port designed
with flexibility and hardware acceleration in mind, leveraging
common 3D graphics APIs for best performance.

---

## Requirements

| Configuration      | Value
|--------------------|---------------
| Define DT overlays | `vc4-kms-v3d`

## Usage

### docker-compose file

``` yaml
version: '2'

volumes:
    pulse:                          # Required for PA over UNIX socket
    weston:

services:
  audio:
    image: balenablocks/audio
    privileged: true
    volumes:
      - 'pulse:/run/pulse'

  weston:
    restart: always
    build: igalia/balena-weston
    privileged: true
    volumes:
      - 'weston:/run/weston'

  wpe:
    restart: always
    build: ./wpe
    privileged: true
    ports:
      - 8080:8080
      - 12321:12321
    volumes:
      - 'weston:/run/weston'
      - 'pulse:/run/pulse'
```

## How to build

* Getting the sources

  ```bash
  git clone https://gitlab.com/browsers/balena-wpe.git
  repo init -u https://gitlab.com/browsers/balena-wpe.git -m manifest-hardknott.xml -b main
  repo sync --force-sync
  ```

* Generating the image root filesystem with Yocto:

  ```bash
  MACHINE=raspberrypi3
  ./build.sh
  ```

* Pushing the image to the registered Docker repository:

  ```bash
  MACHINE=raspberrypi3
  IMAGE_DOCKER_PATH=igalia
  ./push.sh
  ```

## Content Load

The URL displayed by the browser launcher can be set using the `WPE_URL`
environment variable. The default value is [wpewebkit.org](http://www.webkit.org)

| Environment variable   | Default               | Example
|------------------------|-----------------------|---------------------
| **`WPE_URL`**          | https://wpewebkit.org | https://igalia.com

### Changing content at runtime

balena-wpe ships with [tohora](https://github.com/mozz100/tohora/) so which
provides a web interface for changing target URLs at runtime on port 8080.

### Offline content

If you want your device to display content even without internet, you can add
your content in the docker image and point the browser to them. Append a
similar Dockerfile fragment to your project:

```Dockerfile
COPY public_html /var/lib/public_html

ENV WPE_URL="file:///var/lib/public_html/index.html"
```

## Settings

### RaspberryPi `config-txt` settings

A lot of the configuration of this project is about setting up `config.txt`.
The way you do this on balena is by setting some special fleet configuration
variables.

How to set the `config.txt` is pretty well documented in the RaspberryPi
official [documentation](https://www.raspberrypi.org/documentation/computers/config_txt.html).
You can overwrite these settings in the balena dashboard setting
variables in your environment using this prefix `RESIN_HOST_CONFIG_`.
[Read more](https://balena.io/docs/configuration/advanced/#modifying-config-txt-remotely).

Probably you will be interested in to set the GPU memory to a more suitable
value for hardware accelerated graphics.

| Key                                 | Value
|-------------------------------------|----------
|**`RESIN_HOST_CONFIG_gpu_mem_256`**  | `128`
|**`RESIN_HOST_CONFIG_gpu_mem_512`**  | `196`
|**`RESIN_HOST_CONFIG_gpu_mem_1024`** | `396`

### Browser settings

| Environment variable                       | Options   | Default | Description
|--------------------------------------------|-----------|---------|---------------------------------------------------
| **`WPE_COG_PLATFORM_FDO_VIEW_FULLSCREEN`** | `0`, `1`  | `1`     | Enables the fullscreen mode in the browser screen
| **`WPE_COG_PLATFORM_FDO_VIEW_HEIGHT`**     | `integer` | `720`   | Vertical resolution
| **`WPE_COG_PLATFORM_FDO_VIEW_WIDTH`**      | `integer` | `1280`  | Horizontal resolution
| **`WPE_COG_RELAUNCH`**                     | `0`, `1`  | `unset` | Enables forcing relaunch of the browser
| **`WPE_COG_RELAUNCH_DELAY`**               | `integer` | `5`     | Add delay during forced relaunch

By setting `WPE_ENABLE_INSPECTOR_SERVER` to on you can connect to the
Web browser inspector server in remote loading the following URL `inspector://<raspberrypi IP>:12321`
in an Epiphany Browser.

| Environment variable              | Options          |  Default       | Description
|-----------------------------------|------------------|----------------|---------------------------
| **`WPE_ENABLE_INSPECTOR_SERVER`** | `0`,`1`, `unset` | `unset`        | Enables the Web Inspector

Alternatively you can use
[docker-libwebkit2gtk](https://gitlab.com/saavedra.pablo/docker-libwebkit2gtk)
to use the remote Web Inspector.

``` sh
export URL="inspector://<your raspberrypi IP>:12321"
export XAUTHORITY="/run/user/1000/gdm/Xauthority"  # or "xhost +"

cd docker-libwebkit2gtk
sudo -E ./run.sh
URL: inspector://192.168.1.170:12321
Sending build context to Docker daemon  81.92kB
...
Opening URL: inspector://192.168.1.170:12321
```

### Sound settings

balena-wpe relies on balena-audio for the audio processing. Check the specific
[settings](https://github.com/balenablocks/audio#sendreceive-audio) of this
block for audio settings.

Alternatively the block can be also configured to route the audio through other
Pulser Server by setting the `PULSE_SERVER` environment variable.

| Environment variable       | Options                                               |  Default
|----------------------------|-------------------------------------------------------|-----------------
| **`WPE_PULSE_SERVER`**     | `unix:/run/pulse/pulseaudio.socket`, `tcp:audio:4317` | `unix:/run/pulse/pulseaudio.socket`

### Useful environment variables for debugging

| Environment variable         | Example        | Description
|------------------------------|----------------|----------------
| **`EGL_LOG_LEVEL`**          | `debug`        | This changes the log level of the main library and the drivers in Mesa
| **`GALLIUM_HUD`**            | `load+cpu+fps` | Activates and set the Gallium3D Heads-Up Display
| **`GST_DEBUG`**              | `*:DEBUG`      | Set the log level output in GStreamer
| **`G_MESSAGES_DEBUG`**       | `all`          | Set the log level output in GLib
| **`LIBGL_DEBUG`**            | `verbose`      | If defined Mesa LibGL debug information will be printed to stderr. If set to verbose additional information will be printed
| **`MESA_DEBUG`**             | `1`            | If set to `1` Mesa error messages are printed to stderr
| **`WAYLAND_DEBUG`**          | `1`            | Acticates the Wayland debug output

