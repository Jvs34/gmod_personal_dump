if CLIENT then return end








hook.Add("StartCommand","ControlBots",function(ply,cmd)
	if not ply:IsBot() then return end
	
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
			ply:EmitSound("citadel.br_no")
			ply._Target=nil	--forget about our target on death
		end
		return
	end

	--if not penis then return end
	
	if ply:GetObserverMode()~=0 then return end
	
	
	if IsValid(ply._Target) and not ply._Target:Alive() then
		ply:EmitSound("citadel.br_laugh01")
		ply._Target=nil
	end
	
	
	if not IsValid(ply._Target) then
		
		for i,v in RandomPairs(player.GetBots()) do
			if v==ply or not v:Alive() or ply:GetObserverMode()~=0 then continue end
			ply:EmitSound("citadel.br_youfool")
			ply._Target=v
			
			break
		end
	end
	
	
	
	
	if not ply._Target then return end
	
	ply:SelectWeapon("weapon_crowbar")
	local eyeang=ply:EyeAngles()
	local normal=(ply._Target:EyePos()-ply:EyePos()):GetNormal()
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
end)