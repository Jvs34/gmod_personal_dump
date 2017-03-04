
newsa=nil
newsa=SA:New("Parachute test","sa_parachute","Mainly a test for _Kilburn")

local function chutethink(self, time, ent)
	self.transform[2].p = 10 +  3*math.sin(time*5)
	self.transform[2].r = -10 +  -3*math.sin(time*5)
end

multimodel.Register("sa_worms_parachute", {
	{
		transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
		children={
			{
				model = "models/hunter/misc/shell2x2d.mdl",
				material = "models/props_c17/paper01",
				transform = {Vector(-5,-5,0), Angle(10,0,-10), Vector(1,1,1)},
				Think=chutethink,
			},
			{
				model = "models/hunter/misc/shell2x2d.mdl",
				material = "models/props_c17/paper01",
				transform = {Vector(5,-5,0), Angle(10,90,-10), Vector(1,1,1)},
				Think=chutethink,
			},
			{
				model = "models/hunter/misc/shell2x2d.mdl",
				material = "models/props_c17/paper01",
				transform = {Vector(5,5,0), Angle(10,180,-10), Vector(1,1,1)},
				Think=chutethink,
			},
			{
				model = "models/hunter/misc/shell2x2d.mdl",
				material = "models/props_c17/paper01",
				transform = {Vector(-5,5,0), Angle(10,270,-10), Vector(1,1,1)},
				Think=chutethink,
			},
		}
	},
	
	
})

function newsa:Initialize(entity,owner)
	if CLIENT then
		entity.parachute=multimodel.CreateInstance("sa_worms_parachute")
	end
end

function newsa:Deinitialize(entity,owner)

end

function newsa:ResetVars(entity,owner)
	entity:SetActionBool1(true)
end

function newsa:CalcMainActivity(entity,owner,velocity)
	if entity:GetActionBool1() and owner:GetMoveType()==MOVETYPE_WALK then
		owner.SA_CalcIdeal = ACT_MP_SWIM_IDLE
		owner.SA_CalcSeqOverride = -1
	end
end

function newsa:Think(entity,owner,movedata)
	if owner:OnGround() or owner:WaterLevel()>0 then
		entity:SetActionBool1(false)
		return
	end

	if movedata:GetVelocity().z < -500 and not entity:GetActionBool1() then
		entity:SetActionBool1(true)
	end
end

function newsa:Move(entity,owner,movedata)
	if entity:GetActionBool1() and owner:GetMoveType()==MOVETYPE_WALK then
		if movedata:GetVelocity().z < -300 then
			local wind=vector_origin
			if IsValid(WIND_CONTROLLER) then
				local dir = WIND_CONTROLLER:GetWindDirection()

				local force = WIND_CONTROLLER:GetWindForce()

				wind=Angle(0, dir, 0):Forward() * force * 0.4
			end
			
			local oldvel=movedata:GetVelocity()
			local upvel=wind
			wind.z=700
			upvel=upvel*FrameTime()
			movedata:SetVelocity(oldvel+upvel)
		end
	end
end

function newsa:DrawWorldModel(entity,owner)
	local ppos=Vector(0,0,120)
	local ppang=owner:GetAngles()
	
	ppang.p=0
	
	ppos,ppang=LocalToWorld(ppos,angle_zero,owner:GetPos(),ppang)
	
	if entity:GetActionBool1() and entity.parachute then	--
		multimodel.DoFrameAdvance(entity.parachute, CurTime(), entity)
		multimodel.SetOutputTarget(entity.Attachments)
		multimodel.Draw(entity.parachute,owner,{origin=ppos,angles=ppang})
		multimodel.SetOutputTarget(nil)
	end
	local bone=owner:LookupBone("ValveBiped.Bip01_Spine2")
	if not bone then return end
	local matrix = owner:GetBoneMatrix(bone)
	if not matrix then return end
	local pos = matrix:GetTranslation()
	if not pos then return end
	local ang = matrix:GetAngles()
	if not ang then return end
	if not entity.parachute then return end
	
end