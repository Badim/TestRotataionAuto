-- Simulator / desktop stub when plugin.orientation.jar is not loaded.
-- On Android device builds, the native Java plugin replaces this module.

local lib = {}

function lib.set(mode)
	-- No-op outside Android native build; optional print for debugging:
	-- print("[plugin.orientation] set(" .. tostring(mode) .. ") — stub (simulator)")
end

return lib
