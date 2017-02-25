//----------------------------------------------------------------------
//Inventory manager,a nice hud interface that shows you your weapons and ammo.
//Made entirely by Jvs,copyright 2009/2010 , www.multiplayer-italia.com
//----------------------------------------------------------------------
surface.CreateFont( "Tahoma", 16, 1000, true, false, "CoolText")
surface.CreateFont("HalfLife2", 44, 400, true, false, "Hl2Inventory")
surface.CreateFont("HalfLife2", 24, 400, true, false, "Hl2Smaller")
local menx,meny=ScrW()-227,ScrH() / 3;

local items={}
//weapons
items["weapon_crowbar"]="c"//slot1
items["weapon_physcannon"]="m"
items["weapon_stunstick"]="n"
items["weapon_pistol"]="d"//slot2
items["weapon_357"]="e"
items["weapon_smg1"]="a"//slot3
items["weapon_ar2"]="l"
items["weapon_shotgun"]="b"//slot4
items["weapon_crossbow"]="g"
items["weapon_frag"]="k"//slot5
items["weapon_rpg"]="i"
items["weapon_slam"]="o"
items["weapon_physgun"]="h"
items["weapon_bugbait"]="j"
//ammunitions
local ammo={}
ammo["Pistol"]="p"
ammo["357"]="q"
ammo["SMG1"]="r"
ammo["AR2"]="u"
ammo["XBowBolt"]="|"
ammo["Buckshot"]="s"
ammo["RPG_Round"]="x"
ammo["AR2AltFire"]="z"
ammo["SMG1_Grenade"]="t"
ammo["Grenade"]="v"
ammo["slam"]="o"
//dont' absolutely touch this!
local fuckingammo={
"Pistol",
"357",
"SMG1",
"AR2",
"XBowBolt",
"Buckshot",
"RPG_Round",
"AR2AltFire",
"SMG1_Grenade",
"Grenade",
"slam"
}
//from pickups_english.txt,screw with this how much you want.
local fuckingammotranslation={
Localize("Pistol_ammo"),
Localize("357_ammo"),
Localize("SMG1_ammo"),
Localize("AR2_ammo"),
Localize("XBowBolt_ammo"),
Localize("Buckshot_ammo"),
Localize("RPG_round_ammo"),
Localize("AR2AltFire_ammo"),
Localize("SMG1_grenade_ammo"),
Localize("Grenade_ammo"),
Localize("SLAM_ammo")
}
//dont' absolutely touch this!
local stupidtable={
3,
5,
4,
1,
6,
7,
8,
2,
9,
10,
11
}

local menuenabled=true
function ammoenable(ply)
	menuenabled=!menuenabled;
	
end
concommand.Add( "hev_ammo", ammoenable )

