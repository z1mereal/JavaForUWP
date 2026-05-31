# Patching Notes

Minecraft, Fabric, LWJGL, and Java expect desktop Windows behavior. Xbox Developer Mode UWP runs inside a packaged sandbox, so a few targeted patches are needed.

## Fabric Loader patch

`scripts\patch-fabric.ps1` compiles Java sources from `patch\` and overlays the resulting classes into the local Fabric Loader JAR:

```text
staging\cache\gameDir\libraries\net\fabricmc\fabric-loader\0.19.2\fabric-loader-0.19.2.jar
```

Patched classes:

- `LoaderUtil`
- `FileSystemUtil`
- `FileSystemReference`
- `OutputConsumerPath`
- `FabricLauncherBase`

The main goals are:

- Avoid `Path.toRealPath()` in places where the Xbox sandbox blocks or breaks the underlying Windows path query.
- Keep Fabric remapping from using file system calls that fail in packaged app paths.
- Make loader launch behavior tolerate the UWP runtime layout.

Run it directly with:

```powershell
.\scripts\patch-fabric.ps1
```

The top level build also runs it automatically.

## Compatibility mod

`compat_mod` is a Fabric client mod with mixins for Minecraft code paths that need sandbox aware behavior.

Current mixins:

- `MinecraftClientProbeMixin`
- `PathUtilBypassMixin`
- `SystemDetailsOshiBypassMixin`
- `WorldLoadProgressTrackerMixin`
- `ZipFsBypassMixin`

Build it directly with:

```powershell
.\compat_mod\build_compat_mod.ps1
```

The build copies the mod JAR into the local ignored `gameDir\mods` folder. The top level package step then places bundled mods under `runtime\bundled-mods`, and the UWP host copies them into writable `LocalState` on launch.

## GLFW shim

`glfw_shim\glfw_uwp.cpp` builds a replacement `glfw.dll` for LWJGL GLFW.

It handles:

- `CoreWindow` based window setup.
- EGL surface creation for Mesa.
- Keyboard and text input callbacks.
- Basic monitor, cursor, timing, and window API responses expected by LWJGL.
- Xbox controller state through GameInput and the GLFW joystick and gamepad APIs.

Build it directly with:

```powershell
.\glfw_shim\build_glfw.ps1
```

The top level build copies the DLL into package natives and injects it into the LWJGL GLFW native JAR inside the assembled package.

## Runtime layout

The packaged app keeps immutable runtime files under the package folder. At launch, `MC.Xbox.exe` prepares writable state in `LocalState`:

```text
LocalState\game
LocalState\assets
LocalState\natives
```

The game uses `LocalState\game` for saves, config, logs, mods, and other writable files. Bundled compatibility mods are copied there during launch.

## Version bumps

When changing Minecraft, Fabric Loader, or key libraries:

1. Update `scripts/config.ps1`, or pass build overrides while testing.
2. Update `compat_mod/src/main/resources/fabric.mod.json`.
3. Recreate `staging\cache\gameDir`.
4. Recreate `staging\cache\assets`.
5. Recreate `staging\cache\natives-1.21` if native versions changed.
6. Run the local Fabric client once so remapped jars are generated.
7. Run `.\build.ps1`.

Do not commit generated game files, downloaded assets, natives, certificates, app packages, logs, or saves.
