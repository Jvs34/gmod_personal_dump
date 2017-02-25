//----------------------------------------------------------------------
//Players status,a nice hud interface showing you the health/ammo/armor of all the players in the server
//Use this script on a server with at least 7 max players(i know,i know,the player info is too big,whatever).
//Made entirely by Jvs,copyright 2009/2010 , www.multiplayer-italia.com
//----------------------------------------------------------------------
surface.CreateFont( "Tahoma", 16, 1000, true, false, "CoolText")
local items={}
//Lol Dlaor,credits to him for his crysis hud script (this code is not the same,but credits to him anyway)

items["weapon_crowbar"]="c"//slot1
items["weapon_physcannon"]="m"
items["weapon_stunstick"]="n"
items["weapon_pistol"]="d"
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
local startx,starty=4,50;
local boxw,boxh=110,90;
surface.CreateFont("HalfLife2", 44, 400, true, false, "Hl2PStatus")

local DRAWPLAYERS=true;

local function Drawpinfos(ply)
DRAWPLAYERS=!DRAWPLAYERS;
end
concommand.Add( "hev_draw_players_info", Drawpinfos )

local function DrawPlayerStatus()
local num=0;
local currenty=0;
				for k, Ply in pairs( player.GetAll() ) do
					currenty=starty+(num*boxh)+(num*4)
				if(Ply!=LocalPlayer())then
					if(DRAWPLAYERS)then
					if(Ply:Alive())then
					draw.RoundedBox(4,startx,currenty, boxw,boxh,Color(0, 0, 0, 76))
					else
					draw.RoundedBox(4,startx,currenty, boxw,boxh,Color(255, 0, 0, 76))
					end
					draw.SimpleText(Ply:Nick(),"CoolText", startx,currenty, Color(255, 220, 0, 255),0,TEXT_ALIGN_TOP)
						if(Ply:Health()<=100 && Ply:Health()>=50)then
						draw.SimpleText("+","Hl2PStatus", startx+5,currenty,Color(37, 198, 22, 255), 0,TEXT_ALIGN_TOP)
						draw.SimpleText(Ply:Health(),"CoolText", startx+30,currenty+20, Color(255, 220, 0, 255),0,TEXT_ALIGN_TOP)
						else
						draw.SimpleText("+","Hl2PStatus", startx+5,currenty,Color(255, 0, 0, 255), 0,TEXT_ALIGN_TOP)
							if(Ply:Health()<=0)then
							draw.SimpleText("Dead","CoolText", startx+30,currenty+20, Color(255, 220, 0, 255),0,TEXT_ALIGN_TOP)
							else
							draw.SimpleText(Ply:Health(),"CoolText", startx+30,currenty+20, Color(255, 220, 0, 255),0,TEXT_ALIGN_TOP)
							end
						end
						draw.SimpleText("*","Hl2PStatus", startx+5,currenty+20,Color(0, 135, 255, 255), 0,TEXT_ALIGN_TOP)
						draw.SimpleText(Ply:Armor(),"CoolText", startx+30,currenty+40, Color(255, 220, 0, 255),0,TEXT_ALIGN_TOP)
							if(Ply:GetActiveWeapon() != NULL && items[Ply:GetActiveWeapon():GetClass()])then
								draw.SimpleText(items[Ply:GetActiveWeapon():GetClass()],"Hl2PStatus", startx+60,currenty+10,Color(255,220, 0, 255), 0,TEXT_ALIGN_TOP)
							end
						
						if(Ply:GetVelocity():Length()>150)then
						draw.SimpleText("D","Hl2PStatus", startx+5,currenty+40,Color(37, 198, 22, 255), 0,TEXT_ALIGN_TOP)
						else
						draw.SimpleText("C","Hl2PStatus", startx+5,currenty+40,Color(37, 198, 22, 255), 0,TEXT_ALIGN_TOP)
						end
						num=num+1;
						end
					end
				end

end
hook.Add( "HUDPaint", "DrawPlayerStatus", DrawPlayerStatus )