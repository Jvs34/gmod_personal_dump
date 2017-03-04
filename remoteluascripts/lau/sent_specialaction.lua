--[[
	k so here's how it works now
	when the player spawns he's automatically given a special action controller,
	it's just a dummy entity which can hold four special actions, and will relay the hooks to them.
	obviously, you won't be able to spawn special actions if this entity somehow goes NULL
	the controller will also assign IN_ enums keys that the special actions will be able to use
]]

IN_ATTACK3 = 33554432	-- Garry forgot to put this one in, considering tf2 brought this in, it's relatively new

if not SA then
	SA={}
	SA.salist={}
	SA_DEFAULT=nil
end
local ID=1

SA.MaxSpecialActions = 4 --set here as some kind of constant, shouldn't be ever changed during normal gameplay, too much stuff relies on it
SA.DTSlot = 3
SA.ScriptedDTVars = 4
--[[
	Gets a unique id for the string
]]

function SA:GetUniqueID(str)
	local id=0
	for i=1,#str do
		id=id + string.byte(str,i)*i
	end
	return id
end

function SA:CreateController(owner)
	local en=ents.Create("sent_specialaction_controller")
	en:SetPos(owner:GetPos())
	en:SetParent(owner)
	en:SetOwner(owner)
	en:Spawn()
	owner:DeleteOnRemove( en )
	return en
end

--[[
	Gets a special action object to the caller,returns the default one if not found
]]
function SA:GetSAById(id)
	return SA.salist[id] and SA.salist[id] or SA.salist[SA_DEFAULT]
end

--[[
	Gets the id of a modular entity given the class
	returns the base entity id if not found
]]

function SA:GetIdByClass(saclass)
	local _sa=nil
	for i,v in pairs(SA.salist) do
		if v.Class==saclass then 
			_sa=v.ID
			break
		end
	end
	return _sa or SA_DEFAULT
end

function SA:GetMethodByString(str)
	return self[str] or nil
end

function SA:New(name,class,description)
	local specialact={}
	setmetatable(specialact, self)
	self.__index = self
	self.Name=name
	self.Class=class
	self.Description=description or ""
	local idfound=SA:GetIdByClass(class) or "null"
	if SA_DEFAULT and idfound ~= SA_DEFAULT then
		specialact:InternalInitialize(true,idfound)
		SA.salist[idfound]=specialact
	else
		specialact:InternalInitialize()
		SA.salist[self:GetUniqueID(self.Class)]=specialact
		--table.insert(SA.salist,specialact)
	end
	return specialact
end

function SA:InternalInitialize(noidincrease,idfound)
	self.Name=self.Name or "Name not defined"
	self.Class=self.Class or "sa_classnotdefined"
	if not noidincrease then
		self.ID=self:GetUniqueID(self.Class)
		print(self.ID,self.Class)
		--self.ID=ID
		--ID=ID+1
	else
		self.ID=idfound
	end
	
end

SA_DEFAULT=SA:New("Base Special Action","sa_base","The base special action, this is here as a fallback").ID


SA.CanDrop=false
--[[
	SHARED
	
	Duh, called when the special action gets created,
	remember, never save stuff on the special action itself unless it's something static,
	but rather on the entity via networked vars
]]
function SA:Initialize(entity,owner)
end

--[[
	SHARED
	
	Destroy stuff you don't want to hang around
]]
function SA:Deinitialize(entity,owner)
end

--[[
	SHARED
	
	Pretty much simulates the way the think hook works on weapons,
	called clientside only on the owner
	
]]
function SA:Think(entity,owner,mv)
end

--[[
	SHARED
	
	This is called before Think, and it handles the attack
	This should usually not be overridden
	
]]
function SA:AttackThink(entity,owner,mv)
	if entity:IsKeyDown(mv) and entity:GetNextAction() < CurTime() then
		entity:DoSpecialAction("Attack",mv)
	end
end


--[[
	CLIENT
	
	Called on all players, this is here in case you want to do 
	something that you can't network easily or you can't really be arsed to
	
	NOTE: isclientowner is true when the LocalPlayer() is the owner of the entity itself
	(playing gm_bass stuff without using net messages but just networked vars for instance)
	
]]
function SA:AllClientThink(entity,owner,isclientowner)
end

--[[
	SHARED
	
	Called when the player has KeyDown(entity:GetKey()),
	this has the same behaviour as primary attack of a weapon,
	use entity:SetNextAction for the self:SetNextPrimaryAttack of a weapon
	
]]
function SA:Attack(entity,owner,mv) 
end

