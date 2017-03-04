
local ClassName="sent_timebomb"
local ENT={}

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE
ENT.PrintName        = "TIME BOMB, AHHH"
ENT.Author="Jvs"
ENT.Spawnable = true  
ENT.AdminOnly = true  

function ENT:SpawnFunction( ply, tr )
    if ( not tr.Hit ) then return end
    
    local SpawnPos = tr.HitPos + tr.HitNormal * 1
    
    local ent = ents.Create(ClassName)
    ent:SetPos( SpawnPos )
	ent:Spawn()
    ent:Activate()
    return ent
end


if CLIENT then
	ENT.CollisionBounds = {Vector(-10,-20,-13), Vector(10,20,7)}
	function ENT:InitializeModels()
		self.Model = multimodel.CreateInstance("drp_timebomb")
	end

	function ENT:Initialize()
		self:InitializeModels()
		self:DrawShadow(false)
		--self:SetNoDraw(true)
		
		self:SetSolid(SOLID_BBOX)
		self:SetCollisionBounds(unpack(self.CollisionBounds))
		--self:PhysicsInitBox(unpack(self.CollisionBounds))
	end

	function ENT:CalcOffset(pos,ang,off)
			return pos + ang:Right() * off.x + ang:Forward() * off.y + ang:Up() * off.z;
	end

	--there are 25 ticks for 10 seconds,50 for 20 seconds,and 100 for 40 seconds,and 150 for 60 seconds.
	function ENT:Draw()
		multimodel.Draw(self.Model, self)	

	end

	multimodel.Register("drp_timebomb", {
		{
			transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
			children = {
				{
					model = "models/props_junk/gascan001a.mdl",
					transform = {Vector(0,0,0), Angle(90,90,180), Vector(1,1,1)},
				},
				{
					model = "models/props_junk/propane_tank001a.mdl",
					transform = {Vector(5,0,-8), Angle(45,0,90), Vector(1,1,1)},
				},
				{
					model = "models/props_junk/propane_tank001a.mdl",
					transform = {Vector(-5,0,-8), Angle(45,0,90), Vector(1,1,1)},
				},
				--[[
					{
					model = "models/props_trainstation/trainstation_clock001.mdl",
					transform = {Vector(0,3,4.6), Angle(270,90,0), Vector(0.25,0.25,0.25)},
					},
				]]
				{
					transform = {Vector(0,3,7), Angle(270,90,0), Vector(1,1,1)/5},
					children={
						{
						model = "models/props_trainstation/trainstation_clock001.mdl",
						transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
						},
						{
						model = "models/props_phx/construct/metal_plate_curve360.mdl",
						transform = {Vector(3,0,0), Angle(270,0,0), Vector(1,1,1)/1.48},
							material="models/shiny",
							color=Color(200,200,200)
						},
						{
							model = "models/props_c17/clock01.mdl",
							transform = {Vector(0,0,0), Angle(90,0,0), Vector(1,1,1)/3},
							material="models/shiny",
							color=Color(200,200,200)
						},
						{
							model = "models/props_c17/signpole001.mdl",
							transform = {Vector(-4,0,0), Angle(0,0,-35), Vector(1.3,1.3,0.47)},
							material="models/shiny",
							color=Color(259,259,259)
						},
						{
							model = "models/props_c17/signpole001.mdl",
							transform = {Vector(-4,0,0), Angle(0,0,35), Vector(1.3,1.3,0.47)},
							material="models/shiny",
							color=Color(259,259,259)
						},
						{
							model = "models/props_phx/construct/metal_dome360.mdl",
							transform = {Vector(-4,-21,30), Angle(0,0,35), Vector(1,1,1)/4},
							material="models/shiny",
							color=Color(259,259,259)
						},
						{
							model = "models/props_phx/construct/metal_dome360.mdl",
							transform = {Vector(-4,21,30), Angle(0,0,-35), Vector(1,1,1)/4},
							material="models/shiny",
							color=Color(259,259,259)
						},
						{
							model = "models/props_c17/signpole001.mdl",
							transform = {Vector(0,0,0), Angle(0,0,0), Vector(0.2,1,0.2)},
							material="models/shiny",
							color=Color(220,0,0),
							Think = function(self, time, ent)
								if IsValid(ent) && ent.TickTackAng && ent.TickTackTimer && ent.TickTackTimer<CurTime() then
									self.transform[2].r = (ent.TickTackAng+90)*-1
								end
							end,
						},
						{
							model = "models/props_c17/signpole001.mdl",
							transform = {Vector(-6,-25,-33), Angle(0,0,-35), Vector(2.3,2.3,0.47)},
							material="models/shiny",
							color=Color(259,259,259)
						},
						{
							model = "models/props_c17/signpole001.mdl",
							transform = {Vector(-6,25,-33), Angle(0,0,35), Vector(2.3,2.3,0.47)},
							material="models/shiny",
							color=Color(259,259,259)
						},
						{
							model = "models/props_c17/signpole001.mdl",
							transform = {Vector(-6,0,0), Angle(0,0,0), Vector(1,1,0.38)},
							material="models/shiny",
							color=Color(259,259,259),
							Think = function(self, time, ent)
								if IsValid(ent) and ent.dt.TimeToBlowUp < CurTime() and ent.dt.Lastwarning>CurTime() then
									self.transform[2].r = math.random(0,30)-15
								end
							end,
							children={
								{
									model = "models/props_c17/oildrum001.mdl",
									transform = {Vector(0,-6,110), Angle(90,90,0), Vector(1,1,3.5)/5},
									material="models/shiny",
									color=Color(259,259,259)
								}
							}
						},
					}
				},
			},
		}
	})

