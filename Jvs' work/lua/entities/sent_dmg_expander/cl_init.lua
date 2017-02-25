include('shared.lua')
killicon.AddFont( "sent_dmg_reflex", "HL2MPTypeDeath", "9", Color( 255, 80, 0, 255 ) )
language.Add( "sent_dmg_reflex", "Damage Reflex" )
	
function ENT:Initialize()
end

function ENT:Draw()
self.Entity:DrawModel()

end