--[[
	SHARED
	
	Called to setup the player movement
]]
function SA:StartCommand(entity,owner,commanddata)
end

--[[
	SHARED
	
	Called to setup the player movement
]]
function SA:SetupMove(entity,owner,movedata,commanddata)
end

--[[
	SHARED
	
	Called to do the actual player movement
]]
function SA:Move(entity,owner,movedata)
end

--[[
	SHARED
	
	Called at the end of the player movement
]]
function SA:FinishMove(entity,owner,movedata)
end

--[[
	SERVER
	
	Called when the owner takes damage from anything
	
	NOTE:in theory you should be able to even get the hitbox the player got hit to,
	but I don't remember the player function so have fun
]]
function SA:OnOwnerTakesDamage(entity,owner,dmginfo)
end

--[[
	CLIENT
	
	Called after the player gets drawn
]]
function SA:DrawWorldModel(entity,owner)
end


--[[
	CLIENT
	
	Called after the player gets drawn
]]
function SA:PrePlayerDraw(entity,owner)
end

--[[
	CLIENT
	
	Called after the player gets drawn
]]
function SA:PostPlayerDraw(entity,owner)
end


--[[
	CLIENT
	
	Called before the viewmodel gets drawn
	
	NOTE: weapon and viewmodel may be nil sometimes, bear that in mind
]]
function SA:PreDrawViewModel(entity,owner,weapon,viewmodel)
end


--[[
	CLIENT
	
	Called after the viewmodel gets drawn
	
	NOTE: weapon and viewmodel may be nil sometimes, bear that in mind
]]
function SA:PostDrawViewModel(entity,owner,weapon,viewmodel)
end

--[[
	CLIENT
	
	Called on HUDDraw
	
	NOTE:this may be getting a HUDShouldDraw support in the future
]]
function SA:HUDDraw(entity,owner)
end

--[[
	SHARED
	
	Called when the player dies or after/before an initialize(entity spawn)/deinitialize(entity remove)
]]
function SA:ResetVars(entity,owner)
end

--[[
	SERVER
	
	Called after the player uses something
]]
function SA:PlayerUse(entity,owner,useentity)
end

--[[
	SHARED
	
	Called to update player's animations
	
	NOTE:You should be able to override them here, but I haven't tried yet
]]
function SA:UpdateAnimation(entity,owner,velocity, maxseqgroundspeed)
end


--[[
	SHARED
	
	Called to update player's animations
	
	NOTE:You should be able to override them here, but I haven't tried yet
]]
function SA:CalcMainActivity(entity,owner,velocity)

end


function SA:DoAnimationEvent(entity,owner,event,data)
end

function SA:BuildHandsPosition(entity,owner,handsent)
	
end

function SA:OnViewModelChanged(entity,owner,viewmodel,oldmodel,newmodel)
	
end


function SA:__tostring()
	return self.Class.." ["..self.ID.."]["..self.Name.."]"
end







function PrintBones(ent)
	if not IsValid(ent) then print("Invalid entity!") return end
	for i=0,ent:GetBoneCount()-1 do
		print(ent:GetBoneName(i))
	end
end

function FormatViewModelAttachment(pos, eyepos, eyeang, fovsrc, fovdst,invertsources)
	local wepfov=GetConVar("viewmodel_fov"):GetFloat()
	if IsValid(LocalPlayer()) and IsValid(LocalPlayer():GetActiveWeapon()) and LocalPlayer():GetActiveWeapon().ViewModelFOV then
		wepfov=LocalPlayer():GetActiveWeapon().ViewModelFOV
	end

	fovsrc=(fovsrc) and fovsrc or LocalPlayer():GetFOV()
	fovdst=(fovdst) and fovdst or wepfov
	if invertsources then
		fovsrc,fovdst=fovdst,fovsrc
	end
	
	local srcx = math.tan(math.rad(fovsrc/2))
	local dstx = math.tan(math.rad(fovdst/2))
	
	local factor = srcx / dstx
	
	local viewForward, viewRight, viewUp = eyeang:Forward(), eyeang:Right(), eyeang:Up()
	local tmp = pos - eyepos
	
	local transformed = Vector(viewRight:Dot(tmp), viewUp:Dot(tmp), viewForward:Dot(tmp))
	
	if dstx == 0 then
		transformed.x = 0
		transformed.y = 0
	else
		transformed.x = transformed.x * factor
		transformed.y = transformed.y * factor
	end
	
	local out = viewRight * transformed.x + viewUp * transformed.y + viewForward * transformed.z
	out:Add(eyepos)
	
	return out
