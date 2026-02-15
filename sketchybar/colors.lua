-- Catppuccin Mocha palette (ARGB: 0xAARRGGBB)
return {
  -- Core
  black = 0xff181825,      -- mantle
  white = 0xffcdd6f4,      -- text
  grey  = 0xff6c7086,      -- overlay0
  transparent = 0x00000000,

  -- Accents (Catppuccin-ish)
  red     = 0xfff38ba8,
  green   = 0xffa6e3a1,
  blue    = 0xff89b4fa,
  yellow  = 0xfff9e2af,
  orange  = 0xfffab387,    -- peach
  magenta = 0xffcba6f7,

  -- Surfaces
  bar = {
    bg = 0xfa1e1e2e,       -- base with a touch more transparency (-10 alpha)
    border = 0xff313244,   -- surface0
  },
  popup = {
    bg = 0xc01e1e2e,
    border = 0xff6c7086,
  },

  -- Used throughout items as pill backgrounds/borders
  bg1 = 0xf5313244,        -- surface0 (+10 transparency)
  bg2 = 0xf545475a,        -- surface1 (+10 transparency)

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
