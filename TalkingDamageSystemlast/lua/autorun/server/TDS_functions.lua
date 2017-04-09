TDS_DEBUG=false;

local meta = FindMetaTable( "Entity" )
if (!meta) then return end

//In this file we're adding functions to the ... why does everyone writes the same old shit everytime for metatables?

//can the entity talk underwater?
function meta:SetCanTalkUnderWater(bool)
		self.CanTalkUW=bool;
end

function meta:GetCanTalkUnderWater()
		return self.CanTalkUW;
end

meta.oldEmitSound=meta.EmitSound;

function meta:EmitSound(sound,pitch,volume,playedfromtds)
	if (!playedfromtds)then
		MakeAreaSound(sound,TLK_CONCEPT_DEFAULT,(volume or 100)*10,self)
	end
	self:oldEmitSound(sound,pitch,volume,true)
end


function meta:ShouldChoke()
	if self:WaterLevel()>2 && !self:GetCanTalkUnderWater() then return true end
	return false
end

function meta:Drown()//todo,make the player takes the DMG_DROWN when this function get called
		local sound=GetRandomSound(TLK_CHOKING)
		self:EmitSound(sound,100,100,true);
		self:SpeakDelay(sound);
		self.LastSound=sound;
		self.SoundConcept=TLK_CONCEPT_CHOKING;
		MakeAreaSound(sound,self.SoundConcept,1000,self)
end

//We need this function for everything.
function meta:CanSpeak()
		if !self.TalkTimer then self.TalkTimer=CurTime() end
		if(self.TalkTimer<=CurTime())then
			return true;
		else
			return false;
		end
end
//just an alias
function meta:EntCanSpeak()
	return self:CanSpeak()
end

local meta2 = FindMetaTable( "Player" )
if (!meta2) then return end

//can the player talk while dead?
function meta2:SetCanTalkDead(bool)
		self.CanTalkdead=bool;
end

function meta2:GetCanTalkDead()
		return self.CanTalkdead;
end


function meta2:CanSpeak()
		if !self.TalkTimer then self.TalkTimer=CurTime() end
		if(self.TalkTimer<=CurTime() )then
			if !self:Alive() && !self:GetCanTalkDead() then 
				return false
			else
				return true;
			end
		else
			return false;
		end
end
//overriden alias so we can properly show the icon clientside
function meta2:EntCanSpeak()
		if !self.TalkTimer then self.TalkTimer=CurTime() end
		if(self.TalkTimer<=CurTime())then
			return true;
		else
			return false;
		end
end


//Silly delay.
function meta:SpeakDelay(snd)
	self.TalkTimer=CurTime()+SoundDuration(snd)
end



function GetRandomSound(soundtable,retry)
	retry= retry or 0
	if soundtable then
		local rando=table.Random(soundtable)
		if(type(rando) == "number")then
			retry=retry+1;
			if(TDS_DEBUG)then
				ErrorNoHalt("ERROR! GetRandomSound() returned a number instead of a string ,retry number ",retry)
			end
			
			return GetRandomSound(soundtable,retry)
		else
			if(TDS_DEBUG && retry !=0)then
				ErrorNoHalt("Success,GetRandomSound() worked after ",retry," retry")
			end
		end
		return rando;
	else
		return "common/null.wav"
	end
end

//Uses2Models is the boolean that control if we need to speak differently basing on our model (male,and female for example)
//Mod1 is the first model,you don't need to fill in the full model path,example("/female")
//CONCEPT1 is the table of sounds to play randomly
//Mod2 is the second model,if Uses2Models is false,this will be nil, example("/male")
//CONCEPT2 is the table of sounds to play randomly,but if Uses2Models is false,it will be nil
//Returns true if the player has successfully spoken,false otherwise.
function meta:Speak(Uses2Models,Mod1,CONCEPT1,Mod2,CONCEPT2)
	local snd;
	if(Uses2Models)then
		if(self:CanSpeak())then
			if(string.find(self:GetModel(),Mod1) && hook.Call("OnPlayerTalk",nil,self,sound,concept))then
				snd=GetRandomSound(CONCEPT1)
				self:EmitSound(snd,100,100,true);
				self:SpeakDelay(snd);
				self.LastSound=snd;
				self.SoundConcept=CONCEPT1.CONCEPT;
				MakeAreaSound(snd,self.SoundConcept,1000,self)
				return true
			elseif(string.find(self:GetModel(),Mod2) && hook.Call("OnPlayerTalk",nil,self,sound,concept))then
				snd=GetRandomSound(CONCEPT2)
				self:EmitSound(snd,100,100,true);
				self:SpeakDelay(snd);
				self.LastSound=snd;
				self.SoundConcept=CONCEPT2.CONCEPT;
				MakeAreaSound(snd,self.SoundConcept,1000,self)
				return true
			end
		end
	else
		if(self:CanSpeak())then
			if(string.find(self:GetModel(),Mod1) && hook.Call("OnPlayerTalk",nil,self,sound,concept))then
				snd=GetRandomSound(CONCEPT1)
				self:EmitSound(snd,100,100,true);
				self:SpeakDelay(snd);
				self.LastSound=snd;
				self.SoundConcept=CONCEPT1.CONCEPT;
				MakeAreaSound(snd,self.SoundConcept,1000,self)
				return true
			end
		end
	end
	return false;
