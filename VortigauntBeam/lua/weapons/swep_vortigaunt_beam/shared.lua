if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	
	resource.AddFile("models/weapons/v_vortbeamvm.mdl")
	resource.AddFile("materials/vgui/entities/swep_vortigaunt_beam.vmt")
	resource.AddFile("materials/vgui/killicons/swep_vortigaunt_beam.vmt")
	
	
	
	
	SWEP.AutoSwitchTo		= true
	SWEP.AutoSwitchFrom		= true
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName			= "Vortigaunt Beam"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= true
	SWEP.ViewModelFOV		= 54

	SWEP.Contact		= "jvs_34@yahoo.it"
	SWEP.Purpose		= "Zap everything! Vortigaunt Style"
	SWEP.Instructions	= "Primary: Vortigaunt zap.\nSecondary: Self battery healing."

	killicon.Add("swep_vortigaunt_beam","VGUI/killicons/swep_vortigaunt_beam",Color(255,255,255));
end

SWEP.Category				= "Jvs" 
SWEP.Slot					= 3
SWEP.SlotPos				= 5
SWEP.Weight					= 5
SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel 				= "models/weapons/v_vortbeamvm.mdl"
SWEP.WorldModel 			= ""

SWEP.Range					= 2*GetConVarNumber( "sk_vortigaunt_zap_range",100)*12//because it's in feet,we convert it.
SWEP.DamageForce			= 48000	 //12000 is the force done by two vortigaunts claws zap attack
SWEP.AmmoPerUse				= 1		 //we use ar2 altfire ammo,don't exagerate here	
SWEP.HealSound				= Sound("NPC_Vortigaunt.SuitOn")
SWEP.HealLoop				= Sound("NPC_Vortigaunt.StartHealLoop")
SWEP.AttackLoop				= Sound("NPC_Vortigaunt.ZapPowerup" )
SWEP.AttackSound			= Sound("NPC_Vortigaunt.ClawBeam")
SWEP.HealDelay				= 1		//we heal again CurTime()+self.HealDelay
SWEP.MaxArmor				= 18	//used for the math.random
SWEP.MinArmor				= 12	//"		"	"	"
SWEP.ArmorLimit				= 100	//100 is the default hl2 armor limit
SWEP.BeamDamage				= 100	//25 is done by one zap attack,since vortigaunt has two claws,50 dmg,
									//100 is the real damage,try to make a vortigaunt hate you,and if you have 100 hp,you will be oneshotted
SWEP.BeamChargeTime			= 1.25	//the delay used to charge the beam and zap!
SWEP.Deny					= Sound("Buttons.snd19")			

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 5		//give the poor user 5 combine balls to have fun with this wepon
SWEP.Primary.Ammo 			= "AR2AltFire"
SWEP.Primary.Automatic		= true


SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo 		= false
SWEP.Secondary.Automatic 	= true

function SWEP:Initialize()
	self.Charging=false;//we are not charging!
	self.Healing=false;	//we are not healing!
	self.HealTime=CurTime();//we can heal
	self.ChargeTime=CurTime();//we can zap
	self:SetWeaponHoldType("slam")//this is the better holdtype i could find,well,it fits its job
	if (CLIENT) then return end
	self:CreateSounds()			//create the looping sounds	
end 

function SWEP:Precache()
	PrecacheParticleSystem( "vortigaunt_beam" );		//the zap beam
	PrecacheParticleSystem( "vortigaunt_beam_charge" );	//the glow particles
	util.PrecacheModel(self.ViewModel)					//the... come on,that's obvious
end

function SWEP:CreateSounds()

	if (!self.ChargeSound) then
		self.ChargeSound = CreateSound( self.Weapon, self.AttackLoop );
	end
	if (!self.HealingSound) then
		self.HealingSound = CreateSound( self.Weapon, self.HealLoop );
	end
end

