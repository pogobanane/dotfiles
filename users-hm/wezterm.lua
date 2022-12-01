local wezterm = require 'wezterm'

--local base_scheme = "GitHub Dark"
--local base_scheme = "Molokai"
--local base_scheme = "Monokai Vivid"
--local base_scheme
--local base_scheme = "Molokai (Gogh)"
--local base_scheme = "Monokai (terminal.sexy)"
--local base_scheme = "MonokaiDark (Gogh)"
--local base_scheme = "Tango (base16)"
local base_scheme = "Obsidian"
--local base_scheme = "OceanicMaterial"
--local base_scheme = 'Molokai'
local custom_scheme = wezterm.color.get_builtin_schemes()[base_scheme]
--local custom_scheme = wezterm.color.get_default_colors()
custom_scheme.background = '1e1e1e'
custom_scheme.cursor_fg = custom_scheme.background
--custom_scheme.background = 'red'

return {
  font = wezterm.font_with_fallback {
    -- my choice
    'Monospace',

    -- /nix/store/8cf5drzf1gswmcz9hh6jnw2ffxxxwy06-dejavu-fonts-2.37/share/fonts/truetype/DejaVuSansMono.ttf, FontConfigMatch("Monospace")
    "DejaVu Sans Mono",

    -- <built-in>, BuiltIn
    "JetBrains Mono",

    -- /nix/store/wca64hcxc578q0gsx4bga519kc2rrwid-noto-fonts-emoji-2.034/share/fonts/noto/NotoColorEmoji.ttf, FontConfig
    -- Assumed to have Emoji Presentation
    -- Pixel sizes: [128]
    "Noto Color Emoji",

    -- <built-in>, BuiltIn
    "Symbols Nerd Font Mono",

    -- <built-in>, BuiltIn
    "Last Resort High-Efficiency",
  },
  hide_tab_bar_if_only_one_tab = true,
  --color_scheme = "GitHub Dark",
  --color_scheme = "Molokai",
  --color_scheme = "Monokai Vivid",
  --
  --color_scheme = "Molokai (Gogh)",
  --color_scheme = "Monokai (terminal.sexy)",
  --color_scheme = "MonokaiDark (Gogh)",
  --color_scheme = "Tango (base16)",

  color_schemes = {
    ['Custom Scheme'] = custom_scheme,
  },
  color_scheme = 'Custom Scheme',
  enable_scroll_bar = true,
  font_size = 10.2,
}
