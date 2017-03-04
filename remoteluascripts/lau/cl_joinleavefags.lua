local PANEL = {}

function PANEL:Init()

	self.LabelName = vgui.Create( "DLabel", self )
	self.LabelName:SetFont( "ScoreboardDefault" )
	self.LabelName:Dock( FILL )
	self.LabelName:DockMargin( 8, 0, 0, 0 )
	self.LabelName:SetTextColor( Color(51, 181, 229, 255) )
	
	self.ActionType = vgui.Create( "DLabel", self )
	self.ActionType:SetFont( "ScoreboardDefault" )
	self.ActionType:Dock( RIGHT )
	self.ActionType:SetText("joined")
	self.ActionType:DockMargin( 0,0, 0, 0 )
	self.ActionType:SetTextColor( Color(51, 181, 229, 255) )

	
	self.Avatar = vgui.Create( "AvatarImage", self )
	self.Avatar:Dock( LEFT );
	self.Avatar:SetSize( 32, 32 )

	self.Color = color_transparent

	self:SetSize( 300, 32 + 8 )
	self:DockPadding( 4, 4, 4, 4 )
	self:DockMargin( 2, 2, 2, 2 )
	self:Dock( TOP )

end

function PANEL:Setup( ply,action, ftime, nick, steamid64)

	if IsValid(ply) and ply:IsPlayer() then
		self.ply = ply
		self.LabelName:SetText( ply:Nick() )
		self.Avatar:SetPlayer( ply )
		if action then
			self.ActionType:SetText(action)
		end
	else
		self.LabelName:SetText( nick )
		self.Avatar:SetSteamID( steamid64 )
		if action then
			self.ActionType:SetText(action)
		end
	end
	
	self.Color =Color( 230, 255, 230, 255 )
	self.MainColor=Color( 255, 255, 255, 255 )
	self.AdminColor=Color( 80, 255, 80, 255 )
	self.FaggotColor=Color( 255, 116, 250, 255 )
	self:InvalidateLayout()

	if ftime and ftime~=-1 then
		self:StartFadeOut(ftime)
	end
end

function PANEL:Paint( w, h )
	if IsValid(self.ply ) then
		if self.ply:IsAdmin() then
			self.Color=self.AdminColor
		end
		
		if self.ply:GetNWBool("Faggot") then
			self.Color=self.FaggotColor
		end
		
	end
	draw.RoundedBox( 4, 0, 0, w, h, self.Color )

end

function PANEL:Think( )
	if IsValid(self.ply) then
		if self.LabelName then
			self.LabelName:SetText( self.ply:Nick())
		end
	end
	
	if ( self.fadeAnim ) then
		self.fadeAnim:Run()
	end

end

function PANEL:StartFadeOut(ftime)
	self.fadeAnim = Derma_Anim( "FadeOut", self, self.FadeOut )
	self.fadeAnim:Start( ftime )
end

function PANEL:FadeOut( anim, delta, data )
	
	if ( anim.Finished ) then

		self:Remove()
		return 
	end
			
	self:SetAlpha( 255 - (255 * delta) )

end

derma.DefineControl( "FriendNotify", "", PANEL, "DPanel" )



function AddPlayerJoin( ply )

	if ( not ValidPanel( g_friendsstatus ) ) then return end
	
	if ( not IsValid( ply ) ) then return end
	
	

	local pnl = g_friendsstatus:Add( "FriendNotify" )
	
	surface.PlaySound("Friends/friend_online.wav")
	
	pnl:Setup( ply,"joined",20 )

	
	

end

function AddPlayerAction( nick,action,steamid )

	if ( not ValidPanel( g_friendsstatus ) ) then return end

	local pnl = g_friendsstatus:Add( "FriendNotify" )
	
	pnl:Setup( nil,action,20, nick,steamid )

end



local function CreateJoinVGUI()
	if ValidPanel(g_friendsstatus) then
		g_friendsstatus:Remove()
	end	
	g_friendsstatus = vgui.Create( "DPanel" )

	g_friendsstatus:ParentToHUD()
	g_friendsstatus:SetPos( 20, 20 )
	g_friendsstatus:SetSize( 250, ScrH() - 300 )
	g_friendsstatus:SetDrawBackground( false )

end


CreateJoinVGUI()

gameevent.Listen( 'player_activate' )
hook.Add("player_activate","joinmsg",function( data )
	local ply = Player( data.userid )
	if IsValid(ply) and ply~=LocalPlayer() and not ply._ShownJoinMessage then
		AddPlayerJoin( ply )
		ply._ShownJoinMessage=true
	end
end)
