local SWEP = {}

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
SWEP.Category = "Jvs"
SWEP.Spawnable = true
SWEP.AdminOnly = false
SWEP.Base = "weapon_base"
SWEP.Author = "Jvs"

SWEP.Spawnable = true
SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_rocket_launcher.mdl"

SWEP.ViewModelFOV = 54

SWEP.Primary = {}

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"

SWEP.Secondary = {}
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Potato Cannon"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true

SWEP.RenderGroup = RENDERGROUP_OPAQUE

SWEP.ProjectileOffset = Vector( 0 , 10 , -3 )
SWEP.ProjectileSpread = 0.0
SWEP.EnableAngleCorrection = true
SWEP.AddAimPitch = 0
SWEP.MaxAngleCorrection = 15
--multimodel
if CLIENT then

	local PotatoLauncher = {
		{
			transform = {Vector(40,-0.5,5.5), Angle(90,180,0), Vector(1,1,1)/1.6},
			children = {
				{
					model = "models/props_phx/misc/potato_launcher.mdl",
					material = "models/debug/debugwhite",
					transform = {Vector(0,0,0), Angle(0,180,0), Vector(1,1,1)},
					children={
						{
							model = "models/props_c17/light_magnifyinglamp02.mdl",
							transform = {Vector(-4,5.5,73.5), Angle(146,250,0), Vector(0.3,0.3,0.3)},
							refractupdate=true,

							clipplanes = {
								{
									Vector(0,2,0), Vector(0,-1,0)
								},
							},
						},
						{
							model = "models/props_phx/construct/windows/window_curve90x2.mdl",
							transform = {Vector(-2.62,2.62,65), Angle(0,270,0), Vector(0.085,0.085,0.05)},
							material="models/shiny",
						},
						{
							model = "models/hunter/blocks/cube025x05x025.mdl",
							transform = {Vector(5,0,46), Angle(0,90,0), Vector(0.1,0.35,0.3)},
							material="models/shiny",
						}			
					}
				},
				{
					model = "models/props_phx/misc/potato_launcher_chamber.mdl",
					transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
				},
				{
					model = "models/props_phx/misc/potato_launcher_cap.mdl",
					transform = {Vector(0,0,-23), Angle(0,0,0), Vector(1,1,1)},
				},
				{
					model = "models/props_phx/misc/potato.mdl",
					transform = {Vector(0,-1.5,86), Angle(0,0,0), Vector(1.3,1.3,1.3)},
				},
				
				
			},
		}
	}

	multimodel.Register( "c_potatocannon" , PotatoLauncher )
	
end

--effect
if CLIENT then
	local EFFECT = {}
	
	function EFFECT:Init(data)
		local pos = data:GetOrigin()
		local ang = data:GetAngles()
		local spd = data:GetStart()
		
		local emitter = ParticleEmitter( pos )
		
		local num = 15
		for i = 1 , num do
			local particle = emitter:Add("particle/particle_smokegrenade", pos)
			particle:SetGravity(Vector(0,0,600))
			particle:SetVelocity(Angle(math.Rand(-90,90), math.Rand(-180,180), 0):Forward() * math.Rand(50,400))
			particle:SetAirResistance(300)
			particle:SetDieTime(math.Rand(0.1,0.3))
			particle:SetStartSize(math.Rand(5,8))
			particle:SetEndSize(math.Rand(10,20))
			particle:SetRoll(math.Rand(150,180))
			particle:SetRollDelta(0.6*math.random(-1,1))
			particle:SetColor(219,210,84)
			particle:SetStartAlpha(180)
			particle:SetEndAlpha(0)
		end
		
		local num = 15
		for i=1,num do
			local particle = emitter:Add("effects/fleck_cement"..math.random(1,2), pos)
			particle:SetGravity(Vector(0,0,-600))
			particle:SetVelocity(Angle(math.Rand(-90,90), math.Rand(-180,180), 0):Forward() * math.Rand(20,100))
			particle:SetAirResistance(1)
			particle:SetDieTime(math.Rand(0.8,1.5))
			particle:SetStartSize(1 * math.Rand(0.8,1.2))
			particle:SetEndSize(1 * math.Rand(1.2,2))
			particle:SetRoll(math.Rand(150,180))
			particle:SetRollDelta(0.6*math.random(-1,1))
			particle:SetColor(219,210,84)
			particle:SetStartAlpha(255)
			particle:SetEndAlpha(0)
		end
		
		emitter:Finish()
	end

	function EFFECT:Think()
		return false
	end

	function EFFECT:Render()
		return false
	end
	
	effects.Register( EFFECT , "potato_explode" )
end

