//----------------------------------------------------------------------
//Pickup notice,hev suit speak when you picked up something.
//Made entirely by Jvs,copyright 2009/2010 , www.multiplayer-italia.com
//----------------------------------------------------------------------
local SNDPATH="hl1fvox/"
local SNDEXT=".wav"

local itn={}
itn["weapon_bugbait"]=			SNDPATH.."get_alien_wpn"..SNDEXT
itn["weapon_pistol"]=			SNDPATH.."get_pistol"..SNDEXT
itn["weapon_357"]=				SNDPATH.."get_44pistol"..SNDEXT
itn["weapon_smg1"]=				SNDPATH.."get_assault"..SNDEXT
itn["weapon_crossbow"]=			SNDPATH.."get_crossbow"..SNDEXT
itn["weapon_rpg"]=				SNDPATH.."get_rpg"..SNDEXT
itn["weapon_slam"]=				SNDPATH.."get_satchel"..SNDEXT
itn["weapon_shotgun"]=			SNDPATH.."get_shotgun"..SNDEXT
itn["genericweapon"]=			SNDPATH.."weapon_pickup"..SNDEXT	
itn["genericammo"]=				SNDPATH.."ammo_pickup"..SNDEXT	
itn["Grenade"]=					SNDPATH.."get_grenade"..SNDEXT
itn["SMG1_Grenade"]=			SNDPATH.."get_assaultgren"..SNDEXT
itn["XBowBolt"]=				SNDPATH.."get_bolts"..SNDEXT
itn["Buckshot"]= 				SNDPATH.."get_buckshot"..SNDEXT
itn["RPG_Round"]= 				SNDPATH.."get_rpgammo"..SNDEXT
itn["357"]= 					SNDPATH.."get_44ammo"..SNDEXT
itn["Pistol"]= 					SNDPATH.."get_9mmclip"..SNDEXT
itn["item_healthkit"]= 			SNDPATH.."get_medkit"..SNDEXT
itn["item_healthvial"]= 		SNDPATH.."get_medkit"..SNDEXT
local NUMBERS={}
NUMBERS[1]=SNDPATH.."one"..SNDEXT
NUMBERS[2]=SNDPATH.."two"..SNDEXT
NUMBERS[3]=SNDPATH.."three"..SNDEXT
NUMBERS[4]=SNDPATH.."four"..SNDEXT
NUMBERS[5]=SNDPATH.."five"..SNDEXT
NUMBERS[6]=SNDPATH.."six"..SNDEXT
NUMBERS[7]=SNDPATH.."seven"..SNDEXT
NUMBERS[8]=SNDPATH.."eight"..SNDEXT
NUMBERS[9]=SNDPATH.."nine"..SNDEXT
NUMBERS[10]=SNDPATH.."ten"..SNDEXT
NUMBERS[11]=SNDPATH.."eleven"..SNDEXT
NUMBERS[12]=SNDPATH.."twelve"..SNDEXT
NUMBERS[13]=SNDPATH.."thirteen"..SNDEXT
NUMBERS[14]=SNDPATH.."fourteen"..SNDEXT
NUMBERS[15]=SNDPATH.."fifteen"..SNDEXT
NUMBERS[16]=SNDPATH.."sixteen"..SNDEXT
NUMBERS[17]=SNDPATH.."seventeen"..SNDEXT
NUMBERS[18]=SNDPATH.."eighteen"..SNDEXT
NUMBERS[19]=SNDPATH.."nineteen"..SNDEXT
NUMBERS[20]=SNDPATH.."twenty"..SNDEXT
NUMBERS[25]=SNDPATH.."twentyfive"..SNDEXT//what?
NUMBERS[30]=SNDPATH.."thirty"..SNDEXT
NUMBERS[40]=SNDPATH.."fourty"..SNDEXT
NUMBERS[50]=SNDPATH.."fifty"..SNDEXT
NUMBERS[60]=SNDPATH.."sixty"..SNDEXT
NUMBERS[70]=SNDPATH.."seventy"..SNDEXT
NUMBERS[80]=SNDPATH.."eighty"..SNDEXT
NUMBERS[90]=SNDPATH.."ninety"..SNDEXT
NUMBERS[100]=SNDPATH.."onehundred"..SNDEXT

//DON'T TOUCH THESE
local SUIT_IS_SPEAKING=false;
local SUIT_SPEAK_DELAY=0;
local SUIT_SPEAK_TABLE={}
local SUIT_SPEAK_CONT=1;

local function SuitSpeak(tab)
	if(!SUIT_IS_SPEAKING)then //the hev suit is not annoying the player,do it then!
		SUIT_SPEAK_TABLE=tab
		SUIT_IS_SPEAKING=true;
	else	//the hev suit is already annoying the player,add the other annoying table to the queue.
	table.insert(SUIT_SPEAK_TABLE,SNDPATH.."_comma"..SNDEXT)//add at least a comma.
	table.Add(SUIT_SPEAK_TABLE,tab)
	end
	for k,v in pairs(SUIT_SPEAK_TABLE) do Sound(v) end //always precache the sounds.
end

//Im really proud of this function.
local function HevNumberToTable(number)
	local numbtable={}
	local numbercopy=number;
	if numbercopy<=0 then return {SNDPATH.."fuzz"..SNDEXT} end
	if numbercopy>9000 then return {//VEGETA! WHAT'S HIS POWERLEVEL?
	"vo/npc/male01/question26.wav"  //it's over... this is BULLSHIIIIIIIIIIIIIIIIIIT. 
	}//          :V
	end
	if(numbercopy>100)then //if the number is more than 100,cut 100 from numbercopy and add onehundred to the table
		table.insert(numbtable,NUMBERS[100])
		numbercopy=numbercopy-100
	end 
	if(NUMBERS[numbercopy])then//ehi,our number is inside our NUMBERS table,we don't even need to divide it!
		table.insert(numbtable,NUMBERS[numbercopy])
	else				   //otherwise... we need to divide it per 10 and then add the content to the table
		local numb1 = numbercopy - numbercopy%10 //example: 61, 61-61%10=61-1=60
		local numb2 = math.Round(numbercopy%10)//61%10=1
		table.insert(numbtable,NUMBERS[numb1])//sixty
		table.insert(numbtable,NUMBERS[numb2])//one
	end
	return numbtable;//return teh table to the caller.
