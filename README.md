# kas Sulka

This repository contains kas configuration for building Sulka, a secure Yocto Linux distribution. You can find the [Sulka meta-layer from here](https://codeberg.org/AltidSec/meta-sulka-distro).

kas is a tool for configuring and managing Bitbake projects. It allows simple one-command builds with different configurations, meta-layer combinations, etc. kas documentation can be found [from here.](https://kas.readthedocs.io/en/latest/index.html)

To build Sulka using kas, do the following:

1. Install kas:
    ```
    git clone https://github.com/siemens/kas
    cd kas
    python3 -m venv kas-venv
    source kas-venv/bin/activate
    pip3 install .
    ```

1. Clone this repository:
    ```
    cd ..
    git clone https://codeberg.org/AltidSec/kas-sulka.git
    cd kas-sulka
    ```

1. Build Sulka:
    ```
    kas build kas-sulka.yml
    ```

1. For advanced use, you may want to check out `kas shell` command:
    ```
    kas shell kas-sulka.yml -c 'bitbake -e core-image-base'
    ```