function SWEP:DispatchEffect(EFFECTSTR)
	local pPlayer=self.Owner;
	if !pPlayer then return end
	local view;
	if CLIENT then view=GetViewEntity() else view=pPlayer:GetViewEntity() end
		if ( !pPlayer:IsNPC() && view:IsPlayer() ) then
			ParticleEffectAttach( EFFECTSTR, PATTACH_POINT_FOLLOW, pPlayer:GetViewModel(), pPlayer:GetViewModel():LookupAttachment( "muzzle" ) );
		else
			ParticleEffectAttach( EFFECTSTR, PATTACH_POINT_FOLLOW, pPlayer, pPlayer:LookupAttachment( "anim_attachment_rh" ) );
		end
end

function SWEP:ShootEffect(EFFECTSTR,startpos,endpos)
	local pPlayer=self.Owner;
	if !pPlayer then return end
	local view;
	if CLIENT then view=GetViewEntity() else view=pPlayer:GetViewEntity() end
		if ( !pPlayer:IsNPC() && view:IsPlayer() ) then
			util.ParticleTracerEx( EFFECTSTR, self.Weapon:GetAttachment( self.Weapon:LookupAttachment( "muzzle" ) ).Pos,endpos, true, pPlayer:GetViewModel():EntIndex(), pPlayer:GetViewModel():LookupAttachment( "muzzle" ) );
		else
			util.ParticleTracerEx( EFFECTSTR, pPlayer:GetAttachment( pPlayer:LookupAttachment( "anim_attachment_rh" ) ).Pos,endpos, true,pPlayer:EntIndex(), pPlayer:LookupAttachment( "anim_attachment_rh" ) );
		end
end
	
function SWEP:ImpactEffect( traceHit )
	local data = EffectData();
	data:SetOrigin(traceHit.HitPos)
	data:SetNormal(traceHit.HitNormal)
	data:SetScale(20)
	util.Effect( "StunstickImpact", data );
	local rand=math.random(1,1.5);
	self:CreateBlast(rand,traceHit.HitPos)
	self:CreateBlast(rand,traceHit.HitPos)											
	if SERVER && traceHit.Entity && IsValid(traceHit.Entity) && string.find(traceHit.Entity:GetClass(),"ragdoll") then
		traceHit.Entity:Fire("StartRagdollBoogie");
		/*
		local boog=ents.Create("env_ragdoll_boogie")
		boog:SetPos(traceHit.Entity:GetPos())
		boog:SetParent(traceHit.Entity)
		boog:Spawn()
		boog:SetParent(traceHit.Entity)
		*/
	end
end

function SWEP:CreateBlast(scale,pos)
	if CLIENT then return end
	local blastspr = ents.Create("env_sprite");			//took me hours to understand how this damn
	blastspr:SetPos( pos );								//entity works
	blastspr:SetKeyValue( "model", "sprites/vortring1.vmt")//the damn vortigaunt beam ring
	blastspr:SetKeyValue( "scale",tostring(scale))
	blastspr:SetKeyValue( "framerate",60)
	blastspr:SetKeyValue( "spawnflags","1")
	blastspr:SetKeyValue( "brightness","255")
	blastspr:SetKeyValue( "angles","0 0 0")
	blastspr:SetKeyValue( "rendermode","9")
	blastspr:SetKeyValue( "renderamt","255")
	blastspr:Spawn()
	blastspr:Fire("kill","",0.45)							//remove it after 0.45 seconds
end						
function SWEP:Shoot(dmg,effect)
	local pPlayer=self.Owner
	if !pPlayer then return end
	//so you can't just snipe with the long range of 16384 game units
	local traceres=util.QuickTrace(self.Owner:EyePos(),self.Owner:GetAimVector()*self.Range,self.Owner)
	self:ShootEffect(effect or "vortigaunt_beam",pPlayer:EyePos(),traceres.HitPos)	//shoop da whoop
	if SERVER then
		if IsValid(traceres.Entity) then	//we hit something
		local DMG=DamageInfo()
		DMG:SetDamageType(DMG_SHOCK)		//it's called vortigaunt zap attack for a reason
		DMG:SetDamage(dmg or self.BeamDamage)
		DMG:SetAttacker(self.Owner)
		DMG:SetInflictor(self)
		DMG:SetDamagePosition(traceres.HitPos)
		DMG:SetDamageForce(pPlayer:GetAimVector()*self.DamageForce)
		traceres.Entity:TakeDamageInfo(DMG)
		end
	end
	self.Owner:GetViewModel():EmitSound(self.AttackSound)
	self:ImpactEffect( traceres )
