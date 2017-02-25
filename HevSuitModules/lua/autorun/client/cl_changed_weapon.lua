//----------------------------------------------------------------------
//Changed weapon,a simple lua script to show your newly switched weapon.
//Made entirely by Jvs,copyright 2009/2010 , www.multiplayer-italia.com
//----------------------------------------------------------------------
surface.CreateFont( "Tahoma", 16, 1000, true, false, "CoolText")
local LASTWEAPONNAME="No Weapon"
local ALPHA=76;
local BOXW=100
local BOXH=20

local function ChangedWeapon()
	local ply=LocalPlayer();
	if !ply:Alive() then return end
	local wepnam="";
	if(ply:GetActiveWeapon()!=NULL)then
	wepname=ply:GetActiveWeapon():GetPrintName()
	else
	wepname="No Weapon"
	end
	if(LASTWEAPONNAME!=wepname)then
	draw.RoundedBox(4,ScrW()/2-BOXW/2,ScrH()/2+BOXH*3,BOXW, BOXH,Color(0, 0, 0,ALPHA))
	draw.SimpleText(wepname, "CoolText", ScrW()/2-BOXW/2,ScrH()/2+BOXH*3, Color(255, 220, 0, ALPHA+100), 0, 0)
	end
end
hook.Add( "HUDPaint", "ChangedWeapon", ChangedWeapon )


local function FadingBox()
	if !LocalPlayer().NextFading then LocalPlayer().NextFading=CurTime() end
	if(LASTWEAPONNAME!=wepname)then
		if(LocalPlayer().NextFading<CurTime())then
			ALPHA=ALPHA-1;
			LocalPlayer().NextFading=CurTime()+0.01;
		end
		if(ALPHA<=0)then
				if(LocalPlayer():GetActiveWeapon()!=NULL)then
				LASTWEAPONNAME=LocalPlayer():GetActiveWeapon():GetPrintName()
				else
				LASTWEAPONNAME="No Weapon"
				end
				ALPHA=76
		end
	else
		ALPHA=76
	end
end
hook.Add( "Think", "FadingBox",FadingBox )