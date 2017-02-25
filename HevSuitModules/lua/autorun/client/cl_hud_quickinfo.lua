//----------------------------------------------------------------------
//Hud quick info,the hl2dm lovers crosshair is back.
//Made entirely by Jvs,copyright 2009/2010 , www.multiplayer-italia.com
//----------------------------------------------------------------------
surface.CreateFont("HalfLife2", 84, 400, true, false, "Hl2QuickInfo4")
local HEALTH_BELOW_WARNING = 30 
local HEALTH_WARNING=false;
local AMMO_WARNING=false;
local LAST_HEALTH=100;
local LAST_AMMO=555;
local MAX_AMMO=0;
local AMMO_PERCENT=20;//ammunition of weapon clip below this percent will inform the player to reload.

local ClipSizes={}
ClipSizes["weapon_pistol"]=18
ClipSizes["weapon_357"]=6
ClipSizes["weapon_smg1"]=45
ClipSizes["weapon_ar2"]=30
ClipSizes["weapon_shotgun"]=6
ClipSizes["weapon_crossbow"]=1

	local w = ScrW()/2
	local h = ScrH()/2
surface.CreateFont("HalfLife2", 44, 400, true, false, "Hl2QuickInfoC")
local ALTERNATETICK=false;
local oldsec=nil;
local dd=" "
local function QuickInfo()
//
	if  ! tobool( GetConVarNumber( "hud_quickinfo") )  then return end
	local ply=LocalPlayer();
	local hours=os.date("%H")
	local minutes=os.date("%M")
	local seconds=os.date("%S")
	if(seconds!=oldsec)then
			ALTERNATETICK=!ALTERNATETICK;
	end
	dd=" "
	if(ALTERNATETICK)then
		dd="."
	end
	draw.WordBox( 8, ScrW() / 2 -10, ScrH()-80, hours..dd..minutes..dd..seconds, "Hl2QuickInfoC", Color(0,0,0,70),Color(255,220,0,255) )
	oldsec=seconds;
	if ( !gamemode.Call( "HUDShouldDraw", "CHudCrosshair" ) ) then return end
	//don't draw anything if the player is dead,and reset every variable
	if !ply:Alive() then 
	HEALTH_WARNING=false;
	AMMO_WARNING=false;
	LAST_HEALTH=100;
    LAST_AMMO=555
	MAX_AMMO=0;
	return 
	end
	//the player is in a vehicle or zooming with the hev suit zoom or withouth weapons or looking through a camera.
	if ply:InVehicle() || ply:KeyDown(IN_ZOOM) || ply:GetActiveWeapon()==NULL || GetViewEntity() != LocalPlayer() then
	return
	end
		//the health is different than our last think.	
		if(ply:Health()!=LAST_HEALTH && ply:Alive())then
			//set our lasthealth to the current one.
			LAST_HEALTH=ply:Health();
			//the health is below or equal to the warning level.
			if(ply:Health()<=HEALTH_BELOW_WARNING )then
				//play teh sound.
				if(HEALTH_WARNING==false)then
				ply:EmitSound("common/warning.wav");
				HEALTH_WARNING=true
				end
			else
				HEALTH_WARNING=false
			end
		end
		local wep=ply:GetActiveWeapon()
		local AmmoLimit=0;
		if(wep!=NULL && wep:Clip1()!=LAST_AMMO && wep:GetPrimaryAmmoType()!= -1)then
			LAST_AMMO=ply:GetActiveWeapon():Clip1()
			
				if(ClipSizes[ply:GetActiveWeapon():GetClass()])then
					AmmoLimit=(ClipSizes[wep:GetClass()]*AMMO_PERCENT)/100;
				elseif(ply:GetActiveWeapon().Primary)then
					AmmoLimit=(ply:GetActiveWeapon().Primary.ClipSize*AMMO_PERCENT)/100;
				end
			if(LAST_AMMO<AmmoLimit && LAST_AMMO != -1)then
				if(AMMO_WARNING==false)then
				ply:EmitSound("common/warning.wav");
				AMMO_WARNING=true
				end
			else
			AMMO_WARNING=false;
			end
		end
		
		if(ply:Health()>100)then //the player has more then 100 hp,and his crosshair could turn red for overflow.
			draw.SimpleText("[", "Hl2QuickInfo4",w - 16, h-10, Color(255,220, 0, 170), 2, 1)
		else
			draw.SimpleText("[", "Hl2QuickInfo4",w - 16, h-10, Color(255,(ply:Health()*2)+20, 0, 170), 2, 1)
		end
		
		local AmmoColor=Color(255, 220, 0, 170)
		if(AMMO_WARNING == true)then
			AmmoColor=Color(255, 0, 0, 170)
			draw.SimpleText("}", "Hl2QuickInfo4",w + 17, h-10, AmmoColor, 0, 1)
		else
			if(ply:GetActiveWeapon()!=NULL && ply:GetActiveWeapon():GetPrimaryAmmoType()!= -1)then
				if(ClipSizes[ply:GetActiveWeapon():GetClass()])then
					MAX_AMMO=ClipSizes[wep:GetClass()];
				elseif(ply:GetActiveWeapon().Primary)then
					MAX_AMMO=ply:GetActiveWeapon().Primary.ClipSize;
				end
				local VARR=((200*ply:GetActiveWeapon():Clip1())/MAX_AMMO) +20;
				AmmoColor=Color(255, VARR, 0, 170)
				draw.SimpleText("]", "Hl2QuickInfo4",w + 17, h-10, AmmoColor, 0, 1)
			else
				draw.SimpleText("]", "Hl2QuickInfo4",w + 17, h-10, AmmoColor, 0, 1)
			end
		end
		
end
hook.Add( "HUDPaint", "QuickInfo", QuickInfo )