end




local ClassName="sent_specialaction_controller"
local ENT={}
ENT.Base             = "base_anim"
ENT.Editable			= false
ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT



if CLIENT then
	
	hook.Add("CreateMove","SpecialAction",function( cmd )
		local ply=LocalPlayer()
		if not IsValid(ply:GetDTEntity(SA.DTSlot)) or not ply:GetDTEntity(SA.DTSlot).GetSaAndKeys then return end
		if not ply._ClientButtons then ply._ClientButtons = 0 end
		
		for i,v in pairs(ply:GetDTEntity(SA.DTSlot):GetSaAndKeys()) do
			if not IsValid(v[1]) or gui.IsGameUIVisible() or vgui.CursorVisible() then continue end
			if input.IsButtonDown(ply:GetInfoNum("sa_key"..i, 0 )) and bit.band(ply._ClientButtons,v[2]) == 0 then
				ply._ClientButtons=bit.bor(ply._ClientButtons,v[2])
			elseif not input.IsButtonDown(ply:GetInfoNum("sa_key"..i, 0 )) and bit.band(ply._ClientButtons,v[2]) > 0 then
				ply._ClientButtons=bit.bxor(ply._ClientButtons,v[2])
			end
		end
		
		local btns=cmd:GetButtons()
		cmd:SetButtons(bit.bor(btns,ply._ClientButtons))
	end)
	
	hook.Add("PrePlayerDraw", "SpecialAction", function(ply)
		if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
		if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
		ply:GetDTEntity(SA.DTSlot):DoSpecialAction("PrePlayerDraw")
	end)
	
	hook.Add("PostPlayerDraw", "SpecialAction", function(ply)
		if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
		if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
		ply:GetDTEntity(SA.DTSlot):DoSpecialAction("DrawWorldModel")
		ply:GetDTEntity(SA.DTSlot):DoSpecialAction("PostPlayerDraw")
	end)
	
	hook.Add("PreDrawViewModel", "SpecialAction", function(viewmodel, ply, weapon)
		if not IsValid(ply) then return end
		if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
		if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
		ply:GetDTEntity(SA.DTSlot):DoSpecialAction("PreDrawViewModel",weapon,viewmodel)
	end)
	
	hook.Add("PostDrawViewModel", "SpecialAction", function(viewmodel, ply, weapon)
		if not IsValid(ply) then return end
		if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
		if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
		ply:GetDTEntity(SA.DTSlot):DoSpecialAction("PostDrawViewModel",weapon,viewmodel)
	end)
	
	local devving = GetConVar("developer")
	
	local baseposx=30
	local baseposy=100
	local function drawdebugtext(text,x,y)
		surface.SetFont("ScoreboardDefault")
		surface.SetTextColor( 255, 255, 255, 255 )
		surface.SetTextPos( x,y ) 
		surface.DrawText( text )

	end
	local ystackincrease=23
	hook.Add("HUDPaint", "SpecialAction", function()
		if not IsValid(LocalPlayer():GetDTEntity(SA.DTSlot)) then return end
		
		if devving and devving:GetBool() then
			--draw all the debug shit in here
			local ystack=0
			drawdebugtext("Special actions:",baseposx,baseposy+ystack)
			local ent=LocalPlayer():GetDTEntity(SA.DTSlot)
			for i = 0 , SA.MaxSpecialActions - 1 do
				ystack=ystack+ystackincrease
				if IsValid(ent:GetActionEntity(i)) then
					drawdebugtext(i..") "..ent:GetActionEntity(i):GetType().." "..tostring(ent:GetActionEntity(i)).." "..ent:GetStringKey(i),baseposx,baseposy+ystack)
					local debugtab=ent:GetDebugInfo(i)
					for i,v in pairs(debugtab) do
						ystack=ystack+ystackincrease
						drawdebugtext("           "..i..": "..v,baseposx,baseposy+ystack)
					
					end
				else
					drawdebugtext(i..") nil [NULL Entity] "..ent:GetStringKey(i),baseposx,baseposy+ystack)
				end
			end
		end
		if not LocalPlayer():GetDTEntity(SA.DTSlot).DoSpecialAction then return end
		LocalPlayer():GetDTEntity(SA.DTSlot):DoSpecialAction("HUDDraw")
	end)
end

