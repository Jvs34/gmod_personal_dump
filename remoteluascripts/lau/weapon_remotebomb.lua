SWEP = {}

DEFINE_BASECLASS( "weapon_base" )

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
SWEP.Category = "Jvs"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Author			= "Jvs"

SWEP.Spawnable			= true
SWEP.UseHands			= true

SWEP.ViewModel			= "models/error.mdl"
SWEP.FirstViewModel		= "models/weapons/c_grenade.mdl"
SWEP.SecondViewModel	= "models/weapons/c_slam.mdl"
SWEP.WorldModel			= "models/weapons/w_slam.mdl"

SWEP.ViewModelFOV		= 54
SWEP.Primary = {}
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "Grenade"

SWEP.Secondary = {}
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Remote bombs"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= true
SWEP.DrawCrosshair		= true

SWEP.RenderGroup = RENDERGROUP_BOTH

SWEP.STATES = {
	DEPLOY = 1,
	HOLSTER = 2,
	IDLE = 3,
	PULLBACK = 4,
	THROW = 5,
	DETONATE = 6,
}

if CLIENT then


	SWEP.Offsets={
		view = {
			bone = "ValveBiped.Grenade_body",	--TODO: grenade bone
			pos = Vector( 0 , 0 , -1.5 ),
			ang = Angle( 0 , 0 , 0 ),
		},
		world = {
			bone = "ValveBiped.Bip01_R_Hand",
			pos = Vector( 3.5 , -2.3 , -1 ),
			ang = Angle( 0 , 0 , 0 ),
		}
	}
	
	function SWEP:PreDrawViewModel( vm, wep, ply )
		
		--only do this for the viewmodel on the right
		if not IsValid( vm ) or vm:ViewModelIndex() == 0 then
			return true
		end
		
		if vm:ViewModelIndex() == 2 then
			vm:SetMaterial( "engine/occlusionproxy" )
		end
		
	end

	function SWEP:PostDrawViewModel( vm, wep, ply )
	
		if not IsValid( vm ) then
			return
		end
		
		if vm:ViewModelIndex() == 2 then
			vm:SetMaterial()
			if IsValid( self:GetHands2() ) then
				self:GetHands2():DrawModel()
			end
		elseif vm:ViewModelIndex() == 1 then
			--gotta do this manually because we're using custom hands anyway
			if IsValid( self:GetHands1() ) then
				self:GetHands1():DrawModel()
			end
		end
		
		return true
	end
	
	function SWEP:ViewModelDrawn( vm )
		if vm:ViewModelIndex() == 2 then	--right viewmodel handling the grenade animations
			self:DrawModels( true , vm )
		elseif vm:ViewModelIndex() == 1 then	--left viewmodel handling the detonator animations
			--draw a green sprite on the detonator? there's already a red one
		else									--another hand, currently fapping somewhere else
		
		end
    end
    
	function SWEP:DrawModels( view_or_world , vm )
		local ent = ( view_or_world ) and vm or self:GetOwner()
		
		if not IsValid( ent ) then
			ent = self
		end
		
		local offsets = self.Offsets[( view_or_world ) and "view" or "world"]
		
		--wat
		if not offsets then
			return
		end
		
		local boneid = ent:LookupBone( offsets.bone )
		
		if not boneid then
			return
		end
		
		local bonematrix = ent:GetBoneMatrix( boneid )
		
		if not bonematrix then
			return
		end
		
		local pos , ang = LocalToWorld( offsets.pos , offsets.ang , bonematrix:GetTranslation() , bonematrix:GetAngles() )
		
		--draw the BOMB on the grenade bone, A BOMB JC, A BOMB
		
		local bomb = self:GetCurrentBomb()
		
		if IsValid( bomb ) then
			bomb:SetPos( pos )
			bomb:SetAngles( ang )
			bomb:SetupBones()
			bomb:DrawModel()
		end
		
	end
	
    function SWEP:DrawWorldModel()
        self:DrawModels( false )
    end
	
	function SWEP:DrawWorldModelTranslucent()
	
	end
end


