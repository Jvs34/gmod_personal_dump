include('shared.lua')
ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT
include('init.lua')

surface.CreateFont( "Tahoma", 16, 1000, true, false, "CoolText")
surface.CreateFont("HalfLife2", 44, 400, true, false, "Hl2PStatus")

function ENT:Initialize()
	self.Monitor=self:GetNWEntity("monitor");
end
startx,starty=-112,-104


function ENT:DrawCamText(text,font,x,y,Color)
	surface.SetFont(font)
	surface.SetTextColor( Color )
	surface.SetTextPos( x,y )
	surface.DrawText(text)
end
local POSX=100;
function ENT:Draw()
self:DrawModel();
	local rotation = Vector(-90,90,0)
	local angle = self.Monitor:GetAngles()
	angle:RotateAroundAxis(angle:Right(), rotation.x)
	angle:RotateAroundAxis(angle:Up(), 	rotation.y)
	angle:RotateAroundAxis(angle:Forward(), rotation.z)
	cam.Start3D2D(self.Monitor:GetPos()+(self.Monitor:GetForward()*0.3)+(self.Monitor:GetUp()*11.8)+(self.Monitor:GetRight()*-2.35),angle,0.12)
				if self:GetNWEntity("driver")!= nil && IsValid(self:GetNWEntity("driver")) then
				self:DrawCamText(self:GetNWEntity("driver"):Nick(),"CoolText", startx+5,starty-2, Color(255, 220, 0, 255))
				self:DrawCamText("+","Hl2PStatus", startx+5,starty,Color(37, 198, 22, 255))
				self:DrawCamText(self:GetNWEntity("driver"):Health(),"CoolText", startx+30,starty+20, Color(255, 220, 0, 255))
				self:DrawCamText("*","Hl2PStatus", startx+5,starty+20,Color(0, 135, 255, 255))
				self:DrawCamText(self:GetNWEntity("driver"):Armor(),"CoolText", startx+30,starty+40, Color(255, 220, 0, 255))
						
				end
				if self:GetNWEntity("passenger")!= nil && IsValid(self:GetNWEntity("passenger")) then
				self:DrawCamText(self:GetNWEntity("passenger"):Nick(),"CoolText", startx+5+POSX,starty-2, Color(255, 220, 0, 255))
				self:DrawCamText("+","Hl2PStatus", startx+5+POSX,starty,Color(37, 198, 22, 255))
				self:DrawCamText(self:GetNWEntity("passenger"):Health(),"CoolText", startx+30+POSX,starty+20, Color(255, 220, 0, 255))
				self:DrawCamText("*","Hl2PStatus", startx+5+POSX,starty+20,Color(0, 135, 255, 255))
				self:DrawCamText(self:GetNWEntity("passenger"):Armor(),"CoolText", startx+30+POSX,starty+40, Color(255, 220, 0, 255))
				
				end
	cam.End3D2D()

end

