if SERVER then 
 AddCSLuaFile("sh_tds_concepts.lua")
end

/*
This file contains all the sound concepts to clear the base file.
Don't absolutely touch the enums,at least,if you want to add new concept types,start from the last number.
I know,it would have been better to create a TLK={} table and then adding every concept to it.
*/

//Concepts enum

TLK_CONCEPT_DEFAULT							=0  //when someone speaks a generic concept
TLK_CONCEPT_HURT 							=1  //when someone gets hurt
TLK_CONCEPT_CHEERS 							=2  //when someone cheers
TLK_CONCEPT_DANGER							=3  //when someone screams for a danger
TLK_CONCEPT_WEP_PICKUP						=4  //when someone pickups a wepon
TLK_CONCEPT_SQUAD							=5  //when someone talks about generic squad commands
TLK_CONCEPT_MEMBER_DEAD						=6  //when someone crys for his dead teammate
TLK_CONCEPT_IDLE							=7  //when someone gets sick of remaining in the same spot
TLK_CONCEPT_RELOAD							=8  //when someone reloads
TLK_CONCEPT_QUESTION						=9  //when someone says bullshits
TLK_CONCEPT_ANSWER							=10 //when someone answer to these bullshits
TLK_CONCEPT_SENTENCE						=11 //when someone says a fragmented sentence ("ok","unit10-99assistence","rogerthat")
TLK_CONCEPT_NPCKILLED						=12 //when someone kills an npc
TLK_CONCEPT_HEAL							=13 //when someone heals someone
TLK_CONCEPT_AMMO							=14 //when someone gives ammo to someone
TLK_CONCEPT_SEEN_ENEMY						=15 //when someone saw an enemy
TLK_CONCEPT_DIE								=16 //when someone died
TLK_CONCEPT_DANGERSOUND_DEFAULT 			=17 //when something emits a scary sound
TLK_CONCEPT_DANGERSOUND_GRENADE 			=18 //when a grenade blips
TLK_CONCEPT_CHOKING							=19	//when someone chokes underwater

TLK_LAST_CONCEPT=TLK_CONCEPT_CHOKING
TLK_MAX_CONCEPTS=TLK_LAST_CONCEPT+1 

DANGERSOUND_PLAYONCE	=0 						//play the dangersound once
DANGERSOUND_PLAYSIMPLE	=1						//play the danger sound N times
DANGERSOUND_PLAYFOREVER	=2						//play the sound forever

RADIO_MAX_CHANNELS = 7	//max channels on the tds_radio entity