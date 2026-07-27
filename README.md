# kas Sulka

Sulka is a Yocto Linux distribution that focuses on security hardening.
This repository is the top level of the project: it holds the kas configuration that pulls the Sulka meta-layers and their dependencies together into a buildable image.

## Features

- 🚧 Check and block dangerous features like `DEBUG_TWEAKS`
- 🚒 `nftables` firewall and configuration templates
- 🔑 Disabled root-login and added service user with sudo configuration template
- ❓ Enforce secure passwords
- 🔎 Mandatory access control with SELinux
- 🛡️ Hardened kernel configuration and runtime `sysctl` settings
- ✍️ Kernel module signing, with unsigned modules refused
- 🔒 Read-only root file system
- ⛔ Locked-down U-Boot console with command allowlisting
- 📋 Audit logging and a software bill of materials for every image
- 🐢 Applied hardening information from [Lynis](https://cisofy.com/lynis/) and [OpenSCAP](https://www.open-scap.org/)

## Motivation

The default reference distribution of Yocto, Poky, is a general-purpose distribution that is suitable for getting started with Yocto. However, as it is meant mostly to be a reference, it has to make some compromises on security.

Sulka does not have to make such compromises, and it can focus on security. The goal is to make a distro that is as hardened as possible, and then the end user can make a conscious decision to lower hardening if so required.

For example, by default the distribution contains a firewall that drops everything, even outgoing traffic. The end user then has to make the decision on how to configure the firewall if they want to enable networking.

This makes the distribution require some setup before being actually usable, unlike the default reference Poky that can be used out-of-the-box. However, in the long run this makes it easier to ship secure devices when the distro is hardened by default.

## Building

kas is a tool for configuring and managing BitBake projects. It allows simple one-command builds with different configurations, meta-layer combinations, etc. kas documentation can be found [from here.](https://kas.readthedocs.io/en/latest/index.html)

The steps below are the shortest path to a working image. The [quick start guide](https://altidsec.com/sulka/documentation/quick-start.html) walks through the same procedure in more detail and covers the optional configuration you will probably want.

### 1. Install kas

The kas project recommends installing with `pipx`:

```
pipx install kas
```

See the [kas installation instructions](https://kas.readthedocs.io/en/latest/userguide/getting-started.html#installation) for the other options.

### 2. Clone this repository

```
git clone https://codeberg.org/AltidSec/kas-sulka.git
cd kas-sulka
```

### 3. Set a password for the service user

Root login is disabled, so without a service user password there is no way to log in to the resulting image. Generate a hash and escape the dollar signs for BitBake:

```
mkpasswd -m yescrypt -s -R 8 <YOUR_PASSWORD> | sed 's/\$/\\$/g'
```

Assign the result to `SULKA_SERVICEUSER_PASSWORD` in `kas-sulka-configuration.yml`.

### 4. Generate the module signing keys

Module signing is enabled by default and **the build will fail without keys**. The key generation script uses scripts from `meta-security`, so the layers have to be checked out first:

```
kas checkout kas-sulka.yml
./scripts/generate_ima_evm_modsign_keys.sh
```

Then point the build at the generated keys by adding the following to `kas-sulka-configuration.yml`:

```
MODSIGN_KEY_DIR = "/path/to/generated/keys"
IMA_EVM_ROOT_CA = "${MODSIGN_KEY_DIR}/ima-local-ca.pem"
```

Module signing can be turned off instead, but that is not recommended. See [module signing](https://altidsec.com/sulka/documentation/user-guide.html#module-signing) in the user guide.

### 5. Build

```
kas build kas-sulka.yml
```

The default configuration builds `core-image-base` for `qemux86-64`. For advanced use, `kas shell` drops you into the build environment:

```
kas shell kas-sulka.yml -c 'bitbake -e core-image-base'
```

## Repository Layout

| Path | Purpose |
|---|---|
| `kas-sulka.yml` | Top-level configuration. Sets the machine, distro and target image, and includes the two files below. |
| `kas-layers.yml` | The layer repositories and the revisions they are pinned to. |
| `kas-sulka-configuration.yml` | Build configuration, written into `local.conf`. **This is the file you can edit** to configure Sulka. |
| `extra_fragments/` | Optional configurations that can be appended to a build command. See below. |
| `scripts/` | Helper scripts for generating the module signing keys and, if you install SSH keys at build time, an SSH key pair. |

To build for other hardware, add your own configuration file to the list rather than editing these, for example `kas build kas-sulka.yml:my-board.yml`. See the [Raspberry Pi reference project](https://codeberg.org/AltidSec/kas-sulka-raspberrypi-example) for an example.

## Optional Configuration Fragments

`extra_fragments/` holds configurations that can be appended to the build command as needed:

| Fragment | Effect |
|---|---|
| `audit.yml` | Installs Lynis, OpenSCAP, the SCAP Security Guide and kernel-hardening-checker so the running image can be audited. |
| `development.yml` | Turns on Sulka development mode, installs the OpenSSH server, loosens the firewall to allow SSH and ICMP, and adds the SELinux tooling. Convenient during development, not for production images. |
| `kas-layers-development.yml` | Follows the development branches of the Sulka layers instead of the pinned release tags. |

For example, to build a development image that can be audited:

```
kas build kas-sulka.yml:extra_fragments/development.yml:extra_fragments/audit.yml
```

## Meta-Layers

The Sulka metadata is split across three layers, each with its own repository and README:

- [meta-sulka-distro](https://codeberg.org/AltidSec/meta-sulka-distro) — the distro definition and the userspace hardening.
- [meta-sulka-kernel](https://codeberg.org/AltidSec/meta-sulka-kernel) — the kernel hardening metadata and runtime `sysctl` settings.
- [meta-sulka-bsp](https://codeberg.org/AltidSec/meta-sulka-bsp) — the hardened bootloader metadata.

The revisions these are pinned to are in `kas-layers.yml`.

## Documentation

To get started with Sulka, you can read [the quick start guide online](https://altidsec.com/sulka/documentation/quick-start.html).
More information about Sulka can be found in [the user guide](https://altidsec.com/sulka/documentation/user-guide.html), including the full list of [configuration variables](https://altidsec.com/sulka/documentation/user-guide.html#configuration-variables).

If the website is unavailable, the same content can be read from [the documentation repository](https://codeberg.org/AltidSec/sulka-docs/src/branch/main/source).

## Contributing

Send pull requests, patches, comments or questions to the AltidSec repositories in Codeberg, and feel free to open issues to start discussions. Use `*-next` branches as pull request targets.

Maintainer:
Esa Jääskelä <esa.jaaskela@suomi24.fi>

## License

The configuration in this repository is licensed under the MIT license. See [COPYING.MIT](COPYING.MIT) for the full text.
The meta-layers and the upstream components fetched during a build carry their own licenses.
