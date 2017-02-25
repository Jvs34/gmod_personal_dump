include('shared.lua')
ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT
include('init.lua')


function ENT:Initialize()

end

function ENT:Draw()

	if ( LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 256 ) then
		AddWorldTip( self.Entity:EntIndex(), "Health: "..self:GetNetworkedInt("hl"), 0.5, self.Entity:GetPos(), self.Entity  )
	end


self:DrawModel();
end