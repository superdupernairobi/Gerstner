![Gerstner logo](assets/logo.png)
<!--moonwave-hide-before-this-line-->
# Gerstner

Pure Gerstner wave displacement for Roblox. One module and no Instances, no states. It takes wave definitions and returns surface positions.

## Install

Wally:

```toml
[dependencies]
Gerstner = "superdupernairobi/gerstner@0.1.0"
```

## Quickstart

```lua
local gerstner = require(game.ReplicatedStorage.gerstner)

local prepared = gerstner.prepare({
    { wavelength = 40, amplitude = 2, steepness = 0.5, direction = Vector2.new(1, 0) },
    { wavelength = 70, amplitude = 3, steepness = 0.4, direction = Vector2.new(0.7, 0.7) },
})

local position = gerstner.displace(prepared, x, z, t) -- Vector3
```

`prepare` validates and precomputes ONCE. `displace` is the hot path, call it PER vertex, per frame, against the same `prepared` value

## Notes

- **Studs.** `G` is `196.2` studs/s^2, matching a scale of 20 studs per metre
- **`y` is relative to the water plane.** `displace` returns absolute X and Z, but `y` is measured from the planes own level, so your renderer adds sea level
- **Reuse ONE `prepared` value.** Never call `prepare` inside an update loop
- **Buoyancy is an APPROXIMATION.** Gerstner displaces horizontally, so "surface height at world (x, z)" is an inverse problem. Sampling `displace(x,z)` and taking `y` is a good approximation, not an exact answer. If you use it for physics, keep the authoritative lookup on the server

## API

`prepare`, `displace`, `Wave`, `Prepared` - see the [API ref](https://superdupernairobi.github.io/Gerstner/api/Gerstner)

## License

MIT