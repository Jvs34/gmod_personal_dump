include('shared.lua')
killicon.AddFont( "sent_life_leecher", "HL2MPTypeDeath", "9", Color( 255, 80, 0, 255 ) )
language.Add( "sent_life_leecher", "Life Leecher" )
	
function ENT:Initialize()
end

function ENT:Draw()
self.Entity:DrawModel()

end
