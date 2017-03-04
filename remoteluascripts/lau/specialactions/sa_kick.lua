
newsa=nil
newsa=SA:New("Kick","sa_kick","It kicks shit")


newsa.sequence="adoorkick"
newsa.KeepBones={
"ValveBiped.Bip01_R_Thigh",
"ValveBiped.Bip01_R_Calf",
"ValveBiped.Bip01_R_Foot",
"ValveBiped.Bip01_R_Toe0",
}
--self here is actually the leg entity
function newsa:BuildLegBones()
	local thigh=self:LookupBone("ValveBiped.Bip01_R_Thigh")
	if not thigh then return end
	
	local pos,ang=self:GetBonePosition(thigh)
	
	for bone=0,self:GetBoneCount()-1 do
	
		local bonename=self:GetBoneName(bone)
		if not bonename then continue end
		
		if bonename=="ValveBiped.Bip01_R_Thigh" or
		bonename=="ValveBiped.Bip01_R_Calf" or
		bonename=="ValveBiped.Bip01_R_Foot" or
		bonename=="ValveBiped.Bip01_R_Toe0" then
				
		else
			local bonematrix=self:GetBoneMatrix(bone)
			if not bonematrix then continue end
			bonematrix:Scale(vector_origin)
			bonematrix:SetTranslation(pos)
			self:SetBoneMatrix(bone,bonematrix)
		end
	end
	
		
end

function newsa:Initialize(entity,owner)
	if SERVER then return end
	entity.copanimation=ClientsideModel("models/Police.mdl")
	entity.copanimation:SetMaterial("engine/occlusionproxy" )
	entity.copanimation:SetNoDraw(true)
	entity.copanimation:ResetSequence(entity.copanimation:LookupSequence(self.sequence))
	
	entity.playermodel=ClientsideModel("models/player/breen.mdl")
	entity.playermodel:SetParent(entity.copanimation)
	entity.playermodel:AddEffects(EF_BONEMERGE)
	entity.playermodel:AddCallback("BuildBonePositions",self.BuildLegBones)
	entity.playermodel:SetOwner(owner)
	entity.playermodel.GetPlayerColor=function(self) return self:GetOwner():GetPlayerColor() end
	entity.playermodel:SetNoDraw(true)
	

end

function newsa:Deinitialize(entity,owner)
	if SERVER then return end
	--destroy em in here
	if IsValid(entity.copanimation) then
		entity.copanimation:Remove()
	end
	
	if IsValid(entity.playermodel) then
		entity.playermodel:Remove()
	end

end

function newsa:ResetVars(entity,owner)
	entity:SetActionFloat1(CurTime()+1)	--nextattack
	entity:SetActionBool1(false)
	entity:SetActionEntity1(NULL)
	entity:SetNextAction(CurTime()+1)
end


function newsa:Attack(entity,owner)
	--let us kick in vain multiple times and reset the kick animation as well
	
	--if entity:GetActionBool1() then return end
	owner:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM,123)
	entity:SetActionBool1(true)
	entity:SetActionFloat1(CurTime()+0.7)
	entity:SetNextAction(CurTime()+1)
	
end






function newsa:KickAttack(entity,owner)
	owner:EmitSound("citadel.br_no")
end

function newsa:HandleKickAnimation(entity,owner)
	--[[
	if not entity:GetActionBool1() then
		entity.copanimation:SetCycle(0)
		return
	end
	]]
	
	if entity.copanimation:GetCycle()>0.25 then
		entity.copanimation:SetCycle(0.05)
	end
	
	entity.copanimation:FrameAdvance(FrameTime())
end

newsa.Offset={
	Vec=Vector(15,-30,-48),
	Ang=Angle(-15,20,-40)
}

function newsa:PostDrawViewModel(entity,owner,weapon,viewmodel)
	if not IsValid(viewmodel) then	return	end
	
	if IsValid(entity.playermodel) and IsValid(entity.copanimation) then
	
		self:HandleKickAnimation(entity,owner)
		
		local thigh=entity.copanimation:LookupBone("ValveBiped.Bip01_R_Thigh")
		if not thigh then return end
		
		local pos,ang=entity.copanimation:GetBonePosition(thigh)
		
		
		
		
		
		local vpos=viewmodel:GetPos()
		local vang=viewmodel:GetAngles()
		
		local endpos,endang=LocalToWorld(self.Offset.Vec,self.Offset.Ang,vpos,vang)
		
		
		entity.copanimation:SetRenderOrigin(endpos)
		entity.copanimation:SetRenderAngles(endang)
		
		entity.copanimation:DrawModel()
		
		entity.playermodel:DrawModel()
		
	end
	

end


newsa.AnimationOffset={
	n=-20,
	pos=Vector(0,-20,0),
	ang=angle_zero,
}
function newsa:PrePlayerDraw(entity,owner)
	
	if IsValid(entity.playermodel) and IsValid(entity.copanimation) then
	
		self:HandleKickAnimation(entity,owner)
		
		--entity.copanimation:SetRenderOrigin(owner:GetPos())
		--entity.copanimation:SetRenderAngles(owner:GetAngles())
		entity.copanimation:DrawModel()
		entity.playermodel:DrawModel()

		for i,v in pairs(self.KeepBones) do
			local bone=owner:LookupBone(v)
			if not bone then continue end
			
			local p,a=entity.copanimation:GetBonePosition(entity.copanimation:LookupBone(v))
			--p,a=LocalToWorld(self.AnimationOffset.pos,self.AnimationOffset.ang,p,a)
			local plyang=owner:GetAngles()
			
			--owner:SetBonePosition(bone,p,a)
			
		end
		
		
		
	end
	
end

function newsa:IsKicking(entity,owner)

end

function newsa:SetupMove(entity,owner,data,cmddata)

end

function newsa:CalcMainActivity(entity,owner,velocity)
	//if self:IsKicking() then
		owner.SA_CalcIdeal = ACT_MP_WALK
		owner.SA_CalcSeqOverride = -1
	//end
end

function newsa:Think(entity,owner)
	if CLIENT then
		if IsValid(entity.playermodel) and entity.playermodel:GetModel()~=owner:GetModel() then
			entity.playermodel:SetModel(owner:GetModel())
			entity.playermodel:InvalidateBoneCache()
			entity.playermodel:SetupBones()
		end
	end

	if entity:GetActionBool1() and entity:GetActionFloat1() < CurTime() then
		owner:EmitSound("Zombie.AttackMiss")
		entity:SetActionBool1(false)
		self:KickAttack(entity,owner)
		entity:SetNextAction(CurTime()+1)
	end
	
end

function newsa:KickAttack(entity,owner)

end




function newsa:DoAnimationEvent(entity,owner,event,data)
	if data==123 then
		//owner:AnimRestartGesture( GESTURE_SLOT_GRENADE, ACT_GMOD_GESTURE_ITEM_THROW, true )
	end
end
