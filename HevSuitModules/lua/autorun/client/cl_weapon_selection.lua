//----------------------------------------------------------------------
//Weapon selection,a customizable alternative to the hev suit weapon selection.
//Made entirely by Jvs,copyright 2009/2010 , www.multiplayer-italia.com
//----------------------------------------------------------------------


	killicon.AddFont( "weapon_physcannon", "HL2MPTypeDeath", ",", Color( 255, 80, 0, 255 ) )
	killicon.AddFont( "weapon_physgun", "HL2MPTypeDeath", ",", Color( 0, 12, 255, 255 ) )
	killicon.AddFont( "weapon_bugbait", "HL2MPTypeDeath", "5", Color( 255, 80, 0, 255 ) )
	killicon.AddFont( "weapon_rpg", "HL2MPTypeDeath", "3", Color( 255, 80, 0, 255 ) )

	killicon.AddAlias( "weapon_frag", "npc_grenade_frag" )
	killicon.AddAlias( "weapon_crossbow", "crossbow_bolt" )


surface.CreateFont( "Tahoma", 12, 1000, true, false, "CoolText1")
local MAX_WEAPON_SLOTS={}
MAX_WEAPON_SLOTS[1]=KEY_1
MAX_WEAPON_SLOTS[2]=KEY_2
MAX_WEAPON_SLOTS[3]=KEY_3
MAX_WEAPON_SLOTS[4]=KEY_4
MAX_WEAPON_SLOTS[5]=KEY_5
MAX_WEAPON_SLOTS[6]=KEY_6
MAX_WEAPON_SLOTS[7]=KEY_7
/*
EXTRA EXAMPLES.

MAX_WEAPON_SLOTS[8]=KEY_8
MAX_WEAPON_SLOTS[9]=KEY_9
MAX_WEAPON_SLOTS[10]=KEY_0
MAX_WEAPON_SLOTS[11]=KEY_T
MAX_WEAPON_SLOTS[12]=KEY_F
MAX_WEAPON_SLOTS[13]=KEY_G
*/

//TODO,use GLON
local WEAPON_SLOTS={}
WEAPON_SLOTS["weapon_crowbar"]=1;
WEAPON_SLOTS["weapon_physcannon"]=1;
WEAPON_SLOTS["weapon_physgun"]=1;
WEAPON_SLOTS["weapon_stunstick"]=1;
WEAPON_SLOTS["weapon_pistol"]=2;
WEAPON_SLOTS["weapon_357"]=2;
WEAPON_SLOTS["weapon_smg1"]=3;
WEAPON_SLOTS["weapon_ar2"]=3;
WEAPON_SLOTS["weapon_shotgun"]=4;
WEAPON_SLOTS["weapon_crossbow"]=4;
WEAPON_SLOTS["weapon_frag"]=5;
WEAPON_SLOTS["weapon_rpg"]=5;
WEAPON_SLOTS["weapon_slam"]=5;
WEAPON_SLOTS["weapon_bugbait"]=6;

WEAPON_SLOTS["gmod_tool"]=7
WEAPON_SLOTS["gmod_camera"]=7

local MAX_SLOTS=#MAX_WEAPON_SLOTS;
local startx,starty=4,4;
local boxw,boxh=90,50;
local ENABLED=true;
local SELECTION_START_X=5;
local SELECTION_START_Y=50;
local NEXTKEYPRESS=CurTime();

local MENUSELECTED=0;
local SELECTED=0

local slotpos={}

