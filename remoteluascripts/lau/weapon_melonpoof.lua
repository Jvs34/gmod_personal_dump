local ENT = {}
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.PrintName        = ""
ENT.Author            = "Jvs"
ENT.Information        = ""
ENT.Category        = "Other"
ENT.Spawnable            = false
ENT.AdminOnly        = false


function ENT:Initialize()
	if(SERVER)then
		self:SetMaxHealth( 25 )
		self:SetHealth( self:GetMaxHealth() )
		self:SetBroken(false)
		self:SetTrappedPlayer(NULL)
		self:SetTrigger(true)
		self:SetPlayerColor(Vector(1,1,1))


		self:SetModel( "models/props_junk/watermelon01.mdl" )

		self:SetMoveType( MOVETYPE_VPHYSICS )

		self:PhysicsInit( SOLID_VPHYSICS )

		self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )
		self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
		--self:GetPhysicsObject():SetMaterial("flesh")
		self:PrecacheGibs()
		self:PhysWake()

		self:StartMotionController(true)
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0, "Broken" )
	self:NetworkVar( "Entity", 0, "TrappedPlayer" )
	self:NetworkVar( "Vector", 0, "PlayerColor" )
end

function ENT:Think()
	
	if SERVER and IsValid(self:GetTrappedPlayer()) then
		self:PhysWake()
		if self:GetTrappedPlayer():GetObserverMode()==OBS_MODE_NONE or not self:GetTrappedPlayer():Alive() then	
			self:BreakMe()
		end
	end
end

function ENT:OnRemove()
	if SERVER then
		self:BreakMe( nil , true )
	end
end

if SERVER then
	
	function ENT:OnTakeDamage(dmgfo)
		--we're already dead , might happen if multiple jetpacks explode at the same time
		if self:Health() <= 0 then
			return
		end

		self:TakePhysicsDamage( dmgfo )

		local oldhealth = self:Health()

		local newhealth = math.Clamp( self:Health() - dmgfo:GetDamage() , 0 , self:GetMaxHealth() )
		self:SetHealth( newhealth )

		if self:Health() <= 0 then
			self:BreakMe()
		end
	end

	function ENT:TrapPlayer(ent)
		if not IsValid( ent ) or not ent:IsPlayer() then
			return
		end
		
		if ent:GetObserverMode() ~= OBS_MODE_NONE then
			self:BreakMe()
			return
		end
		
		self:SetOwner( NULL )
		ent:Spectate( OBS_MODE_CHASE )
		ent:StripWeapons()
		ent:SpectateEntity( self )
		self:SetTrappedPlayer(ent)
		self:SetPlayerColor( ent:GetPlayerColor() )
	end

	ENT.MelonSpeedOnAxis = 5000

	function ENT:PhysicsSimulate( phys, deltaTime )
		if IsValid( self:GetTrappedPlayer() ) then
			self:GetTrappedPlayer():SetPos( phys:GetPos() )
			local ply = self:GetTrappedPlayer()
			local aimdirection = ply:EyeAngles()
			aimdirection.p = 0
			
			local angledirection = Vector( 0 , 0 , 0 )
			local direction = Vector( 0 , 0 , 0 )
			
			if ply:KeyDown( IN_FORWARD ) then
				direction:Add( aimdirection:Forward() * self.MelonSpeedOnAxis)
			end
			
			if ply:KeyDown( IN_BACK ) then
				direction:Add( aimdirection:Forward() * self.MelonSpeedOnAxis * -1)
			end

			if ply:KeyDown( IN_MOVELEFT ) then
				direction:Add( aimdirection:Right() * self.MelonSpeedOnAxis * -1 )
			end
			
			if ply:KeyDown( IN_MOVERIGHT ) then
				direction:Add( aimdirection:Right() * self.MelonSpeedOnAxis )
			end

			return angledirection , direction , SIM_GLOBAL_FORCE 
		end
		
		return SIM_NOTHING

	end

	function ENT:StartTouch(ent)
		if IsValid(ent) and ent:IsPlayer() and not IsValid(self:GetTrappedPlayer()) then	--and ent~=self:GetOwner()
			self:TrapPlayer(ent)
		end
	end

	function ENT:BreakMe( oldvel , noeffects )

		if self:GetBroken() then 
			return 
		end
		
		self:SetBroken( true )
		
		if IsValid(self:GetTrappedPlayer()) then
			local eyeang = self:GetTrappedPlayer():EyeAngles()
			
			self:GetTrappedPlayer():UnSpectate()
			self:GetTrappedPlayer():SetPos(self:GetPos())
			self:GetTrappedPlayer():Spawn()
			self:GetTrappedPlayer():SetPos( self:GetPos() )
			self:GetTrappedPlayer():SetEyeAngles( eyeang )
			self:SetTrappedPlayer(NULL)
		end
		
		if not noeffects then
			self:GibBreakClient( oldvel or self:GetVelocity() )
			self:Remove()
		end
	end



	function ENT:PhysicsCollide( data, physobj )
		if SERVER and self:IsPlayerHolding() then 
			return 
		end
		
		if not SERVER then 
			return 
		end
		
		if data.Speed > 70 and data.DeltaTime > 0.5 then
			self:EmitSound("Watermelon.Impact" )
		end
		
		--we may want to trap this player
		if not IsValid(self:GetTrappedPlayer()) and IsValid(data.HitEntity) and data.HitEntity:IsPlayer() then
			return
		end
		
		
		if data.Speed > 500 then
			self:BreakMe( data.OurOldVelocity )
		end
	end
