include('shared.lua')
ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT
include('init.lua')

surface.CreateFont( "Tahoma", 25, 1000, true, false, "RadioText1")
surface.CreateFont( "Tahoma", 14, 1000, true, false, "RadioText2")
function ENT:Initialize()
	self.DontDrawSpeaker=true;
	self.Station = self.Entity:GetNetworkedInt("station")
	self.Speaking= self.Entity:GetNWBool("tds_speaking")
	self.Radios   = self.Entity:GetNetworkedInt("radios")
end	
startx,starty=-112,-104

function ENT:DrawCamText(text,font,x,y,Color)
	surface.SetFont(font)
	surface.SetTextColor( Color )
	surface.SetTextPos( x,y )
	surface.DrawText(text)
end

local ExampleTexture = surface.GetTextureID( "gui/silkicons/sound" );
function ENT:Draw()
self:DrawModel();

	local rotation = Vector(-90,90,0)
	local angle = self:GetAngles()
	angle:RotateAroundAxis(angle:Right(), rotation.x)
	angle:RotateAroundAxis(angle:Up(), 	rotation.y)
	angle:RotateAroundAxis(angle:Forward(), rotation.z)
	cam.Start3D2D(self:GetPos()+(self:GetForward()*9)+(self:GetUp()*11.8)+(self:GetRight()),angle,0.12)
				self:DrawCamText("Channel "..self.Station,"RadioText1", startx+80,starty+75, Color( 255, 220,0, 255 ))
				self:DrawCamText(self.Radios.." radios on this channel.","RadioText2", startx+75,starty+100, Color( 255, 220,0, 255 ))
				if self.Speaking then
				surface.SetDrawColor( 255, 255, 255, 255 );
				surface.SetTexture( ExampleTexture );
				surface.DrawTexturedRect(startx+65,starty+120, 64,64 );
				end
	cam.End3D2D()
end

function ENT:Think()
	self.Station  = self.Entity:GetNetworkedInt("station")
	self.Radios   = self.Entity:GetNetworkedInt("radios")
	self.Speaking = self.Entity:GetNWBool("tds_speaking")


end

