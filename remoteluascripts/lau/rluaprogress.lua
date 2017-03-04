if SERVER then
	AddCSLuaFile()
	return
end

local PANEL = {}


surface.CreateFont( "WorkshopLarge",
{
	font		= "Helvetica",
	size		= 19,
	antialias	= true,
	weight		= 800
})

local matProgressCog	= Material( "gui/progress_cog.png", "nocull smooth mips" )
local matHeader			= Material( "gui/steamworks_header.png" )

AccessorFunc( PANEL, "m_bDrawProgress", 			"DrawProgress", 			FORCE_BOOL )

function PANEL:Init()

	self.Label = self:Add( "DLabel" )
	self.Label:SetText( "Updating Subscriptions.." )
	self.Label:SetFont( "WorkshopLarge" )
	self.Label:SetTextColor( Color( 255, 255, 255, 200 ) )
	self.Label:Dock( TOP )
	self.Label:DockMargin( 16, 10, 16, 8 )
	self.Label:SetContentAlignment( 5 )

	self.ProgressLabel = self:Add( "DLabel" )
	self.ProgressLabel:SetText( "-" )
	self.ProgressLabel:SetContentAlignment( 7 )
	self.ProgressLabel:SetVisible( false )
	self.ProgressLabel:SetTextColor( Color( 255, 255, 255, 50 ) )

	self.TotalsLabel = self:Add( "DLabel" )
	self.TotalsLabel:SetText( "File 1 or 30" )
	self.TotalsLabel:SetContentAlignment( 7 )
	self.TotalsLabel:SetVisible( false )
	self.TotalsLabel:SetTextColor( Color( 255, 255, 255, 50 ) )
	
	self:SetDrawProgress( false )

	self.Progress = 0
	self.TotalProgress = 0
		
end

function PANEL:PerformLayout()

	self:SetSize( 500, 80 )
	self:Center()
	self:AlignBottom( 16 )

	self.ProgressLabel:SetSize( 100, 20 )
	self.ProgressLabel:SetPos( self:GetWide() - 100, 40 )

	self.TotalsLabel:SetSize( 100, 20 )
	self.TotalsLabel:SetPos( self:GetWide() - 100, 60 )
	
end

function PANEL:Spawn()

	self:PerformLayout()

end

function PANEL:StartDownloading( id, steamid, title, iSize )

	self.Label:SetText( "Downloading " .. title )
	
	self:SetDrawProgress( true )
	self.ProgressLabel:Show()
	self.ProgressLabel:SetText( "" )

	self.TotalsLabel:Show()

	self:UpdateProgress( 0, iSize )
	
end

function PANEL:FinishedDownloading( id, title )
	
	self.Progress = 0

	
end

function PANEL:Think()
	if ( self.fadeAnim ) then
		self.fadeAnim:Run()
	end
end

function PANEL:Paint()

	DisableClipping( true )
		draw.RoundedBox( 4, -1, -1, self:GetWide()+2, self:GetTall()+2, Color( 0, 0, 0, 255 ) )
	DisableClipping( false )

	draw.RoundedBox( 4, 0, 0, self:GetWide(), self:GetTall(), Color( 50, 50, 50, 255 ) )
	
	surface.SetDrawColor( 0, 0, 0, 100 )
	surface.SetMaterial( matProgressCog )
	surface.DrawTexturedRectRotated( 0, 32, 64 * 4, 64 * 4, SysTime() * -20 )
	
	if ( self:GetDrawProgress() ) then
	
		-- Overall progress
		local off = 0
		local w = (self:GetWide() - 64 - 64 - 100)
		local x = 80
		
		draw.RoundedBox( 4, x+32 + off, 44 + 18, w, 10, Color( 0, 0, 0, 150 ) )
		draw.RoundedBox( 4, x+33 + off, 45 + 18, w * math.Clamp( self.TotalProgress, 0.05, 1 )-2, 8, Color( 255, 255, 255, 200 ) )

		-- Current file Progress
		draw.RoundedBox( 4, x+32, 40, w, 15, Color( 0, 0, 0, 150 ) )
		draw.RoundedBox( 4, x+33, 41, w * math.Clamp( self.Progress, 0.05, 1 )-2, 15-2, Color( 255, 255, 255, 200 ) )
		
	end
	
	-- Workshop LOGO
	--[[
	DisableClipping( true )

		local x = -8

		surface.SetDrawColor( 255, 255, 255, 255 )
		surface.SetMaterial( matHeader )
		surface.DrawTexturedRect( x, -22, 128, 32 )
		
		surface.SetDrawColor( 255, 255, 255, math.random( 0, 255 ) )
		surface.DrawTexturedRect( x, -22, 128, 32 )

	DisableClipping( false )
	]]
end

function PANEL:UpdateProgress( downloaded, expected )

	self.Progress = downloaded / expected

	if ( self.Progress > 0 ) then
		self.ProgressLabel:SetText( Format( "%.0f%%", (self.Progress) * 100 ) .. " of " .. tostring( expected ) )
	else
		self.ProgressLabel:SetText( tostring( expected ) )
	end

end

function PANEL:UpdateTotalProgress( completed, iTotal )

	self.TotalsLabel:SetText( "Script "..completed.." of "..iTotal )
	self.TotalProgress = completed / iTotal

end

function PANEL:FadeAway(secs)
	self.fadeAnim = Derma_Anim( "FadeOut", self, self.FadeOut )
	self.fadeAnim:Start( secs )
end

function PANEL:StopFading()
	self:Show()
	self:SetAlpha( 255 )
	if self.fadeAnim then
		self.fadeAnim:Stop()
		self.fadeAnim=nil
	end
end

function PANEL:FadeOut( anim, delta, data )

	if ( anim.Finished ) then
		self:Hide()
		self:SetAlpha( 255)
		return
	end
			
	self:SetAlpha( 255 - (255 * delta) )

	
end

derma.DefineControl( "RLuaProgressPanel", "", PANEL, "DPanel" )



if remotelua_gui then remotelua_gui:Remove() remotelua_gui=nil end

hook.Add("RemoteLuaProgress","Remoteluaprogress",function(id,curblock,numblocks)
	if remotelua_gui==nil then
		remotelua_gui = vgui.Create( "RLuaProgressPanel" )
		remotelua_gui:ParentToHUD()
		remotelua_gui:UpdateTotalProgress( 1,1 )
		remotelua_gui:StartDownloading(1,nil, "Extra Lua Scripts", 0 )
	end
	
	
	
	if curblock==numblocks then
		if numblocks==1 then
			--show ourselves anyway first and then fade
			remotelua_gui:Show()
		end
		remotelua_gui:FadeAway(3)
	else
		remotelua_gui:StopFading()
	end
	
	remotelua_gui:UpdateProgress( curblock, numblocks )
end)