
local ply=Entity(1)
if not game.SinglePlayer() or not IsValid(ply) then Error("Fuck off wanker") end


if IsValid(ply:GetVehicle()) then
	ply:GetVehicle().HandleAnimation=function(vehicle, ply )
		
		if not IsValid(ply:GetActiveWeapon()) or not ply:GetActiveWeapon():IsScripted() then
			
			if ( class == "prop_vehicle_jeep" ) then
				ply.CalcSeqOverride = ply:LookupSequence( "drive_jeep" )
			elseif ( class == "prop_vehicle_airboat" ) then
				ply.CalcSeqOverride = ply:LookupSequence( "drive_airboat" )
			elseif ( class == "prop_vehicle_prisoner_pod" && pVehicle:GetModel() == "models/vehicles/prisoner_pod_inner.mdl" ) then
				-- HACK!!
				ply.CalcSeqOverride = ply:LookupSequence( "drive_pd" )
			else
				ply.CalcSeqOverride = ply:LookupSequence( "sit_rollercoaster" )
			end
		end
	end


	--[[
	ply:GetVehicle().HandleAnimation=function(vehicle, ply )
		
		ply.CalcIdeal=ACT_HL2MP_SIT
		ply.CalcSeqOverride = -1
		
	end
	]]

end

