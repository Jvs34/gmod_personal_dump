
newsa=nil
newsa=SA:New("Grapplehook","sa_grapplehook","Ropes are overrated")
newsa.Range=10000

function newsa:Initialize(entity,owner)
	if CLIENT then
		--entity.mm=multimodel.CreateInstance("sa_rocketlauncher")
		entity.grapple=multimodel.CreateInstance("sa_hook")
		entity.animatedhands=ClientsideModel("models/weapons/c_arms_citizen.mdl")
		entity.animatedhands:SetNoDraw(true)
		entity.animatedhands:Spawn()
		entity.animatedhands:SetMaterial("engine/occlusionproxy" )
	end
	entity.LaunchSound = CreateSound( entity, "TripwireGrenade.ShootRope" )
	entity.ReelSound = CreateSound( entity, "vehicles/digger_grinder_loop1.wav" )
end


function newsa:Deinitialize(entity,owner)
	if IsValid(entity.animatedhands) then
		entity.animatedhands:Remove()
	end
	
	if entity.LaunchSound then
		entity.LaunchSound:Stop()
		entity.LaunchSound=nil
	end
	
	if entity.ReelSound then
		entity.ReelSound:Stop()
		entity.ReelSound=nil
	end
end

function newsa:ResetVars(entity,owner)
	
	entity:AliasNetworkVar("ActionFloat1","AttachTime")		--self.dt.AttachTime=CurTime()
	
	entity:SetAttachTime(CurTime())
	
	entity:AliasNetworkVar("ActionFloat2","AttachStart")		--self.dt.AttachStart=CurTime()
	
	entity:SetAttachStart(CurTime())
	
	
	entity:SetNextAction(CurTime())	--self.dt.NextGrapple=CurTime()	--this one is just setnextaction pretty much
	
	entity:AliasNetworkVar("ActionVector1","AttachedTo")		--self.dt.AttachedTo=Vector(0,0,0)
	entity:SetAttachedTo(Vector(0,0,0))
	
	entity:AliasNetworkVar("ActionVector2","GrappleNormal")		--self.dt.GrappleNormal=Vector(0,0,0)
	entity:SetGrappleNormal(Vector(0,0,0))
	
	entity:AliasNetworkVar("ActionBool1","IsAttached")			--self.dt.IsAttached=false
	entity:SetIsAttached(false)
	
	entity:AliasNetworkVar("ActionBool2","AttachSoundPlayed")			--self.dt.AttachSoundPlayed=false
	entity:SetAttachSoundPlayed(false)
	self:Detach(entity,owner)
end

