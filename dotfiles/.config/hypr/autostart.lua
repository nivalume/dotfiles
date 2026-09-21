-- Extra autostart processes.
-- o.launch_on_start("my-service")

local home = os.getenv("HOME")

-- Start FlowZ once when the Hyprland session starts.
o.launch_on_start(home .. "/Downloads/FlowZ-4.3.2-linux-x86_64.AppImage")

-- Start the graphical window overview daemon.
o.launch_on_start(home .. "/.local/bin/hyprswitch init --show-title --workspaces-per-row 5")