function SWEP:Initialize()
	self:SetDeploySpeed( 1 )
	self:SetNextLeftHandAction( CurTime() )
	self:SetNextRightHandAction( CurTime() )
	
	self:SetRightHandState( self.STATES.IDLE )
	self:SetLeftHandState( self.STATES.IDLE )
	self:SetNextPrimaryFire( CurTime() )
	self:SetNextSecondaryFire( CurTime() )
	
	self:SetHoldType( "slam" )
end 

function SWEP:SetupDataTables()
	self:NetworkVar( "Entity" , 0 , "Hands1" )
	self:NetworkVar( "Entity" , 1 , "Hands2" )
	
	self:NetworkVar( "Entity" , 2 , "CurrentBomb" )
	
	self:NetworkVar( "Int" , 0 , "RightHandState" )
	self:NetworkVar( "Int" , 1 , "LeftHandState" )
	
	self:NetworkVar( "Float" , 0 , "NextRightHandAction" )
	self:NetworkVar( "Float" , 1 , "NextLeftHandAction" )
	
end

function SWEP:Deploy()
	self:SetupViewModels( true )
	
	self:SetNextLeftHandAction( CurTime() )
	self:SetNextRightHandAction( CurTime() )
	
	self:SetState( true , self.STATES.DEPLOY , CurTime() )
	self:SetState( false , self.STATES.HOLSTER , CurTime() )
	
	--these are here because of the whole deploy time stuff garry added, they're not used thorough the weapon 
	self:SetNextPrimaryFire( CurTime() )		--garry's stuff
	self:SetNextSecondaryFire( CurTime() )	--garry's stuff
	return true
end

function SWEP:SetupViewModels( setup )
	local vm1 = self:GetVM( 1 )
	
	if IsValid( vm1 ) then
		if setup then
			vm1:SetNoDraw( false )
			vm1:SetWeaponModel( self.SecondViewModel , self )
		else
			vm1:SetNoDraw( true )
		end
	end
	
	local vm2 = self:GetVM( 2 )
	
	if IsValid( vm2 ) then
		if setup then
			vm2:SetNoDraw( false )
			vm2:SetWeaponModel( self.FirstViewModel , self )
		else
			vm2:SetNoDraw( true )
		end
	end
	
	if SERVER then
		if setup and IsValid( vm1 ) then
			if not IsValid( self:GetHands1() ) then
				local hands = ents.Create( "gmod_hands" )
				hands:SetOwner( self:GetOwner() )
				hands:AttachToViewmodel( vm1 )
				hands:Spawn()
				hook.Call( "PlayerSetHandsModel", GAMEMODE, self:GetOwner() , hands )
				self:SetHands1( hands )
			else
				hook.Call( "PlayerSetHandsModel", GAMEMODE, self:GetOwner() , self:GetHands1() )
				self:GetHands1():AttachToViewmodel( vm1 )
			end
		else
			if IsValid( self:GetHands1() ) then
				self:GetHands1():Remove()
				self:SetHands1( NULL )
			end
		end
		
		if setup and IsValid( vm2 ) then
			if not IsValid( self:GetHands2() ) then
				local hands = ents.Create( "gmod_hands" )
				hands:SetOwner( self:GetOwner() )
				hands:AttachToViewmodel( vm2 )
				hands:Spawn()
				hook.Call( "PlayerSetHandsModel", GAMEMODE, self:GetOwner() , hands )
				self:SetHands2( hands )
			else
				hook.Call( "PlayerSetHandsModel", GAMEMODE, self:GetOwner() , self:GetHands2() )
				self:GetHands2():AttachToViewmodel( vm2 )
			end
		else
			if IsValid( self:GetHands2() ) then
				self:GetHands2():Remove()
				self:SetHands2( NULL )
			end
		end
	end
end

function SWEP:GetVM( index )
	if IsValid( self:GetOwner() ) then
		return self:GetOwner():GetViewModel( index )
	end
end

function SWEP:Think()
	
	self:HandleLeftHand()
	self:HandleRightHand()
	
end

