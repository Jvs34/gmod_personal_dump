if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
	SWEP.Slot				= 0
	SWEP.SlotPos			= 5
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= false
	SWEP.PrintName			= "Light Baton"
	SWEP.Author				= "Jvs"
	SWEP.Instructions = "Primary: Turn on/off the light.\nSecondary: Throw a little light."
	SWEP.DrawCrosshair		= false
	local PURPLE = Color(50, 0, 120, 255)
	local CYAN = Color(0, 255, 255, 255)
	local texthud = {
	text = "",
	font = "MenuLarge",
	color = CYAN,
	xalign = TEXT_ALIGN_CENTER, 
	yalign = TEXT_ALIGN_CENTER }
	
	//pos = {ScrW()/2 + 16, ScrH()/2 - 20},
	function SWEP:DrawHUD()
		surface.SetFont("MenuLarge")
		texthud.text="Charge: "..self:GetNetworkedFloat("charge");
		local Width, Height = surface.GetTextSize(texthud.text)
		Width = Width + 25
		texthud.pos = {ScrW() - (Width / 2) - 3, ScrH()/2 - 165},	
	
		draw.RoundedBox(4, ScrW() - (Width + 4), (ScrH()/2 - 170) - (4), Width + 5, Height + 5, CYAN)
		draw.RoundedBox(4, ScrW() - (Width + 3), (ScrH()/2 - 170) - (3), Width + 3, Height + 3, PURPLE)
		draw.TextShadow(texthud, 1, 200)
	end
	
	
end

SWEP.Category = "Jvs" 

SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel="models/weapons/v_stunstick.mdl";
SWEP.WorldModel="models/weapons/w_stunbaton.mdl";

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= 1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic		= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false
SWEP.Light=nil;

function SWEP:Initialize()
	if (CLIENT) then return end
	self:SetWeaponHoldType("slam")
	self.Light=nil;
	self.wep=nil;
	self.NextT=CurTime()+3;
	self.InitBrt=7.1
end 
function SWEP:Think()
if (CLIENT) then return end
	if(IsValid(self.Light))then
		if(self.Light:GetOn() == true)then
			if(self.InitBrt>0)then
			self.InitBrt=self.InitBrt-0.001;
			self.Light:SetBrightness( self.InitBrt )
			end
		else
			if(self.InitBrt<=7.1)then self.InitBrt=self.InitBrt+0.005;end
		end
		self:SetNetworkedFloat("charge",self.InitBrt);
	end
end

function SWEP:Holster()
	if (CLIENT) then return end
	if(IsValid(self.Light))then
	
	self.Light:SetOn(false);
	self.Light:Remove();
	end
	return true
end

function SWEP:PrimaryAttack()
	if(IsValid(self.Light))then
		self.Light:Toggle();
		self.Light:EmitSound("items/flashlight1.wav");
	end
	self.Weapon:SetNextPrimaryFire(CurTime() + 1.1)
end

function SWEP:SecondaryAttack()
if(self.NextT<CurTime() && self.Light:GetOn()==true && self.InitBrt>0)then
	if(IsValid(self.wep))then self.wep:Remove();end
	self.wep=ents.Create("gmod_light")
	self.wep:SetOwner(self.Owner);
	self.wep:SetPos(self:GetPos()+Vector(0,0,50));
	self.wep:Spawn();
	self.wep:Activate();
	self.NextT=CurTime()+3
	self.wep:GetPhysicsObject():SetVelocity( self.Owner:GetAimVector() * 1000.0 );
	self.wep:SetBrightness( self.InitBrt );
	self.InitBrt=self.InitBrt-1;//Heh,so the player will not continue throwing lights
	self.wep:SetLightSize( 148 );
	timer.Simple( 3, function( Entity ) Entity:Remove() end, self.wep ) //let's remove it after 3 seconds
	end
end

function SWEP:Deploy()
self.Weapon:SendWeaponAnim( ACT_VM_DEPLOY )
self:CreateLight()
	

return true
end
function SWEP:Reload()

end

function SWEP:CreateLight()
	if(!IsValid(self.Light))then
	self.Light = ents.Create("gmod_light");
	self.Light:SetOwner(self.Owner);
	self.Light:SetPos(self.Weapon:GetPos())
	self.Light:Activate();
	self.Light:Spawn();
	self.Light:SetParent(self.Weapon);
	self.Light:SetBrightness( self.InitBrt )
	self.Light:SetLightSize( 148 )
	self.Light:SetOn(true);
	end
end
