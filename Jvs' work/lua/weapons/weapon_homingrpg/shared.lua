if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= false
	SWEP.PrintName			= "Homing Rpg"
	SWEP.Author				= "Jvs,credits to Sakarias88 for his awesome\nmissile sent. (from HelicopterVehicle Addon)"
	SWEP.DrawCrosshair		= true
	killicon.AddFont( "weapon_homingrpg", "HL2MPTypeDeath", "3", Color( 255, 80, 0, 255 ) )
	
	SWEP.AmmoXT				= ScrW() * 0.929292
	SWEP.AmmoYT				= ScrH() * 0.8866719
	SWEP.AmmoX				= ScrW() - ScrW()/9.5
	SWEP.AmmoY				= ScrH() - ScrH()/9.5

local PANEL = {}


function PANEL:SetModel( strModelName )

	if ( IsValid( self.Entity ) ) then
		self.Entity:Remove()
		self.Entity = nil		
	end
	
	if ( !ClientsideModel ) then return end
	
	self.Entity = ClientsideModel( strModelName, RENDER_GROUP_OPAQUE_ENTITY )
	if ( !IsValid(self.Entity) ) then return end
	
	self.Entity:SetNoDraw( true )
			
end


vgui.Register("DManhack",PANEL,"DModelPanel")
function SWEP:OnRemove()
	if self.AmmoIcon then
		self.AmmoIcon:SetVisible(false)
		self.AmmoIcon = nil
	end
end
	
function SWEP:DrawHUD()

	if(!self.AmmoIcon)then
		self.AmmoIcon = vgui.Create( "DManhack" )
		self.AmmoIcon:SetPos(self.AmmoX, self.AmmoY)
		self.AmmoIcon:SetSize(256,256)
		self.AmmoIcon:SetCamPos( Vector( 128, 0, 90 ) )
		self.AmmoIcon:SetLookAt( Vector( 0, 0, 0 ) )
		self.AmmoIcon:SetVisible(true)
	else
		local ent=self:GetNetworkedEntity("entit");
		if(IsValid(ent))then
		self.AmmoIcon:SetModel(ent:GetModel());
		else
		self.AmmoIcon:SetModel("");
		end
	end
end

	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
end
SWEP.Category = "Jvs" 

SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel				= "models/weapons/v_rpg.mdl"
SWEP.WorldModel				= "models/weapons/w_rocket_launcher.mdl"
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic		= false

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

SWEP.Missile=nil;
function SWEP:Initialize()
	if (CLIENT) then return end
	self:SetWeaponHoldType("rpg")
	self.RedDotLaser=nil;
	self.Missile=nil;
	self.IsHoming=false;

end 

function SWEP:Holster()
if(!IsValid(self.Missile))then

	if (CLIENT) then return true end
		if(IsValid(self.RedDotLaser))then self.RedDotLaser:Remove(); end
	
	return true
	
else
	if(self.IsHoming==true)then
	return true
	else
	return false
	end
end
end

function SWEP:PrimaryAttack()
if CLIENT then return end
if(self.Owner:IsNPC())then
self:SecondaryAttack()
else
	if(!IsValid(self.Missile))then
		if(!self.Owner:IsNPC()   )then
		self.Owner:ViewPunch( Vector( -math.random( 8, 12 ), math.random( 1, 2 ), 0 ) ); 
		end
		self:ShootMissile(self.RedDotLaser);
			if(!self.Owner:IsNPC())then
			self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
			end
			self.Weapon:SetNextPrimaryFire(CurTime() + 2)
			self.Weapon:SetNextSecondaryFire(CurTime() + 2)
	end
end
end

function SWEP:Reload()
	if(IsValid(self.Missile))then self.Missile:Detonate();end
end

	
function SWEP:Think()

		if(self.RedDotLaser && IsValid(self.RedDotLaser))then
		
					local Dir =self.Owner:GetAimVector()
					local Pos1 = self.Owner:GetPos()
					local tr = self.Owner:GetEyeTrace()
					
					self.RedDotLaser:SetPos( tr.HitPos );
		end
		if(!IsValid(self.Missile))then self.IsHoming=false end
