# Mesa Runtime

Bundled Mesa UWP runtime DLLs for local builds live in this folder.

Minimum files checked by the build:

- `libEGL.dll`
- `opengl32.dll`
- `libgallium_wgl.dll`

Other Mesa DLLs are copied when present:

- `libGLESv2.dll`
- `libGLESv1_CM.dll`
- `libglapi.dll`
- `spirv_to_dxil.dll`
- `vulkan_dzn.dll`
- `glu32.dll`
- `dxil.dll`
- `z-1.dll`

Use another Mesa runtime with:

```powershell
.\build.ps1 -MesaRuntimeDir "C:\path\to\mesa-runtime"
```

Or:

```powershell
$env:MESA_UWP_DIR = "C:\path\to\mesa-runtime"
```