function SWEP:SetState( which , state , nexttime )
	if which then
		self:SetRightHandState( state )
		self:SetNextRightHandAction( nexttime )
	else
		self:SetLeftHandState( state )
		self:SetNextLeftHandAction( nexttime )
	end
end

function SWEP:HandleLeftHand()
	--handle the deploy and detonation
	local state = self:GetLeftHandState()
	local canact = self:GetNextLeftHandAction() <= CurTime() and self:GetNextLeftHandAction() ~= -1
	
	if state == self.STATES.DEPLOY and canact then
		
		self:SendViewModelAnim( ACT_SLAM_DETONATOR_DRAW , 1 )
		self:SetState( false , self.STATES.IDLE , CurTime() + 1 )
		
	elseif state == self.STATES.HOLSTER and canact then
		
		self:SendViewModelAnim( ACT_SLAM_DETONATOR_HOLSTER , 1 )
		self:SetState( false , self.STATES.IDLE , CurTime() + 1.25 )
		
	elseif state == self.STATES.DETONATE and canact then
		
		self:EmitSound( "Buttons.snd14" )
		
		if SERVER then
			local stickybombs = self:GetBombs()
			if stickybombs then
			
				if self:GetOwner():IsPlayer() then
					SuppressHostEvents( NULL )	--disregard prediction cull on effect dispatches
					self:GetOwner():LagCompensation( true )	--move props and other players them back where the owner saw them!
				end
				
				for i , v in ipairs( stickybombs ) do
					--that would be so hilarious if the player detonated the bomb in his hand
					if IsValid( v ) and v:IsPrimed() and not v:IsOnWeapon() then
						v:Detonate()
					end
				end
				
				if self:GetOwner():IsPlayer() then
					self:GetOwner():LagCompensation( false )
					SuppressHostEvents( self:GetOwner() )
				end
				
			end
		end
	
		self:SendViewModelAnim( ACT_SLAM_DETONATOR_IDLE , 1 )
		self:SetState( false , self.STATES.IDLE , CurTime() + 0.25 )
	
	elseif state == self.STATES.IDLE and canact then
		self:SendViewModelAnim( ACT_SLAM_DETONATOR_IDLE , 1 )
		self:SetState( false , self.STATES.IDLE , -1 )
	end
	
end

function SWEP:HandleRightHand()
	--handle deploy and throwing
	
	local state = self:GetRightHandState()
	local canact = self:GetNextRightHandAction() <= CurTime() and self:GetNextRightHandAction() ~= -1
	
	if state == self.STATES.DEPLOY and canact then
		self:SetHoldType( "slam" )
		
		self:SendViewModelAnim( ACT_VM_DRAW , 2 )
		self:SetState( true , self.STATES.IDLE , CurTime() + 1 )
		self:RestockBomb()
		
	elseif state == self.STATES.PULLBACK and canact then
		
		if self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
			self:SetState( true , self.STATES.DEPLOY , CurTime() )
			return
		end
		
		if not self:GetOwner():KeyDown( IN_ATTACK ) then
			self:EmitSound("Weapon_Crowbar.Single")
			self:SendViewModelAnim( ACT_VM_THROW , 2 )
			self:GetOwner():DoAttackEvent()
			self:SetState( true , self.STATES.THROW , CurTime() + 0.1 )
		else
			self:SetState( true , state, CurTime() )
		end
		
	elseif state == self.STATES.THROW and canact then
	
		self:ThrowBomb()
		self:SetState( true , self.STATES.DEPLOY , CurTime() + 0.5 )
		self:SetState( false , self.STATES.HOLSTER , CurTime() )
		
	elseif state == self.STATES.IDLE and canact then
		self:SendViewModelAnim( ACT_VM_IDLE , 2 )
		self:SetState( true , self.STATES.IDLE , -1 )
	end
end


function SWEP:PrimaryAttack()

	if self:GetRightHandState() ~= self.STATES.IDLE or self:GetNextRightHandAction() >= CurTime() then
		return
	end
	
	if self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
		return
	end
	
	self:SetHoldType( "grenade" )
	self:SendViewModelAnim( ACT_VM_PULLBACK_HIGH , 2 )
	self:SetState( true , self.STATES.PULLBACK , CurTime() + 0.25 )
