
--initiate the metatable if you have to

--initiate the hooks, they'll always run and check if the player is a nextbot
--otherwise we'd have to network extra shit and I just cba

local meta=FindMetaTable("Player")


function meta:GetNBPTable()
	if not self:IsBot() then return end
	local id=self:GetDTInt(2)
	local tab=NBP:GetTable(id) or NBP.basemeta

	--get the table from the global NBP, depending on the id that's set on the player
	
	--return the table associated to this shit
	--before returning it, set the tab.Player to the player, it'll be removed
	--after the RunHook call
	tab.Player=self
	self.NextBotInfo = self.NextBotInfo or {}
	return tab
end



if SERVER then
	hook.Add("PlayerSpawn","NBP",function(ply)
		if not ply:IsBot()  then return end
		ply:GetNBPTable():RunHook("PlayerSpawn")
	end)

	hook.Add("StartCommand","NBP",function(ply,cmd)
		if not ply:IsBot()  then return end
		ply:GetNBPTable():RunHook("StartCommand",cmd)
	end)
	--WARNING, there's no clientside equivalent, we might have to run the global think hook clientside and run it manually on this entity
	hook.Add("PlayerTick", "NBP", function(ply,mv)	
		if not ply:IsBot() then return end
		ply:GetNBPTable():RunHook("Think",mv)
		
	end)

	hook.Add("SetupMove", "NBP", function(ply,mv,cm)
		if not ply:IsBot() then return end
		ply:GetNBPTable():RunHook("SetupMove",mv,cm)
		
	end)

	hook.Add("Move", "NBP", function(ply,mv)
		if not ply:IsBot() then return end
		ply:GetNBPTable():RunHook("Move",mv)
		
	end)
	
	hook.Add("DoPlayerDeath", "NBP", function(ply,atk,dmginfo)
		if not ply:IsBot() then return end
		ply:GetNBPTable():RunHook("OnDeath",atk,dmginfo)
		
	end)

	hook.Add("EntityTakeDamage", "NBP", function(ply,dmginfo)
		if not ply:IsPlayer() then return end
		if not ply:IsBot() then return end
		ply:GetNBPTable():RunHook("OnTakeDamage",dmginfo)
		
	end)
	
	hook.Add("PlayerUse", "NBP", function(ply,ent)
		if not ply:IsBot() then return end
		ply:GetNBPTable():RunHook("PlayerUse",ent)
		
	end)
	
else

	hook.Add("PrePlayerDraw", "NBP", function(ply)
		if not ply:IsBot() then return end
		ply:GetNBPTable():RunHook("PreDraw")
		
	end)
	
	hook.Add("PostPlayerDraw", "NBP", function(ply)
		if not ply:IsBot() then return end
		ply:GetNBPTable():RunHook("PostDraw")
		
	end)

end

hook.Add("CalcMainActivity","NBP",function( ply, velocity )	
	if not ply:IsBot()  then return end
	
	ply:GetNBPTable():RunHook("CalcMainActivity",velocity)
	
	if ply.NBP_CalcIdeal and ply.NBP_CalcSeqOverride then
		local calcideal=ply.NBP_CalcIdeal
		local seqoverride=ply.NBP_CalcSeqOverride
		ply.NBP_CalcIdeal=nil
		ply.NBP_CalcSeqOverride=nil
		return calcideal, seqoverride
	end

end)

hook.Add("UpdateAnimation","NBP",function( ply, velocity, maxseqgroundspeed )
	if not ply:IsBot() then return end
	ply:GetNBPTable():RunHook("CalcMainActivity",velocity,maxseqgroundspeed)
	
end)

hook.Add("DoAnimationEvent","NBP",function( ply, event, data )
	if not ply:IsBot() then return end
	
	if event==PLAYERANIMEVENT_CUSTOM then
		ply:GetNBPTable():RunHook("DoAnimationEvent",event, data)
		
		return ACT_INVALID
	end
end)




