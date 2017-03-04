local ClassName = "sent_stalker"
local ENT = {}

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Admin Stalker"
ENT.Category = "Jvs"
ENT.Author = "Jvs"
ENT.Spawnable = true  
ENT.AdminOnly = false  

if SERVER then
	AccessorFunc( ENT , "_apikey" , "APIKey" )
else
	AccessorFunc( ENT , "_stalkerpanel" , "StalkerPanel" )
end

ENT.SteamAPI = {
	MainUrl = "http://api.steampowered.com/",
	GetPlayerSummaries = "ISteamUser/GetPlayerSummaries/v0002/"
}

ENT.Sides={
	{
		scale = 0.12,
		pos = Vector( 24 , 48 , 1.6 ),
		ang = Angle( 0 , -90 , 0 ),
		maxw = 800,
		maxh = 400,
	},
	--[[
	{
		scale = 0.12,
		pos = Vector( 24 , 48 , -1.8 ),
		ang = Angle( 180 , 0 , 0 ),
	},
	]]
}

function ENT:SpawnFunction( ply, tr )
	if not tr.Hit then 
		return 
	end

	local spawnpos = tr.HitPos + tr.HitNormal * 25

	local ent = ents.Create( ClassName )
	ent:SetPos( spawnpos )
	ent:Spawn()
	return ent
end

function ENT:SetupDataTables()
	self:CreateNWVarsAccessor( "Bool" , "HasAPIKey" )
	self:CreateNWVarsAccessor( "Float" , "NextAPICheck" )
	self:CreateNWVarsAccessor( "String" , "PlayerSteamID" )
	
	self:CreateNWVarsAccessor( "Int" , "PlayerStatus" )
	self:CreateNWVarsAccessor( "Int" , "PlayerNick" )
	self:CreateNWVarsAccessor( "Int" , "PlayerGameID" )
	self:CreateNWVarsAccessor( "Int" , "PlayerProfileVisibility" )
	
	self:CreateNWVarsAccessor( "String" , "PlayerGameName" )
end

function ENT:CreateNWVarsAccessor( accessortype , accessorname )
	local nwversion = "NW2"
	
	if not self["Set"..nwversion..accessortype] or not self["Get"..nwversion..accessortype] then
		ErrorNoHalt( "Cannot find accessor Set/Get "..nwversion..accessortype ) 
		return
	end
	
	self["Set"..accessorname] = function( ent , val )
		ent["Set"..nwversion..accessortype]( ent , accessorname , val ) 
	end
	
	self["Get"..accessorname] = function( ent )
		return ent["Get"..nwversion..accessortype]( ent , accessorname )
	end
	
end

function ENT:Initialize()
	if SERVER then
		self:SetModel( "models/hunter/plates/plate1x2.mdl" )
		self:SetAPIKey( "5329841E768903C147777E26FB355792" )
		self:SetPlayerSteamID( "76561197998646590" ) --"STEAM_0:0:19190431" ) --76561197998646590
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
	end
end

function ENT:Think()
	self:HandleData()
	
	if SERVER then
		self:HandleRequests()
	else
		self:HandlePanel()
	end
	
	

end

if SERVER then
	function ENT:HandleRequests()
		--can't send requests if we don't have an API key
		if not self:GetHasAPIKey() then
			return
		end
		
		if self:GetNextAPICheck() < CurTime() then
			self:SteamGetPlayerSummaries()
			self:SetNextAPICheck( CurTime() + 10 )
		end
		
	end
	
	function ENT:SteamGetPlayerSummaries()
		--this is a get
		local url = self.SteamAPI.MainUrl..self.SteamAPI.GetPlayerSummaries
		local getrequest = "?key="..self:GetAPIKey().."&steamids="..self:GetPlayerSteamID()
		
		http.Fetch( url..getrequest , 
		function( body , bodylen , headers , code )
			local jsonbody = util.JSONToTable( body )
			if IsValid( self ) and jsonbody then
				self:SteamGetPlayerSummariesCallback( jsonbody )
			end
		end
		, nil )
	end
	
	function ENT:SteamGetPlayerSummariesCallback( jsonbody )
		local players = jsonbody.response.players
		
		local ply = players[1]
		
		if not ply then
			return
		end
		
		--fill in the data
		self:SetPlayerProfileVisibility( ply.communityvisibilitystate )
		self:SetPlayerStatus( ply.profilestate )
		self:SetPlayerNick( ply.personaname )
		self:SetPlayerGameID( ply.gameid )
		self:SetPlayerGameName( ply.gameextrainfo )
	end
else
	function ENT:HandlePanel()
		--only on me for now
		if IsValid( LocalPlayer() ) then--and LocalPlayer():SteamID64() == self:GetPlayerSteamID() then
			
			if not ValidPanel( self:GetStalkerPanel() ) then
				local pnl = vgui.Create( "derma_stalkerpanel" )
				pnl:SetOwnerEntity( self )
				pnl:ParentToHUD()
				pnl:SetWidth( 800 )
				pnl:SetHeight( 400 )
				pnl:SetVisible( true )
				self:SetStalkerPanel( pnl )
			end

		end
	end
	
	function ENT:Draw( flags )
		self:DrawModel()
		
		for i , v in pairs( self.Sides ) do
			local pos , ang = LocalToWorld( v.pos or vector_origin , v.ang or angle_zero , self:GetPos() ,self:GetAngles() )
			cam.Start3D2D( pos , ang , v.scale or 0.15 )
				render.PushFilterMag( TEXFILTER.ANISOTROPIC )
				render.PushFilterMin( TEXFILTER.ANISOTROPIC )
				
				--[[
				surface.SetDrawColor( 0 , 0 ,  0 , 255 )
				surface.DrawRect( 0 , 0 , v.maxw , v.maxh )
				]]
				surface.SetFont( "Default" )
				surface.SetTextColor( 255, 255, 255, 255 )
				surface.SetTextPos( 0 , 0 )
				surface.DrawText( "im gay" )
				
				render.PopFilterMin()
				render.PopFilterMag()
			cam.End3D2D()
		end
	end
end

function ENT:HandleData()
	if SERVER then
		self:SetHasAPIKey( self:GetAPIKey() ~= nil )
	else
	
	end
end

function ENT:OnRemove()
	if CLIENT then
		if ValidPanel( self:GetStalkerPanel() ) then
			self:GetStalkerPanel():SetOwnerEntity( NULL )
			self:GetStalkerPanel():Remove()
			self:SetStalkerPanel( nil )
		end
	else
	
	end
end

scripted_ents.Register( ENT , ClassName , true )

if CLIENT then

	local PANEL = {}
	
	AccessorFunc( PANEL , "_ownerentity" ,	"OwnerEntity" )

	function PANEL:Init()
		--create the panels
	end

	function PANEL:Spawn()
	
	end
	
	function PANEL:Think()
		--update the info here
		if IsValid( self:GetOwnerEntity() ) then
			
		else
			self:Remove()
		end
	end
	
	function PANEL:PerformLayout( x , y )
		--move the panels here to where they should be
	end
	
	function PANEL:Paint( w , h )
		surface.SetDrawColor( 0 , 0 ,  0 , 255 )
		surface.DrawRect( 0 , 0 , w , h )
	end


	derma.DefineControl( "derma_stalkerpanel", "A panel that stalks the guy that is set to", PANEL, "DPanel" )

end