if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end
if ( CLIENT ) then
	SWEP.DrawAmmo			= false
	SWEP.PrintName			= "Sonic Sprint"
	SWEP.Author				= "Jvs"
	SWEP.Purpose		= ""
	SWEP.Instructions	= "Become pure energy and dissolve anything in your path."
	SWEP.DrawCrosshair		= false
	surface.CreateFont("HalfLife2", 44, 400, true, false, "Hl2D")
	killicon.AddFont( "weapon_sonic_sprint", "Hl2D", "D", Color( 255, 80, 0, 255 ) )
	function SWEP:DrawHUD()
		local var=self:GetNWFloat("speed");
		draw.SimpleText("D", "Hl2D", 24,ScrW() / 2, Color(255, 0, 0, 255), 1, 1)
	end
end

SWEP.Category = "Jvs" 
SWEP.ViewModelFOV	= 62
SWEP.Spawnable     			= false
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel				= ""
SWEP.WorldModel				= ""

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic		= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

function SWEP:Initialize()
	if (SERVER) then 
	self:SetWeaponHoldType("normal")
	end
	self.Trail=nil;
	self.OLDRUNSPEED=500;
	self.Var=false;
	self:SetNWFloat("speed",self.Var);
	self.LastOwner=nil;
	self.NextIncrease=CurTime()+1;
	self.SoundPlayed=false;
	self.SpeedSound=Sound("NPC_CombineBall.HoldingInPhysCannon")
end 

function SWEP:Holster()
	self:Discharge(self.Owner)
	return true
end

function SWEP:PrimaryAttack()

end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( 1 )
	return true
end
function SWEP:Reload()
end
function SWEP:SecondaryAttack()
end

function SWEP:Think()
	if CLIENT then return end
	if(self.Owner:KeyDown(IN_SPEED))then
			self.Var=true;
			if(self.Var==true)then
				if(self.SoundPlayed==false)then
					self.Owner:EmitSound("AlyxEMP.Discharge")
					self.Owner:EmitSound(self.SpeedSound)
					self.SoundPlayed=true;
				end
				if(!IsValid(self.Trail))then self:CreateTrail() end
				self.Owner:SetRunSpeed(self.OLDRUNSPEED*5);
				self.Owner:SetMaterial("Models/effects/comball_sphere")
			end
		self.LastOwner=self.Owner;
	else
		if(self.Var==true)then
		self.Var=false;
		self:Discharge(self.Owner)
		end
	end
	
end

function SWEP:OnDrop()
	self:DestroyTrail()
	self.Var=false;
	self:SetNWFloat("speed",self.Var);
	if(self.LastOwner && IsValid(self.LastOwner))then
	self:Discharge(self.LastOwner)
	end
	
end

function SWEP:OnRemove()
	self:DestroyTrail()
	self.Var=false;
	self:SetNWFloat("speed",self.Var);
	if(self.LastOwner && IsValid(self.LastOwner))then
	self:Discharge(self.LastOwner)
	end
end

function SWEP:Discharge(Ownah)
		if(self.SoundPlayed==true)then
			Ownah:EmitSound("AlyxEMP.Discharge")
			self.SoundPlayed=false;
		end
		Ownah:StopSound(self.SpeedSound)
		Ownah:SetRunSpeed(self.OLDRUNSPEED);
		Ownah:SetMaterial("")
		self:DestroyTrail()
		self.Var=false;
		self:SetNWFloat("speed",self.Var);
end


function SWEP:CreateTrail()
	if SERVER then
	self.Trail = util.SpriteTrail( self,0,Color( 215, 244, 23, 244 ),true,32.0,8,0.5,1,"sprites/combineball_trail_black_1.vmt")
	end
end

function SWEP:DestroyTrail()
	if SERVER then
	if(self.Trail && IsValid(self.Trail))then self.Trail:Remove(); end
	end
end

function SonicSprint(ent1,ent2)
		if(ent1:IsPlayer() && ent1:GetActiveWeapon() != NULL && ent1:GetActiveWeapon():GetClass()=="weapon_sonic_sprint" && ent1:GetActiveWeapon().Var==true)then
			local dmg=DamageInfo();
			dmg:SetAttacker(ent1)
			dmg:SetInflictor(ent1:GetActiveWeapon())
			dmg:SetDamage(100);//a combine ball does heavy damage,tought you are not a combine ball,whatever...
			dmg:SetDamageType(DMG_DISSOLVE)
			dmg:SetDamageForce(ent1:GetAimVector()*900000)
			dmg:SetDamagePosition(ent2:GetPos())
			if SERVER && ent1:GetMoveType()==MOVETYPE_WALK && ent1:GetPos():Distance( ent2:GetPos() )<=200 && ent1:GetActiveWeapon().Var==true then 
			ent2:TakeDamageInfo(dmg)
			end
		end
end
hook.Add("ShouldCollide","SonicSprint",SonicSprint)

function SonicSprintDMG(victim, attacker)
	if(victim:IsPlayer() && victim:GetActiveWeapon() != NULL && victim:GetActiveWeapon():GetClass()=="weapon_sonic_sprint" && victim:GetActiveWeapon().Var==true)then
		return false;
	end
end
 
hook.Add( "PlayerShouldTakeDamage", "SonicSprintDMG", SonicSprintDMG)