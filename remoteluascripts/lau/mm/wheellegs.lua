
if IsValid( BREEN ) then
	BREEN:Remove()
end

local rembones = {
	"ValveBiped.Bip01_R_Thigh",
	"ValveBiped.Bip01_R_Calf",
	"ValveBiped.Bip01_R_Foot",
	"ValveBiped.Bip01_R_Toe0",
	
	"ValveBiped.Bip01_L_Thigh",
	"ValveBiped.Bip01_L_Calf",
	"ValveBiped.Bip01_L_Foot",
	"ValveBiped.Bip01_L_Toe0",
}

BREEN = ClientsideModel( "models/player/breen.mdl" )
BREEN:SetSequence( 217 )

for i , v in pairs( rembones ) do
	local boneid = BREEN:LookupBone( v )
	print( boneid )
	if boneid and boneid ~= -1 then
		
		print( v )
		BREEN:ManipulateBoneScale( boneid , Vector( 0 , 0 , 0 ) )
	end
end