if SERVER then
	hook.Add("DoPlayerDeath", "SpecialAction", function(ply,atk,dmginfo)
		if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
		if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
		ply:GetDTEntity(SA.DTSlot):DoSpecialAction("ResetVars")
	end)

	hook.Add("EntityTakeDamage", "SpecialAction", function(ply,dmginfo)
		if not ply:IsPlayer() then return end
		if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
		if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
		ply:GetDTEntity(SA.DTSlot):DoSpecialAction("OnOwnerTakesDamage",dmginfo)
	end)
	
	hook.Add("PlayerUse", "SpecialAction", function(ply,ent)
		if not ply:IsPlayer() then return end
		if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
		if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
		ply:GetDTEntity(SA.DTSlot):DoSpecialAction("PlayerUse",ent)
	end)
end

hook.Add("CalcMainActivity","SpecialAction",function( ply, velocity )	
	if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
	if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
	ply:GetDTEntity(SA.DTSlot):DoSpecialAction("CalcMainActivity",velocity)
	
	
	if ply.SA_CalcIdeal and ply.SA_CalcSeqOverride then
		local calcideal=ply.SA_CalcIdeal
		local seqoverride=ply.SA_CalcSeqOverride
		ply.SA_CalcIdeal=nil
		ply.SA_CalcSeqOverride=nil
		return calcideal, seqoverride
	end

end)

hook.Add("UpdateAnimation","SpecialAction",function( ply, velocity, maxseqgroundspeed )
	if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
	if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
	ply:GetDTEntity(SA.DTSlot):DoSpecialAction("UpdateAnimation",velocity, maxseqgroundspeed)
end)

hook.Add( "OnViewModelChanged", "SpecialAction", function(vm, old, new)
	local ply=vm:GetOwner()
	if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
	if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
	ply:GetDTEntity(SA.DTSlot):DoSpecialAction("OnViewModelChanged",vm,old,new)
end)

hook.Add("DoAnimationEvent","SpecialAction",function( ply, event, data )
	if event==PLAYERANIMEVENT_CUSTOM then
		if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
		if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
		ply:GetDTEntity(SA.DTSlot):DoSpecialAction("DoAnimationEvent", event, data)
		return ACT_INVALID
	end
end)

hook.Add("PlayerTick", "SpecialAction", function(ply,mv)
	if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
	if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
	if ply:GetDTEntity(SA.DTSlot):GetNextTick() < CurTime() then
		ply:GetDTEntity(SA.DTSlot):DoSpecialAction("AttackThink",mv)
		ply:GetDTEntity(SA.DTSlot):DoSpecialAction("Think",mv)
		ply:GetDTEntity(SA.DTSlot):SetNextTick(CurTime()+ ply:GetDTEntity(SA.DTSlot):GetTickRate()) --engine.TickInterval())--
	end
end)

hook.Add("StartCommand", "SpecialAction", function(ply,cm)
	if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
	if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
	if ply:InVehicle() or ply:IsDrivingEntity() then return end
	ply:GetDTEntity(SA.DTSlot):DoSpecialAction("StartCommand",cm)
end)

hook.Add("SetupMove", "SpecialAction", function(ply,mv,cm)
	if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
	if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
	if ply:InVehicle() or ply:IsDrivingEntity() then return end
	ply:GetDTEntity(SA.DTSlot):DoSpecialAction("SetupMove",mv,cm)
end)

hook.Add("Move", "SpecialAction", function(ply,mv)
	if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
	if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
	if ply:InVehicle() or ply:IsDrivingEntity() then return end
	ply:GetDTEntity(SA.DTSlot):DoSpecialAction("Move",mv)
end)

hook.Add("FinishMove", "SpecialAction", function(ply,mv)
	if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
	if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
	if ply:InVehicle() or ply:IsDrivingEntity() then return end
	ply:GetDTEntity(SA.DTSlot):DoSpecialAction("FinishMove",mv)
end)

--what the fuck am I even doing

ENT.KeysToString={
	[16384]="IN_ALT1",
	[32768]="IN_ALT2",
	[1]="IN_ATTACK",
	[2048]="IN_ATTACK2",
	[33554432]="IN_ATTACK3", 
	[16]="IN_BACK",	 
	[4194304]="IN_BULLRUSH",	
	[64]="IN_CANCEL",	 
	[4]="IN_DUCK",	 
	[8]="IN_FORWARD",
	[8388608]="IN_GRENADE1",	 
	[16777216]="IN_GRENADE2",	 
	[2]="IN_JUMP",	 
	[128]="IN_LEFT",	 
	[512]="IN_MOVELEFT",	 
	[1024]="IN_MOVERIGHT",	 
	[8192]="IN_RELOAD",	 
	[256]="IN_RIGHT",	 
	[4096]="IN_RUN", 
	[65536]="IN_SCORE",	 
	[131072]="IN_SPEED",	 
	[32]="IN_USE",	 
	[262144]="IN_WALK",	 
	[1048576]="IN_WEAPON1",	 
	[2097152]="IN_WEAPON2",	 
	[524288]="IN_ZOOM",	 

}

