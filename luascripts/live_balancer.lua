-- live_balancer.lua
-- Put this file in your fs_homepath/legacy/luascripts folder
-- and add it to lua_modules in your server config:
-- set lua_modules "luascripts/live_balancer.lua"

et.RegisterModname("Live Balancer API")

print("Live Balancer API: Initializing...")

function et_ConsoleCommand()
    local cmd = et.trap_Argv(0)
    -- Debug: print every command to see if we're hitting the hook
    -- print("Command caught: " .. tostring(cmd))

    if string.lower(cmd) == "api_live_players" then
        print("Live Balancer API: Command 'api_live_players' triggered")
        local num_clients = tonumber(et.trap_Cvar_Get("sv_maxclients")) or 64
        local players = {}
        
        for i=0, num_clients-1 do
            local team = et.gentity_get(i, "sess.sessionTeam")
            -- team 1 = Axis, 2 = Allies, 3 = Spectator
            if team and (team == 1 or team == 2 or team == 3) then
                local userinfo = et.trap_GetUserinfo(i)
                local name = et.Info_ValueForKey(userinfo, "name")
                local guid = et.Info_ValueForKey(userinfo, "cl_guid")
                
                if name and guid and guid ~= "" then
                    -- Escape quotes in name
                    name = string.gsub(name, '"', '\\"')
                    name = string.gsub(name, '\\', '\\\\')
                    
                    table.insert(players, string.format('{"slot":%d,"name":"%s","guid":"%s","team":%d}', i, name, guid, team))
                end
            end
        end
        
        local json_payload = table.concat(players, ",\n")
        local final_output = "\nAPI_PLAYERS_START\n[" .. json_payload .. "]\nAPI_PLAYERS_END\n"
        
        -- Use standard print for RCON redirection
        print(final_output)
        return 1
    end
    return 0
end

print("Live Balancer API: Ready.")
