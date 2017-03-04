--this is a ghetto copy of gmod_hands


if IsValid(HANDSTEST) then
	HANDSTEST:Remove()
	HANDSTEST=NULL
end

HANDSTEST=ClientsideModel("models/weapons/c_arms_citizen.mdl")
--HANDSTEST=ClientsideModel(LocalPlayer():GetModel())

HANDSTEST:Spawn()
HANDSTEST:AddCallback("BuildBonePositions",function(self,bonenumbers)
	local bone=self:LookupBone("ValveBiped.Bip01_L_Upperarm")
	--self:ManipulateBonePosition(bone,Vector(5,5,5))
	self:ManipulateBoneAngles(bone,Angle(0,-150,30))
	self:ManipulateBoneScale(bone,Vector(1,1,1))

end)



--[[
HANDSTEST:AddEffects( EF_BONEMERGE )
HANDSTEST:SetParent( LocalPlayer():GetViewModel() )
HANDSTEST:SetNoDraw(true)


hook.Add("PostDrawViewModel","dickstest",function( vm, weapon )
		if ( IsValid( HANDSTEST ) ) then
			HANDSTEST:DrawModel()
		end

end)
]]

if not gayass then return end

local ENT={}
local ClassName="gay_hands"
ENT.Type			= "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup		= RENDERGROUP_OTHER

ENT.KeepBones={
	["ValveBiped.Bip01_Spine4"]=true,
	["ValveBiped.Bip01_L_Clavicle"]=true,
	["ValveBiped.Bip01_L_UpperArm"]=true,
	["ValveBiped.Bip01_L_Forearm"]=true,
	["ValveBiped.Bip01_L_Hand"]=true,
	["ValveBiped.Bip01_L_Finger4"]=true,
	["ValveBiped.Bip01_L_Finger41"]=true,
	["ValveBiped.Bip01_L_Finger42"]=true,
	["ValveBiped.Bip01_L_Finger3"]=true,
	["ValveBiped.Bip01_L_Finger31"]=true,
	["ValveBiped.Bip01_L_Finger32"]=true,
	["ValveBiped.Bip01_L_Finger2"]=true,
	["ValveBiped.Bip01_L_Finger21"]=true,
	["ValveBiped.Bip01_L_Finger22"]=true,
	["ValveBiped.Bip01_L_Finger1"]=true,
	["ValveBiped.Bip01_L_Finger11"]=true,
	["ValveBiped.Bip01_L_Finger12"]=true,
	["ValveBiped.Bip01_L_Finger0"]=true,
	["ValveBiped.Bip01_L_Finger01"]=true,
	["ValveBiped.Bip01_L_Finger02"]=true,
	["ValveBiped.Bip01_R_Clavicle"]=true,
	["ValveBiped.Bip01_R_UpperArm"]=true,
	["ValveBiped.Bip01_R_Forearm"]=true,
	["ValveBiped.Bip01_R_Hand"]=true,
	["ValveBiped.Bip01_R_Finger4"]=true,
	["ValveBiped.Bip01_R_Finger41"]=true,
	["ValveBiped.Bip01_R_Finger42"]=true,
	["ValveBiped.Bip01_R_Finger3"]=true,
	["ValveBiped.Bip01_R_Finger31"]=true,
	["ValveBiped.Bip01_R_Finger32"]=true,
	["ValveBiped.Bip01_R_Finger2"]=true,
	["ValveBiped.Bip01_R_Finger21"]=true,
	["ValveBiped.Bip01_R_Finger22"]=true,
	["ValveBiped.Bip01_R_Finger1"]=true,
	["ValveBiped.Bip01_R_Finger11"]=true,
	["ValveBiped.Bip01_R_Finger12"]=true,
	["ValveBiped.Bip01_R_Finger0"]=true,
	["ValveBiped.Bip01_R_Finger01"]=true,
	["ValveBiped.Bip01_R_Finger02"]=true,
	["ValveBiped.Bip01_L_Ulna"]=true,
	["ValveBiped.Bip01_R_Ulna"]=true,
	["ValveBiped.Bip01_R_Wrist"]=true,
}


function ENT:Initialize()
	
	hook.Add( "OnViewModelChanged", self, self.ViewModelChanged )

	self:SetNotSolid( true )
	self:DrawShadow( false )
	self:SetTransmitWithParent( true ) -- Transmit only when the viewmodel does!
	
	if CLIENT then
		self:AddCallback("BuildBonePositions",self.BuildBones)
	end
	
end

function ENT:DoSetup( ply )

	-- Set these hands to the player
	ply:SetHands( self )
	self:SetOwner( ply )

	-- Which hands should we use?
	local info = player_manager.RunClass( ply, "GetHandsModel" )
	if ( info ) then
		self:SetModel( ply:GetModel() )
		self:SetSkin( info.skin )
		self:SetBodyGroups( info.body )
	end

	-- Attach them to the viewmodel
	local vm = ply:GetViewModel( 0 )
	self:AttachToViewmodel( vm )

	vm:DeleteOnRemove( self )
	ply:DeleteOnRemove( self )

end

function ENT:BuildBones(numberbones)
	for i=0,self:GetBoneCount()-1 do
		local bonename=self:GetBoneName(i)
		
		if not self.KeepBones[bonename] then
			local bm=self:GetBoneMatrix(i)
			if not bm then continue end
			bm:Scale(vector_origin)
			self:SetBoneMatrix(i,bm)
		end
		
	end
end

function ENT:GetPlayerColor()
	
	--
	-- Make sure there's an owner and they have this function
	-- before trying to call it!
	--
	local owner = self:GetOwner()
	if ( !IsValid( owner ) ) then return end
	if ( !owner.GetPlayerColor ) then return end
	
	return owner:GetPlayerColor()

end

function ENT:ViewModelChanged( vm, old, new )

	-- Ignore other peoples viewmodel changes!
	if ( vm:GetOwner() != self:GetOwner() ) then return end

	self:AttachToViewmodel( vm )

end

function ENT:AttachToViewmodel( vm )
	
	self:AddEffects( EF_BONEMERGE )
	self:SetParent( vm )
	self:SetMoveType( MOVETYPE_NONE )

	self:SetPos( Vector( 0, 0, 0 ) )
	self:SetAngles( Angle( 0, 0, 0 ) )

end
if SERVER then
	concommand.Add("give_gayhands", function(ply,command,args)
		if not IsValid(ply) or not ply:Alive() then return end
		local oldhands = ply:GetHands();
		if ( IsValid( oldhands ) ) then
			oldhands:Remove()
		end

		local hands = ents.Create( "gay_hands" )
		if ( IsValid( hands ) ) then
			hands:DoSetup( ply )
			hands:Spawn()
		end	
		
	end,function() end, nil,0)
end

scripted_ents.Register(ENT,ClassName,true)