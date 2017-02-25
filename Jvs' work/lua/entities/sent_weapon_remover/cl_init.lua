include('shared.lua')

function ENT:Initialize()
end

function ENT:Draw()
self.Entity:DrawModel()
	if ( LocalPlayer():GetEyeTrace().Entity == self.Entity && EyePos():Distance( self.Entity:GetPos() ) < 256 ) then
		AddWorldTip( self.Entity:EntIndex(), "Battery: "..self:GetNetworkedInt("sb"), 0.5, self.Entity:GetPos(), self.Entity  )
	end
end
