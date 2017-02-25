//----------------------------------------------------------------------
//Items finder,the hev suit finds items on the floor when you are distracted.
//Made entirely by Jvs,copyright 2009/2010 , www.multiplayer-italia.com
//----------------------------------------------------------------------
surface.CreateFont("HalfLife2", 44, 400, true, false, "Hl2Items")
surface.CreateFont("HalfLife2",22, 400, true, false, "Hl2SmallRadar")
surface.CreateFont( "Tahoma", 16, 1000, true, false, "CoolText")
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
items["item_ammo_pistol"]="p"
items["item_ammo_357"]="q"
items["item_ammo_smg1"]="r"
items["item_ammo_ar2"]="u"
items["item_ammo_crossbow"]="|"
items["item_box_buckshot"]="s"
items["item_rpg_round"]="x"
items["item_ammo_ar2_altfire"]="z"
items["item_ammo_smg1_grenade"]="t"
items["item_battery"]="*"
items["item_healthvial"]="+"
items["item_healthkit"]="+"
items["item_item_crate"]="A"
items["item_suit"]="@"

items["rpg_missile"]="x"
items["npc_grenade_frag"]="_"
items["npc_grenade_bugbait"]="~"
items["npc_tripmine"]="[o]"
items["npc_satchel"]="{o}"
items["prop_combine_ball"]="z"
items["crossbow_bolt"]="|"
items["grenade_ar2"]="t"
local DRAWITEMNAME=true;

local function Drawitemname(ply)
DRAWITEMNAME=!DRAWITEMNAME;
end
concommand.Add( "hev_draw_item_name", Drawitemname )
//local RADARPOSX=80
//local RADARPOSY=ScrH()/1.3
local function DrawItemFinder()
			local ply=LocalPlayer();
			local ps=ply:GetPos()
			//RadarCircle(Vector(RADARPOSX,RADARPOSY,0),Vector(70,70,0),Color( 255, 220, 0,70))
			//RadarCircle(Vector(RADARPOSX,RADARPOSY,0),Vector(72,72,0),Color( 255, 220, 0,70))
				
	
				for k, Entity in pairs( ents.FindInSphere( LocalPlayer():GetPos(), 500 ) ) do
					/*
					if  Entity && Entity:IsValid() && items[Entity:GetClass()]then
						if Entity:IsWeapon() && Entity:GetOwner()==ply then
						else
						local pos1=Entity:GetPos()
						local pooos=(pos1-ps)/10 + Vector(RADARPOSX,RADARPOSY,0)
						draw.SimpleText(items[Entity:GetClass()], "Hl2SmallRadar", pooos.x, pooos.y, Color(255, 220, 0, 255), 1, 1)
						end
					end				
					*/
					
					if ( Entity && Entity:IsValid() && items[Entity:GetClass()]) then
								local pos= Entity:LocalToWorld( Entity:OBBCenter() ):ToScreen() //thanks AndrewMcWatters for this snippet
								local tracedata = {}
								tracedata.start = LocalPlayer():GetShootPos()
								tracedata.endpos = Entity:LocalToWorld( Entity:OBBCenter() )
								tracedata.filter = LocalPlayer()
								local trace = util.TraceLine(tracedata)
								if ( pos.visible && trace.Entity && IsValid(trace.Entity) && trace.Entity==Entity) then
									if(Entity:IsWeapon() && Entity:GetOwner()!=NULL )then 
									
									else
										if(Entity:IsWeapon() && Entity:Clip1()>=1)then 
										draw.SimpleText("Ammo: "..Entity:Clip1(), "CoolText", pos.x, pos.y-35, Color(255, 220, 0, 255), 1, 1)
										end
										
									if(DRAWITEMNAME==true)then
									draw.SimpleText(Localize(Entity:GetClass()), "CoolText", pos.x, pos.y-55, Color(255, 220, 0, 255), 1, 1)
									draw.SimpleText(items[Entity:GetClass()], "Hl2Items", pos.x, pos.y-85, Color(255, 220, 0, 255), 1, 1)
									else
									draw.SimpleText(items[Entity:GetClass()], "Hl2Items", pos.x, pos.y-55, Color(255, 220, 0, 255), 1, 1)
									end
									draw.SimpleText("?", "Hl2Items", pos.x, pos.y-15, Color(255, 220, 0, 255), 1, 1)
									end
								end
					end
				end
end
hook.Add( "HUDPaint", "DrawItemFinder", DrawItemFinder )


	function RadarCircle(center,scale,col)
				local segmentdist = 360 / ( 2 * math.pi * math.max( scale.x, scale.y ) / 2 )
					surface.SetDrawColor(col)
				for a = 0, 360 - segmentdist, segmentdist do
					surface.DrawLine( center.x + math.cos( math.rad( a ) ) * scale.x, center.y - math.sin( math.rad( a ) ) * scale.y, center.x + math.cos( math.rad( a + segmentdist ) ) * scale.x, center.y - math.sin( math.rad( a + segmentdist ) ) * scale.y )
				end
	end