end

function SWEP:SecondaryAttack()
	
	if self:GetLeftHandState() ~= self.STATES.IDLE or self:GetNextLeftHandAction() >= CurTime() then
		return
	end
	
	self:SetState( false , self.STATES.DETONATE , CurTime() + 0.1 )
	self:SendViewModelAnim( ACT_SLAM_DETONATOR_DETONATE , 1 )
end

function SWEP:SendViewModelAnim( act , index , rate )
	
	if not game.SinglePlayer() and not IsFirstTimePredicted() then
		return
	end
	
	local vm = self:GetVM( index )
	
	if not IsValid( vm ) then
		return
	end
	
	local seq = vm:SelectWeightedSequence( act )
	
	if seq == -1 then
		return
	end
	
	vm:SendViewModelMatchingSequence( seq )
	vm:SetPlaybackRate( rate or 1 )
end


function SWEP:Holster()
	self:SetupViewModels( false )
    return true
end

function SWEP:RestockBomb()
	
	if IsValid( self:GetCurrentBomb() ) then
		return
	end
	
	if SERVER then
		local bomb = ents.Create( "sent_remotebomb" )
		
		if not IsValid( bomb ) then
			return
		end
		bomb:AddEffects( EF_NOINTERP )
		bomb:SetNoDraw( true )
		bomb:SetExplosionRadius( 250 )
		bomb:SetExplosionDamage( 75 )
		bomb:SetParent( self )	--parent to the weapon, if it gets transmitted, so will the bomb
		bomb:SetThrowerWeapon( self )
		bomb:Spawn()
		self:SetCurrentBomb( bomb )
	end
end

function SWEP:ThrowBomb()
	
	if self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ) <= 0 then
		return false
	end
	
	if not IsValid( self:GetCurrentBomb() ) then
		return false
	end
	
	self:GetOwner():RemoveAmmo( 1 , self:GetPrimaryAmmoType() )
	
	if SERVER then
		local ent = self:GetCurrentBomb()
		ent:RemoveEffects( EF_NOINTERP )
		ent:SetNoDraw( false )
		ent:SetPos( self:GetOwner():EyePos() )
		ent:SetAngles( self:GetOwner():EyeAngles() )
		ent:SetOwner( self:GetOwner() )
		ent:SetThrower( self:GetOwner() )
		ent:SetThrowerWeapon( self )
		ent:SetOwnerForgetTime( CurTime() + 3 )
		ent:SetExplosionPrimeTime( CurTime() + 2 )
		ent:Throw( self:GetOwner():GetAimVector() )
	end
	
	self:SetCurrentBomb( NULL )	--forget about the bomb shared
	
	return true
end

--gets all the bombs, even the one attached to us

