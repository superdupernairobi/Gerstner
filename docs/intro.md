---
sidebar_position: 1
---

![Gerstner logo](./introicon.png)

# Getting started

Gerstner is only math. No instances or services or states. So it runs on the server, on the client, or from the command bar with no play session

## Install

```toml
[dependencies]
Gerstner = "superdupernairobi/gerstner@0.1.0" | `@0.1.1` (or use `@0.1`)
```

## Prepare once, displace a lot

`prepare` validates your wave set and precomputes every per wave const, so the hot loop never calls `sqrt`

```lua
local gerstner = require(game.ReplicatedStorage.gerstner)

local prepared = gerstner.prepare({
    { wavelength = 40, amplitude = 2, steepness = 0.5, direction = Vector2.new(1, 0) },
    { wavelength = 70, amplitude = 3, steepness = 0.4, direction = Vector2.new(0.7, 0.7) },
})
```

## Sampling the surface

```lua
local position = gerstner.displace(prepared, x, z, t) -- position.Y is relative to the water plane, not to sea level
```

## Verifying it works

One wave - `wavelength = 40`, `amplitude = 2`, `steepness = 0.5`, `direction = Vector2.new(1, 0)`, `t = 0` - reproduces this exactly:

| `x` | `.Y` | `.X` |
|---|---|---|
| 0 | 0 | 3.183 |
| 10 | +2 | 10 |
| 20 | 0 | 16.817 |
| 30 | -2 | 30 |
| 40 | 0 | 43.183 |
| 50 | +2 | 50 |

The `.X` column is not decoration, Gerstner displaces X and Z as well as Y, which is what bunches crests and stretches troughs. That term is zero at a crest or a trough, and maximal at the zero crossing, so `X == x` at `x = 10` is correct, not a dead term

## Fail fast

`prepare` throws at setup time and names the offending wave, since it rejects a `wavelength <= 0` an `amplitude <= 0` (`Q` divides by amplitude, so zero would produce infinite positions), a `steepness` outside `0..1` (above 1 the wave self intersects and the surface spikes), a zero length `direction`, and an empty wave list

## Performance

`displace` costs a handful of multiplies and two trig calls per wave, so reuse a single `prepared` value and write vertices in one batch, per vertex `SetPosition` in a loop is a known trap!