local function DrawInventoryManager()
	if LocalPlayer():Alive()==false || menuenabled==false then return end
	draw.RoundedBox(4,menx,ScrW() / 9, ScrW() / 2 - (300) , meny-ScrW() / 9 -5,Color(0, 0, 0, 76))
		for	i,v in pairs (fuckingammo) do
				if(LocalPlayer():GetActiveWeapon()!= NULL && ( LocalPlayer():GetActiveWeapon():GetPrimaryAmmoType()==stupidtable[i] || LocalPlayer():GetActiveWeapon():GetSecondaryAmmoType()==stupidtable[i]))then
					if(LocalPlayer():GetAmmoCount(fuckingammo[i])!=0)then
					draw.SimpleText(LocalPlayer():GetAmmoCount(fuckingammo[i]), "CoolText", menx+60,ScrW() / 9+(11*i), Color(37, 198, 22, 255), 1, 1)
					draw.SimpleText(ammo[fuckingammo[i]],"Hl2Smaller", menx+90,ScrW() / 9+(11*i), Color(37, 198, 22, 255), 1, 1)
					draw.SimpleText(fuckingammotranslation[i], "CoolText", menx+150,ScrW() / 9+(11*i), Color(37, 198, 22, 255), 1, 1)
					else
					draw.SimpleText(LocalPlayer():GetAmmoCount(fuckingammo[i]), "CoolText", menx+60,ScrW() / 9+(11*i), Color(255,0, 0, 255), 1, 1)
					draw.SimpleText(ammo[fuckingammo[i]],"Hl2Smaller", menx+90,ScrW() / 9+(11*i), Color(255,0, 0, 255), 1, 1)
					draw.SimpleText(fuckingammotranslation[i], "CoolText", menx+150,ScrW() / 9+(11*i), Color(255,0, 0, 255), 1, 1)
					end
				else
					if(LocalPlayer():GetAmmoCount(fuckingammo[i])!=0)then
					draw.SimpleText(LocalPlayer():GetAmmoCount(fuckingammo[i]), "CoolText", menx+60,ScrW() / 9+(11*i), Color(255, 220, 0, 255), 1, 1)
					draw.SimpleText(ammo[fuckingammo[i]],"Hl2Smaller", menx+90,ScrW() / 9+(11*i), Color(255, 220, 0, 255), 1, 1)
					draw.SimpleText(fuckingammotranslation[i], "CoolText", menx+150,ScrW() / 9+(11*i), Color(255, 220, 0, 255),1, 1)
					else
					draw.SimpleText(LocalPlayer():GetAmmoCount(fuckingammo[i]), "CoolText", menx+60,ScrW() / 9+(11*i), Color(255,0, 0, 255), 1, 1)
					draw.SimpleText(ammo[fuckingammo[i]],"Hl2Smaller", menx+90,ScrW() / 9+(11*i), Color(255,0, 0, 255), 1, 1)
					draw.SimpleText(fuckingammotranslation[i], "CoolText", menx+150,ScrW() / 9+(11*i), Color(255,0, 0, 255), 1, 1)
					end
				end
				
		end
	
	local weps = LocalPlayer():GetWeapons()
	local cont=0;
	for k, v in pairs( weps ) do
		if(items[weps[k]:GetClass()])then
		cont=cont+1;
		end						
	end
	draw.RoundedBox(4,menx,meny, ScrW() / 2 - (300) , ScrH() / 2 +50,Color(0, 0, 0, 76))
	cont=1;
	for k, v in pairs( weps ) do
		if(items[weps[k]:GetClass()])then
			if(LocalPlayer():GetActiveWeapon()==weps[k])then
			draw.SimpleText(items[weps[k]:GetClass()], "Hl2Inventory", menx+170,meny+(30*cont), Color(37, 198, 22, 255), 1, 1)
			else
				if(weps[k]:Clip1()==0 && LocalPlayer():GetAmmoCount(weps[k]:GetPrimaryAmmoType())==0 && weps[k]:GetPrimaryAmmoType()>0)then
				draw.SimpleText(items[weps[k]:GetClass()], "Hl2Inventory", menx+170,meny+(30*cont), Color(255,0, 0, 255), 1, 1)
				else
				draw.SimpleText(items[weps[k]:GetClass()], "Hl2Inventory", menx+170,meny+(30*cont), Color(255, 220, 0, 255), 1, 1)
				end
			end
			if(weps[k]:Clip1()>-1)then
				if(LocalPlayer():GetActiveWeapon()==weps[k])then
					if(weps[k]:Clip1()==0 && weps[k]:GetPrimaryAmmoType()<1)then
					else
					draw.SimpleText("Ammo: "..weps[k]:Clip1().."/"..LocalPlayer():GetAmmoCount(weps[k]:GetPrimaryAmmoType()), "CoolText", menx+60,meny+(30*cont), Color(37, 198, 22, 255), 1, 1)
					end
				else
					if(weps[k]:Clip1()==0 && weps[k]:GetPrimaryAmmoType()<1)then
					elseif(weps[k]:Clip1()==0 && LocalPlayer():GetAmmoCount(weps[k]:GetPrimaryAmmoType())==0)then
					draw.SimpleText("Ammo: "..weps[k]:Clip1().."/"..LocalPlayer():GetAmmoCount(weps[k]:GetPrimaryAmmoType()), "CoolText", menx+60,meny+(30*cont), Color(255, 0, 0, 255), 1, 1)
					else
					draw.SimpleText("Ammo: "..weps[k]:Clip1().."/"..LocalPlayer():GetAmmoCount(weps[k]:GetPrimaryAmmoType()), "CoolText", menx+60,meny+(30*cont), Color(255, 220, 0, 255),1, 1)
					end
				end
			end
		cont=cont+1;
		end						
	
	end
	
end
hook.Add( "HUDPaint", "DrawInventoryManager", DrawInventoryManager )