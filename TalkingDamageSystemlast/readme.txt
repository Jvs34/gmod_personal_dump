Talking Damage System by Jvs

Introduction:
 -What is this addon?
 This addon lets your player emit a sound when hit,when he kills an npc or a player,when get killed.
 -For what i could use this?
 For any simple deathmatch for example,combine vs rebels,or anything like that.
 -How can i create my own modules?
 See the default.lua module in the autorun/server/tds_classes folder,you can choose which player model
 will trigger the functions in the module,just copy default.lua,rename it,and start modifying it,
 just remember to call TDS_RegisterClass(moduletable,"Module description") in the end of the file.
 -I have a great idea:if you press USE on a player with the rebel model i order him to go where i want to,and so on..
 That's gamemodeish,this is an addon,anyway,install this addon in your server and then you can use every
 functions you might need for it.
 -That's all?
 That's all.
 -Did'nt you just copied the WorkShippers work?
 Oh my... NO.

Installation:
-garrysmod/garrysmod/Addons,of course
-To activate the rebel speak,use the male or female rebel models,to activate the combine speak,use
 the combine player model,same for other models.

Features:
-Team fortress 2 talk time,you can't talk if you did earlier.
-Receive damage from anything,and finally hear yourself struggling from the pain.
-Support for fragmented combine sounds,see the combine module for an example of it.
-Danger Sounds,see the line 174 of tds_functions to see an example.
-Every entity emitting a sound will show a speaker icon,even players.
-You can choose whenever add an another table to the player speak queue (like the hev suit)
-The entity can choose whenever draw the speaker icon clientside,the variable is DontDrawSpeaker (see tds_radio)

Todo:

-Hook into the CSoundPatch:Play() so you can hear a looping sound only once
-Find a way to use ent:Speaktable(table,true) withouth overriding the concept type,i know,that's irritating.
-Find a way to emit again a sound if the receiver didn't hear it in the first place and the sound is still
 playing,(example,a hl2 song,but the concept only,and giving to the receiver the timeleft to the sound)

Changelog:

-Made the changelog :V
-The icon now shows on the emitter's head,not on where it's EyePos or GetShootPos should be.
-Added a new tds_radio,the old one renamed to tds_radio_old,this new radio has 9 channels,and works wireless,
 press use to change channel.
-Now your ragdoll will show the speaker icon if you are dead but still talking.
-CreateDangerSound now returns the tds_dangersound entity.
-New entity hook: "ListenToSound(emitter,sound,concept)",see tds_radio for an example.
-Icon changes depending on the sound concept played. 
 (TLK_CONCEPT_DANGER=!icon,TLK_CONCEPT_SENTENCE=Speaker icon,etc)
-Added a new hook,"OnPlayerTalk",this specify when an entity can talk,this gets called after Entity:CanSpeak()
 so when this hooks gets called generally the player can speak,see tds_functions for an example.
-Players talking underwater will emit a bubble from theyr mouth,if they don't have one,no bubble emitted.
-Added new entity conditions: Entity:ShouldChoke(),returns true or false.
-Added new entity functions: Entity:SetCanTalkUnderWater(bool),Entity:GetCanTalkUnderWater().
-Added new two sent: tds_portal_radio and tds_samvox.
-Removed tds_npc,it's useless for now.
-Added new entity function: Entity:Drown(),this just emits a drown sound,nothing else for now
-Finally added the class module system,see autorun/tds_classes/default.lua for an example of it
-Added tds_getclasses command to show the player which classes are on the server
-Added Entity:SetCanTalkDead(bool) and Entity:GetCanTalkDead()
-Added MetroPolice,Father Grigori,Barney modules,have fun
-Modified the way the module system uses the functions,now it should not completely lag the server.
-Removed tds_samvox for now.
-Fixed the GetRandomSound() sometime returning the concept number(since it was in the same table)
-Removed tf2 choke sound and the icon drawing clientside,those were just silly
-Hooked in the Entity:EmitSound("sound",pitch,volume) so we can hear almost any non-engine sound,maybe a module will add that feature