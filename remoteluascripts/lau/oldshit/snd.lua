concommand.Add("gaysound", function(ply,command,args)
	if !IsValid(ply) || !args[1] then return end
	local volume=(tonumber(args[2])) and math.Clamp(tonumber(args[2]),50,500) or 100
	local pitch=(tonumber(args[3])) and math.Clamp(tonumber(args[3]),25,255) or 100
	ply:EmitSound(args[1],volume,pitch)
	
end)



concommand.Add("grigori", function(ply,command,args)
	if !IsValid(ply) then return end
	local numb=math.random(1,22)
	local numbstring=(numb<10) and "0"..tostring(numb) or tostring(numb)
	ply:EmitSound("ravenholm.monk_rant"..numbstring)
	
end)
--[[
concommand.Add("passwordthefuckingserver", function(ply,command,args)
	if not IsValid(ply) or not ply:IsAdmin() then return end
	RunConsoleCommand("sv_password","granpcGRANPCgayvs")
	
end)

concommand.Add("kickfagt", function(ply,command,args)
	if not IsValid(ply) then return end
	local idply=tonumber(args[1])
	if not IsValid(Player(idply)) then return end
	Player(idply):Kick("")
	
end)
]]