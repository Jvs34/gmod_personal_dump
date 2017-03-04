hook.Add("PlayerTick","Player controller",function(ply,movedata)

end)
--m_afButtonForced
--m_afButtonDisabled
hook.Add("SetupMove","Player controller",function(ply,movedata)
	if ply.Shit then
		--movedata:AddKey(IN_ATTACK)
	end
	--[[
	if not IsValid(ply.ControlledBy) then
		ply._curcmd=ply:GetCurrentCommand()
	end
	
	if IsValid(ply.ControlledBy) then
		local controller=ply.ControlledBy
		if not controller._curcmd then return end
		movedata:SetButtons(0)
		movedata:SetForwardSpeed(controller._curcmd:GetForwardMove())
		movedata:SetSideSpeed(controller._curcmd:GetSideMove())
		movedata:SetButtons(controller._curcmd:GetButtons())
		movedata:SetMoveAngles(controller._curcmd:GetViewAngles())
		movedata:SetImpulseCommand(controller._curcmd:GetImpulse())
		ply:SetEyeAngles(controller:EyeAngles())
		return movedata
		
	end
	]]
end)
--[[
hook.Add("SetupMove","Player controller",function(ply,movedata)

end)
]]



