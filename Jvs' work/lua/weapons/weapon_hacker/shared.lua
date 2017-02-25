if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
	SWEP.Slot				= 0
	SWEP.SlotPos			= 5
end
SWEP.BatteryPerEnemy=2;//Modify this variable to set how much battery consumes the emp per enemy killed.
SWEP.EnemyInRange=0;	
if ( CLIENT ) then
	SWEP.DrawAmmo			= false
	SWEP.PrintName			= "Emp Impulse"
	SWEP.Author				= "Jvs"
	SWEP.Instructions = "Primary: Destroy every elettronic component in range.\nThe ammo on the left is the battery you are going to consume.\nUses "..SWEP.BatteryPerEnemy.." suit battery per enemy,don't use it underwater."
	SWEP.DrawCrosshair		= false
	killicon.AddFont( "weapon_hacker", "HL2MPTypeDeath", "*", Color( 255, 80, 0, 255 ) )
	
	function SWEP:CustomAmmoDisplay()
	self.AmmoDisplay =  {}  //self.AmmoDisplay or {}
    self.AmmoDisplay.Draw = true 
		self.AmmoDisplay.PrimaryClip = self.EnemyInRange*self.BatteryPerEnemy  //This will show the client how much battery is going consume
		self.AmmoDisplay.PrimaryAmmo = LocalPlayer():Armor(); 
	return self.AmmoDisplay
	end
	
end

SWEP.Category = "Jvs" 

SWEP.Spawnable     			= false
SWEP.AdminSpawnable  		= true

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= true

SWEP.ViewModel="models/weapons/v_slam.mdl";
SWEP.WorldModel="models/weapons/w_slam.mdl";

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

function SWEP:Initialize()
	if (CLIENT) then return end
	self:SetWeaponHoldType("slam")
	self.InWaterDmg=25; //Modify this variable to set how much damage does the emp to everything under water.
end 
	



function SWEP:Think()
	self.EnemyInRange=0;
		local entz=ents.FindInSphere(self:GetPos(), 500)
		for _,ent in pairs(entz) do
			if(ent:GetClass()=="npc_rollermine" 
			|| ent:GetClass()=="npc_cscanner" 
			|| ent:GetClass()=="npc_clawscanner"
			|| ent:GetClass()=="npc_manhack"
			|| ent:GetClass()=="npc_turret_floor"
			|| ent:GetClass()=="npc_turret_ceiling"
			|| ent:GetClass()=="combine_mine"
			|| ent:GetClass()=="npc_satchel"
			|| ent:GetClass()=="npc_tripmine")then
			self.EnemyInRange=self.EnemyInRange+1;
			end
		end
end

function SWEP:Holster()
	if (CLIENT) then return end
	return true
end

function SWEP:PrimaryAttack()
	self.Weapon:SendWeaponAnim( ACT_SLAM_DETONATOR_DETONATE )
	if(self.Owner:Armor()>=self.BatteryPerEnemy)then
		if(self.Owner:WaterLevel()!=0)then //I told you to not use this weapon underwater...
			self.Owner:EmitSound("NPC_RollerMine.Shock");
			local DMG=DamageInfo();
			DMG:SetDamage(self.InWaterDmg);
			DMG:SetDamageType(DMG_SHOCK);
			DMG:SetAttacker(self:GetOwner());
			DMG:SetInflictor(self:GetOwner());
			local entz=ents.FindInSphere(self.Owner:GetPos(), 2000)
			for _,ent in pairs(entz) do
				if(ent:WaterLevel()!=0)then ent:TakeDamageInfo(DMG)end //everyone underwater will be elettrocutted
			end
		else
		self:EmitSound("weapons/slam/buttonclick.wav")
		self:EMP();
		end
	else
	self:EmitSound("player/suit_denydevice.WAV");

	end
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
end

function SWEP:SecondaryAttack()

end

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_SLAM_DETONATOR_DRAW )
self:SetDeploySpeed(1)
return true
end
function SWEP:Reload()

