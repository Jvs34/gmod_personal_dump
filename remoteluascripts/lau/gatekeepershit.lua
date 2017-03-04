if CLIENT then
	return
end

gatekeeper = gatekeeper or {}
gatekeeper.sv_guestpassword = CreateConVar( "sv_guestpassword" , "" , FCVAR_NOTIFY + FCVAR_SERVER_CAN_EXECUTE + FCVAR_ARCHIVE + FCVAR_PROTECTED , "The guest password, blank out to disable this feature." )
gatekeeper.sv_canfaggotsjoin = CreateConVar( "sv_canfaggotsjoin" , "0" , FCVAR_NOTIFY + FCVAR_SERVER_CAN_EXECUTE + FCVAR_ARCHIVE , "Control if faggots can join when the server is passworded." )

--in steamid64
gatekeeper.JoinReasons = gatekeeper.JoinReasons or {}

function gatekeeper.HandleJoinReason( steamid64 , playername , joinreason )
	gatekeeper.JoinReasons[ steamid64 ] = joinreason
end

function gatekeeper.PlayerAuthedHook( ply , steamid , uniqueid )
	local steamid64 = util.SteamIDTo64( steamid )
	
	local joinreason = gatekeeper.JoinReasons[ steamid64 ]
	
	if joinreason then
		ply:SetNWString( "joinreason" , joinreason )
	end
end

function gatekeeper.CanFaggotJoin( steamid64 , ip , playername )
	local sv_canfaggotsjoin = gatekeeper.sv_canfaggotsjoin:GetString()
	
	local plys = player.GetHumans()
	
	local hasadmins = false
	
	for i , v in pairs( plys ) do
		if v:IsSuperAdmin() then
			hasadmins = true
			break
		end
	end
	
	local canjoin = sv_canfaggotsjoin:GetBool() and hasadmins
	
	return canjoin
end

function gatekeeper.CheckPasswordHook( steamid64 , ip , sv_password , clientpassword , playername )
	local joinreason = ""
	local sv_guestpassword = gatekeeper.sv_guestpassword:GetString()
	local steamid = util.SteamIDFrom64( steamid64 )
	local message = ""
	local result = nil
	local kickreason = "Bad Password"
	
	--don't care, the server is open to everyone
	if sv_password == "" then
		result = true
		joinreason = "without a password"
		message = playername .. " has joined the server"
	end
	
	--trusted user don't care
	if result == nil and sv_password ~= "" then
		if TRUSTED[steamid] then
			result = true
			joinreason = "because the user is trusted"
			message = playername .." joined without a password( TRUSTED )"
		else
			--not a trusted user, if they're a faggot then we deny them
			if FAGGOTS[steamid] then
				if not gatekeeper.CanFaggotJoin( steamid64 , ip , playername ) then
					result = false
					message = playername .. " was not allowed from joining( FAGGOT CVAR OFF )"
					kickreason = "Server uses different client tables"
				else
					result = true
					joinreason = "because faggots are allowed"
					message = playername .. " because he is a faggot ( FAGGOTS CVAR ON )"
				end
			else	
				--if they're not a faggot, check if they used the guestpassword
				if sv_guestpassword ~= "" and clientpassword == sv_guestpassword then
					result = true
					joinreason = "with the guest password"
					message = playername .. " joined with the guest password ( GUEST PASSWORD )"
				end
			end
		end
	end
				
	--finally, if nothing else was checked, check sv_password instead
	if result == nil and sv_password ~= "" then
		if sv_password ~= clientpassword then
			result = false
			--no kickreason, this way it'll use Bad Password
			message = playername .. " was not allowed from joining ( WRONG PASSWORD )"
		else
			result = true
			joinreason = "with the server password"
			message = playername .. " joined with the server password ( SERVER PASSWORD )"
		end
	end
	
	if result ~= nil then
		--only record join reasons when joins are successful
		if result then
			gatekeeper.HandleJoinReason( steamid64 , playername , joinreason )
		end
		
		print( message )
		PrintMessage( HUD_PRINTTALK , message )
		
		if result then
			return result
		else
			return result , kickreason
		end
	end
	
end


hook.Add( "CheckPassword" , "gatekeeper" , gatekeeper.CheckPasswordHook )
hook.Add( "PlayerAuthed" , "gatekeeper" , gatekeeper.PlayerAuthedHook )

hook.Remove( "CheckPassword" , "Allowtrusted" )