else
	
	function ENT:Draw()
		local r = self:GetPlayerColor().x
		local g = self:GetPlayerColor().y
		local b = self:GetPlayerColor().z
		render.SetColorModulation( r , g , b )
		self:DrawModel()
	end

end

scripted_ents.Register(ENT,"melon_poof",true)

local SWEP = {}


SWEP.AutoSwitchTo        = true
SWEP.AutoSwitchFrom        = true
SWEP.Category                = "Jvs"
SWEP.Spawnable            = true
SWEP.AdminOnly        = true
SWEP.Base = "weapon_base" 
SWEP.Author			= "Jvs"
SWEP.Spawnable			= true
SWEP.UseHands			= true
SWEP.ViewModel			= "models/weapons/c_bugbait.mdl"
SWEP.WorldModel			= "models/props_junk/watermelon01.mdl"
SWEP.ViewModelFOV		= 54
SWEP.Primary={}
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Secondary={}
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"
SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false
SWEP.PrintName			= "Melon poof"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.STATE_IDLE			= 1
SWEP.STATE_PULLBACK		= 2
SWEP.STATE_THROWING		= 3
SWEP.STATE_SQUEEZING	= 4

if CLIENT then

	SWEP.Offsets={
		view={
			bone="ValveBiped.cube1",
			pos=Vector(-3,-1,0),--Vector(3.5,-2.8,0),
			ang=Angle(0,0,185),
		},
		world={
			bone="ValveBiped.Bip01_R_Hand",
			pos=Vector(3,-2.5,-0.5),
			ang=Angle(0,0,90),
		}
	}
	
	
	function SWEP:PreDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial( "engine/occlusionproxy" )

	end

	function SWEP:PostDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial()

	end
	
	function SWEP:ViewModelDrawn(vm)
        self:DrawEffects(true,vm)
    end
    
	function SWEP:CreateMelon()
		if IsValid(self.Melon) then return end
		self.Melon = ClientsideModel(self.WorldModel)
		self.Melon:SetNoDraw( true )
		self.Melon:Spawn()
	end
	
	function SWEP:DrawEffects(view_or_world,vm)
		self:CreateMelon()
		if not IsValid(self.Owner) then return end
		local ent=(view_or_world) and vm or self.Owner
		if not IsValid(self.Melon) then return end
		local offsets=self.Offsets[(view_or_world) and "view" or "world"]
		local bone=ent:LookupBone(offsets.bone)
		if not bone then return end
		local bonematrix=ent:GetBoneMatrix(bone)
		if not bonematrix then return end
		
		local pos,ang=LocalToWorld(offsets.pos,offsets.ang, bonematrix:GetTranslation(), bonematrix:GetAngles() )
		self.Melon:SetModelScale(0.3,0)
		self.Melon:SetRenderOrigin(pos)
		self.Melon:SetRenderAngles(ang)
		self.Melon:DrawModel()
	end
	
    function SWEP:DrawWorldModel()
        self:DrawEffects(false)
    end
end


function SWEP:Initialize()
	self:SetHoldType("slam")
	self:SetState( self.STATE_IDLE )
	self:SetNextFire( CurTime()+1 )
end 

function SWEP:SetupDataTables()
	self:NetworkVar( "Int", 0, "State" )
	self:NetworkVar( "Float", 0, "NextFire" )
end



function SWEP:Deploy()
	self:SetHoldType("slam")
	self:SetState( self.STATE_IDLE )
	self:SendWeaponAnim(ACT_VM_DRAW)
	self:SetNextFire( CurTime() + 1 )
	return true
end

