if CLIENT then return end

local ply=RemotePlayer() or player.GetByID(1)


if IsValid(ply) then

	ply:SendLua([[RunConsoleCommand("remote_lua_sh", "lau/sent_specialaction")]])
	
	ply:SendLua([[RunConsoleCommand("remote_lua_sh", "lau/specialactions/sa_meleecharge")]])
	
	
	ply:SendLua([[RunConsoleCommand("remote_lua_sh", "lau/specialactions/sa_bassvoice")]])
	
	ply:SendLua([[RunConsoleCommand("remote_lua_sh", "lau/specialactions/sa_superjump")]])
	

	ply:SendLua([[RunConsoleCommand("remote_lua_sh", "lau/specialactions/sa_kick")]])

	ply:SendLua([[RunConsoleCommand("remote_lua_sh", "lau/specialactions/sa_mseedsshooter")]])
	
	
	
	ply:SendLua([[RunConsoleCommand("remote_lua_sh", "lau/specialactions/sa_grapplehook")]])

	ply:SendLua([[RunConsoleCommand("remote_lua_sh", "lau/specialactions/sa_jetpack")]])

	ply:SendLua([[RunConsoleCommand("remote_lua_sh", "lau/specialactions/sa_laser")]])

	ply:SendLua([[RunConsoleCommand("remote_lua_sh", "lau/specialactions/sa_rocketlauncher")]])

	ply:SendLua([[RunConsoleCommand("remote_lua_sh", "lau/specialactions/sa_rshield")]])

	ply:SendLua([[RunConsoleCommand("remote_lua_sh", "lau/specialactions/sa_stuffthrower")]])

	ply:SendLua([[RunConsoleCommand("remote_lua_sh", "lau/specialactions/sa_teleporter")]])
	
	
end