ENT.DefaultKeys={
	IN_WEAPON1,
	IN_WEAPON2,
	IN_GRENADE1,
	IN_GRENADE2,
	IN_ATTACK3,
	IN_ALT1,
	IN_ALT2,
}


if CLIENT then
	for i = 0 , SA.MaxSpecialActions - 1 do
		CreateClientConVar( "sa_key"..i, 0, true, true )
	end
end

function ENT:Initialize()
	
	if ( SERVER ) then

		self:DrawShadow(false)
		self:SetNoDraw(true)
		for i = 0 , SA.MaxSpecialActions - 1 do
			self:SetAvailableKey( i , self.DefaultKeys[i+1] or 0 )
		end
		
		self:SetNextTick(CurTime())
		
		--so we don't stress out too much shit in the playerTick hook, can be increased but most of my special actions aren't
		--tickrate indipendant except for the melee charge, gotta fix that
		
		self:SetTickRate(0.1)	
	else
		if LocalPlayer()==self:GetOwner() then
			self:SetPredictable(true)
		end
	end
	self:SetTransmitWithParent( true )
	
end

function ENT:CreateSpecialaction(id,slot)
	local en=ents.Create("sent_specialaction")
	if not IsValid(en) then return nil end
	if type(id)=="string" then
		id=SA:GetIdByClass(id)
	end
	en:SetSlot( slot )
	en:SetPos(self:GetPos())
	en:SetParent(self:GetOwner())
	en:SetOwner(self:GetOwner())
	en:SetAction(id)
	en:SetSaController(self)
	en:Spawn()
	self:ReplaceAction(en,slot)
	self:GetOwner():DeleteOnRemove( en )
	return en
end

function ENT:GetStringKey( id )
	if self:GetAvailableKey( id ) then
		return self.KeysToString[self:GetAvailableKey( id )] or tostring(self:GetAvailableKey( id ))
	end
end

function ENT:SetupDataTables()

	self:NetworkVar( "Float", 0, "NextTick")
	self:NetworkVar( "Float", 1, "TickRate",{ KeyName = "TickRate", Edit = { type = "Float", min = engine.TickInterval(), max = 1, category = "Special action", order = 1 } })

	for i = 0 , SA.MaxSpecialActions - 1 do
		self:NetworkVar( "Int", i, "AvailableKey"..i,{ KeyName = "AvailableKey"..i, Edit = { type = "Generic", category = "Special action", order = i + 2 } })
		self:NetworkVar( "Entity", i, "ActionEntity"..i )
	end
	
end

function ENT:SetAvailableKey( id , key )
	if self["SetAvailableKey"..id] then
		self["SetAvailableKey"..id]( self , key )
	end
end

function ENT:GetAvailableKey( id )
	return self["GetAvailableKey"..id] and self["GetAvailableKey"..id](self) or nil
end

function ENT:SetActionEntity( id , ent )
	if self["SetActionEntity"..id] then
		self["SetActionEntity"..id]( self , ent )
	end
end

function ENT:GetActionEntity( id )
	return self["GetActionEntity"..id] and self["GetActionEntity"..id](self) or nil
end
--gets the debug info from a special action
function ENT:GetDebugInfo(actionid)
	if IsValid(self:GetActionEntity(actionid)) then
		return self:GetActionEntity(actionid):GetDebugInfo()
	end
end

function ENT:GetActionByClass(classname)
	for i=0, SA.MaxSpecialActions - 1 do	
		if IsValid(self:GetActionEntity(i)) then
			if self:GetActionEntity(i):GetType() == classname then
				return self:GetActionEntity(i)
			end
		end
	end
end

function ENT:Think()
	if SERVER and IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
		
		if not self:GetOwner():Alive() then return end
		
		local oldhands = self:GetOwner():GetHands()
		
		if not IsValid(oldhands) or oldhands:GetClass()~="sa_hands" then
			if ( IsValid( oldhands ) ) then
				oldhands:Remove()
			end

			local hands = ents.Create( "sa_hands" )
			if ( IsValid( hands ) ) then
				hands:DoSetup( self:GetOwner() )
				hands:Spawn()
			end
		end
	
	end