function SWEP:GetBombs()
	local tab = {}
	for i , v in ipairs( ents.FindByClass( "sent_remotebomb" ) ) do
		if IsValid( v ) and v:GetThrowerWeapon() == self then
			tab[ #tab + 1 ] = v
		end
	end
	return tab
end


--this will hide the other viewmodel, remove the hands entity and remove all the bombs, even the attached one

function SWEP:OnDrop()
	self:SetupViewModels( false )
	if SERVER then
		for i , v in ipairs( self:GetBombs() ) do
			if IsValid( v ) then
				v:Remove()
			end
		end
	end
end

function SWEP:OnRemove()
	self:OnDrop()
end

weapons.Register( SWEP ,"weapon_remotebomb" , true )

local ENT = {}
ENT.Base             = "base_anim"
ENT.Editable			= false
ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.RenderGroup 		= RENDERGROUP_BOTH

if CLIENT then
	AccessorFunc( ENT , "_nextblip" , "NextBombBlip" )
else
	AccessorFunc( ENT , "_forgettime" , "OwnerForgetTime" )
	AccessorFunc( ENT , "_playedprimedblip" , "PlayedPrimedBlip" )
end

ENT.Size = 1.65

function ENT:SetupDataTables()
	self:NetworkVar( "Bool" , 0 , "Detonated" )
	
	self:NetworkVar( "Entity" , 0 , "Thrower" )
	self:NetworkVar( "Entity" , 1 , "ThrowerWeapon" )
	
	self:NetworkVar( "Float" , 0 , "ExplosionPrimeTime" )
	self:NetworkVar( "Float" , 1 , "ExplosionDamage" )
	self:NetworkVar( "Float" , 2 , "ExplosionRadius" )
	self:NetworkVar( "Float" , 3 , "CreatedTime" )
end

function ENT:Initialize()
	
	if SERVER then
		self:SetPlayedPrimedBlip( false )
		self:SetOwnerForgetTime( 0 )
		self:SetExplosionPrimeTime( 0 )
		self:SetDetonated( false )
		self:SetTransmitWithParent( true )
		self:SetTrigger( true )
		self:SetModelScale( 0.1 , 0 )	--TODO: tweak the size to correspond to the actual hull / phyobj
		self:SetModel( "models/combine_helicopter/helicopter_bomb01.mdl" )
		self:SetCollisionBounds( Vector( -self.Size , -self.Size, -self.Size ) * 2, Vector( self.Size , self.Size, self.Size ) * 2 )
		self:RemovePhysics()
	else
		self:MarkShadowAsDirty()
		self:SetNextBombBlip( 0 )
		self.CLModels = {}
	end
	
end

function ENT:IsOnWeapon()
	return self:GetNoDraw() and IsValid( self:GetParent() ) and self:GetSolid() == SOLID_NONE and self:GetMoveType() == MOVETYPE_NONE
end

function ENT:Think()
	if SERVER then
		if self:IsPrimed() and not self:GetPlayedPrimedBlip() then
			self:EmitSound( "Buttons.snd15" )
			self:SetPlayedPrimedBlip( true )
		end
	
		if self:GetOwnerForgetTime() > 0 and self:GetOwnerForgetTime() <= CurTime() then
			self:SetOwner( NULL )
			self:SetOwnerForgetTime( 0 )
		end
		
		--[[
		if not self:IsOnWeapon() and self:GetSolid() == SOLID_NONE then
			if not IsValid( self:GetParent() ) then
				self:Detach()
			end
		end
		]]
		
	else
		self:HandlePrediction()
		self:HandleDynamicLight()
		self:HandleModels()
	end
end

function ENT:IsPrimed()
	return self:GetExplosionPrimeTime() <= CurTime() and self:GetExplosionPrimeTime() ~= 0
end

if SERVER then

	function ENT:InitPhysics()
		self:PhysicsInitSphere( self.Size , "metal" )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )

		local physobj = self:GetPhysicsObject()

		if IsValid( physobj ) then
			physobj:SetMass( 85 )
		end
		
		return physobj
	end

	function ENT:RemovePhysics()
		self:PhysicsDestroy()
		self:SetMoveType( MOVETYPE_NONE )
		self:SetSolid( SOLID_NONE )
	end
	
	function ENT:AttachTo( ent )
		
		if not IsValid( ent ) or ent:GetNoDraw() then
			return
		end
		
		self:RemovePhysics()
		self:SetParent( ent )
	end
	
	function ENT:Detach()
		self:SetParent( NULL )
		self:InitPhysics()
	end
	
	function ENT:Detonate()
	
		if not self:IsPrimed() or self:GetDetonated() then
			return
		end
		
		local inflictor = self
		local attacker = self
		
		if IsValid( self:GetThrowerWeapon() ) then
			attacker = self:GetThrowerWeapon()
		end
		
		if IsValid( self:GetThrower() ) then
			attacker = self:GetThrower()
		end
		
		local dmg = self:GetExplosionDamage()
		local radius = self:GetExplosionRadius()
		
		local dmginfo = DamageInfo()
		dmginfo:SetAttacker( attacker )
		dmginfo:SetInflictor( inflictor )
		dmginfo:SetDamage( dmg )
		dmginfo:SetDamageType( bit.bor( DMG_ALWAYSGIB , DMG_CLUB , DMG_PREVENT_PHYSICS_FORCE ) )
		dmginfo:SetDamageForce( vector_origin )
		dmginfo:SetDamagePosition( self:GetPos() )
		
		util.BlastDamageInfo( dmginfo , self:GetPos(), radius )
		util.ScreenShake( self:GetPos() , 3 , dmg , 0.25 , radius * 2 )
		--util.BlastDamage( inflictor , attacker , self:GetPos() , radius , dmg )
		
		local effect = EffectData()
		effect:SetOrigin( self:GetPos() )
		effect:SetMagnitude( dmg )	--this is actually the force of the explosion
		effect:SetFlags( bit.bor( 0x80 , 0x20 ) ) --NOFIREBALLSMOKE, ROTATE
		util.Effect( "Explosion" , effect )
		
		self:Remove()
		self:SetDetonated( true )
	end

	function ENT:Throw( direction )
		self:SetParent( NULL )
		self:SetTransmitWithParent( false )
		
		local physobj = self:InitPhysics()
		
		if IsValid( physobj ) then
			physobj:AddVelocity( direction * 100 * physobj:GetMass() )
			--physobj:AddAngleVelocity( direction * 300 * physobj:GetMass() )
		end
		
		self:SetCreatedTime( CurTime() )
	end
	
	--can only attach to something when we're not primed
	function ENT:EndTouch( ent )
		--[[
		if not self:IsPrimed() then
			self:AttachTo( ent )
		end
		]]
	end
	
