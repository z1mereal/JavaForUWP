# Legal Notes

This repository contains source code and build scripts for the UWP host, GLFW shim, compatibility mod, Fabric Loader patches, and related project tooling.

It does not grant rights to redistribute Minecraft, Mojang assets, Fabric, LWJGL, Java, Xbox platform files, or any other third party component.

The Mesa UWP runtime DLLs in `mesa-runtime/` remain under their own upstream license terms.

## Repository license

Original project code is covered by the custom license in `LICENSE`.

In short:

- Private forks are allowed for personal, educational, research, or internal use.
- Public content based on the project must include credit and a visible link back to veroxsity / BanditVault.
- Redistribution requires prior written permission from veroxsity / BanditVault.
- Third party components keep their own licenses and terms.

## Local files

The build creates or uses local files that should stay out of git:

- Minecraft game files.
- Mojang asset indexes and asset objects.
- Downloaded libraries.
- Fabric installer JAR.
- Java runtime images.
- Native DLLs.
- Mesa runtime DLLs from local test folders outside `mesa-runtime/`.
- Signed `.appx` packages.
- Development signing certificates.
- Saves, logs, config files, and local debug output.

These files are ignored under `staging` or `output`.
