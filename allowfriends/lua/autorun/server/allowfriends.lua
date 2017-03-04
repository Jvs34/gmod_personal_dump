AddCSLuaFile()

--the entire point of this is that it works in a listen/dedicated server
if game.SinglePlayer() then 
	MsgN( "AllowFriends: Not loading while in singleplayer." )
	return 
end
	
if SERVER then
	--[[
		As a limitation of the steam api this script cannot get a player's friendslist if his profile privacy is not public
		
	]]

	local allowfriends = {}

	allowfriends.sv_allowfriends = CreateConVar( "sv_allowfriends" , 
		"2", 
		FCVAR_SERVER_CAN_EXECUTE + FCVAR_REPLICATED + FCVAR_ARCHIVE , 
		"Allows your friends to join without a password and kicks other people. 0 disables it. 1 allows default behaviour if not friend. 2 disallow entry for non friends." 
	)
	
	allowfriends.sv_steamapikey = CreateConVar( 
		"sv_allowfriends_apikey" , 
		"0", 
		FCVAR_SERVER_CAN_EXECUTE + FCVAR_ARCHIVE , 
		"The api key for this script" 
	)
	
	allowfriends.sv_maxfails = CreateConVar( 
		"sv_allowfriends_maxretries" , 
		"5", 
		FCVAR_SERVER_CAN_EXECUTE + FCVAR_ARCHIVE , 
		"Max retries when the script fails to fetch the friends list" 
	)
	
	allowfriends.sv_steamid = CreateConVar( 
		"sv_allowfriends_steamid64" , 
		"0", 
		FCVAR_SERVER_CAN_EXECUTE + FCVAR_ARCHIVE , 
		"The steamid64 to get the friends list from"
	)
	
	allowfriends.sv_kickmessage = CreateConVar( 
		"sv_allowfriends_kickmessage" , 
		"Bad Password", 
		FCVAR_SERVER_CAN_EXECUTE + FCVAR_ARCHIVE , 
		"The kick message" 
	)
	
	allowfriends.api_url = "http://api.steampowered.com/"

	allowfriends.friends_api 	= "ISteamUser/GetFriendList/V001/"
	allowfriends.user_info 	= "ISteamUser/GetPlayerSummaries/V002/"	--not a good idea for now, especially if the user has like 200+ friends, 
																	--although this callback was made with that in mind
	allowfriends.chosen_steamid64 = allowfriends.sv_steamid:GetString()	--this way if we're a server we can set the steamid on startup

	allowfriends.current_retry = 0

	allowfriends.steamfriends = {
		--indexed by
		--[[ 
			["7673 and so on"] = true,
		]]
	}

	function allowfriends:IsValid()
		return true
	end
	
	function allowfriends:IsFriend( steamid64 )
		return self.steamfriends[steamid64]
	end

	function allowfriends:FetchFriends()
		if not self.chosen_steamid64 then
			return
		end
		
		local convertedsteamid = util.SteamIDFrom64( self.chosen_steamid64 )
		
		if convertedsteamid == "STEAM_0:0:0" or not convertedsteamid then
			ErrorNoHalt( "AllowFriends: Invalid steamid " .. self.chosen_steamid64.. " " .. tostring( convertedsteamid ) )
			return
		end
		
		if #self.sv_steamapikey:GetString() < 1 then
			ErrorNoHalt( "AllowFriends: Steam api key too short!" )
		end
		
		http.Fetch( self.api_url .. self.friends_api .. "?key="..self.sv_steamapikey:GetString().."&steamid="..self.chosen_steamid64,
			function( body, len, headers, code )
				
				if not self then
					return
				end
				
				local jsontab = util.JSONToTable( body )
				
				if not jsontab or not jsontab.friendslist or not jsontab.friendslist.friends then
					ErrorNoHalt( "AllowFriends: Could not fetch friends list, account visibility is not public, wrong steamid or wrong api key" )
					return
				end
				
				local friendsn = 0
				
				for i , v in pairs( jsontab.friendslist.friends ) do
					if v.relationship == "friend" then
						self.steamfriends[v.steamid] = true
						friendsn = friendsn + 1
					end
				end
				
				PrintMessage( HUD_PRINTTALK , "AllowFriends: "..friendsn.." friends can join this listen server." )
			end,
			
			function( err )
				self.current_retry = self.current_retry + 1
				if self.current_retry < self.sv_maxfails:GetInt() then
					self:FetchFriends()
				end
			end
		)
	end

	function allowfriends:InstallCallbacks()
		--listen server support
		if not game.IsDedicated() then
			hook.Add( "PlayerAuthed" , self , function( self , ply , steamid, retardeduniqueid )
				if IsValid( ply ) and ply:IsListenServerHost() then
					self.chosen_steamid64 = ply:SteamID64()
					self:FetchFriends()
				end
			end)
		else
			hook.Add( "Initialize" , self , function( self )
				self.chosen_steamid64 = sv_steamid:GetString()	--refresh the steamid just in case
				self:FetchFriends()
			end)
		end

		hook.Add( "CheckPassword" , self , function( self , steamid64 , ip , sv_password , cl_password , playernick )
			local mode = self.sv_allowfriends:GetInt()
			if mode < 1 or mode > 2 then 
				return 
			end	--not enabled, let the normal stuff handle it
			
			if self:IsFriend( steamid64 ) then
				PrintMessage( HUD_PRINTTALK , "AllowFriends: " .. playernick .. " has joined the server." )
				return true
			else
				if mode == 2 then --we don't care if you have a good password or not, fuck off
					PrintMessage( HUD_PRINTTALK , "AllowFriends: " .. playernick .. " has been denied entry." )
					return false, self.sv_kickmessage:GetString()
				end
			end
			
		end)

		cvars.AddChangeCallback( self.sv_steamid:GetName() , function( convar_name, value_old, value_new )
			self.chosen_steamid64 = value_new
			self.steamfriends = {}
			self:FetchFriends()
		end, "Callback:"..self.sv_steamid:GetName() )
		
		concommand.Add( "sv_allowfriends_refresh" , function( ply , command , args )
			self.steamfriends = {}
			self:FetchFriends()
		end)
	end
	
	
	allowfriends:InstallCallbacks()
else
	
end