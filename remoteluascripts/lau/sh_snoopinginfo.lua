--a simple script to broadcast some clientside info such as OS, game being alttabbed and shit
--totally not invading the privacy

--this is the table that will organize how the net messages will be received, sent and read
if SERVER then
	util.AddNetworkString( "snoopinginfo" )
end

local META = FindMetaTable("Player")

if META then
	function META:GetSnoopedInfo( str , defaultval )
		if self._SnoopedInfo and self._SnoopedInfo[string.lower(str)] ~= nil then
			return self._SnoopedInfo[string.lower(str)]
		end
		return defaultval
	end
end

META = nil

SNOOP_SENDALWAYS	=	2^0	--always send every "tick", we want this for stuff like fps
SNOOP_SENDONCE		=	2^1	--for stuff like iswindows
SNOOP_SENDTIMED		=	2^2

SNOOP_DELAY_DEFAULT	=	5
SNOOP_DELAY_LOW		=	10
SNOOP_DELAY_MEDIUM	=	60
SNOOP_DELAY_HIGH	=	360

local info_tab={
	[1]={
		Name="os",
		Type=TYPE_STRING,
		Flags=SNOOP_SENDONCE,
		Return=function()
			if system.IsWindows and system.IsWindows() then return "Windows" 
			elseif system.IsLinux and system.IsLinux() then return "Linux" 
			elseif system.IsOSX and system.IsOSX() then return "OSX"
			else return "Unknown" end
		end,
		Write=function(val)
			net.WriteString(val)
		end,
		Read=function()
			return net.ReadString()
		end
	},
	[2]={
		Name="has_focus",
		Type=TYPE_BOOL,
		Flags=SNOOP_SENDALWAYS,
		Return=function()
			return system.HasFocus()
		end,
		Write=function( val )
			net.WriteBit( val )
		end,
		Read=function()
			return tobool( net.ReadBit() )
		end
	},
	[3]={
		Name="in_menu",
		Type=TYPE_BOOL,
		Flags=SNOOP_SENDALWAYS,
		Return=function()
			return gui.IsGameUIVisible()
		end,
		Write=function(val)
			net.WriteBit(val)
		end,
		Read=function()
			return tobool(net.ReadBit())
		end
	},
	[4]={
		Name="in_console",
		Type=TYPE_BOOL,
		Flags=SNOOP_SENDALWAYS,
		Return=function()
			return gui.IsConsoleVisible()
		end,
		Write=function(val)
			net.WriteBit(val)
		end,
		Read=function()
			return tobool(net.ReadBit())
		end
	},
	[5]={
		Name="fps",
		Type=TYPE_NUMBER,
		Flags=SNOOP_SENDTIMED,
		Return=function()
			return 1/RealFrameTime()
		end,
		Write=function(val)
			net.WriteFloat(val)
		end,
		Read=function()
			return net.ReadFloat()
		end
	},
	[6]={
		Name="in_spawnmenu",
		Type=TYPE_BOOL,
		Flags=SNOOP_SENDALWAYS,
		Return=function()
			return g_SpawnMenu and g_SpawnMenu:IsVisible() or false
		end,
		Write=function(val)
			net.WriteBit(val)
		end,
		Read=function()
			return tobool(net.ReadBit())
		end
	},
	[7]={
		Name="dx_level",
		Type=TYPE_NUMBER,
		Flags=SNOOP_SENDONCE,
		Return=function()
			return render.GetDXLevel( )
		end,
		Write=function(val)
			net.WriteFloat(val)
		end,
		Read=function()
			return net.ReadFloat()
		end
	},
	[8]={
		Name="os_country",
		Type=TYPE_STRING,
		Flags=SNOOP_SENDONCE,
		Return=function()
			return system.GetCountry()
		end,
		Write=function(val)
			net.WriteString(val)
		end,
		Read=function()
			return net.ReadString()
		end
	},
	[9] = {
		Name = "screen",
		Type = TYPE_TABLE,
		Flags = SNOOP_SENDTIMED,
		Delay = SNOOP_DELAY_MEDIUM,
		Return = function()
			return nil
		end,
		Write = function( val )
		
		end,
		Read = function()
			return nil
		end
	
	},
}

