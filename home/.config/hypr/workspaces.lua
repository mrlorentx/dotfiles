-- Named workspaces, reachable with the same key from any monitor.
--
-- Omarchy 4.5 gives every monitor its own workspaces 1-10, so SUPER+N means
-- "slot N on the focused monitor" and the same key lands somewhere else per
-- monitor. These slots are named workspaces instead: Hyprland gives a named
-- workspace a negative id, which the per-monitor logic in
-- default/hypr/monitor-workspaces.lua ignores, so SUPER+N focuses the named
-- workspace wherever it is and jumps monitors when needed. Slots not listed
-- here keep Omarchy's per-monitor behaviour.

local named = {
	[1] = "terminal",
	[2] = "browser",
	[3] = "slack",
	[4] = "tickets",
	[5] = "calendar",
	[8] = "chats",
	[9] = "music",
}

for slot, name in pairs(named) do
	local key = "code:" .. tostring(slot + 9)
	local workspace = "name:" .. name
	o.rebind("SUPER + " .. key, "Switch to " .. name, hl.dsp.focus({ workspace = workspace }))
	o.rebind("SUPER + SHIFT + " .. key, "Move window to " .. name, hl.dsp.window.move({ workspace = workspace }))
	o.rebind("SUPER + SHIFT + ALT + " .. key, "Move window silently to " .. name, hl.dsp.window.move({ workspace = workspace, follow = false }))
end

o.window("slack", { workspace = "name:slack" })

-- The bar widget (~/.config/omarchy/plugins/mrlorentx.workspaces) labels each
-- named workspace with its key, read from this file.
local paths = require("default.hypr.paths")
local state = io.open(paths.state_home .. "/omarchy/named-workspaces", "w")
if state then
	local slots = {}
	for slot in pairs(named) do
		slots[#slots + 1] = slot
	end
	table.sort(slots)
	for _, slot in ipairs(slots) do
		state:write(slot .. "\t" .. named[slot] .. "\n")
	end
	state:close()
end

-- Omarchy's reconcile runs on every reload and monitor change and puts each
-- monitor back on a workspace of its own block, which would push a monitor off
-- a named workspace it is showing. Put it back afterwards.
local function is_named(workspace)
	return workspace ~= nil and not workspace.special and workspace.id < 0
end

local reconcile = o.workspaces.reconcile
o.workspaces.reconcile = function(added, gone)
	local showing = {}
	for _, monitor in ipairs(hl.get_monitors()) do
		if monitor.name ~= gone and is_named(monitor.active_workspace) then
			showing[monitor.name] = monitor.active_workspace.name
		end
	end
	local focused = hl.get_active_window()

	reconcile(added, gone)

	for monitor_name, workspace in pairs(showing) do
		local monitor = hl.get_monitor(monitor_name)
		if monitor and (not monitor.active_workspace or monitor.active_workspace.name ~= workspace) then
			monitor:set_workspace({ workspace = workspace })
		end
	end
	if focused and hl.get_window("address:" .. focused.address) then
		hl.dispatch(hl.dsp.focus({ window = "address:" .. focused.address }))
	end
end