end

function SWEP:Holster( wep )
	self:StopEveryThing()
	return true
end

function SWEP:OnRemove()
	self:StopEveryThing()
end

function SWEP:StopEveryThing()
	self.Charging=false;
	if SERVER && self.ChargeSound then
		self.ChargeSound:Stop();
	end
	self.Healing=false;
	if SERVER && self.HealingSound then
		self.HealingSound:Stop();
	end
	
	local pPlayer = self.LastOwner;
	if (!pPlayer) then
		return;
	end
	local Weapon = self.Weapon
		if (!pPlayer) then return end
		if (!pPlayer:GetViewModel()) then return end
		if ( CLIENT ) then if ( pPlayer == LocalPlayer() ) then pPlayer:GetViewModel():StopParticles();end	end
		pPlayer:StopParticles();
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( 1 )
	return true
end

function SWEP:Think()
	if self.Owner && IsValid(self.Owner)then self.LastOwner=self.Owner end //i hate doing this,whatever
	//i send the weapon animation before the actual shooting because the gravity gloves attack is delayed...
	if self.Charging && self.ChargeTime-0.25 < CurTime() && !self.attack then
		
		if self.Owner:GetAmmoCount(self.Primary.Ammo)>=self.AmmoPerUse then//check always if we have ammo
			self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
			self:DispatchEffect("vortigaunt_charge_token")//this effect lags a lot,but we see it for 0.75 seconds,who cares
			//self.Owner:SetAnimation(PLAYER_ATTACK1)	//todo:sincronize the world model player attack
			//and,send the idle animation
			timer.Simple(0.75,function()if !IsValid(self.Owner) || self.Owner:GetActiveWeapon()!=self || !IsValid(self)  then return end self.Weapon:SendWeaponAnim(ACT_VM_IDLE)end)
		end
		self.attack=true;
	end
	
	if self.Charging && self.ChargeTime < CurTime() then
		
		if self.Owner:GetAmmoCount(self.Primary.Ammo)<self.AmmoPerUse then 
			//what the hell? something stole my ammo!
			self.Weapon:EmitSound(self.Deny)
			self.Weapon:SetNextPrimaryFire(CurTime()+SoundDuration(self.Deny))
			self.Weapon:SetNextSecondaryFire(CurTime()+SoundDuration(self.Deny))
			if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
			self.Owner:StopParticles()
			self.Charging=false;
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
			if SERVER && self.ChargeSound then	self.ChargeSound:Stop();end
			return
		end
		
		self.Owner:RemoveAmmo(self.AmmoPerUse,self.Primary.Ammo);
		if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
		self.Owner:StopParticles()
		self:Shoot()
		self.Charging=false;
	
		self.attack=false;
		if SERVER && self.ChargeSound then	self.ChargeSound:Stop();end
		
		self.Weapon:SetNextPrimaryFire(CurTime()+1)
		self.Weapon:SetNextSecondaryFire(CurTime()+1)
	end
	
	if self.Healing && self.HealTime<CurTime() then
		if self.Owner:GetAmmoCount(self.Primary.Ammo)<self.AmmoPerUse || self.Owner:Armor()>=self.ArmorLimit then 
		self.Weapon:EmitSound(self.Deny)
		self.Weapon:SetNextPrimaryFire(CurTime()+SoundDuration(self.Deny))
		self.Weapon:SetNextSecondaryFire(CurTime()+SoundDuration(self.Deny))
		if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
		self.Owner:StopParticles()
		self.Healing=false;
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		if SERVER && self.HealingSound then	self.HealingSound:Stop();end
		return
		end
		self.Owner:RemoveAmmo(self.AmmoPerUse,self.Primary.Ammo);
		if IsValid(self.Owner:GetViewModel())then self.Owner:GetViewModel():StopParticles() end
		self.Owner:StopParticles()
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
		self.Healing=false;
		self.Owner:EmitSound(self.HealSound)
		if SERVER && self.HealingSound then	self.HealingSound:Stop();end
		self:GiveArmor()
		self.Weapon:SetNextPrimaryFire(CurTime()+1)
		self.Weapon:SetNextSecondaryFire(CurTime()+1)
	end
