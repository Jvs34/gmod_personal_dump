local canmodel = ClientsideModel( "models/props_junk/PopCan01a.mdl" )
canmodel:SetNoDraw( true )

local cmodels = {
	{
		OffsetVec = Vector( 0 , -10 , 0 ),
		OffsetAng = angle_zero,
		Skin = 0,
	},
	{
		OffsetVec = Vector( 0 , 0 , 0 ),
		OffsetAng = angle_zero,
		Skin = 1,
	},
	{
		OffsetVec = Vector( 0 , 10 , 0 ),
		OffsetAng = angle_zero,
		Skin = 2,
	}
}

hook.Add( "PostPlayerDraw" , "CANTEST" , function( ply )
	local pos = ply:EyePos() + ply:GetAimVector() * 20
	local ang = ply:EyeAngles()
	
	for i , v in pairs( cmodels ) do
		local mypos , myang = LocalToWorld( v.OffsetVec , v.OffsetAng , pos , ang )
		
		--canmodel:SetPos( mypos )
		--canmodel:SetAngles( myang )
		canmodel:SetRenderOrigin( mypos )
		canmodel:SetRenderAngles( myang )
		canmodel:SetSkin( v.Skin )
		canmodel:SetupBones()
		canmodel:DrawModel()
	end
end)