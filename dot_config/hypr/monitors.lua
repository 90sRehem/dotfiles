-- See https://wiki.hypr.land/Configuring/Basics/Monitors/
-- List current monitors and supported resolutions with: hyprctl monitors all

local omarchy_gdk_scale = 2
local omarchy_monitor_scale = 2

hl.env("GDK_SCALE", tostring(omarchy_gdk_scale))
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = omarchy_monitor_scale })

-- Main ultrawide monitor (LG UltraWide, DP-3). Workspaces 1-5 live here.
hl.monitor({ output = "DP-3", mode = "preferred", position = "0x0", scale = 1 })
hl.workspace_rule({ workspace = "1", monitor = "DP-3", persistent = true, default = true })
hl.workspace_rule({ workspace = "2", monitor = "DP-3", persistent = true })
hl.workspace_rule({ workspace = "3", monitor = "DP-3", persistent = true })
hl.workspace_rule({ workspace = "4", monitor = "DP-3", persistent = true })
hl.workspace_rule({ workspace = "5", monitor = "DP-3", persistent = true })

-- Smaller secondary monitor (Arzopa, HDMI-A-1), directly below the LG and
-- horizontally centered under it so the mouse crosses cleanly between the
-- two. Scaled up a bit (1.5) since it's smaller and denser, so UI reads
-- larger. Workspace 6 lives here.
hl.monitor({ output = "HDMI-A-1", mode = "preferred", position = "1080x1440", scale = 1.5 })
hl.workspace_rule({ workspace = "6", monitor = "HDMI-A-1", persistent = true, default = true })

-- Configure a specific monitor.
-- hl.monitor({ output = "DP-2", mode = "2560x1440@144", position = "0x0", scale = 1 })

-- Portrait/rotated secondary monitor (transform: 1 = 90°, 3 = 270°).
-- hl.monitor({ output = "DP-2", mode = "preferred", position = "auto", scale = 1, transform = 1 })
