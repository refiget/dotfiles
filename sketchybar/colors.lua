-- macOS-like dark palette (vibrant B) (ARGB: 0xAARRGGBB)
return {
  -- Core
  black = 0xff1c1c1e,
  white = 0xfff2f2f7,
  grey  = 0xff8e8e93,
  transparent = 0x00000000,

  -- Accents (a bit more lively)
  red     = 0xffff453a,
  green   = 0xff30d158,
  blue    = 0xff5aa9ff,   -- brighter + more airy
  yellow  = 0xffffd60a,
  orange  = 0xffff9f0a,
  magenta = 0xffbf5af2,

  -- Surfaces
  bar = {
    bg = 0xb21c1c1e,
    border = 0x5a4a4a4d,
  },
  popup = {
    bg = 0xe6262629,
    border = 0x7085858f,
  },

  -- Pill backgrounds/borders
  bg1 = 0xc338383c,
  bg2 = 0xaa505055,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
