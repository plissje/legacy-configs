-- live_balancer.lua (v1.4 - Fixed Player Detection)
et.RegisterModname("Live Balancer API")

print("[Live API] LOADED - version 1.4")

function et_ConsoleCommand()
    local cmd = et.trap_Argv(0)
    if string.lower(cmd) == "api_live_players" then
        local players = {}
        local maxclients = tonumber(et.trap_Cvar_Get("sv_maxclients")) or 64
        
        for i=0, maxclients-1 do
            -- Get player team (1=Axis, 2=Allies, 3=Spec)
            -- This is the most reliable way to check if a player is in a slot
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
        
        local final_output = "\nAPI_PLAYERS_START\n[" .. table.concat(players, ",\n") .. "]\nAPI_PLAYERS_END\n"
        
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
