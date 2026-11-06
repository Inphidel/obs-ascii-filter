# OBS ASCII filter

Two filters for OBS Studio, built for [obs-shaderfilter](https://github.com/exeldro/obs-shaderfilter).

`ascii-bloom.shader` turns a camera into colored glyphs on black, with a glow on the bright strokes. `scramble.shader` is the unpaid cable channel: the picture is sliced into bands that slide out of sync. Put Scramble under ASCII Bloom and it scrambles the letters. Put it above, and the letters are made from an already scrambled picture.

## Install

Install OBS Studio and the obs-shaderfilter plugin. Plugin builds are on the [obs-shaderfilter releases](https://github.com/exeldro/obs-shaderfilter/releases) page. On Linux, unpack the plugin so `obs-shaderfilter.so` lives at:

```text
~/.config/obs-studio/plugins/obs-shaderfilter/bin/64bit/obs-shaderfilter.so
```

Restart OBS after the plugin appears.

Copy this repo's `shaders` folder somewhere permanent. On a source:

1. Filters, +, User-defined shader.
2. Turn on **Load shader text from file**.
3. Choose `shaders/ascii-bloom.shader`.
4. Add a second User-defined shader and choose `shaders/scramble.shader`.
5. Drag **Scramble** under **ASCII Bloom** in the filter list. OBS runs that list from top to bottom.

The eye beside a filter turns that pass off. Strength 0 on Scramble leaves the picture alone.

Right-click a filter and choose **Reload effect** after you edit a shader file.

## ASCII Bloom

Glyphs, light to dense: space `.` `-` `:` `;` `*` `+` `x` `o` `#` `@`. The bitmaps are 16×16 and were rasterized from DejaVu Sans Mono Bold.

- **Glyphs** sets the cell and how brightness maps onto a character.
- **Bloom** is the glow. Amount, radius, and cutoff.
- **Color** grades the letters. Hue and saturation recolor the glyphs. Camera tint mixes the webcam color into the ink. Background opacity 0 keeps the letters and the glow and drops the black, so the source can sit over another camera.

The camera's own exposure and white balance are on the source properties, not on this filter.

## Scramble

- **Band height** is how tall each torn strip is.
- **Slide** is how far a strip moves sideways. The picture wraps, the way a set with a bad sync used to.
- **Roll** moves the pattern. **Line jitter** shakes single rows.
- **Snow** and **Color split** are the noisy cable signal.
- **Search bar** is the dark band that crawls while the set hunts for a lock.

## License

MIT. See [LICENSE](LICENSE).
