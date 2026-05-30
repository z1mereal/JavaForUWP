# JavaForUWP
Full on Minecraft Java ported to Xbox One/Series

## How it works

1. `MC.Xbox.exe` starts as a UWP app.
2. The launcher checks for a saved Microsoft refresh token.
3. If needed, it shows a device-code sign-in screen with a QR code for `microsoft.com/link`.
4. The launcher verifies Xbox/Minecraft Services ownership and loads the Minecraft profile.
5. The signed-in menu opens with Play, Mods placeholder, Repair downloads, and Sign out.
6. Play prepares launcher-owned files in `LocalState` only when the packaged runtime has changed.
7. The app verifies all files from `download_manifest.tsv`, downloading missing or stale official Minecraft/Fabric files into `LocalState`.
8. The app publishes the live `CoreWindow` through app properties.
9. The app loads `jvm.dll` and starts Java in the same process.
10. Fabric launches Minecraft from the embedded JVM.
11. LWJGL loads the custom `glfw.dll`.
12. The GLFW shim creates an EGL surface for the UWP window.
13. Mesa translates OpenGL calls to D3D12.

The main launcher work is around Microsoft auth, ownership verification, UWP package identity, Xbox sandbox paths, packaged app file access, native library loading, GLFW behavior, input, and Fabric remapping.

## Status and limits

Known limits include:

- Xbox Developer Mode is the only supported target.
- Retail mode is not supported.
- Mods menu is currently only a placeholder.
- First launch can take a while because official game libraries and asset objects are downloaded after sign-in. Missing/stale files are downloaded with limited parallelism.
- Path handling is still the most sensitive area.
- Some Java platform diagnostics can still warn or fail because the sandbox does not look like desktop Windows.
- Controller support exists through GameInput, but game controls still need testing and tuning.
- Version bumps can break Fabric patches, the compatibility mod, or native runtime layout.

## Documentation

- [Building](docs/BUILDING.md)