NBP={}
NBP.basemeta={}
NBP.list={}


function NBP.basemeta:RunHook(hookname,...)
	if not IsValid(self.Player) then return end
	local func=self[hookname]
	
	if func then
		func(self,...)
	end
	self.Player=nil
end

function NBP.basemeta:GetName()
	return self.Name
end

function NBP:GetUniqueID(str)
	local id=0
	for i=1,#str do
		id=id + string.byte(str,i)*i
	end
	return id
end



function NBP:GetTable(index)
	return self.list[index]
end


function NBP:New(name,class,description)
	local nbp=setmetatable({}, {__index=NBP.basemeta})	
	nbp.Name=name
	nbp.Class=class
	nbp.Description=description or "no description"
	nbp.ID=NBP:GetUniqueID(nbp.Class)
	NBP.list[NBP:GetUniqueID(nbp.Class)]=nbp
	return nbp
end




if SERVER then
	concommand.Add("createnbp", function(ply,command,args)
		local nextbotclass = "nbp_basebot"
		if args[1] then
			nextbotclass=args[1]
		end
		
		local botname = NBP:GetTable(NBP:GetUniqueID(nextbotclass)):GetName()
		
		
		local bot=player.CreateNextBot(botname);
		
		if not IsValid(bot) then
				ErrorNoHalt("Cannot create a nextbot player, not enough slots.")
			return
		end
		
		if IsValid(ply) then
			undo.Create(botname)
				undo.SetPlayer(ply)
				undo.AddFunction(function(tab,bot,ply)
					if IsValid(bot) and IsValid(ply) then
						bot:Kick(ply:Nick().." undid "..bot:Nick())
					end
				end,bot,ply)
			undo.Finish()
			bot:SetCreator(ply)
		end
		
		bot:SetDTInt(2,NBP:GetUniqueID(nextbotclass))
		bot:Spawn()
	end)
	
	concommand.Add("kicknbp", function(ply,command,args)
		local plyid=tonumber(args[1])
		local ent=nil
		if not plyid then return end
		
		ent=Player(plyid)
		
		if not IsValid(ent) or not ent:IsBot() or ent:GetDTInt(2)==0 then return end
		
		ent:Kick("Kicking next bot player.")
		
	end)
	
	concommand.Add("kickallnbp", function(ply,command,args)
		for i,v in pairs(player.GetBots()) do
			if (v:GetDTInt(2)~=0) then
				v:Kick("Kicking next bot player.")
			end
		end
	end)
	
end




local cuntbot=NBP:New("Deathmatch bot","nbp_basebot","Just a bot example that attacks random players")

function cuntbot:StartCommand(cmd)

	local ply=self.Player
	
	ply._NextAction= ply._NextAction or CurTime()

	
	cmd:ClearButtons()
	cmd:ClearMovement()
	cmd:SetViewAngles(ply:EyeAngles())
	
	if not ply:Alive() then
		if ply._NextAction<=CurTime() then
			cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_JUMP))
			ply._NextAction=CurTime()+1
		end
		if IsValid(ply._Target) then
			--ply:EmitSound("citadel.br_no")
			ply._Target=nil	--forget about our target on death
		end
		return
	end

	--if not penis then return end
	
	if ply:GetObserverMode()~=0 then return end
	
	
	if IsValid(ply._Target) and not ply._Target:Alive() then
		ply:EmitSound("citadel.br_laugh01")
		ply._Target=nil
		return
	end
	
	
	if not IsValid(ply._Target) and ply._NextAction<=CurTime() then
		
		for i,v in RandomPairs(player.GetAll()) do
			if v==ply or not v:Alive() or ply:GetObserverMode()~=0 then continue end
			--ply:EmitSound("citadel.br_youfool")
			ply._Target=v
			ply._NextAction=CurTime()+1
			break
		end
	end
	
	
	
	
	if not IsValid(ply._Target) then return end
	ply:Give("weapon_357")
	ply:SelectWeapon("weapon_357")
	local eyeang=ply:EyeAngles()
	local normal=(ply._Target:BodyTarget(vector_origin,false)-ply:EyePos()):GetNormal()
	eyeang=normal:Angle()
	
	eyeang.p=math.NormalizeAngle(eyeang.p)
	eyeang.y=math.NormalizeAngle(eyeang.y)
	eyeang.r=math.NormalizeAngle(eyeang.r)
	
	cmd:SetForwardMove(ply:GetMaxSpeed())
	
	
	if ply._NextAction<=CurTime() then
		--cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK))
		cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_ATTACK))
		ply._NextAction=CurTime()+0.1
	else
		--doesn't matter, we're clearing the buttons at the start of the command anyway
		--cmd:SetButtons(bit.bxor(cmd:GetButtons(),IN_ATTACK))
	end
	
	cmd:SetViewAngles(eyeang)
	ply:SetEyeAngles(eyeang)