if CLIENT then

	function SWEP:PreDrawViewModel( vm, wep, ply )
		if not IsValid( vm ) then 
			return 
		end
		
		vm:SetMaterial( "engine/occlusionproxy" )
		
	end

	function SWEP:PostDrawViewModel( vm , wep , ply )
		if not IsValid( vm ) then 
			return 
		end
		
		vm:SetMaterial()

	end
	
	function SWEP:ViewModelDrawn( vm )
		if not IsValid( vm ) then
			return
		end
		
		self:DrawMultiModel( vm , true )
	end
	
	function SWEP:DrawWorldModel()
		self:DrawMultiModel( self:GetOwner() or ent , false )
	end
	
	function SWEP:DrawMultiModel( ent , mode )
		self:CreateMultiModels()
		
		if not self.MultiModels or not self.MultiModels.Model then
			return
		end
		
		local pos = self:GetPos()
		local ang = self:GetAngles()
		
		if IsValid( ent ) then
			if mode then
				--viewmodel
				local boneid = ent:LookupBone( "ValveBiped.Gun" )
					if boneid and boneid ~= -1 then
					local bm = ent:GetBoneMatrix( boneid )
					if bm then
						pos , ang = LocalToWorld( Vector( 0 , 5.3 , 0 ) , Angle( 90 , 0 , 90 ) , bm:GetTranslation() , bm:GetAngles() )
					end
				end
			else
				--worldmodel
				local attchid = ent:LookupAttachment( "anim_attachment_RH" )
				
				if attchid and attchid ~= -1 then
					local attch = ent:GetAttachment( attchid )
					
					if attch then
						pos , ang = LocalToWorld( Vector( 9 , 0 , 12.5 ) , Angle( 168 , 0 , 0 ) , attch.Pos , attch.Ang )
					end
				end
				
			end
		else
			--rotate to match the rpg
		end
		
		multimodel.Draw( self.MultiModels.Model , ent ,
		{
			origin = pos,
			angles = ang
		})
		
	end
	
	function SWEP:CreateMultiModels()
	
		if not self.MultiModels then
			self.MultiModels = {}
		end
		
		if not self.MultiModels.Model then
			self.MultiModels.Model = multimodel.CreateInstance( "c_potatocannon" )
		end
	end
	
	function SWEP:GetViewModelPosition( pos , ang )
		pos = pos + ( ang:Up() * 2.5 ) + ( ang:Right() * -1.5 )
		return pos , ang
	end
	
	function SWEP:FireAnimationEvent( pos, ang, event, name )
		return true
	end
end

function SWEP:Initialize()
	if SERVER then
		self:SetHoldType( "rpg" )
	else
		self:CreateMultiModels()
	end
end

function SWEP:GetShootPosition()
	local pos, ang = self.Owner:GetShootPos(), self.Owner:EyeAngles()
	
	pos = pos
		+ ang:Forward()	* self.ProjectileOffset.x
		+ ang:Right()	* self.ProjectileOffset.y
		+ ang:Up()		* self.ProjectileOffset.z
	return pos
end

function SWEP:GetShootAngles()
	local ang = self.Owner:EyeAngles()
	
	if self.EnableAngleCorrection then
		-- Do some angle rectification
		local tr = util.TraceLine{
			start = self.Owner:GetShootPos(),
			endpos = self.Owner:GetShootPos() + ang:Forward() * 10000,
			filter = self.Owner
		}
		
		if tr.Hit then
			local ang2 = (tr.HitPos - self:GetShootPosition()):Angle()
			
			if math.abs( math.AngleDifference( ang.y , ang2.y ) ) < self.MaxAngleCorrection then
				ang = ang2
			end
		end
	end
	
	ang.p = ang.p + self.AddAimPitch
	
	local vel = (ang:Forward()
		+ math.Rand(-self.ProjectileSpread, self.ProjectileSpread) * ang:Right()
		+ math.Rand(-self.ProjectileSpread, self.ProjectileSpread) * ang:Up())
	
	return vel:Angle()
end

function SWEP:PrimaryAttack()
	
	self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
	if IsValid( self:GetOwner() ) then
		self.Owner:DoCustomAnimEvent( PLAYERANIMEVENT_ATTACK_PRIMARY , 0 )
	end
	
	if SERVER then
		local proj = ents.Create("projectile_potato")
		
		if IsValid( proj ) then
			if self:GetOwner():IsPlayer() then
				self:GetOwner():LagCompensation( true )
			end
			
			local pos, ang = self:GetShootPosition(), self:GetShootAngles()
			
			if self:GetOwner():IsPlayer() then
				self:GetOwner():LagCompensation( false )
			end
			
			proj:SetPos( pos )
			proj:SetAngles( ang )
			proj:SetOwner( self.Owner )
			proj:SetLocalVelocity( proj:GetForward() * proj.BaseSpeed )
			proj:Spawn()
		end
		
	end
	self:EmitSound( "weapons/grenade_launcher1.wav" , 75 , 140 )
	self:SetNextPrimaryFire( CurTime() + 0.6 )
