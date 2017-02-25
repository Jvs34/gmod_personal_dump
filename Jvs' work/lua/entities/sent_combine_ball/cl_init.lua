
include( 'shared.lua' )
//i love you blackops
ENT.RenderGroup = RENDERGROUP_BOTH

local ballsprite1 = Material("effects/ar2_altfire1b")
local ballsprite2 = Material("effects/ar2_altfire1")
killicon.AddFont( "sent_combine_ball", "HL2MPTypeDeath", 8, Color( 255, 80, 0, 255 ) )
language.Add( "sent_combine_ball", "Combine ball" )
function ENT:Initialize()

end

function ENT:Draw()
	local scale=self:GetNWFloat("scale")
	local MyPos = self:GetPos()
	local size = 24*scale
	//if(self:GetNWBool("pickedup")==false)then
		render.SetMaterial(ballsprite1)
		render.DrawSprite(MyPos, size, size, Color(255,255,255,255))
		render.SetMaterial(ballsprite2)
		render.DrawSprite(MyPos, size, size, Color(255,255,255,255))
		
		if ( self.Entity:GetVelocity():Length() > 500 ) then
	
			for i = 1, 5 do
		
				render.DrawSprite( self.Entity:GetPos() + self.Entity:GetVelocity()*(i*-0.005), size/1.5, size/1.5, Color(255,255,255,70) )
			
			end
	
		end
end
