if not SA then return end

local newsa=SA:New("Run run run","sa_runner","RUNNING FAST AS FUCKKKK")

sound.Add( {
	name = "sanic.run_loop",
	channel = CHAN_STATIC,
	volume = 1.0,
	soundlevel = 0.1,
	sound = "^vehicles/v8/v8_turbo_on_loop1.wav"
})

function newsa:Initialize(entity,owner)
end

function newsa:Deinitialize(entity,owner)
end


function newsa:Think(entity,owner,mv)
	if entity:GetKey()~=IN_SPEED then
		entity:SetKey(IN_SPEED)
	end
	
end


function newsa:AllClientThink(entity,owner,isclientowner)
end


function newsa:Attack(entity,owner,mv) 
end


function newsa:SetupMove(entity,owner,movedata,commanddata)
	
end

--[[
ENT.SteerDecayRate=2
ENT.SteerRate=5
function ENT:HandleSteer(mv,cmd)
	local oldval=self:GetSteer()
	local val=0
	
	
	if mv:KeyDown(IN_MOVELEFT) then	
		val=self.SteerRate*FrameTime()
	end
	self:SetSteer(math.Clamp(oldval+val,-1,1))
end
]]

function newsa:Move(entity,owner,movedata)
	local done=false
	if not owner:Crouching() and entity:IsKeyDown() then
		--increase movespeed
		if movedata:GetForwardSpeed()>0 then
			local val=entity:GetActionFloat1()
			if owner:OnGround() then
				val=val + 200*FrameTime()
				entity:SetActionFloat1(math.Clamp(val,0,entity:GetActionInt1()))
			end
			movedata:SetMaxClientSpeed(entity:GetActionFloat1())
			movedata:SetMaxSpeed(entity:GetActionFloat1())
			movedata:SetSideSpeed(0)
			
			done=true
		else
			entity:SetActionFloat1(owner:GetRunSpeed())
		end
		
	else
		entity:SetActionFloat1(owner:GetRunSpeed())
	end
	entity:SetActionBool1(done)
end


function newsa:OnOwnerTakesDamage(entity,owner,dmginfo)
end


function newsa:DrawWorldModel(entity,owner)
end


function newsa:PrePlayerDraw(entity,owner)
end

function newsa:PostPlayerDraw(entity,owner)
end



function newsa:PreDrawViewModel(entity,owner,weapon,viewmodel)
end


function newsa:PostDrawViewModel(entity,owner,weapon,viewmodel)
end

function newsa:HUDDraw(entity,owner)
end

newsa.FullSpeedAfter=3
function newsa:ResetVars(entity,owner)
	entity:SetActionBool1(false)
	entity:SetActionInt1(1500)
	entity:SetActionFloat1(0)
end

function newsa:PlayerUse(entity,owner,useentity)
end

function newsa:UpdateAnimation(entity,owner,velocity, maxseqgroundspeed)
end

function newsa:CalcMainActivity(entity,owner,velocity)
	if not owner:Crouching() and entity:GetActionBool1() then
		local vel=velocity:Length2D()
		if vel>owner:GetRunSpeed() and owner:OnGround() then
			owner.SA_CalcIdeal = ACT_HL2MP_RUN_FAST
			owner.SA_CalcSeqOverride = -1
		end
		
	end
end


function newsa:DoAnimationEvent(entity,owner,event,data)
end

function newsa:BuildHandsPosition(entity,owner,handsent)
	
end

function newsa:OnViewModelChanged(entity,owner,viewmodel,oldmodel,newmodel)
	
end