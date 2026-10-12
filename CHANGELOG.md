# Changelog

```markdown
## 0.1.1

- Added `description` and `authors` to the wally package
- Trimmed the package archive: `build/` output is no longer included, and the empty `docs/` is gone
- Documentation: API references, getting started and an editable mesh example

## 0.1.0

Initial release:

- `prepare(waves)` - validates a wave set once and precomputes every per wave constant
- `displace(prepared, x, z, t)` - returns the absolute world position of the surface point whose rest position is `(x, z)`
- `Wave` and `Prepared` exported types
- Deepwater dispersion with `G = 196.2` studs/s^2 (20 studs per metre)
- `prepare` throws the offending wave index for `wavelength <= 0`, `amplitude <= 0`, `steepness` outside `0..1`, a zero length `direction`, or an empty wave list