--[[
16:44 - Jvs: hey ralle, do you still have that lua rope script somewhere?
16:44 - Jvs: talking about this one
16:44 - Jvs: https://www.youtube.com/watch?v=BBt4s7u4mVo
16:44 - Rama: uh i might
16:44 - Rama: hold on a sec
16:46 - Rama: nope sorry :(
16:47 - Jvs: aw damn
16:47 - Jvs: do you think you posted it on one of the waywo perhaps?
16:47 - Rama: no i just posted the video
16:47 - Jvs: ah well
16:47 - Rama: it's really simple though
16:47 - Rama: the rope is made up of nodes
16:48 - Rama: i do traces in think between each pair of nodes
16:48 - Rama: if it hits something i insert another node there
16:48 - Rama: then i trace between every 2 nodes that have 1 node between
16:48 - Rama: if it hits nothing i remove the middle node
16:49 - Rama: so if there's nothing between node 1 and 3 i remove node 2
16:50 - Rama: udnerstand?
16:50 - Jvs: yeah I see
16:50 - Rama: alright
16:50 - Jvs: I was just thinking that it might be a bit unreliable under prediction
16:50 - Jvs: I wanted to improve my grappling hook
16:50 - Jvs: with something simple as that
16:51 - Rama: i think i did a little something with the hit point as well to move it out to the edge of stuff
16:51 - Rama: do 1 trace from 1 -> 2 and one trace from 2 -> 1
16:52 - Rama: take the line the 2 planes form when they intersect and get the closest point to the average of the 2 hitposes
16:52 - Jvs: hmm, understood
16:53 - Jvs: that's gonna be a bit hard to network reliably, I'll see what I can do
16:53 - Jvs: thanks for the help
16:53 - Rama: no problem and good luck

]]

--[[

	the plan is to have two initial nodes, the grapple hitpos and the player eyepos or whatever
	these nodes are just hardcoded
	
]]

function newsa:GetFirstNode()

end

function newsa:GetLastNode()

end

function newsa:GetNode(i)

end

function newsa:Attack(entity,owner)
	if entity:GetIsAttached() then return end
	
	entity:SetNextAction(CurTime()+0.3)
	
	--do a trace, make it only hit the world, if it didn't, do nothing
	owner:LagCompensation(true)
	local tr=self:DoGrappleTrace(entity,owner)
	owner:LagCompensation(false)
	if not tr.HitSky and tr.Hit then
		local len=(owner:EyePos():Distance(tr.HitPos))/self.Range
		local timetoreach=Lerp(tr.Fraction,0,2.5)
		
		
		
		entity:SetAttachedTo(tr.HitPos)
		entity:SetAttachTime(CurTime()+timetoreach)
		entity:SetAttachStart(CurTime())
		--if it did, then set AttachedTo to the hitpos, calculate the delay from the distance between eyepos and hitpos and add it with CurTime() on AttachTime
		entity:SetIsAttached(true)
		if entity.LaunchSound then
			entity.LaunchSound:Play()
			entity.LaunchSound:ChangeVolume(4,0)
		end
		entity:EmitSound("ambient/machines/catapult_throw.wav")
		entity:SetGrappleNormal(self:GetDirection(entity,owner))
		
	end
	
end

function newsa:Detach(entity,owner,bool)
	if bool==nil then bool=false end
	--we reset every variable here
	entity:SetIsAttached(false)
	entity:SetAttachTime(CurTime())
	entity:SetAttachStart(CurTime())
	if entity.LaunchSound then
		entity.LaunchSound:Stop()
	end
	if entity.ReelSound then
		entity.ReelSound:Stop()
	end
	entity:SetAttachSoundPlayed(false)
	--when the boolean's true it means that we detached gracefully by touching the hook, and thus we want a faster refire
	entity:SetNextAction(CurTime()+(bool and 0.5 or 1))
end

function newsa:Think(entity,owner)
	--if IsAttached is true and AttachTime is bigger than CurTime() then
	--we get the time fraction with the timefraction function, between curtime and attachtime
	--we use it to lerpvector(eyepos,attachedto)
	if entity:GetIsAttached() then 
		if entity:GetAttachTime()<=CurTime() then
			if not entity:GetAttachSoundPlayed() then
				entity:EmitSound( "NPC_CombineMine.CloseHooks")
				entity:SetAttachSoundPlayed(true)
			end
			if entity.ReelSound then
				entity.ReelSound:Play()
				entity.ReelSound:ChangePitch(200,0)
				entity.ReelSound:ChangeVolume(0.3,0)
			end
			if entity.LaunchSound then
				entity.LaunchSound:Stop()
			end
			if self:ShouldStopPulling(entity,owner) then
				self:Detach(entity,owner,true)
			end
		end

	else
		if entity.LaunchSound then
			entity.LaunchSound:Stop()
		end
		if entity.ReelSound then
			entity.ReelSound:Stop()
		end
	end

end

function newsa:DoGrappleTrace(entity,owner,endpos)
	local tr={}
	tr.filter=owner
	--tr.mask=MASK_SOLID_BRUSHONLY
	tr.start=owner:EyePos()
	tr.endpos=endpos or (owner:EyePos()+owner:GetAimVector()*self.Range)
	tr.mins=Vector(4,4,4)*-1
	tr.maxs=Vector(4,4,4)
	return util.TraceHull(tr)
end

function newsa:GetDirection(entity,owner)
	return (entity:GetAttachedTo() - owner:EyePos()):GetNormalized()
end

function newsa:ShouldStopPulling(entity,owner)
	return (owner:NearestPoint(entity:GetAttachedTo())):Distance(entity:GetAttachedTo())<=45 or not entity:IsKeyDown()
end

function newsa:CanPull(entity,owner)
	return entity:GetIsAttached() and entity:GetAttachTime()<CurTime() and not self:ShouldStopPulling(entity,owner)
end

function newsa:Move(entity,owner,data)
	if self:CanPull(entity,owner) then
		owner:SetGroundEntity(NULL)	--this prevents the player from actually going up steps
		data:SetForwardSpeed(0)
		--data:SetSideSpeed(0)
		data:SetUpSpeed(0)
		local vel=data:GetVelocity()+self:GetDirection(entity,owner)*2000*FrameTime()
		data:SetVelocity(vel)
	end
end
--[[
	ValveBiped.Bip01_L_Clavicle
	ValveBiped.Bip01_L_UpperArm
	ValveBiped.Bip01_L_Forearm
	ValveBiped.Bip01_L_Hand
]]
--[[
	ValveBiped.Bip01_L_Finger4
	ValveBiped.Bip01_L_Finger41
	ValveBiped.Bip01_L_Finger42
	ValveBiped.Bip01_L_Finger3
	ValveBiped.Bip01_L_Finger31
	ValveBiped.Bip01_L_Finger32
	ValveBiped.Bip01_L_Finger2
	ValveBiped.Bip01_L_Finger21
	ValveBiped.Bip01_L_Finger22
	ValveBiped.Bip01_L_Finger1
	ValveBiped.Bip01_L_Finger11
	ValveBiped.Bip01_L_Finger12
	ValveBiped.Bip01_L_Finger0
	ValveBiped.Bip01_L_Finger01
	ValveBiped.Bip01_L_Finger02

]]

function PrintBonesF(ent)
	if not IsValid(ent) then print("Invalid entity!") return end
	for i=0,ent:GetBoneCount()-1 do
		print(ent:GetBoneName(i),ent:GetBonePosition(i))
	end
end


newsa.GrapplePose={
	["ValveBiped.Bip01_L_UpperArm"]={
		vector_origin,Angle(0,-65,0),
	},
	["ValveBiped.Bip01_L_Forearm"]={
		vector_origin,Angle(0,-30,40),
	},
	
	["ValveBiped.Bip01_L_Finger0"]={	
		vector_origin,Angle(0,10,0),
	},
	
	
	--[[
	ValveBiped.Bip01_L_Finger41	-198.550125 488.966980 -12241.087891	86.382 -33.944 -0.030
	ValveBiped.Bip01_L_Finger42	-198.550125 488.966980 -12241.087891	86.382 -33.944 -0.030
	ValveBiped.Bip01_L_Finger3	-129.233109 450.379791 -12240.501953	54.534 -147.139 -7.570
	ValveBiped.Bip01_L_Finger31	-198.550125 488.966980 -12241.087891	86.382 -33.944 -0.030
	ValveBiped.Bip01_L_Finger32	-198.550125 488.966980 -12241.087891	86.382 -33.944 -0.030
	ValveBiped.Bip01_L_Finger2	-129.877045 449.990204 -12240.065430	62.131 -135.486 6.906
	ValveBiped.Bip01_L_Finger21	-198.550125 488.966980 -12241.087891	86.382 -33.944 -0.030
	ValveBiped.Bip01_L_Finger22	-198.550125 488.966980 -12241.087891	86.382 -33.944 -0.030
	ValveBiped.Bip01_L_Finger1	-130.522552 449.559296 -12239.597656	60.230 -135.463 14.472
	ValveBiped.Bip01_L_Finger11	-198.550125 488.966980 -12241.087891	86.382 -33.944 -0.030
	ValveBiped.Bip01_L_Finger12	-198.550125 488.966980 -12241.087891	86.382 -33.944 -0.030
	ValveBiped.Bip01_L_Finger0	-132.594559 451.695374 -12240.315430	18.260 -81.335 -4.890
	ValveBiped.Bip01_L_Finger01	-132.338486 450.015137 -12240.875977	17.494 -77.576 -21.233
	ValveBiped.Bip01_L_Finger02	-132.103241 448.947296 -12241.220703	20.680 -8.409 15.608
	]]
}

function newsa:BuildHandsPosition(entity,owner,handsent)
	if not entity:GetIsAttached() then return end
	
	if IsValid(entity.animatedhands) then
		
		--for i,v in pairs(self.BoneMergeBones) do
		for i=0,handsent:GetBoneCount()-1 do
			local v=handsent:GetBoneName(i)
			local lookupb=handsent:LookupBone(v)
			
			if self.GrapplePose[v] then
				entity.animatedhands:ManipulateBonePosition(lookupb,self.GrapplePose[v][1])
				entity.animatedhands:ManipulateBoneAngles(lookupb,self.GrapplePose[v][2])
			end
			
			if not lookupb then continue end

			local vmbm=handsent:GetBoneMatrix(lookupb)
			local vmbm2=entity.animatedhands:GetBoneMatrix(lookupb)
			
			if vmbm and vmbm2 and string.find(v,"L_") then
				handsent:SetBonePosition(lookupb,vmbm2:GetTranslation(),vmbm2:GetAngles())
				--vmbm:Scale(Vector(0.0001,0.0001,0.001))
				--vmbm:SetTranslation(vector_origin)
				--handsent:SetBoneMatrix(lookupb,vmbm)
			
			end
		end

	end
end


function newsa:DrawWorldModel(entity,owner)
	self:DrawGrappleHook(entity,owner,false)
end


newsa.AhOffsets={Vector(0,0,-60),Angle(0,0,0)}
function newsa:PostDrawViewModel(entity,owner,weapon,viewmodel)
	if not entity:GetIsAttached() then return end
	
	if IsValid(entity.animatedhands) then
		local pos=viewmodel:GetPos()
		local ang=viewmodel:GetAngles()
		pos,ang=LocalToWorld(self.AhOffsets[1],self.AhOffsets[2],pos,ang)
		
		entity.animatedhands:SetRenderOrigin(pos)
		entity.animatedhands:SetRenderAngles(ang)
		entity.animatedhands:DrawModel()
		
	end
	self:DrawGrappleHook(entity,owner,true)
end

newsa.EyeOffsets={Vector(25,-7,-5),Angle(0,0,0)}

function newsa:GetEyeOffset(entity,owner)
	local pos=owner:EyePos()
	local ang=owner:EyeAngles()
	pos,ang=LocalToWorld(self.EyeOffsets[1],self.EyeOffsets[2],pos,ang)
	return pos
end

if CLIENT then
	newsa.CableMat=Material("cable/cable2")
	
	newsa.localgpos=Vector(0,0,5)
	newsa.localgang=Angle(-90,0,0)
end

if CLIENT then
	local chainmodel="models/props_c17/utilityconnecter005.mdl"

	if IsValid(CHAIN) then
		CHAIN:Remove()
	end

	CHAIN=ClientsideModel(chainmodel)
	CHAIN:SetNoDraw(true)
	CHAIN:SetModelScale(0.5,0)
	CHAIN:Spawn()
	CHAIN.Length=5.5


	function DrawChain(pointa,pointb)
		if not IsValid(CHAIN) then return end
		local direction=(pointb - pointa):GetNormalized()
		local chainlength=(pointb - pointa):Length()
		local subd=chainlength/CHAIN.Length
		
		local ang=direction:Angle()
		ang.p=0
		ang.r=direction:Angle().p
		ang:RotateAroundAxis( Vector(0,0,-1), -90 )
		for i=0,math.Round(subd) do
			CHAIN:SetupBones()
			
			local p,a=LocalToWorld(Vector(0,-CHAIN.Length*i,0),angle_zero or angle_zero,pointa,ang)
			if i%2==0 then
				local ppp
				ppp,a=LocalToWorld(Vector(0,-CHAIN.Length*i,0),Angle(90,0,0),pointa,ang)
			end
			CHAIN:SetRenderOrigin(p)
			CHAIN:SetRenderAngles(a)
			CHAIN:DrawModel()
		end
		
	end
end

function newsa:DrawGrappleHook(entity,owner,isvm)
	
	local gpos=vector_origin	--self:GetEyeOffset(entity,owner)
	local gang=angle_zero		--owner:EyeAngles()
	local startpos=vector_origin
	
	local bone="ValveBiped.Bip01_L_Hand"
	
	if isvm then
		if IsValid(owner:GetHands()) and owner:GetHands():LookupBone(bone) then
			local ent=owner:GetHands()
			local pos,ang=ent:GetBonePosition(ent:LookupBone(bone))
			startpos=pos
		end
	else
		if owner:LookupBone(bone) then
			local ent=owner
			local pos,ang=ent:GetBonePosition(ent:LookupBone(bone))
			startpos=pos
		else
			startpos=self:GetEyeOffset(entity,owner)
		end
	end
	
	if entity:GetIsAttached() and entity.grapple then
		--if it's still travelling, lerp the vector
		if entity:GetAttachTime()>=CurTime() then
			local travelfraction=math.TimeFraction(entity:GetAttachStart(), entity:GetAttachTime(), CurTime() )
			
			gpos=LerpVector(travelfraction,startpos,entity:GetAttachedTo())
		else	--already attached, draw it still
			gpos=entity:GetAttachedTo()
		end
		
		gang=entity:GetGrappleNormal():Angle()
		
		if isvm then
			gpos=FormatViewModelAttachment(gpos,EyePos(),EyeAngles(),nil,nil,true)
		end
		
		render.SetMaterial(self.CableMat)
		if isvm and not ohgoddisabled then
			DrawChain(startpos,gpos)
		else
			render.StartBeam( 2 )
				render.AddBeam(startpos,0.5,2,Color(255,255,255,255))
				render.AddBeam(gpos,0.5,3,Color(255,255,255,255))
			render.EndBeam()
		end
		multimodel.Draw(entity.grapple,entity,{origin=gpos or vector_origin,angles=gang or angle_zero})
	end

end


multimodel.Register("sa_hook", {
	{
		transform = {Vector(0,0,0), Angle(0,90,90), Vector(1,1,1)/1.5},
		children = {
				{
					model = "models/props_lab/jar01b.mdl",
					transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,0.1)/2},

				},
				{
					model = "models/Gibs/manhack_gib05.mdl",
					transform = {Vector(0,2.3,1),Angle(-45,90,90), Vector(1,1,5)/3},

				},
				{
					model = "models/Gibs/manhack_gib05.mdl",
					transform = {Vector(0,-2.3,1),Angle(-45,-90,90), Vector(1,1,5)/3},

				},
				{
					model = "models/Gibs/manhack_gib05.mdl",
					transform = {Vector(-2.3,0,1),Angle(-45,180,90), Vector(1,1,5)/3},

				},
				{
					model = "models/Gibs/manhack_gib05.mdl",
					transform = {Vector(2.3,0,1),Angle(-45,0,90), Vector(1,1,5)/3},

				},
		}

	}
})