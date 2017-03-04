
if GAYASSCM then
	GAYASSCM:Remove()
	
end

if not shit then return end

local gaypos=Vector("-580.128357 312.856628 -12767.968750")
GAYASSCM=ClientsideModel("models/player/breen.mdl")
GAYASSCM:SetPos(gaypos)
GAYASSCM:Spawn()

GAYASSCM.RenderOverride=function(self)
	self:FrameAdvance(FrameTime())
	self:DrawModel()
end
GAYASSCM:RestartGesture(ACT_HL2MP_GESTURE_RELOAD_REVOLVER)	

local tim=CurTime()
hook.Add("Think","gayasscm",function() 
	if IsValid(GAYASSCM) then
		if tim<CurTime() then
			GAYASSCM:RestartGesture(ACT_HL2MP_GESTURE_RELOAD_REVOLVER)
			--GAYASSCM:EmitSound("citadel.br_no")
			tim=CurTime()+3
		end
	end

end)


