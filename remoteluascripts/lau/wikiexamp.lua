
local modelexample = ClientsideModel( "models/thrusters/jetpack.mdl" )
modelexample:SetNoDraw( true )

local offsetvec = Vector( 3 , -5.6 , 0 )
local offsetang = Angle( 180 , 90 , -90 )

hook.Add( "PostPlayerDraw" , "manual_model_draw_example" , function( ply )
	local boneid = ply:LookupBone( "ValveBiped.Bip01_Spine2" )
	
	if not boneid then
		return
	end
	
	local matrix = ply:GetBoneMatrix( boneid )
	
	if not matrix then 
		return 
	end
	
	local newpos , newang = LocalToWorld( offsetvec , offsetang , matrix:GetTranslation() , matrix:GetAngles() )
	
	modelexample:SetPos( newpos )
	modelexample:SetAngles( newang )
	modelexample:SetupBones()
	modelexample:DrawModel()
	
end)