end

if SERVER then

	ENT.TimeConvar=CreateConVar( "drp_timebomb_timer", "60", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "Time in seconds before blowing up the bomb" )
	ENT.DmgAreaConvar=CreateConVar( "drp_timebomb_dmgarea", "1600", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "The area damage of the bomb in hammer units" )
	ENT.DmgConvar=CreateConVar( "drp_timebomb_dmg", "200", { FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED }, "The damage of the bomb" )
	

	local CollisionBounds = {Vector(-10,-20,-13), Vector(10,20,7)}

	function ENT:Initialize()
		self:DrawShadow(false)
		--self:SetNoDraw(true)
		
		self:SetSolid(SOLID_BBOX)
		self:SetCollisionBounds(unpack(CollisionBounds))
		self:PhysicsInitBox(unpack(CollisionBounds))
		local phy=self:GetPhysicsObject();
		if IsValid(phy) then
			phy:SetMass(120);
			phy:AddGameFlag(FVPHYSICS_NO_IMPACT_DMG)
			phy:AddGameFlag(FVPHYSICS_NO_NPC_IMPACT_DMG)
			phy:Wake()
		end
		--self:SetKillIcon("drp_icon_timebomb")
	end

	function ENT:Use(activator)
		if !IsValid(activator) || !activator:IsPlayer() || self.dt.Activated then return end
		
		self.dt.TimeToBlowUp=CurTime() + self.TimeConvar:GetInt();
		self.dt.TimeToBlowUpwarning=CurTime() + Lerp(0.70,0,self.TimeConvar:GetInt());
		self.dt.Lastwarning=self.dt.TimeToBlowUp+1;
		self.TickTackTimer=CurTime();
		self.Activator=activator;
		self.dt.Activated=true;
		
		--[[
		net.Start("sndplayer")
			net.WriteString("https://dl.dropbox.com/u/20140357/filessharex/bombpl.wav")
			net.WriteEntity(NULL)
		net.Broadcast()
		]]
	end

	function ENT:OnTakeDamage( dmginfo )
		--[[
		if dmginfo:GetDamage()<2 then return end
		self:BlowUp(dmginfo:GetAttacker());	
		]]
	end

end


ENT.Activated=false;
ENT.BlowedUp=false;
ENT.TickTack=false;//false=tick,true=tack
ENT.Activator=nil;
ENT.TickNormal=0.5;
ENT.TickFast=0.1;

ENT.TickTackSound=Sound("weapons/pistol/pistol_empty.wav")
ENT.TickPitch=100
ENT.TackPitch=130
ENT.RingSound=Sound("ambient/alarms/alarm1.wav")
ENT.RingPitch=200;