end

function ENT:ReplaceAction(ent,number)
	if not number then	number = 0 end
	if not self:GetActionEntity(number) then
		print("can't find function GetActionEntity"..number.." ! Gee I wonder why")
		return
	end
	
	if IsValid(self:GetActionEntity(number)) then
		print("replacing "..self:GetActionEntity(number):GetType().." with "..ent:GetType().." on slot "..number)
		self:GetActionEntity(number):Remove()
	end
	
	self:SetAvailableKey( number , self.DefaultKeys[number+1] )
	self:SetActionEntity( number, ent )
end

function ENT:GetKey(ent)
	return self:GetAvailableKey( ent:GetSlot() )
	--[[
	for i=0,SA.MaxSpecialActions - 1 do	
		if IsValid(self:GetActionEntity(i)) then
			if self:GetActionEntity(i)==ent then
				return self:GetAvailableKey( i )
			end
		end
	end
	]]
end

function ENT:GetSaAndKeys()
	if not self.sakeystab then self.sakeystab={} end
	
	for i=0,SA.MaxSpecialActions - 1 do	
		if IsValid(self:GetActionEntity(i)) then
			if not self.sakeystab[i] then self.sakeystab[i] = {} end
			self.sakeystab[i][1]=self:GetActionEntity( i )
			self.sakeystab[i][2]=self:GetAvailableKey( i )
		end
	end
	
	return self.sakeystab
end

function ENT:ResetKeys()
	for i = 0 , SA.MaxSpecialActions - 1 do
		self:SetAvailableKey( i , self.DefaultKeys[i+1] or 0 )
	end
end

function ENT:SetKey(ent,key_enum)
	self:SetAvailableKey( ent:GetSlot() , key_enum )
	--[[
	for i=0,SA.MaxSpecialActions - 1 do	
		if IsValid(self:GetActionEntity(i)) then
			if self:GetActionEntity(i)==ent then
				self:SetAvailableKey( i , key_enum )
			end
		end
	end
	]]
end

function ENT:ResetKey(ent)
	self:SetAvailableKey( ent:GetSlot() , self.DefaultKeys[i+1] or 0 )
	--[[
	for i=0,SA.MaxSpecialActions - 1 do	
		if IsValid(self:GetActionEntity(i)) then
			if self:GetActionEntity(i)==ent then
				self:SetAvailableKey( i , self.DefaultKeys[i+1] )
			end
		end
	end
	]]
end




function ENT:RemoveAllSA()
	for i=0,SA.MaxSpecialActions - 1 do	
		if IsValid(self:GetActionEntity(i)) then
			self:GetActionEntity( i ):Remove()
		end
	end
end


function ENT:DoSpecialAction(actionstring , ... )
	for i=0, SA.MaxSpecialActions - 1 do	
		if IsValid(self:GetActionEntity(i)) and self:GetActionEntity(i).DoSpecialAction then
			self:GetActionEntity(i):DoSpecialAction(actionstring, ...)
		end
	end
end




scripted_ents.Register(ENT,ClassName,true)



local ClassName="sent_specialaction"
local ENT={}

ENT.Base             = "base_anim"
ENT.Editable			= false
ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.RenderGroup 		= RENDERGROUP_TRANSLUCENT

function ENT:Initialize()

	if ( SERVER ) then
		self:DrawShadow(false)
		self:SetNoDraw(true)
		self:SetNextAction( CurTime() + 1 )
	else
		if LocalPlayer() == self:GetOwner() then
			self:SetPredictable(true)
		end
	end
	self:SetTransmitWithParent( true )
	self:DoSpecialAction("Initialize")
	self:DoSpecialAction("ResetVars")
end

function ENT:SetupDataTables()

	self:NetworkVar( "Float", 0, "NextAction")		--like a nextprimaryfire
	self:NetworkVar( "Int", 0, "Action")			--my special action is 696969 ( converted to whatever like sa_penis )
	self:NetworkVar( "Int", 1, "Slot")				--hi I'm special action ID 0/1/2/3/4/5/6 etc etc
		
	self:NetworkVar( "Entity", 0, "SaController")	--oh this is my controller!
	self:NetworkVar( "Vector", 0, "ReservedVector")	--for future use
	self:NetworkVar( "Angle", 0, "ReservedAngle")	--for future use
	self:NetworkVar( "String", 0, "ReservedString")	--for future use
	self:NetworkVar( "Bool", 0, "IsDropped")		--am I dropped or not???
	
	for i = 1 , SA.ScriptedDTVars do
		self:NetworkVar( "Float", i , "ActionFloat"..i)
		self:NetworkVar( "Bool", i, "ActionBool"..i)
		self:NetworkVar( "Int", i + 1, "ActionInt"..i)
		self:NetworkVar( "Entity", i, "ActionEntity"..i)
		self:NetworkVar( "Vector", i, "ActionVector"..i)
		self:NetworkVar( "Angle", i, "ActionAngle"..i)
	end

	--we're not going to network strings yet
	