--[[
ACT_VM_PULLBACK_HIGH
ACT_VM_PULLBACK_LOW
ACT_VM_THROW
ACT_VM_SECONDARYATTACK
ACT_VM_HAULBACK
ACT_VM_DRAW
ACT_VM_HOLSTER
]]

function SWEP:Think()
	if self:GetState() ==self.STATE_PULLBACK and self:GetNextFire()<CurTime() then
		if self.Owner:KeyDown(IN_ATTACK) then
		
		
		else
			--throw the nade
			self:ThrowMelon()
			self:EmitSound("Weapon_Crowbar.Single")
			self:SetState( self.STATE_THROWING )
			self:SendWeaponAnim(ACT_VM_THROW)
			self.Owner:DoAttackEvent()
			self:SetNextFire( CurTime()+0.7 )
		end
	end
	
	if self:GetState()==self.STATE_THROWING and self:GetNextFire()<CurTime() then
		self:SetHoldType("slam")
		self:SetState( self.STATE_IDLE )
		self:SendWeaponAnim(ACT_VM_DRAW)
		self:SetNextFire( CurTime()+1 )
	end
	
	if self:GetState()==self.STATE_SQUEEZING and self:GetNextFire()<CurTime() then
		if SERVER then
			local melons=ents.FindByClass( "melon_poof" )
			SuppressHostEvents(NULL)
			for i,v in pairs(melons) do
				if IsValid(v) and not v:GetBroken() then
					v:BreakMe()
				end
			end
			SuppressHostEvents(self.Owner)
		
		end
		
		
		self:SetHoldType("slam")
		self:SetState( self.STATE_IDLE )
		self:SendWeaponAnim(ACT_VM_IDLE)
		self:SetNextFire( CurTime()+0.1 )
	end
end


function SWEP:PrimaryAttack()
	if self:GetState() ~=self.STATE_IDLE or self:GetNextFire() > CurTime() then return end
	self:SetHoldType("grenade")
	self:SetState( self.STATE_PULLBACK )
	self:SendWeaponAnim(ACT_VM_HAULBACK)
	
	self:SetNextFire( CurTime()+0.25 )
end

function SWEP:SecondaryAttack()
	if self:GetState() ~=self.STATE_IDLE or self:GetNextFire() > CurTime() then return end
	self:SetState( self.STATE_SQUEEZING )
	self:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
	self:EmitSound("Watermelon.Impact")
	self:SetNextFire( CurTime()+0.3 )
end

function SWEP:Reload()
	if self:GetState()~=self.STATE_IDLE or self:GetNextFire() > CurTime() then return end
	
	if SERVER then
		local melon = self:ThrowMelon()
		if IsValid( melon ) then
			melon:TrapPlayer( self:GetOwner() )
		end
	end
end



function SWEP:ThrowMelon()
    if CLIENT then return end

    local    vecEye = self.Owner:EyePos()
    local    vForward, vRight
    vForward = self.Owner:GetForward()
    vRight = self.Owner:GetRight()
    local vecSrc = vecEye + vForward * 18.0 + vRight * 8.0
    vecSrc = self:CheckThrowPosition( self.Owner, vecEye, vecSrc )
    local vecThrow
    vecThrow =self.Owner:GetVelocity()/2
    
    local throwspeeddamnit=1200 
    vecThrow = vecThrow + vForward * throwspeeddamnit
    local Melon = ents.Create("melon_poof")
    if not Melon or not IsValid(Melon) then return end
    Melon:SetPos( vecSrc )
    Melon:SetAngles( self.Owner:EyeAngles() )
    Melon:SetOwner( self.Owner )
    Melon:Spawn()
	Melon:Activate()
    Melon:GetPhysicsObject():SetVelocity( vecThrow )
    Melon:GetPhysicsObject():AddAngleVelocity( Vector(600,math.random(-1200,1200),0) )
	
	return Melon
end

function SWEP:Holster()
    return true
end

function SWEP:OnDrop()

end

function SWEP:OnRemove()

end

function SWEP:CheckThrowPosition( pPlayer, vecEye, vecSrc )

    local tr

    tr = {}
    tr.start = vecEye
    tr.endpos = vecSrc
    tr.mins = Vector(6,6,6)*-1
    tr.maxs = Vector(6,6,6)
    tr.mask = MASK_PLAYERSOLID
    tr.filter = pPlayer
    tr.collision = pPlayer:GetCollisionGroup()
    local trace = util.TraceHull( tr )

    if ( trace.Hit ) then
        vecSrc = tr.endpos
    end

    return vecSrc

end


weapons.Register(SWEP,"weapon_melonpoof",true)