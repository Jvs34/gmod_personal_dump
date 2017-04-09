TDS_VERSION=1.2

//Functions useful on both server/client
if SERVER then 
 AddCSLuaFile("sh_tds.lua")
end

function SoundExist(soundpath)
	if SoundDuration(soundpath) != 0 then
		return true
	else
		return false
	end
end

function TDS_includefolder( foldername )

	local tree = file.FindDir( "../lua/" .. foldername .. "/*" )

	for _, fdir in pairs( tree ) do

		if ( fdir != ".svn" || fdir != "_svn" ) then includefolder( fdir ) end

	end

	for k, v in pairs( file.Find( "../lua/" .. foldername .. "/*.lua" ) ) do
		if TDS_DEBUG then print("TDS_INCLUDING FILE: "..foldername.."/"..v) end
		include( foldername .. "/" .. v )

	end

end

local function PlayerFootstep( ply, pos, foot, sound, volume, rf ) 
    if( CLIENT ) then
       return ply:GetNWBool("overridefootsteps") -- Don't allow default footsteps
    end
end
hook.Add("PlayerFootstep","TDS_Client_Footsteps",PlayerFootstep)

local function OverrideDeathSound()
	return true
end
hook.Add("PlayerDeathSound", "TDS_OverrideDeathSound", OverrideDeathSound)