end

function ENT:AliasNetworkVar(ntvar,newname)
	if self["Get"..ntvar] and self["Set"..ntvar] then
		self["Get"..newname]=self["Get"..ntvar]
		self["Set"..newname]=self["Set"..ntvar]
	end
end

function ENT:GetDebugInfo()
	--remember to return everything as a string
	return {
		Reserved=tostring(self:GetNextAction())..";"..tostring(self:GetAction()),
		Floats=tostring(self:GetActionFloat1())..";"..tostring(self:GetActionFloat2())..";"..tostring(self:GetActionFloat3()),
		Bools=tostring(self:GetActionBool1())..";"..tostring(self:GetActionBool2())..";"..tostring(self:GetActionBool3()),
		Ints=tostring(self:GetActionInt1())..";"..tostring(self:GetActionInt2())..";"..tostring(self:GetActionInt3()),
		Ents=tostring(self:GetActionEntity1())..";"..tostring(self:GetActionEntity2())..";"..tostring(self:GetActionEntity3()),
	}
end

function ENT:Think()
	if not self.dt or not IsValid(self:GetOwner()) then 
		if self.dt then
			--we still want to call the dropped think here
			
		end
		
		return
	end
	
	--we simulate the think hook not getting called clientside for other clients here
	if not self:GetOwner():Alive() then
		self:DoSpecialAction("ResetVars")
		return
	end
	

	if CLIENT then 
		self:DoSpecialAction("AllClientThink",LocalPlayer()==self:GetOwner())
	end
		
end

function ENT:GetCurSA()
	return SA:GetSAById(self:GetAction())
end

function ENT:GetType()
	return self:GetCurSA().Class
end

function ENT:GetKey()
	return self:GetSaController():GetKey(self)
end

function ENT:SetKey(key_enum)
	return self:GetSaController():SetKey(self,key_enum)
end

function ENT:ResetKey()
	return self:GetSaController():ResetKey(self)
end

function ENT:TickRate()
	return self:GetSaController():GetTickRate()
end

function ENT:IsKeyDown(movedata)
	local target=movedata or self:GetOwner()
	return target:KeyDown(self:GetKey()) --or bit.band(self:GetOwner():GetDTInt(SA.DTSlot),self:GetKey())>0	--removed, not needed anymore
end

function ENT:DoSpecialAction(actionstring , ... )
	if ( not IsValid(self:GetOwner()) or not IsValid(self) ) and not self:GetIsDropped() then return end
	
	if self:GetOwner():IsPlayer() then
		if not self:GetOwner():Alive() or self:GetOwner():GetObserverMode()~=0 then return end
	else
		--check if they have a function condition like .CanRunAction, since this is a custom entity and not a player
		if self:GetOwner().CanRunAction and not self:GetOwner():CanRunAction( self ) then
			return
		end
	end
	

	--OH SHIT, OH FUCK WHERE'S OUR CONTROLLER, I DON'T KNOW WHAT TO DO , AAAAAAAAAAAAAAAAAAAHHHHHHHH
	--as you can see, we still don't have support for "rogue" or droppable special actions
	--yet.
	if not IsValid(self:GetSaController()) then	return end
	local func=self:GetCurSA():GetMethodByString(actionstring)
	if func then
		func(self:GetCurSA(),self,self:GetOwner(), ...)
	else
		print("Could not find function "..actionstring.." from the base special action!")
	end
end


function ENT:OnRemove()
	self:DoSpecialAction("ResetVars")
	self:DoSpecialAction("Deinitialize")
end

scripted_ents.Register(ENT,ClassName,true)



local ClassName="sa_hands"
local ENT={}

ENT.Base             = "base_anim"
ENT.Type			= "anim"
ENT.RenderGroup		= RENDERGROUP_OTHER


