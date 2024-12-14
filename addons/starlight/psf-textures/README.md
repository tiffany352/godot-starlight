= PSF Textures

When you set one of these as the PSF texture in the shader, you should
also set the `texture_emission_tint` value in the shader parameters to
the corresponding value for each texture:

| filename           | value                 |
| ------------------ | --------------------- |
| `airy_disk.png`    | `0.127, 0.129, 0.133` |
| `hex_aperture.png` | `0.124, 0.126, 0.130` |
| `hst.png`          | `0.521, 0.515, 0.504` |
| `jwst.png`         | `0.252, 0.157, 0.292` |