end


local followbot=NBP:New("Follow bot","nbp_followbot","A bot that goes around the map")

--[[
] lua_run print(debug.getregistry().NextBotInfo.GetVision(BOT):GetFOV())
> print(debug.getregistry().NextBotInfo.GetVision(BOT):GetFOV())...
90

lua_run PrintTable(debug.getregistry().NextBotInfo.GetVision(BOT):GetKnownEntities())
]]

function followbot:PlayerSpawn()
	
	self:RecreatePath()

end

function followbot:RecreatePath()
	
	self.Player.NextBotInfo.Path = Path("Follow")
	self.Player.NextBotInfo.Path:SetMinLookAheadDistance( 300 )
	self.Player.NextBotInfo.Path:SetGoalTolerance( 20 )
	self.Player.NextBotInfo.Path:Compute(self.Player,player.GetHumans()[1]:GetPos())
	
	if not IsValid(self.Player.NextBotInfo.Path) then
		self.Player:EmitSound("citadel.br_no")
		PrintMessage(3,"Path Follow is not valid!")
	else
		PrintMessage(3,"Path Length"..self.Player.NextBotInfo.Path:GetLength())
	end
	
end

function followbot:Think()

	if IsValid( self.Player.NextBotInfo.Path ) then
		--self.Player.NextBotInfo.Path:Compute(self.Player,player.GetHumans()[1]:GetPos())
		
		self.Player.NextBotInfo.Path:Update(self.Player)
		self.Player.NextBotInfo.Path:Draw()
	else
		self:RecreatePath()
	end
	--[[
	if IsValid(self.Player:GetCreator()) then
		--self.Player:AimToPos(self.Player:GetCreator():GetEyeTrace().HitPos)
		self.Player:AimToEntity(self.Player:GetCreator())
	end
	]]
	
	if self.Player:GetVision():CanSeeEntity(self.Player:GetCreator()) then
		if not self.Player.NextBotInfo.SeenPlayer then
			self.Player:EmitSound("citadel.br_youfool")
			self.Player.NextBotInfo.SeenPlayer = true
		end
	else
		self.Player.NextBotInfo.SeenPlayer = false
	end
	
end

function followbot:StartCommand(cmd)
	--[[
	if not IsValid( self.Player.NextBotInfo.Path ) then return end
	
	local reachpos = self.Player.NextBotInfo.Path:GetPositionOnPath(0)
	
	local ang = (self.Player:GetPos() - reachpos):GetNormal() * -1
	
	ang = ang:Angle()
	
	ang.p=math.NormalizeAngle(ang.p)
	ang.y=math.NormalizeAngle(ang.y)
	ang.r=math.NormalizeAngle(ang.r)
	
	cmd:ClearButtons()
	cmd:ClearMovement()
	
	cmd:SetButtons(bit.bor(cmd:GetButtons(),IN_SPEED))


	cmd:SetForwardMove(self.Player:GetMaxSpeed())
	
	cmd:SetViewAngles(ang)
	
	self.Player:SetEyeAngles(ang)
	]]
end

