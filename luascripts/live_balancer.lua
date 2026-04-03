-- live_balancer.lua (v1.3 - Final RCON Fix)
et.RegisterModname("Live Balancer API")

print("[Live API] LOADED - version 1.3")

function et_ConsoleCommand()
    local cmd = et.trap_Argv(0)
    if string.lower(cmd) == "api_live_players" then
        local players = {}
        -- ET: Legacy supports up to 64 slots
        for i=0, 63 do
            local cs = et.trap_GetConfigstring(64 + i) -- 64+i is the player info CS
            if cs and cs ~= "" then
                local name = et.Info_ValueForKey(cs, "n")
                local guid = et.Info_ValueForKey(cs, "cl_guid")
                local team = tonumber(et.Info_ValueForKey(cs, "t")) or 3
                
                -- Only include players who actually have a name and GUID
                if name and name ~= "" and guid and guid ~= "" then
                    -- Escape quotes in name for JSON safety
                    name = string.gsub(name, '"', '\\"')
                    name = string.gsub(name, '\\', '\\\\')
                    table.insert(players, string.format('{"slot":%d,"name":"%s","guid":"%s","team":%d}', i, name, guid, team))
                end
            end
        end
        
        local final_output = "\nAPI_PLAYERS_START\n[" .. table.concat(players, ",\n") .. "]\nAPI_PLAYERS_END\n"
        
        -- et.trap_Print is the most reliable way to send text back to the RCON client
        if et.trap_Print then
            et.trap_Print(final_output)
        elseif et.G_Printf then
            et.G_Printf("%s", final_output)
        else
            -- Fallback to standard Lua print
            print(final_output)
        end
        return 1
    end
    return 0
end
