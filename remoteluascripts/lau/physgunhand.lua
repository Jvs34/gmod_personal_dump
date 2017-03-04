if SERVER then return end

if IsValid( LocalPlayer() ) then
	if IsValid( LocalPlayer()._PhysgunHand ) then
		LocalPlayer()._PhysgunHand:Remove()
		LocalPlayer()._PhysgunHand = nil
	end
end

local laser = CreateMaterial("physgunlaser",
	"UnlitGeneric",{
		['$basetexture' ] = "sprites/laser",
		[ '$nopicmip' ] = "1",
		[ '$additive' ] = "1",
		[ '$vertexcolor' ] = "1",
		[ '$vertexalpha' ] = "1",
	}
)

local function BuildPhysgunHandBones( self , numbones )
	self:ManipulateBonePosition( 0 , Vector( 10 , 0 , 10 ) )
	
	--self:ManipulateBonePosition( self:LookupBone( "ValveBiped.Bip01_R_Hand" ) , Vector( 0 , 0 , 10 ) )
	for i = 0 , numbones - 1 do
		local bm = self:GetBoneMatrix( i )
		if bm then
			local bonename = self:GetBoneName( i )
			if string.find( bonename , "_L_" ) then
				bm:SetScale( vector_origin )
			end
			self:SetBoneMatrix( i , bm )
		end
	end
end

hook.Add( "DrawPhysgunBeam" , "Physgun Hand" , function( ply, weapon, enabled, target, bone, hitPos )
	if not IsValid( ply._PhysgunHand ) then
		if IsValid( ply:GetHands() ) then
			ply._PhysgunHand = ClientsideModel( ply:GetHands():GetModel() )
			ply._PhysgunHand:SetNoDraw( true )
			ply._PhysgunHand:AddCallback( "BuildBonePositions" , BuildPhysgunHandBones )
		end
	end
	
	local endPos = ply:GetEyeTrace().HitPos
	
	if IsValid( ply._PhysgunHand ) then
		ply._PhysgunHand:DrawModel()
	end
	
	
	return false
end)