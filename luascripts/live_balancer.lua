-- live_balancer.lua (v1.6 - Final RCON fix)
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
        
        -- Add a non-empty character at the start to ensure engine captures the first line
        local json_payload = "[" .. table.concat(players, ",") .. "]"
        local final_output = " \nAPI_PLAYERS_START\n" .. json_payload .. "\nAPI_PLAYERS_END\n"
        
        if et.trap_Print then
            et.trap_Print(final_output)
        elseif et.G_Printf then
            et.G_Printf("%s", final_output)
        else
            print(final_output)
        end
        return 1
    end
    return 0
end

print("[Live API] LOADED - version 1.6")
et.trap_SendConsoleCommand(et.EXEC_APPEND, "say Live Balancer API v1.6 Loaded\n")