function ENT:Initialize()
	
	hook.Add( "OnViewModelChanged", self, self.ViewModelChanged )

	self:SetNotSolid( true )
	self:DrawShadow( false )
	self:SetTransmitWithParent( true ) -- Transmit only when the viewmodel does!
	
	self:AddCallback("BuildBonePositions",function (self)
		local ply=self:GetOwner()
		if not IsValid(ply) then return end
		if not IsValid(ply:GetDTEntity(SA.DTSlot)) then return end
		if not ply:GetDTEntity(SA.DTSlot).DoSpecialAction then return end
		ply:GetDTEntity(SA.DTSlot):DoSpecialAction("BuildHandsPosition",self)
	end)

end

function ENT:DoSetup( ply )

	-- Set these hands to the player
	ply:SetHands( self )
	self:SetOwner( ply )

	-- Which hands should we use?
	local info = player_manager.RunClass( ply, "GetHandsModel" )
	if ( info ) then
		self:SetModel( info.model )
		self:SetSkin( info.skin )
		self:SetBodyGroups( info.body )
	end

	-- Attach them to the viewmodel
	local vm = ply:GetViewModel( 0 )
	self:AttachToViewmodel( vm )

	vm:DeleteOnRemove( self )
	ply:DeleteOnRemove( self )

end

function ENT:GetPlayerColor()
	
	--
	-- Make sure there's an owner and they have this function
	-- before trying to call it!
	--
	local owner = self:GetOwner()
	if ( !IsValid( owner ) ) then return end
	if ( !owner.GetPlayerColor ) then return end
	
	return owner:GetPlayerColor()

end

function ENT:ViewModelChanged( vm, old, new )

	-- Ignore other peoples viewmodel changes!
	if ( vm:GetOwner() != self:GetOwner() ) then return end

	self:AttachToViewmodel( vm )

end

function ENT:AttachToViewmodel( vm )
	
	self:AddEffects( EF_BONEMERGE )
	self:SetParent( vm )
	self:SetMoveType( MOVETYPE_NONE )

	self:SetPos( Vector( 0, 0, 0 ) )
	self:SetAngles( Angle( 0, 0, 0 ) )

end

scripted_ents.Register(ENT,ClassName,true)


if SERVER then
	
	function GiveSpecialAction(ply,args)
		if not args[1] or args[1]=="" then
			for i,v in pairs(SA.salist) do
				ply:ChatPrint(v.ID.." : "..v.Class)
			end
			return
		end
		
		if not IsValid(ply:GetDTEntity(SA.DTSlot)) then
			local en=SA:CreateController(ply)
			ply:SetDTEntity(SA.DTSlot,en)
		end
		
		if not IsValid(ply:GetDTEntity(SA.DTSlot)) then
			--it should never happen, unless the entity didn't register or didn't get created for some MOTHERFUCKING reason
			print("Trying to give "..ply:Nick().." a special action without a valid special action controller!")
		end
		
		if IsValid(ply:GetDTEntity(SA.DTSlot)) then
			local said=tonumber(args[1])
			if not said then
				said=SA:GetIdByClass(args[1])
			end
			
			said= said or SA_DEFAULT
			
			local number=tonumber(args[2]) or 0
			number=math.Clamp(number , 0 , SA.MaxSpecialActions - 1)
			
			
			ply:GetDTEntity(SA.DTSlot):CreateSpecialaction(said,number)
			
			
			
			print("Giving "..ply:Nick().." a "..SA:GetSAById(said).Class.." on slot "..number)
			ply:ChatPrint("Equipped a "..SA:GetSAById(said).Class.." on slot "..number)

		end
		
	end
	concommand.Add("give_specialaction", function(ply,command,args)
		if not IsValid(ply) or not ply:Alive() then return end
		--if not ply:IsAdmin() or ply:GetNWBool("trusted",false)==false then
			--[[
			if not game.SinglePlayer() then
				ply:ChatPrint("You can't spawn this, sorry")
				return
			end
			]]
		--end
		GiveSpecialAction( ply , args )
	end,function() end, nil, FCVAR_REPLICATED)

	concommand.Add("removeall_specialaction", function(ply,command,args)
		if not IsValid(ply) then print("Can't do this on the server, yet") end
		
		if IsValid(ply:GetDTEntity(SA.DTSlot)) then
			if not ply:Alive() then 
				ply:ChatPrint("You can't run this command when dead.")
				return 
			end
			ply:GetDTEntity(SA.DTSlot):RemoveAllSA()
			ply:GetDTEntity(SA.DTSlot):Remove()
			ply:SetDTEntity(SA.DTSlot,NULL)			
		else
			ply:ChatPrint("You got no special actions on you")
		end
	end)
else
	

end



