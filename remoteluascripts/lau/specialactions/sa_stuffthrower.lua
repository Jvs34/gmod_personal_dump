
newsa=nil
newsa=SA:New("Stuff Thrower","sa_stuffthrower","It throws stuff, mainly balloons, but that counts as stuff too")


if CLIENT then
    local EFFECT={}
    
    function EFFECT:Init( data )
        self.Position = data:GetOrigin()    
        self.Speed = data:GetStart()
        self.Size = data:GetScale()
        local emitter = ParticleEmitter( self.Position )
            for i=1, 200 do    
                local particle = emitter:Add( "particle/particle_noisesphere", self.Position )
                    particle:SetVelocity( Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(-100,100))+(self.Speed*self.Size*4) )
                    particle:SetDieTime(1)
                    particle:SetStartAlpha(200)
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(math.random(self.Size,10+self.Size))
                    particle:SetEndSize( 0 )
                    particle:SetRoll( math.Rand( -10,10  ) )
                    particle:SetRollDelta(math.Rand( -0.2, 0.2 ))
					local cola=196	--/3
					local colb=255	--/3
					local colr=255	--/3
					particle:SetColor( cola, colb, colr)            
                    particle:SetGravity( Vector( 0, 0, -15*i ) )
                    particle:SetCollide( true )
                    particle:SetBounce( 0.2 )
            end            
        emitter:Finish()
    end
    function EFFECT:Think()return false end
    function EFFECT:Render() end
    effects.Register(EFFECT,"WaterBalloon_Explode")
end


ENT2=nil
ENT2={}
ENT2.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT2.Type             = "anim"
ENT2.Base             = "base_anim"
ENT2.PrintName        = ""
ENT2.Author            = "Jvs"
ENT2.Information        = ""
ENT2.Category        = ""
ENT2.Spawnable            = false
ENT2.AdminSpawnable        = false

function ENT2:Initialize()
	if SERVER then
		self:SetModel( "models/maxofs2d/balloon_classic.mdl" )
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		if IsValid(self:GetPhysicsObject()) then
			self:GetPhysicsObject():AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			self:GetPhysicsObject():AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
			self:GetPhysicsObject():Wake()
			self:GetPhysicsObject():SetMass(100)
		end
		self:SetDetonated(false)
		if IsValid(self:GetOwner()) and self:GetOwner().GetPlayerColor then
			local vec=self:GetOwner():GetPlayerColor()
			self:SetColor(Color(vec.x*255,vec.y*255,vec.z*255))
		else
			self:SetColor(Color(math.random(0,255),math.random(0,255),math.random(0,255)))
		end
	end
end

function ENT2:Throw(vec)
	if IsValid(self:GetPhysicsObject()) then
		self:GetPhysicsObject():Wake()
		self:GetPhysicsObject():AddVelocity(vec)
		self:GetPhysicsObject():AddAngleVelocity(VectorRand()*500)
	end
end

function ENT2:Draw()
	local s=math.sin(CurTime()*10)/10
	local c=math.cos(CurTime()*10)/10
	local mat = Matrix()
	mat:Scale( Vector(1+s,1+c,1) ) 
	self:EnableMatrix( "RenderMultiply",mat)
		
	self:DrawModel()
end

function ENT2:SetupDataTables()

	self:NetworkVar( "Entity", 0, "Target")
	self:NetworkVar( "Bool", 0, "Detonated")
end


function ENT2:PhysicsCollide( data, physobj )
	if SERVER and IsValid(data.HitEntity) then
		local owner=self:GetOwner()
		if not IsValid(owner) then owner=self end
		local dmgnf=DamageInfo()
		dmgnf:SetAttacker(owner)
		dmgnf:SetDamage(10)
		dmgnf:SetInflictor(self)
		dmgnf:SetDamageType(bit.bor(DMG_POISON,DMG_DROWN))
		dmgnf:SetDamagePosition(self:GetPos())
		dmgnf:SetDamageForce(data.OurOldVelocity)
		data.HitEntity:TakeDamageInfo(dmgnf)
	end
	self:Detonate()
end

function ENT2:GetColorVector()
	return Vector(self:GetColor().r,self:GetColor().g,self:GetColor().b)
end


function ENT2:OnTakeDamage(dmgfo)
	if dmgfo:IsDamageType(DMG_PHYSGUN) then return end
	self:Detonate()
end