else

	
	function ENT:HandlePrediction()
		local bool = self:IsOnWeapon()
		if self:GetPredictable() ~= bool then
			self:SetPredictable( bool )
		end
	end
	
	ENT.GlowSprite = Material( "" )
	ENT.FriendlyColor = Color( 170 , 255 , 170 , 255 )
	ENT.EnemyColor = Color( 255 , 170 , 170 , 255 )
	ENT.WireFrame = Material( "models/wireframe" )
	
	function ENT:Draw( flags )
		
		if GetConVar( "vcollide_wireframe" ):GetBool() then
			local mins, maxs = self:GetCollisionBounds()
			render.SetMaterial( self.WireFrame )
			render.DrawSphere( self:GetPos() , self.Size , 16 , 16 , color_white )
			render.DrawBox( self:GetPos(), angle_zero, mins, maxs, color_white, true )
		end
		
		self:DrawCLModels()
		
		--dirty hack because manually calling :DrawModel outside of here doesn't pass the translucent flag
		--this is needed during the viewmodel draw
		if self:IsOnWeapon() then
			self:DrawTranslucent( flags )
		end
		
	end
	
	function ENT:DrawTranslucent( flags )
		
		if not self:IsPrimed() then
			return
		end
		
		local spritesize = self.Size / 2
		
		local color = self:GetLightColor()
		
		--render.SetMaterial( self.GlowSprite )
		--render.DrawSprite( self:GetPos() , spritesize , spritesize , color )
	end
	
	--TODO: draw hoverball model
	function ENT:DrawCLModels()
		self:DrawModel()
	end
	
	function ENT:GetLightColor()
		
		if self:GetThrower() == LocalPlayer() then
			return self.FriendlyColor
		end
		
		return self.EnemyColor
	end
	
	function ENT:HandleDynamicLight()
		
		if not self:IsPrimed() then
			return
		end
		
		local light = DynamicLight( self:EntIndex() )
		
		if not light then
			return
		end
		
		local lightcol = self:GetLightColor()
		
		light.Pos = self:GetPos()
		light.r = lightcol.r
		light.g = lightcol.g
		light.b = lightcol.b
		light.Brightness = 1
		light.Size = 250
		light.Decay = 1000
		light.DieTime = UnPredictedCurTime() + 1
	end
	
	function ENT:HandleModels()
		--create the models if necessary
	end
	
end

function ENT:OnRemove()
	if CLIENT then
		for i , v in pairs( self.CLModels ) do
			if IsValid( v ) then
				v:Remove()
			end
		end
	else
		
	end
end

scripted_ents.Register( ENT ,"sent_remotebomb" , true )

SWEP = nil