function ENT:SetupDataTables()
    self:DTVar( "Bool", 0, "Activated" );
    self:DTVar( "Float", 0, "TimeToBlowUp" );
	self:DTVar( "Float", 1, "TimeToBlowUpwarning" );
	self:DTVar( "Float", 2, "Lastwarning" );
end

function ENT:Think()
	if !self.dt then return end	--god damnit gran
	if self.dt.Activated && !self.BlowedUp then
		if !self.dt.TimeToBlowUp || !self.dt.TimeToBlowUpwarning || !self.dt.Lastwarning then return end
		
		if CLIENT && !self.TickTackTimer then
			self.TickTackTimer=CurTime();
			self.StartingTickTack=CurTime();
		end
		if CLIENT then
			local frac1=0
			if self.dt.Activated && self.dt.TimeToBlowUp && self.StartingTickTack then
				frac1=math.TimeFraction(self.StartingTickTack,self.dt.TimeToBlowUp, CurTime() )
			end
			self.TickTackAng=Lerp(frac1,0,360)-90
			
			multimodel.DoFrameAdvance(self.Model, CurTime(), self)
			
			if self.TickTackTimer<CurTime() and self.dt.TimeToBlowUp>CurTime() then
				self:EmitSound(self.TickTackSound,68,(self.TickTack)and self.TickPitch or self.TackPitch)
				local frac=0
				if (self.dt.TimeToBlowUpwarning<CurTime()) then
					frac=math.TimeFraction(self.dt.TimeToBlowUpwarning,self.dt.TimeToBlowUp, CurTime() )
				end
				local rampup=Lerp(frac,self.TickNormal,self.TickFast)
				self.TickTack=!self.TickTack
				self.TickTackTimer=CurTime()+rampup
			end
			
			if self.dt.TimeToBlowUp < CurTime() and self.dt.Lastwarning>CurTime() then
				if !self.RingCPatch then
					self.RingCPatch=CreateSound(self,self.RingSound)
					self.RingCPatch:PlayEx(1,self.RingPitch)
				end
			else
				if self.RingCPatch then
					self.RingCPatch:Stop()
					self.RingCPatch=nil;
				end
			end
		end
		
		if SERVER then
			if self.dt.TimeToBlowUp < CurTime() and self.dt.Lastwarning>CurTime() then
				local phy=self:GetPhysicsObject()
				if IsValid(phy) then
					phy:AddAngleVelocity(Vector(0,math.random(0,180)-90,0)*5)
				end
			end
		
		end
		if (self.dt.Lastwarning<CurTime()) then
			self:BlowUp()
		end
		

	end
self:NextThink(CurTime())
return true;
end

function ENT:BlowUp(whodidattack)
	if self.BlowedUp then return end
	self.BlowedUp=true;
	local attacker=IsValid(self.Activator) and self.Activator or self
    if attacker==self && IsValid(whodidattack) then
		attacker=whodidattack;
	end
	if SERVER then
		--[[
		net.Start("sndplayer")
			net.WriteString("https://dl.dropbox.com/u/20140357/filessharex/terwin.wav")
			net.WriteEntity(NULL)
		net.Broadcast()
		]]
		util.BlastDamage( self,attacker,self:GetPos(),self.DmgAreaConvar:GetInt(),self.DmgConvar:GetInt());
		util.ScreenShake( self:GetPos(), 25,self.DmgConvar:GetInt(), 1.0, Lerp(1.5,0,self.DmgAreaConvar:GetInt()) );
    end
    local effectdata = EffectData()
    effectdata:SetScale(127)
    effectdata:SetOrigin( self:GetPos())
    effectdata:SetMagnitude(128)
	local effectstring=(self:WaterLevel()>2) and "WaterSurfaceExplosion" or "HelicopterMegaBomb"
    util.Effect( effectstring, effectdata )
	if self:WaterLevel()<2 then self:EmitSound("BaseExplosionEffect.Sound",100,100) end
	if SERVER then
		self:Remove()
	end
end

function ENT:OnRemove()
	if self.RingCPatch then
		self.RingCPatch:Stop()
		self.RingCPatch=nil;
	end
end


scripted_ents.Register(ENT,ClassName,true)