end

function SWEP:GiveArmor()
	if CLIENT then return end
	local arm=math.random(self.MinArmor,self.MaxArmor)
	local plarm=self.Owner:Armor()
	if plarm>=self.ArmorLimit then return end
	if plarm <= (self.ArmorLimit - arm) then
	self.Owner:SetArmor( plarm + arm )
	else
	self.Owner:SetArmor(self.ArmorLimit)
	end
				
end


function SWEP:PrimaryAttack()
	if self.Charging || self.Healing then return end
	
	if self.Owner:GetAmmoCount(self.Primary.Ammo)<self.AmmoPerUse then 
	self.Weapon:EmitSound(self.Deny)
	self.Weapon:SetNextPrimaryFire(CurTime()+SoundDuration(self.Deny))
	self.Weapon:SetNextSecondaryFire(CurTime()+SoundDuration(self.Deny))
	return 
	end
	
	self:DispatchEffect("vortigaunt_charge_token_b")
	self:DispatchEffect("vortigaunt_charge_token_c")
	self.ChargeTime=CurTime()+self.BeamChargeTime;
	self.attack=false;
	self.Charging=true
	self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
	
	//commented because util.particletracer does not follow the attachment pos
	//and ParticleEffectAttach does not let you set the endpoint of an effect,or it does?
	/*
	self:ShootEffect("vortigaunt_beam_charge",self.Owner:EyePos(),self.Owner:GetPos()+Vector(0,32,0))
	self:ShootEffect("vortigaunt_beam_charge",self.Owner:EyePos(),self.Owner:GetPos()+Vector(0,-32,0))
	self:ShootEffect("vortigaunt_beam_charge",self.Owner:EyePos(),self.Owner:GetPos()+Vector(32,0,0))
	self:ShootEffect("vortigaunt_beam_charge",self.Owner:EyePos(),self.Owner:GetPos()+Vector(-32,0,0))
	*/
	if SERVER && self.ChargeSound then
	self.ChargeSound:PlayEx( 100, 150 );
	end
	self.Weapon:SetNextPrimaryFire(CurTime()+3)
	self.Weapon:SetNextSecondaryFire(CurTime()+3)
end


function SWEP:SecondaryAttack()
	if self.Charging || self.Healing || self.Owner:Armor()>=self.ArmorLimit then return end
		if self.Owner:GetAmmoCount(self.Primary.Ammo)<self.AmmoPerUse  then 
		self.Weapon:EmitSound(self.Deny)
		self.Weapon:SetNextPrimaryFire(CurTime()+SoundDuration(self.Deny))
		self.Weapon:SetNextSecondaryFire(CurTime()+SoundDuration(self.Deny))
		return 
		end
		self.HealTime=CurTime()+self.HealDelay;
		self.Healing=true;
	self:DispatchEffect("vortigaunt_charge_token")
	self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
	if SERVER && self.HealingSound then
	self.HealingSound:PlayEx( 100, 150 );
	end

	self.Weapon:SetNextPrimaryFire(CurTime()+1)
	self.Weapon:SetNextSecondaryFire(CurTime()+1)
end

function SWEP:Reload()
end