end



function SWEP:SecondaryAttack()

end

function SWEP:Think()

end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
end

function SWEP:Reload()

end

weapons.Register( SWEP , "weapon_potatocannon" , true )

--potato projectile
local ENT = {}
ENT.Base 			= "base_anim"
ENT.Type 			= "anim"
ENT.Spawnable            = false
ENT.AdminOnly        = false
ENT.BaseDamage = 10
ENT.DamageRandomize = 2.5

ENT.Size = 5
ENT.BaseSpeed = 2500
ENT.MaxDamageDistance = 3100
ENT.RampUpMinDistance = 250 --you need to be this far away from the enemy in order to do more damage

function ENT:Initialize()
	self:SetModelScale( 1.5 , 0 )
	
	if SERVER then
		local min = Vector(-self.Size, -self.Size, -self.Size)
		local max = Vector( self.Size,  self.Size,  self.Size)
		self:SetModel( "models/props_phx/misc/potato.mdl" )
		
		self:SetMoveType( MOVETYPE_FLYGRAVITY )
		self:SetMoveCollide( MOVECOLLIDE_FLY_CUSTOM )
		self:SetCollisionBounds( min , max )
		self:SetSolid( SOLID_BBOX )
		self:SetTrigger( true )
		
		self:SetNotSolid( true )
		self:SetGravity( 0.7 )
		self.SpawnPosition = self:GetPos()
		self.AlreadyHit = false
		self.Trail = util.SpriteTrail( self , 0 , Color( 127 , 111 , 63 , 255 ) , false , 6 , 0, 0.46 , 1 / 3 , "effects/beam_generic01.vmt" )
	end
end

if CLIENT then

	function ENT:Draw()
		local vel = self:GetVelocity()
		
		if vel == vector_origin then
			self:DrawModel()
			return 
		end
		
		local ang = vel:Angle()
		
		ang:RotateAroundAxis( ang:Forward() , 90 )
		ang:RotateAroundAxis( ang:Right(), 90 )
		ang:RotateAroundAxis( ang:Up() , 500 * CurTime() )
		 
		self:SetAngles( ang )
		self:SetupBones()
		self:DrawModel()
	end
	
end

if SERVER then


	function ENT:Hit( ent )
		self.AlreadyHit = true
		local dm = self.BaseDamage
		
		if self.SpawnPosition:Distance( self:GetPos() ) > self.RampUpMinDistance then
			
			dm = Lerp( self.SpawnPosition:Distance( self:GetPos() ) / self.MaxDamageDistance , 10 , 100 )
			dm = math.Clamp( dm , 9 , 101 )
		end
		
		local damage = dm + (1 + math.Rand(-self.DamageRandomize, self.DamageRandomize))
		
		if ent:IsWorld() then
			local vel = self:GetVelocity()
			local ang = vel:Angle()
			ang:RotateAroundAxis(ang:Right(), 90)
		end

		local owner = self:GetOwner()
		
		if not IsValid( owner ) then 
			owner = self 
		end
		
		local dir
		if ent:IsPlayer() or ent:IsNPC() then
			dir = ( ent:BodyTarget( self:GetPos() ) - self:GetPos() ):GetNormal()
		else
			dir = self:GetVelocity():GetNormal()
		end
		
		local force = self:GetVelocity():Length()*2
		local dmgforce = self:GetVelocity():Angle()
		dmgforce.p = math.Clamp(dmgforce.p - 30, -90, 0)
		dmgforce = dmgforce:Forward() * force
			
		local dmg = DamageInfo()
		dmg:SetAttacker( owner )
		dmg:SetInflictor( self )
		dmg:SetDamage( damage )
		dmg:SetDamagePosition( self:GetPos() )
		dmg:SetDamageType( DMG_BULLET )
		dmg:SetReportedPosition( self:GetPos() )
		dmg:SetDamageForce( dmgforce * dm * 0.25 )
		ent:TakeDamageInfo( dmg )
		
		local theirvel = dmg:GetDamageForce() * 0.05
		ent:SetVelocity( theirvel )
		
		local effectdata = EffectData()
			effectdata:SetOrigin( self:GetPos() )
		util.Effect( "potato_explode" , effectdata )
		
		self:EmitSound( "physics/flesh/flesh_squishy_impact_hard3.wav" )
		self:Remove()
	end

	function ENT:Touch( ent )
		if ent ~= self:GetOwner() and not self.AlreadyHit then
			self:Hit( ent )
		end
	end

end

scripted_ents.Register( ENT , "projectile_potato" , true )
