local meta = FindMetaTable( "Entity" )
if (!meta) then return end

//In this file we add functions to the ... why does everyone writes the same old shit everytime for metatables?


//We need this function for everything.
function meta:CanSpeak() 
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
			if(string.find(self:GetModel(),Mod1))then
				snd=CONCEPT1[math.random(1,#CONCEPT1)]
				self:EmitSound(snd);
				self:SpeakDelay(snd);
				self.LastSound=snd;
				self.SoundConcept=CONCEPT1.CONCEPT;
				MakeAreaSound(snd,self.SoundConcept,1000,self)
				return true
			elseif(string.find(self:GetModel(),Mod2))then
				snd=CONCEPT2[math.random(1,#CONCEPT2)]
				self:EmitSound(snd);
				self:SpeakDelay(snd);
				self.LastSound=snd;
				self.SoundConcept=CONCEPT2.CONCEPT;
				MakeAreaSound(snd,self.SoundConcept,1000,self)
				return true
			end
		end
	else
		if(self:CanSpeak())then
			if(string.find(self:GetModel(),Mod1))then
				snd=CONCEPT1[math.random(1,#CONCEPT1)]
				self:EmitSound(snd);
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
	if(self.LastSound && self.LastSound != "common/null.wav")then
	self:StopSound(self.LastSound)
	self.LastSound="common/null.wav"
	self.TalkTimer=CurTime();
	end
end

//a simpler speak function,it just needs the sound path and the concept type.
function meta:SpeakSimple(sound,concept)
		if(self:CanSpeak())then
				self:EmitSound(sound);
				self:SpeakDelay(sound);
				self.LastSound=sound;
				self.SoundConcept=concept;
				MakeAreaSound(sound,self.SoundConcept,1000,self)
				return true
		end
	return false;
end


//a really simple function,it does'nt emit sounds,but it "silently" emit the concept,useful for grenades warning.
function meta:SpeakSilent(concept)
				self.LastSound="common/null.wav";
				self.SoundConcept=concept;
				MakeAreaSound(self.LastSound,self.SoundConcept,1000,self)
end


function MakeAreaSound(sound,concept,range,emitter)

		for k, Entity in pairs( ents.FindInSphere( emitter:GetPos(), range ) ) do
				if(Entity:IsPlayer() && Entity != emitter)then	//so the emitter can't "hear" himself
					OnPlayerListenToSound(Entity,emitter,sound,concept) //TODO:Use hook.Call so everyone can add an hook.
					OnPlayerListenToSound_citizen_module(Entity,emitter,sound,concept)
				elseif(Entity:GetClass()=="sent_radio" && Entity != emitter)then
					Entity:ListenToSound(emitter,sound,concept)
				end
		end
end


function OnPlayerListenToSound(player,emitter,sound,concept)
	print(player:Nick().." heard the sound: "..sound.." with a concept id "..concept);
end