function ENT2:Detonate()
    if self:GetDetonated() then return end
	self:SetDetonated(true)
	
	if not IsValid(self:GetOwner()) then 
		if SERVER then
			self:Remove()
		end
	
		return 
	end
	
	
	
	
	local effectdata = EffectData()
		effectdata:SetOrigin( self:GetPos() )
		effectdata:SetStart( self:GetColorVector() )
	util.Effect( "balloon_pop", effectdata )
	
	effectdata = EffectData()
		effectdata:SetScale(10)
		effectdata:SetOrigin( self:GetPos()+(self:GetUp())*7 )
		effectdata:SetStart(self:GetUp() )
    util.Effect( "WaterBalloon_Explode", effectdata )
	self:EmitSound("ambient/water/water_splash1.wav",75,100)
	if SERVER then
		self:Remove()
	end
end

scripted_ents.Register(ENT2,"sa_waterballoon",true)






function newsa:Initialize(entity,owner)
	--self:ApplyBoneCallback(entity,owner)
	if SERVER then return end
	
	--this actually performs the animation
	entity.viewmodel=ClientsideModel("models/player/breen.mdl")
	entity.viewmodel:Spawn()
	entity.viewmodel:SetCycle(0)
	entity.viewmodel:SetNoDraw(true)
	entity.playanimation=true
	
	
	--this used to be drawn instead of the player's viewmodel, but now it's here just for the bonemerge
	local model="models/weapons/c_arms_citizen.mdl"
	if IsValid(owner:GetHands()) then
		owner:GetHands():GetModel()
	end
	entity.hands=ClientsideModel(model)
	entity.hands:SetParent(entity.viewmodel)
	entity.hands:AddEffects(EF_BONEMERGE)
	entity.hands:SetOwner(owner)
	entity.hands.GetPlayerColor=function(self) return self:GetOwner():GetPlayerColor() end
	entity.hands:SetNoDraw(true)
	entity.hands:Spawn()
	entity.hands:SetMaterial("engine/occlusionproxy" )
	


end

function newsa:Deinitialize(entity,owner)
	if SERVER then return end
	--destroy em in here
	if IsValid(entity.viewmodel) then
		entity.viewmodel:Remove()
	end
	
	if IsValid(entity.hands) then
		entity.hands:Remove()
	end

end

function newsa:ResetVars(entity,owner)
	entity:SetActionFloat1(CurTime()+1)	--nextattack
	entity:SetActionBool1(false)
	entity:SetActionEntity1(NULL)
	entity:SetNextAction(CurTime()+1)
end


function newsa:Attack(entity,owner)
	if entity:GetActionBool1() then return end
	owner:DoCustomAnimEvent(PLAYERANIMEVENT_CUSTOM,69)
	entity:SetActionBool1(true)
	entity:SetActionFloat1(CurTime()+0.7)
	entity:SetNextAction(CurTime()+1)
end

function newsa:ApplyBoneCallback(entity,owner)

	if not IsValid(entity:GetActionEntity1()) and IsValid(owner:GetHands()) then
		if CLIENT then
			owner:GetHands():AddCallback("BuildBonePositions",function (self)
				local ply=self:GetOwner()
				if not IsValid(ply) then return end
				if not IsValid(ply:GetDTEntity(3)) then return end
				if not ply:GetDTEntity(3).DoSpecialAction then return end
				ply:GetDTEntity(3):DoSpecialAction("BuildHandsPosition",self)
			end)
			print("applied BuildBonePositions to LocalPlayer():GetHands()")
		end
		entity:SetActionEntity1(owner:GetHands())
	end
end

function newsa:OnViewModelChanged(entity,owner,viewmodel,oldmodel,newmodel)
	--self:ApplyBoneCallback(entity,owner)
end

function newsa:AllClientThink(entity,owner,isowner)
	--[[
	if game.SinglePlayer() then
		self:ApplyBoneCallback(entity,owner)
	end
	]]
end

function newsa:PreDrawViewModel(entity,owner,weapon,viewmodel)

end