end

local function SuitPowerLevel(ply)
	local taba=HevNumberToTable(ply:Armor())
	table.insert(taba,1,SNDPATH.."power_level_is"..SNDEXT)
	table.insert(taba,1,SNDPATH.."fuzz"..SNDEXT)
	table.insert(taba,1,SNDPATH.."fuzz"..SNDEXT)
	table.insert(taba,SNDPATH.."percent"..SNDEXT)
	SuitSpeak(taba);
end
concommand.Add( "hev_powerlevel", SuitPowerLevel )//just for debug,but you can use it as a silly reminder.

local function ClearTabSpeak(ply) //the only way to save your ears if the queue is reeeally long.
	table.Empty(SUIT_SPEAK_TABLE)
	SUIT_IS_SPEAKING=false;
	SUIT_SPEAK_CONT=1;
end
concommand.Add( "hev_clearqueue", ClearTabSpeak)

//A secret hev suit command!don't tell anyone!
local function SuitTime(ply)
	local hours=tonumber(os.date("%H"))
	local minutes=tonumber(os.date("%M"))
	local seconds=tonumber(os.date("%S"))
	local AMPM=false;//false for am,true for PM
	if(hours>12)then hours=hours-12; AMPM=true; end
	local tabhours=HevNumberToTable(hours)
	local tabminutes=HevNumberToTable(minutes)
	local tabseconds=HevNumberToTable(seconds)
	local finaltab={SNDPATH.."time_is_now"..SNDEXT}
	
	table.Add(finaltab,tabhours)
	table.insert(finaltab,SNDPATH.."hours"..SNDEXT)	
	table.insert(finaltab,SNDPATH.."_comma"..SNDEXT)	
	
	table.Add(finaltab,tabminutes)
	table.insert(finaltab,SNDPATH.."minutes"..SNDEXT)	
	table.insert(finaltab,SNDPATH.."_comma"..SNDEXT)	
	
	table.Add(finaltab,tabseconds)
	table.insert(finaltab,SNDPATH.."seconds"..SNDEXT)
	table.insert(finaltab,SNDPATH.."_comma"..SNDEXT)	
	if(AMPM)then 
	table.insert(finaltab,SNDPATH.."pm"..SNDEXT) 
	else
	table.insert(finaltab,SNDPATH.."am"..SNDEXT)
	end
	SuitSpeak(finaltab);
end
concommand.Add( "hev_clocktime", SuitTime )

local function ItemPickedUp( ItemName )
	timer.Simple(0.1, function() //i had to put this in a timer because the suit battery does not get acquired instantly.
	if ItemName=="item_battery" then 
		SuitPowerLevel(LocalPlayer())
	elseif(itn[ItemName])then
		local taba={}
		table.insert(taba,itn[ItemName])
		SuitSpeak(taba);
	else
	print(ItemName);
	end
	end)
end
hook.Add( "HUDItemPickedUp", "ItemPickedUp", ItemPickedUp )

local function AmmoPickedUp( ItemName,amount )
	if itn[ItemName] then 
		local taba=HevNumberToTable(amount)
		table.insert(taba,itn[ItemName])
		SuitSpeak(taba);
	else
		local taba=HevNumberToTable(amount)
		table.insert(taba,itn["genericammo"])
		SuitSpeak(taba);
	end
end
hook.Add( "HUDAmmoPickedUp", "AmmoPickedUp", AmmoPickedUp )

local function WeapPickedUp( wep )
	if itn[wep:GetClass()] then 
		local taba={}
		table.insert(taba,itn[wep:GetClass()])
		SuitSpeak(taba);
	else
		local taba={}
		table.insert(taba,itn["genericweapon"])
		SuitSpeak(taba);
	
	end
end
hook.Add( "HUDWeaponPickedUp", "WeapPickedUp", WeapPickedUp )

local function SuitSpeakThink()
	if SUIT_IS_SPEAKING && SUIT_SPEAK_CONT <= #SUIT_SPEAK_TABLE then
		if(SUIT_SPEAK_DELAY<CurTime())then
		surface.PlaySound( SUIT_SPEAK_TABLE[SUIT_SPEAK_CONT] )
		SUIT_SPEAK_DELAY=CurTime()+SoundDuration(SUIT_SPEAK_TABLE[SUIT_SPEAK_CONT])
		SUIT_SPEAK_CONT=SUIT_SPEAK_CONT+1
		end
	else
	table.Empty(SUIT_SPEAK_TABLE)
	SUIT_IS_SPEAKING=false;
	SUIT_SPEAK_CONT=1;
	end
end
hook.Add( "Think", "SuitSpeakThink", SuitSpeakThink )

//materials\voice\icntlk_pl.vtf
local tex = surface.GetTextureID("voice/icntlk_pl")
local function SuitSpeakDraw()
	if SUIT_SPEAK_DELAY>CurTime() then
	surface.SetTexture(tex)
	surface.SetDrawColor(255,255,255,255) 
	surface.DrawTexturedRect(20,ScrH()-160,64,64)
	end

end
hook.Add(  "HUDPaint", "SuitSpeakDraw", SuitSpeakDraw )