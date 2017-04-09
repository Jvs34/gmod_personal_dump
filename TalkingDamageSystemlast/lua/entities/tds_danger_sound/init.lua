AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" );
include( "shared.lua" );

ENT.SoundToEmit=TLK_CONCEPT_DANGERSOUND_DEFAULT
ENT.EmitTimes=1; 	//Used when EmitType is 1
ENT.EmitDelay=1;	//Used for everything
ENT.EmitType=0; 	//0=Once,1=Repeat the sound 'EmitTimes' times,2=Continous
ENT.EmitStartFrom=CurTime();
ENT.EmitRange=500;

ENT.CurDelay=CurTime();
ENT.CanFinallyRemove=false;


function ENT:SpawnFunction( Player, Trace ) end
function ENT:Initialize( ) self:SetModel( "models/props_junk/popcan01a.mdl" ) end

function ENT:Setup(par1,par2,par3,par4,par5,par6)
self.SoundToEmit=par1
self.EmitTimes=par2
self.EmitDelay=par3
self.EmitType=par4
self.EmitStartFrom=par5;
self.EmitRange=par6;
end
function ENT:Think()
	if CLIENT then return end
	if self.CanFinallyRemove then
	self:Remove()
	end
	if self.EmitStartFrom < CurTime() then
		if self.CurDelay < CurTime() then
			if self.EmitType == DANGERSOUND_PLAYONCE then
				self.CanFinallyRemove=true;
			elseif self.EmitType == DANGERSOUND_PLAYSIMPLE then
				if self.EmitTimes==0 then
					self.CanFinallyRemove=true;
				else
					self.CanFinallyRemove=false;
					self.EmitTimes=self.EmitTimes-1;
				end
			elseif self.EmitType == DANGERSOUND_PLAYFOREVER then
				self.CanFinallyRemove=false;
			end
			self:SpeakSilent(self.SoundToEmit,self.EmitRange)
			self.CurDelay=CurTime()+self.EmitDelay;
		end
	end
	self:NextThink(CurTime())
	return true
end