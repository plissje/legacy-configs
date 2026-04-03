-- live_balancer.lua (v1.7 - The Cvar Method)
et.RegisterModname("Live Balancer API")

function et_ConsoleCommand()
    local cmd = et.trap_Argv(0)
    if string.lower(cmd) == "api_live_players" then
        local players = {}
        local maxclients = tonumber(et.trap_Cvar_Get("sv_maxclients")) or 64
        
        for i=0, maxclients-1 do
            -- Type 1=Axis, 2=Allies, 3=Spec
            local team = tonumber(et.gentity_get(i, "sess.sessionTeam"))
            
            if team and (team >= 1 and team <= 3) then
                local userinfo = et.trap_GetUserinfo(i)
                if userinfo ~= "" then
                    local name = et.Info_ValueForKey(userinfo, "name")
                    local guid = et.Info_ValueForKey(userinfo, "cl_guid")
                    
                    if name and name ~= "" and guid and guid ~= "" then
                        name = string.gsub(name, '"', '\\"')
                        name = string.gsub(name, '\\', '\\\\')
                        table.insert(players, string.format('{"slot":%d,"name":"%s","guid":"%s","team":%d}', i, name, guid, team))
                    end
                end
            end
        end
        
        -- Store the result in a Cvar. Calling "api_live_players" directly from RCON
        -- will also still print the markers just in case the console capture works.
        local json_payload = "[" .. table.concat(players, ",") .. "]"
        et.trap_Cvar_Set("etl_live_api", json_payload)
        
        local final_output = "\nAPI_PLAYERS_START\n" .. json_payload .. "\nAPI_PLAYERS_END\n"
        if et.trap_Print then et.trap_Print(final_output) end
        
        return 1
    end
    return 0
end

print("[Live API] LOADED - version 1.7")
et.trap_SendConsoleCommand(et.EXEC_APPEND, "say Live Balancer API v1.7 Loaded\n")
