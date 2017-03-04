if SWEP then
	AddCSLuaFile()
end

--[[
	This weapon will be a dummy kind of weapon that wil be used for the predicted entities
	
	
	How this works: 
			
		predicted entities can work as normal before they're used by this weapon
		the player will equip this weapon on his own
		once the weapon is equipped, the weapon can choose what entity it'll start controlling
		the weapon will then look through the list and show some hud or some shit I dunno and let the player pick the entity
		
		Although now we have the current entity set to the one the user chose, it's the entity that will keep doing the main logic
		
		The weapon here will be mainly used to draw viewmodel stuff and other weapon selection stuff
		
		
		For the entity selection, we're not going to send net messages or anything, we'll just use the literal user input from the cusercmd
		To handle it, most likely the mouse input itself ( getmousex/y )
]]


SWEP = {}

DEFINE_BASECLASS( "weapon_base" )

SWEP.AutoSwitchTo = true
SWEP.AutoSwitchFrom = true
SWEP.Category = "Jvs"
SWEP.Spawnable = true
SWEP.AdminOnly = true

SWEP.Author = "Jvs"

SWEP.Spawnable = true
SWEP.UseHands = true

SWEP.ViewModel = "models/weapons/c_grenade.mdl"
SWEP.WorldModel = "models/props_junk/PopCan01a.mdl"

SWEP.ViewModelFOV = 54

SWEP.Primary = {}
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"

SWEP.Secondary = {}
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Can-nade"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false

if CLIENT then
	SWEP.RenderGroup = RENDERGROUP_BOTH
	
	function SWEP:PreDrawViewModel( vm , wep , ply )
		if wep == self then
		
		end
	end
	
	function SWEP:PostDrawViewModel( vm , wep , ply )
		if wep == self then
		
		end
	end
	
	--pretty useless honestly, postdrawviewmodel gives more info
	function SWEP:ViewModelDrawn( vm ) end
	
	function SWEP:DrawWorldModel()
	
	end
	
	function SWEP:DrawWorldModelTranslucent()
	
	end

	function SWEP:DrawHUD()
	
	end
	
	--meh
	function SWEP:DrawHUDBackground()
	
	end
	
	--useful
	function SWEP:GetTracerOrigin()
		
	end
	
	--pretty useless too, we don't use it
	function SWEP:TranslateFOV( fov ) end
	
	--we could've reused the code for the spawnicon drawing here, I need to reimplement that
	--so I can just draw its png in an easypeasy way
	function SWEP:DrawWeaponSelection( x , y , w , h , alpha )
	
	end
	
else
	
	


end

function SWEP:SetupDataTables()
	self:NetworkVar( "Entity" , 0 , "CurrentEntity" )
	
	--the entity has already the nextfire stuff, so we don't need it here
	
	self:NetworkVar( "Bool" , 0 , "InSelection" ) --when the user is choosing the new entity to be selected
	
	self:NetworkVar( "Float" , 0 , "CursorX" )
	self:NetworkVar( "Float" , 1 , "CursorY" )
end

function SWEP:Initialize()
	if SERVER then
		self:SetCurrentEntity( NULL )
		self:SetInSelection( false )
		
		self:SetCursorX( 0 )
		self:SetCursorY( 0 )
		self:SetHoldType( "normal" )
	end
end

--called mostly for the entity selection hud
function SWEP:GetPredictedEntities()
	if IsValid( self:GetOwner() ) then
		local nwlist = self:GetOwner():GetNW2VarTable()
		local prdents = {}
		
		for i , v in pairs( nwlist ) then
			--we use iscarriedby as it already does the proper slot checks and whatnot
			if v.type == "Entity" and IsValid( v.value ) and v.value.IsPredictedEnt and v.value:IsCarriedBy( self:GetOwner() ) then
				prdents[i] = v.value	--there shouldn't be a need to use v.value:GetSlotName()
			end
		end
		
		return prdents
	end
	
	--we don't return anything without an owner
end

function SWEP:Think()

end

function SWEP:PrimaryAttack()

end

function SWEP:SecondaryAttack()

end

function SWEP:Deploy()
	return true
end

function SWEP:Holster()
	return true
end

--when we drop, we drop our current entity as well, this behaviour might change in the future
--but considering that this is mostly for weapons-like entities, it should be fine
function SWEP:OnDrop()
	if IsValid( self:GetCurrentEntity() ) then
		self:GetCurrentEntity():Drop( true )
	end
	
	self:Remove()
end

function SWEP:OnRemove()

end

weapons.Register( SWEP , "sent_predictedswep" , true )
weapons.OnLoaded()

SWEP = nil