end	




function SWEP:Deploy()
if ( CLIENT ) then return true end
	if(!self.RedDotLaser || !self.RedDotLaser:IsValid())then
						self.RedDotLaser = ents.Create("env_sprite");
						self.RedDotLaser:SetPos( self:GetPos() );
						self.RedDotLaser:SetKeyValue( "renderfx", "14" )
						self.RedDotLaser:SetKeyValue( "model", "sprites/glow1.vmt")
						self.RedDotLaser:SetKeyValue( "scale","0.5")
						self.RedDotLaser:SetKeyValue( "spawnflags","1")
						self.RedDotLaser:SetKeyValue( "angles","0 0 0")
						self.RedDotLaser:SetKeyValue( "rendermode","9")
						self.RedDotLaser:SetKeyValue( "renderamt","255")
						self.RedDotLaser:SetKeyValue( "rendercolor", "255 0 0" )				
						self.RedDotLaser:Spawn()
	end
	
	
	return true
end

function SWEP:SecondaryAttack()
	if (CLIENT) then return end
	local tr;
	if(self.Owner:IsNPC())then
				local Dir =self.Owner:GetAimVector()
				Pos1 = self.Owner:GetPos()
				local trace = {}
				trace.start = Pos1 
				trace.endpos = trace.start + (Dir * 50000)
				trace.filter = { self.Owner, self.Owner}
				tr = util.TraceLine( trace )
				local hitpos = tr.HitPos
	else
	tr = self.Owner:GetEyeTrace()
	end
	if(IsValid(tr.Entity) && !IsValid(self.Missile))then
		if(!self.Owner:IsNPC())then
		self.Owner:ViewPunch( Vector( -math.random( 8, 12 ), math.random( 1, 2 ), 0 ) ); 
		end
		self.IsHoming=true;
		self:SetNetworkedEntity("entit",tr.Entity);
		self:ShootMissile(tr.Entity);
		self.Owner:EmitSound( "NPC_RollerMine.Hurt" )
		if(!self.Owner:IsNPC())then
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		end
		self.Weapon:SetNextPrimaryFire(CurTime() + 2)
		self.Weapon:SetNextSecondaryFire(CurTime() + 2)
	else
		if(IsValid(tr.Entity))then
		self.Missile.Laser=tr.Entity;
		self.Owner:EmitSound( "NPC_RollerMine.Hurt" )
		self.IsHoming=true;
		
			self.Weapon:SetNextPrimaryFire(CurTime() + 2)
			self.Weapon:SetNextSecondaryFire(CurTime() + 2)
		end
	end
end 

function SWEP:ShootMissile(Entity)

	self.Owner:EmitSound( "Weapon_RPG.NPC_Single" )
	local shootAngles = self.Weapon:GetAngles()
	local Dir =self.Owner:GetAimVector()
	local Missil = ents.Create( "sent_homingmissile" );
	
	self.Missile=Missil;
	Missil.Laser=Entity;
	Missil:SetPhysicsAttacker(self.Owner);
	Missil:SetOwner( self.Owner );
	Missil:SetPos( self.Owner:GetPos() +Vector(0,0,50));
	Missil:SetAngles( shootAngles );
	Missil:Spawn()
	Missil.Owner=self.Owner;
	Missil.WasGrabbed=false;
	if(!self.Owner:IsNPC())then
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	end
end

function SWEP:RocketDied()
if(!self.Owner:IsNPC())then
self:SendWeaponAnim(ACT_VM_RELOAD)
end
		self.Weapon:SetNextPrimaryFire(CurTime() + 2)
		self.Weapon:SetNextSecondaryFire(CurTime() + 2)
end

function SWEP:GetCapabilities()

	return CAP_WEAPON_RANGE_ATTACK1 | CAP_INNATE_RANGE_ATTACK1 | CAP_WEAPON_RANGE_ATTACK2

end