
include('shared.lua')


SWEP.PrintName			= "Matt Pipe"		// 'Nice' Weapon name (Shown on HUD)
SWEP.ClassName			= "weapon_mattpip"
SWEP.Slot				= 0						// Slot in the weapon selection menu
SWEP.SlotPos			= 0						// Position in the slot
SWEP.DrawAmmo			= false					// Should draw the default HL2 ammo counter
SWEP.DrawCrosshair		= true 					// Should draw the default crosshair
SWEP.DrawWeaponInfoBox	= false					// Should draw the weapon info box
SWEP.BounceWeaponIcon   = false					// Should the weapon icon bounce?

// Override this in your SWEP to set the icon in the weapon selection
SWEP.WepSelectFont		= "TitleFont"
SWEP.WepSelectLetter	= "c"
SWEP.IconFont			= "HL2MPTypeDeath"
SWEP.IconLetter			= "6"

killicon.AddFont( SWEP.ClassName, SWEP.IconFont, SWEP.IconLetter, Color( 255, 80, 0, 255 ) )

/*---------------------------------------------------------
	Checks the objects before any action is taken
	This is to make sure that the entities haven't been removed
---------------------------------------------------------*/
function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

	// Set us up the texture
	surface.SetDrawColor( color_transparent )
	surface.SetTextColor( 255, 220, 0, alpha )
	surface.SetFont( self.WepSelectFont )
	local w, h = surface.GetTextSize( self.WepSelectLetter )

	// Draw that mother
	surface.SetTextPos( x + ( wide / 2 ) - ( w / 2 ),
						y + ( tall / 2 ) - ( h / 2 ) )
	surface.DrawText( self.WepSelectLetter )

end

