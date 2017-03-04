
local META = FindMetaTable("Entity")

if not META.EmitSound00 then
	META.EmitSound00 = META.EmitSound
end

function META:EmitSound(snd, lvl, pitch, nope)
	if not nope then
		local pl
		if self:IsPlayer() then
			pl = self
		elseif IsValid(self:GetOwner()) and self:GetOwner():IsPlayer() then
			pl = self:GetOwner()
		end
		
		if pl then
			pitch = math.Clamp((pitch or 100) + pl:GetNWInt("PitchAdd"),1,255)
			lvl = 75
		end
	end
	self:EmitSound00(snd, lvl, pitch)
end

--local TFHull = {Vector(-24, -24, 0), Vector(24, 24, 82)}
--local TFHullDuck = {Vector(-24, -24, 0), Vector(24, 24, 62)}

local DefaultHull = {Vector(-16, -16, 0), Vector(16,  16,  72)}
local DefaultHullDuck = {Vector(-16, -16, 0), Vector(16,  16,  36)}

local function findplayer(name)
	local best, bestscore
	name = string.lower(name)
	for _,v in pairs(player.GetAll()) do
		local s = string.find(string.lower(v:GetName()), name)
		if s then
			if not bestscore or s < bestscore then
				bestscore, best = s, v
			end
		end
	end
	
	return best
end

if SERVER then

concommand.Add("resize", function(pl,cmd,args)
	if not pl:IsAdmin() then return end
	local target = pl
	if #args > 1 then
		target = findplayer(table.remove(args, 1))
		if not IsValid(target) then return end
	end
	
	local sz = tonumber(args[1])
	if not sz or sz <= 0.05 then return end
	
	SizePlayer(target, sz)
end)

end

if not GAMEMODE.SP_UpdateAnimation then
GAMEMODE.SP_UpdateAnimation = GAMEMODE.UpdateAnimation
end

function GAMEMODE:UpdateAnimation(ply, velocity, maxseqgroundspeed)
	local size = ply:GetModelScale()
	if size ~= 0 and size ~= 1 then
		velocity = velocity / math.sqrt(size)
	end
	
	return GAMEMODE:SP_UpdateAnimation(ply, velocity, maxseqgroundspeed)
end

function SizePlayer(pl, scl)
	if SERVER then
		pl:SetViewOffset(Vector(0,0,64*scl))
		pl:SetViewOffsetDucked(Vector(0, 0, 28*scl))
		--[[
		pl:SetViewOffset(Vector(0,0,68*scl))
		pl:SetViewOffsetDucked(Vector(0,0,48*scl))]]
		
		if scl < 1 then
			pl:SetJumpPower(200*math.pow(scl,0.4))
			--pl:SetGravity(math.sqrt(scl))
		else
			pl:SetJumpPower(200*math.pow(scl,0.2))
			pl:SetHealth(100*math.sqrt(scl))
		end
		pl:SetGravity(1)
		
		pl:SetStepSize(18*scl)
		
		if scl<=1 then
			pl:SetNWInt("PitchAdd", math.Clamp(1-scl, 0, 1.2)*100)
		else
			pl:SetNWInt("PitchAdd", math.Clamp(-(1-1/scl), -0.8, 0)*100)
		end
		
		--pl:SetNWFloat("PlayerSize", scl)
		pl:SetModelScale(scl,0)
		
		--pl.TempAttributes.SpeedBonus = math.sqrt(scl)
		pl:SetWalkSpeed(250*math.sqrt(scl))
		pl:SetRunSpeed(500*math.sqrt(scl))
		--pl:ResetClassSpeed()
		
		--BroadcastLua(Format("if SizePlayer then SizePlayer(Entity(%d), %f) end", pl:EntIndex(), scl))
	end
	
	if scl < 1 then
		pl.UpSpeed = 6*(1-scl)
	else
		pl.UpSpeed = nil
	end
	
	local min,max = unpack(DefaultHull)
	local mind,maxd = unpack(DefaultHullDuck)
	
	pl:SetHull(min*scl, max*scl)
	pl:SetHullDuck(mind*scl, maxd*scl)
	
	pl.LastScale = scl
	
	local phys = pl:GetPhysicsObject()
	if phys:IsValid() then phys:SetMass(85 * scl * scl) end
	
	if CLIENT then
		--pl:SetRenderBounds(min*scl*1.5, max*scl*1.5)
		--pl:SetModelScale(scl)
	end
end

hook.Add("Move", "SizePlayerMove", function(pl, move)
	if pl.UpSpeed and not pl:IsOnGround() then
		local vel = move:GetVelocity()
		vel.z = vel.z + pl.UpSpeed
		move:SetVelocity(vel)
	end
end)

if CLIENT then

hook.Add("CalcView", "SizePlayerChangeZNear", function(pl, origin, angles, fov, znear, zfar)
	local size = pl:GetModelScale()
	if size ~= 0 and size < 1 then
		return GAMEMODE:CalcView(pl, origin, angles, fov, znear * size, zfar)
	end
end)

hook.Add("Tick", "SizePlayerUpdate", function()
	for _,v in pairs(player.GetAll()) do
		local scl = v:GetModelScale()
		if v.LastScale ~= scl and scl ~= 0 then
			SizePlayer(v, scl)
		end
	end
end)

end

if SERVER then

if not GAMEMODE.PlayerSpawn0 then
	GAMEMODE.PlayerSpawn0 = GAMEMODE.PlayerSpawn
end

function GAMEMODE:PlayerSpawn(pl)
	GAMEMODE:PlayerSpawn0(pl)
	if pl.LastScale then
		SizePlayer(pl, pl.LastScale)
	end
end

hook.Add("EntityTakeDamage", "dmgsclreduction", function(ent,dmg)
	local scl = 1
	
	local att=dmg:GetAttacker()
	
	if ent:IsPlayer() and ent.LastScale then
		scl = 1 / ent.LastScale
	end
	
	if att:IsPlayer() and att.LastScale then
		scl = scl * att.LastScale
	end
	
	if not dmg:IsFallDamage() and scl ~= 1 then
		dmg:SetDamage(dmg:GetDamage() * scl)
		dmg:SetDamageForce(dmg:GetDamageForce() * scl)
	end
end)

else

for _,pl in pairs(player.GetAll()) do
	if pl.LastScale then
		SizePlayer(pl, pl.LastScale)
	end
end

end