if CLIENT then

	local alttabbed=Material("icon16/application_double.png")
	local terminal=Material("icon16/application_xp_terminal.png")
	local menu=Material("icon16/application_side_contract.png")
	local spwnmenu=Material("icon16/application_side_expand.png")
	local devving=GetConVar("developer")
	

	
	hook.Add( "PostPlayerDraw" , "valuestest",function( ply )
		local has_focus	=	ply:GetSnoopedInfo( "has_focus" , true )
		local fps	=	ply:GetSnoopedInfo( "fps" , -1)
		local in_menu	=	ply:GetSnoopedInfo( "in_menu" , false )
		local in_console	=	ply:GetSnoopedInfo( "in_console" , false )
		local in_spawnmenu	=	ply:GetSnoopedInfo( "in_spawnmenu" , false )
		local os_country	=	ply:GetSnoopedInfo( "os_country" , "")
		render.SetLightingMode( 2 )
		
		local ang = EyeAngles()

		ang:RotateAroundAxis( ang:Forward(), 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )
		
		local pos = ply:EyePos()+Vector(0,0,20)
		local bone = ply:LookupBone("ValveBiped.Bip01_Head1")
		if bone == nil then return end
		
		local m=ply:GetBoneMatrix(bone)
		if m then
			pos=m:GetTranslation()+Vector(0,0,20)
		end
			cam.Start3D2D(pos, Angle( 0, ang.y, 90 ), 0.25)
				
				if devving:GetBool() and os_country then
					surface.SetFont("ScoreboardDefault")
					surface.SetTextColor( 255, 255, 255, 255 )
					surface.SetTextPos( 16+4, 20 ) 
					surface.DrawText( os_country or "" )
				end
				
				if not has_focus then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( alttabbed )
					surface.DrawTexturedRect(0,3, 16 , 16 )
					
					surface.SetFont("ScoreboardDefault")
					surface.SetTextColor( 255, 255, 255, 255 )
					surface.SetTextPos( 16+4,0 ) 
					surface.DrawText( "ALT-TABBED" )
				end

				if in_menu and in_console then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( terminal )
					surface.DrawTexturedRect(0,-17, 16 , 16 )
					
					surface.SetFont("ScoreboardDefault")
					surface.SetTextColor( 255, 255, 255, 255 )
					surface.SetTextPos( 16+4,-20 ) 
					surface.DrawText( "CONSOLE OPEN")
				elseif in_menu and not in_console then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( menu )
					surface.DrawTexturedRect(0,-17, 16 , 16 )
					
					surface.SetFont("ScoreboardDefault")
					surface.SetTextColor( 255, 255, 255, 255 )
					surface.SetTextPos( 16+4,-20 ) 
					surface.DrawText( "IN MENU")
				
				elseif in_spawnmenu then
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetMaterial( spwnmenu )
					surface.DrawTexturedRect(0,-17, 16 , 16 )
					
					surface.SetFont("ScoreboardDefault")
					surface.SetTextColor( 255, 255, 255, 255 )
					surface.SetTextPos( 16+4,-20 ) 
					surface.DrawText( "IN SPAWNMENU")
				end
				
				if devving and devving:GetBool() and fps ~= -1 then
					surface.SetFont("ScoreboardDefault")
					surface.SetTextColor( 255, 255, 255, 255 )
					surface.SetTextPos( 16+4,-40 ) 
					surface.DrawText( "FPS: "..tostring(math.Round(fps)) )
				end
				
			cam.End3D2D()
		
		render.SetLightingMode( 0 )
	end)
	
end



	
local function sendClientInfo( ply )
	local plys = nil
	
	if SERVER then
		
		plys = {}
		
		for i ,v in pairs( player.GetHumans() ) do
			if v ~= ply then
				plys[#plys] = v
			end
		end

		if #plys <= 0 then return end
	end
	
	net.Start("snoopinginfo")
	
	net.WriteEntity( ply or NULL )	--only NULL when sending from the CLIENT
	
	
	
	if CLIENT then
		if not LocalPlayer()._SnoopedInfo then
			LocalPlayer()._SnoopedInfo={}
		end
	end
	
	for i,v in ipairs( info_tab ) do
					
		if not v.Time then v.Time=CurTime() end
		
		local val = nil
		if CLIENT then
			val = v.Return()
		else
			val = ply:GetSnoopedInfo( v.Name )
		end
		
		if val == nil then continue end
		
		if CLIENT then
			if bit.band( v.Flags , SNOOP_SENDTIMED ) ~= 0 then
				if v.Time > CurTime() then continue end
				v.Time = CurTime()+ (v.Delay or SNOOP_DELAY_DEFAULT)
			end
			
			if bit.band( v.Flags , SNOOP_SENDONCE ) ~= 0 then
				if v.SentOnce then continue end
				v.SentOnce = true
			end
		end
		
		if CLIENT then
			LocalPlayer()._SnoopedInfo[v.Name] = val	--set it clientside right now
		end
		
		--before sending the value itself, we have to send the id of this current snooped info
		
		net.WriteInt( i, 8 )
		v.Write( val )
	end
	
	net.WriteInt( -1, 8 )	--end of the packet
	
	if CLIENT then
		net.SendToServer( )
	else
		net.Send( plys )
	end

end

--receiving this from the server or client
local function ReadClientInfo( len , senderply )
	local ply=net.ReadEntity()
	
	if SERVER then
		ply = senderply	--disregard whatever we read from the packet, it's supposedly NULL anyway
						--but we only read it to remove it from the buffer
						--plus it'd be exploitable otherwise
	end
	
	if not IsValid( ply ) or not ply:IsPlayer() then return end
	
	local snoopid = net.ReadInt( 8 )
	while ( snoopid ~= -1 ) do
		local v = info_tab[snoopid]
		if v then
			local val = v.Read()
			if not ply._SnoopedInfo then
				ply._SnoopedInfo = {}
			end
			ply._SnoopedInfo[v.Name] = val
		end
		snoopid = net.ReadInt( 8 )
	end
	
end
net.Receive("snoopinginfo", ReadClientInfo)


hook.Add("PlayerTick","SnoopedValuesUpdate",function(ply,mv)
	if not ply._NextSnoopedUpdate then ply._NextSnoopedUpdate = CurTime() end
	
	if ply:IsBot() then return end
	
	if ply._NextSnoopedUpdate < CurTime() then
		sendClientInfo(ply)
		if CLIENT then
			ply._NextSnoopedUpdate = CurTime() + 1
		else
			ply._NextSnoopedUpdate = CurTime() + 3
		end
	end
	
end)