end

//Ugh,should'nt this be obvious,damn,it does not seems to work...
function meta:StopSpeaking()
	if(self.LastSound)then
	self:StopSound(self.LastSound)
	end
	self.LastSound="common/null.wav"
	self.TalkTimer=CurTime();
	self.IsSpeaking_TDS=false;
		if self.SpeakTable then
		table.Empty(self.SpeakTable)
		end
	
end

//a simpler speak function,it just needs the sound path and the concept type.
function meta:SpeakSimple(sound,concept,range)
		if(self:CanSpeak())then
			if hook.Call("OnPlayerTalk",nil,self,sound,concept) then
				self:EmitSound(sound,100,100,true);
				self:SpeakDelay(sound);
				self.LastSound=sound;
				self.SoundConcept=concept;
				local ran;
				if ! range then
				ran=1000
				else
				ran=range
				end
				MakeAreaSound(sound,self.SoundConcept,ran,self)
				return true
			end
		end
	return false;
end


//a really simple function,it does not emit sounds,but it "silently" emit the concept,useful for grenades warning.
function meta:SpeakSilent(concept,range)
				self.LastSound="common/null.wav";
				self.SoundConcept=concept;
				local ran;
				if ! range then
				ran=1000
				else
				ran=range
				end
				MakeAreaSound(self.LastSound,self.SoundConcept,ran,self)
end


function meta:Speaktable(soundtable,shouldstack)
	if !shouldstack && self.IsSpeaking_TDS then return end
		if !self.SpeakTable then
			self.SpeakTable={}
		end
		table.Add(self.SpeakTable,soundtable);
		self.IsSpeaking_TDS=true;
end

function meta:GetTDSTable()
	return self.SpeakTable;
end

local function TDS_Speak_table()
	for k, pl in pairs(player.GetAll()) do
		if pl.IsSpeaking_TDS && pl:CanSpeak() then
			if ! pl.SpeakTable then pl.SpeakTable={} end
			if #pl.SpeakTable == 0 then
				pl.IsSpeaking_TDS=false;
			else
				pl.LastSound=pl.SpeakTable[1];
				pl.SoundConcept=TLK_CONCEPT_SENTENCE;
				pl:SpeakSimple(pl.SpeakTable[1],TLK_CONCEPT_SENTENCE)
				table.remove( pl.SpeakTable, 1 )
			end
		end
	end
end
hook.Add( "Think", "TDS_Speak_table", TDS_Speak_table )


function OnPlayerListenToSound(player,emitter,sound,concept)
	if TDS_DEBUG then
		if emitter:IsPlayer() then
		ErrorNoHalt(player:GetName().." heard the sound: "..sound.." with a concept id "..concept.." from player "..emitter:GetName().."\n");
		else
		local ent=emitter:GetClass()
		ErrorNoHalt(player:GetName().." heard the sound: "..sound.." with a concept id "..concept.." from entity "..ent.."\n");
		end
	end
end
hook.Add( "OnPlayerListenToSound", "OnPlayerListenToSound", OnPlayerListenToSound )

local function OnPlayerTalk(player,sound,concept)//for now sound and concept are nil,don't use them
	if player:IsPlayer() && player:ShouldChoke() then
		player:Drown();
		return false;
	end
	return true;
end
hook.Add( "OnPlayerTalk", "OnPlayerTalk", OnPlayerTalk )

function MakeAreaSound(sound,concept,range,emitter)
		for k, Entity in pairs( ents.FindInSphere( emitter:GetPos(), range ) ) do
				if(Entity != emitter)then	//so the emitter can't "hear" himself and creating a time paradox
					if Entity:IsPlayer() then
					hook.Call("OnPlayerListenToSound",nil,Entity,emitter,sound,concept)
					elseif(Entity.ListenToSound)then //feed it to the entity
					Entity:ListenToSound(emitter,sound,concept)//if that damn thing has the listentosound function,call it
					end
				end
		end
end

function CreateDangerSound(entity,soundconcept,range,emittype,emittimes,emitdelay,startfrom)
	local ent=ents.Create("tds_danger_sound")
	ent:SetPos(entity:GetPos())
	ent:SetParent(entity)
	ent:Spawn()
	ent:Setup(soundconcept,emittimes,emitdelay,emittype,startfrom,range)
	return ent
end

function SpawnDangerSounds(entity)
	if !entity || !IsValid(entity) then return end
	if entity:GetClass() == "npc_grenade_frag"  then
		CreateDangerSound(entity,TLK_CONCEPT_DANGERSOUND_GRENADE,300,DANGERSOUND_PLAYFOREVER,0,1.5,CurTime()+1)
	elseif entity:GetClass() == "grenade_ar2" then
		CreateDangerSound(entity,TLK_CONCEPT_DANGERSOUND_GRENADE,500,DANGERSOUND_PLAYFOREVER,0,0.5,CurTime()+1)
	elseif entity:GetClass() == "sniperbullet" then
		CreateDangerSound(entity,TLK_CONCEPT_DANGERSOUND_DEFAULT,200,DANGERSOUND_PLAYSIMPLE,7,0.1,CurTime())
	end
end
hook.Add("OnEntityCreated", "SpawnDangerSounds", SpawnDangerSounds)