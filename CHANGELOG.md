# Changelog

## 0.1.0

Initial release:

- `prepare(waves)` - validates a wave set once and precomputes every per wave constant
- `displace(prepared, x, z, t)` - returns the absolute world position of the surface point whose rest position is `(x, z)`
- `Wave` and `Prepared` exported types
- Deepwater dispersion with `G = 196.2` studs/s^2 (20 studs per metre)
- `prepare` throws the offending wave index for `wavelength <= 0`, `amplitude <= 0`, `steepness` outside `0..1`, a zero length `direction`, or an empty wave list