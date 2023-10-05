# Starlight for Godot 4.1

[![GitHub link](https://img.shields.io/github/license/tiffany352/godot-starlight)](https://github.com/tiffany352/godot-starlight)
[![Godot asset library](https://img.shields.io/badge/godot-assets-blue)](https://godotengine.org/asset-library/asset/2221)

![Screenshot](docs/screenshot.jpg)
(Planet rendered using [Atmosphere Shader v0.4](https://godotengine.org/asset-library/asset/2002))

Starlight is a Godot addon that renders 100,000 stars in realtime, with
low performance cost. It's an alternative to using a skybox, and
also may be relevant to anyone making a space game.

Check out the demo in your web browser: https://tiffnix.com/starlight-demo/

# Features

- Stars are rendered positionally in 3D, allowing you to fly around and
  see stars go by.
- Exact position, luminosity, and temperature of each star can be
  configured by you.
- Default star generator is based on real main sequence stars (classes M through O).
- Physically based light model: Using a [Point Spread Function
  (PSF)][1], rather than a texture that grows or shrinks with
  distance/brightness.
- Based on [MultiMeshInstance3D][2] for performance.
- Works with Forward+, Mobile, and Compatibility renderers.

[1]: https://en.wikipedia.org/wiki/Point_spread_function
[2]: https://docs.godotengine.org/en/stable/classes/class_multimeshinstance3d.html

# Usage Guide

To get started, insert `Stars.tscn` into your scene. This will
automatically spawn 100,000 randomly generated stars.

On the instance itself there are some properties you can configure that
affect the star spawning. These are:

- `size`: Stars are spawned inside of a sphere of this radius.
- `star_count`: The number of stars to create.
- `rng_seed`: The random seed to use when generating stars. Incrementing
  this will give you a different sky.
- `generate_at_origin`: If checked, one extra G-type star will be
  generated exactly at `0, 0, 0`. This can be useful for representing
  the Sun in your scene.

For further customization of the star generator, I recommend editing the
script directly.

To make changes to the visual appearance you will need to edit the
Material. You can do this either by opening Stars.tscn, or by clicking
the dropdown arrow on the MultiMesh resource and click "Make unique".
You'll then need to do this again on the Mesh resource inside it. Expand
the Mesh, expand the Material, expand the Shader Parameters section.
Inside here you will find more properties to configure.

- `emission_energy` - Multiplier for how bright stars should be.
  Generally this is some extremely large number like `50000000000` -
  you'll need to add or remove zeros until it looks right.
- `camera_vertical_fov` - The vertical camera FOV. By default in Godot
  this is 70, but if you change it you may need to adjust it here. For
  example, if you're zooming in the camera, you'll need to adjust this.
- `billboard_size_deg` - This controls how much of the screen the PSF
  texture takes up, in degrees. For the default JWST PSF I recommend a
  value of around 70.
- `min_size_ratio` - There is a performance optimization where the PSF texture
  is cropped for stars that are dim. This will be 99.999% of stars.
  Generally set this to some low value like 0.005.
- `debug_show_rects` - This can be useful while tweaking the values of
  `billboard_size_deg` and `min_size_ratio`.
- `max_luminosity` - This is the point at which the cropping stops and
  the full PSF texture is used. If your PSF looks cut off, you may need
  to lower this.
- `meters_per_lightyear` - This is a scaling setting, you'll need to set
  it depending on how far away you want your stars to be.
- `distance_limit` - This acts as an upper bound on how bright stars can
  be. Once you get closer to a star than this distance, it stops getting
  any brighter. This setting can be used to prevent blowing out the PSF
  texture.
- `texture_emission` - This is the actual PSF texture. The default one
  is the PSF from the James Webb Space Telescope, because it looks cool.
  There are a few others in the `psf-textures` folder which can be used
  instead.

# Credit

Code is released under [MIT license](./LICENSE.md).

The default PSF texture, `jwst.exr`, is based on FITS data [obtained
from here][3]. Code for cropping, downscaling, and converting to OpenEXR
is located in `docs/fits2exr.py`.

The alternative PSF textures `hst.exr`, `hex_aperture.exr`, and
`airy_disk.exr` were created using [Poppy][4] based on examples in the
documentation. Code is located in `docs/poppy psfs.ipynb`.

[3]: https://www.stsci.edu/jwst/science-planning/proposal-planning-toolbox/simulated-data
[4]: https://poppy-optics.readthedocs.io/en/latest/