end

function SWEP:EMP()
	local DMG=DamageInfo();
	DMG:SetDamage(100);
	DMG:SetDamageType(DMG_BLAST);
	DMG:SetAttacker(self:GetOwner());
	DMG:SetInflictor(self:GetOwner());
	local entz=ents.FindInSphere(self:GetPos(), 500)
	for _,ent in pairs(entz) do
		if((ent:GetClass()=="npc_rollermine" || ent:GetClass()=="npc_cscanner" || ent:GetClass()=="npc_clawscanner") && self.Owner:Armor()>=self.BatteryPerEnemy)then
		if(ent:GetClass()=="npc_rollermine")then
		ent:Fire("powerdown",""); 
		else
		ent:TakeDamageInfo(DMG);
		end
		local effect = EffectData()
					effect:SetStart(ent:GetPos())
					effect:SetOrigin(ent:GetPos())
					effect:SetScale(25)
					effect:SetRadius(25);
					util.Effect("cball_explode", effect)
					self.Owner:SetArmor(self.Owner:Armor()-self.BatteryPerEnemy);
					ent:EmitSound("npc/roller/mine/rmine_tossed1.wav")
		elseif(ent:GetClass()=="npc_manhack" && self.Owner:Armor()>=self.BatteryPerEnemy)then
		ent:TakeDamageInfo(DMG);
					local effect = EffectData()
					effect:SetStart(ent:GetPos())
					effect:SetOrigin(ent:GetPos())//self:GetPos()+ Vector(0, 0, 10)
					effect:SetScale(25)
					effect:SetRadius(25);
					util.Effect("cball_explode", effect)
					self.Owner:SetArmor(self.Owner:Armor()-self.BatteryPerEnemy);
					ent:EmitSound("npc/roller/mine/rmine_tossed1.wav")
		elseif((ent:GetClass()=="npc_turret_floor" || ent:GetClass()=="npc_turret_ceiling") && self.Owner:Armor()>=self.BatteryPerEnemy)then
		ent:Fire("disable",""); 
		ent:Fire("selfdestruct","");
					local effect = EffectData()
					effect:SetStart(ent:GetPos())
					effect:SetOrigin(ent:GetPos())//self:GetPos()+ Vector(0, 0, 10)
					effect:SetScale(25)
					effect:SetRadius(25);
					util.Effect("cball_explode", effect)
					self.Owner:SetArmor(self.Owner:Armor()-self.BatteryPerEnemy);
					ent:EmitSound("npc/roller/mine/rmine_tossed1.wav")
		elseif(ent:GetClass()=="combine_mine" && self.Owner:Armor()>=self.BatteryPerEnemy)then
		ent:Fire("disarm","");
					local effect = EffectData()
					effect:SetStart(ent:GetPos())
					effect:SetOrigin(ent:GetPos())//self:GetPos()+ Vector(0, 0, 10)
					effect:SetScale(25)
					effect:SetRadius(25);
					util.Effect("cball_explode", effect)
					self.Owner:SetArmor(self.Owner:Armor()-self.BatteryPerEnemy);
					ent:EmitSound("npc/roller/mine/rmine_tossed1.wav")
		elseif( (ent:GetClass()=="npc_satchel" || ent:GetClass()=="npc_tripmine") && self.Owner:Armor()>=self.BatteryPerEnemy)then
		ent:TakeDamageInfo(DMG);
					local effect = EffectData()
					effect:SetStart(ent:GetPos())
					effect:SetOrigin(ent:GetPos())//self:GetPos()+ Vector(0, 0, 10)
					effect:SetScale(25)
					effect:SetRadius(25);
					util.Effect("cball_explode", effect)
					self.Owner:SetArmor(self.Owner:Armor()-self.BatteryPerEnemy);
					ent:EmitSound("npc/roller/mine/rmine_tossed1.wav")
		end
	end
end