local function DrawWepSel()
	if !ENABLED || !LocalPlayer():Alive() || LocalPlayer():InVehicle() then return end
	local ply=LocalPlayer()
	if ( !gamemode.Call( "HUDShouldDraw", "CHudWeaponSelection",true ) ) then return end

	
	local num=1;
	local currenty=0;
	local slotnums={}
	
	local lastmenu=0;
	for k, wep in pairs( ply:GetWeapons( ) ) do
			
			if(WEAPON_SLOTS[wep:GetClass()])then
				if !slotnums[WEAPON_SLOTS[wep:GetClass()]] then slotnums[WEAPON_SLOTS[wep:GetClass()]]=1 end
				currentx=SELECTION_START_X+(WEAPON_SLOTS[wep:GetClass()]*boxw)+(WEAPON_SLOTS[wep:GetClass()]*3)
				currenty=SELECTION_START_Y+(slotnums[WEAPON_SLOTS[wep:GetClass()]]*boxh)+(slotnums[WEAPON_SLOTS[wep:GetClass()]]*3)
				if ! slotpos[WEAPON_SLOTS[wep:GetClass()]] then slotpos[WEAPON_SLOTS[wep:GetClass()]]={} end
				slotpos[WEAPON_SLOTS[wep:GetClass()]][slotnums[WEAPON_SLOTS[wep:GetClass()]]]=wep:GetClass()
				slotnums[WEAPON_SLOTS[wep:GetClass()]]=slotnums[WEAPON_SLOTS[wep:GetClass()]]+1
			else
				if wep.Slot then
				WEAPON_SLOTS[wep:GetClass()]=wep.Slot+1;
				else
				WEAPON_SLOTS[wep:GetClass()]=#WEAPON_SLOTS
				end
			end
		if MENUSELECTED == WEAPON_SLOTS[wep:GetClass()] && MENUSELECTED!=0 then
			if slotpos[WEAPON_SLOTS[wep:GetClass()]][slotnums[WEAPON_SLOTS[wep:GetClass()]]-1]== slotpos[WEAPON_SLOTS[wep:GetClass()]][SELECTED] then
				draw.RoundedBox(4,currentx,currenty, boxw,boxh,Color(0, 0, 0, 76))
				draw.SimpleText(string.upper(wep:GetPrintName()),"CoolText1", currentx+5,currenty,Color(32, 220, 0, 255), 0,TEXT_ALIGN_TOP)
				killicon.Draw( currentx+35,currenty+20, wep:GetClass(),255 )
			
			else
			draw.RoundedBox(4,currentx,currenty, boxw,boxh,Color(0, 0, 0, 76))
			draw.SimpleText(string.upper(wep:GetPrintName()),"CoolText1", currentx+5,currenty,Color(255, 220, 0, 255), 0,TEXT_ALIGN_TOP)
			killicon.Draw( currentx+35,currenty+20, wep:GetClass(),255 )
			end
		end
	end
	
		for	cont,table_object in pairs (MAX_WEAPON_SLOTS) do
	
		draw.RoundedBox(4,SELECTION_START_X+(cont*boxw)+(cont*3),SELECTION_START_Y, boxw,boxh,Color(0, 0, 0, 76))
		draw.SimpleText(cont,"CoolText1", SELECTION_START_X+(cont*boxw)+(cont*3)+25,SELECTION_START_Y,Color(255, 220, 0, 255), 0,TEXT_ALIGN_TOP)
		if slotnums[cont] && slotnums[cont]>0 then
		draw.SimpleText((slotnums[cont]-1).." weapons","CoolText1", SELECTION_START_X+(cont*boxw)+(cont*3)+25,SELECTION_START_Y+25,Color(255, 220, 0, 255), 0,TEXT_ALIGN_TOP)
		else
			if MENUSELECTED == cont then MENUSELECTED = 0 SELECTED = 0	end
			
		draw.SimpleText("No weapons","CoolText1", SELECTION_START_X+(cont*boxw)+(cont*3)+25,SELECTION_START_Y+25,Color(255, 220, 0, 255), 0,TEXT_ALIGN_TOP)
		end
		if input.IsKeyDown(MAX_WEAPON_SLOTS[cont]) && NEXTKEYPRESS<CurTime() then 
			
			if MENUSELECTED!=cont then	
				MENUSELECTED=cont;
				SELECTED=1;
				surface.PlaySound( "common/wpn_moveselect.wav")
			else
				if SELECTED < slotnums[MENUSELECTED]-1 then
				SELECTED=SELECTED+1;
				else
				SELECTED=1;
				end
				surface.PlaySound( "common/wpn_moveselect.wav")
			end
		NEXTKEYPRESS=CurTime()+0.15
		end
		
		if (input.IsMouseDown(MOUSE_LEFT) || input.IsMouseDown(MOUSE_RIGHT) )&& MENUSELECTED != 0 then
			surface.PlaySound("common/wpn_hudoff.wav" )
			RunConsoleCommand("use",slotpos[MENUSELECTED][SELECTED])
			MENUSELECTED=0;
			SELECTED=0;
		end
	end
	//this is just for debugging purpose.
	//ErrorNoHalt("Menu Selected "..MENUSELECTED.." CHOICE SELECTED "..SELECTED.."\n")
end
hook.Add( "HUDPaint", "DrawWepSel", DrawWepSel )

local function WeaponSelect( name ,param)
	if param then return true end
	if ( name == "CHudWeaponSelection") then return false end
end
hook.Add( "HUDShouldDraw", "WeaponSelect", WeaponSelect )


function BlockAttack( ply, bind, pressed )
      if string.find( bind, "attack" ) && MENUSELECTED != 0 then return true end
end
hook.Add( "PlayerBindPress", "BlockAttack", BlockAttack )