newsa.Offset={
	Vec=Vector(6.5,-10,-64),
	Ang=Angle(0,90,-9)
}

	
function newsa:PostDrawViewModel(entity,owner,weapon,viewmodel)
	if not IsValid(viewmodel) then	return	end
	
	if entity:GetActionBool1() and entity:GetActionFloat1() > CurTime() then
		if not entity.playanimation and IsValid(entity.viewmodel) then
			local seq=entity.viewmodel:LookupSequence( "gesture_item_throw" )
			if seq then
				entity.viewmodel:ResetSequence( seq )
			end
			entity.viewmodel:SetCycle(0)
			entity.playanimation=true
		end
	else
		entity.playanimation=false
	end
	
	if entity:GetNextAction() < CurTime() then return end
	
	if IsValid(entity.viewmodel) and IsValid(entity.hands) then
		
		local vpos=viewmodel:GetPos()
		local vang=viewmodel:GetAngles()
		vpos,vang=LocalToWorld(self.Offset.Vec,self.Offset.Ang,vpos,vang)
		entity.viewmodel:FrameAdvance( FrameTime() )
		entity.viewmodel:SetRenderAngles(vang)
		entity.viewmodel:SetRenderOrigin(vpos)
		render.SetBlend(0)
		entity.hands:DrawModel()
		render.SetBlend(1)
	end

end

function newsa:ThrowStuff(entity,owner)
    if SERVER then
		local stuff=ents.Create("sa_waterballoon")--sa_waterballoon
		stuff:SetOwner(owner)
		local pos,ang=LocalToWorld(Vector(0,10,-2),Angle(0,0,0),owner:GetShootPos(),owner:GetAimVector():Angle())--owner:EyeAngles())
		stuff:SetPos(pos)
		stuff:SetAngles(Angle(math.random(0,360),math.random(0,360),math.random(0,360)))
		stuff:Spawn()
		stuff:Throw(owner:GetAimVector()*600)
	end
end

function newsa:Think(entity,owner)
	
	
	
	if entity:GetActionBool1() and entity:GetActionFloat1() < CurTime() then
		owner:EmitSound("Zombie.AttackMiss")
		entity:SetActionBool1(false)
		self:ThrowStuff(entity,owner)
		entity:SetNextAction(CurTime()+1)
	end
end

function testingshit(owner)
	owner:GetHands():AddCallback("BuildBonePositions",function(self)
		local ply=self:GetOwner()
		if not IsValid(ply) then return end
		if not IsValid(ply:GetDTEntity(3)) then return end
		if not ply:GetDTEntity(3).DoSpecialAction then return end
		ply:GetDTEntity(3):DoSpecialAction("BuildHandsPosition",self)
	end)
end

newsa.BoneMergeBones={
	"ValveBiped.Bip01_L_Clavicle",
	"ValveBiped.Bip01_L_UpperArm",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_L_Finger4",
	"ValveBiped.Bip01_L_Finger41",
	"ValveBiped.Bip01_L_Finger42",
	"ValveBiped.Bip01_L_Finger3",
	"ValveBiped.Bip01_L_Finger31",
	"ValveBiped.Bip01_L_Finger32",
	"ValveBiped.Bip01_L_Finger2",
	"ValveBiped.Bip01_L_Finger21",
	"ValveBiped.Bip01_L_Finger22",
	"ValveBiped.Bip01_L_Finger1",
	"ValveBiped.Bip01_L_Finger11",
	"ValveBiped.Bip01_L_Finger12",
	"ValveBiped.Bip01_L_Finger0",
	"ValveBiped.Bip01_L_Finger01",
	"ValveBiped.Bip01_L_Finger02",
}


function newsa:BuildHandsPosition(entity,owner,handsent)
	if entity:GetNextAction() < CurTime() then return end
	
	if IsValid(entity.viewmodel) then
		
		--for i,v in pairs(self.BoneMergeBones) do
		for i=0,handsent:GetBoneCount()-1 do
			local v=handsent:GetBoneName(i)
			local lookupb=handsent:LookupBone(v)
			if not lookupb then continue end

			local vmbm=handsent:GetBoneMatrix(lookupb)
			local vmbm2=entity.hands:GetBoneMatrix(lookupb)
			
			if vmbm and vmbm2 and string.find(v,"L_") then
				handsent:SetBonePosition(lookupb,vmbm2:GetTranslation(),vmbm2:GetAngles())
				--vmbm:Scale(Vector(0.0001,0.0001,0.001))
				--vmbm:SetTranslation(vector_origin)
				--handsent:SetBoneMatrix(lookupb,vmbm)
			
			end
		end

	end
end

function newsa:DoAnimationEvent(entity,owner,event,data)
	if data==69 then
		owner:AnimRestartGesture( GESTURE_SLOT_GRENADE, ACT_GMOD_GESTURE_ITEM_THROW, true )
	end
end
