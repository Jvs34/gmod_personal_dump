if not SA then return end

local newsa=SA:New("Smod super jump","sa_superjump","woosh")

--[[
smod_player_superjump_scale <float> ( Default: 3 )
Adjusts the power of super jumping. 1.0 is equal to a normal jump.

smod_player_superjump_speed <float> ( Default: 250 )
Sets a minimum speed the player must reach before being able to super jump. At default settings, sprinting is necessary to achieve a jump.

smod_player_superjump_damagecancel <boolean> ( Default: 1 )
]]

if SERVER then
	local smod_player_superjump_scale=CreateConVar("smod_player_superjump_scale",3,{FCVAR_NOTIFY,FCVAR_REPLICATED})
	local smod_player_superjump_speed=CreateConVar("smod_player_superjump_speed",250,{FCVAR_NOTIFY,FCVAR_REPLICATED})
	local smod_player_superjump_damagecancel=CreateConVar("smod_player_superjump_damagecancel",1,{FCVAR_NOTIFY,FCVAR_REPLICATED})
else
	local smod_player_superjump_scale=GetConVar("smod_player_superjump_scale")
	local smod_player_superjump_speed=GetConVar("smod_player_superjump_speed")
	local smod_player_superjump_damagecancel=GetConVar("smod_player_superjump_damagecancel")
end

newsa.JumpSound=""

function newsa:Initialize(entity,owner)
end

function newsa:Deinitialize(entity,owner)
end


function newsa:Think(entity,owner,mv)
end


function newsa:AllClientThink(entity,owner,isclientowner)
end


function newsa:Attack(entity,owner,mv) 
end


function newsa:SetupMove(entity,owner,movedata,commanddata)
end

function newsa:Move(entity,owner,movedata)
end


function newsa:OnOwnerTakesDamage(entity,owner,dmginfo)
end


function newsa:DrawWorldModel(entity,owner)
end


function newsa:PrePlayerDraw(entity,owner)
end

function newsa:PostPlayerDraw(entity,owner)
end



function newsa:PreDrawViewModel(entity,owner,weapon,viewmodel)
end


function newsa:PostDrawViewModel(entity,owner,weapon,viewmodel)
end

function newsa:HUDDraw(entity,owner)
end

function newsa:ResetVars(entity,owner)
end

function newsa:PlayerUse(entity,owner,useentity)
end

function newsa:UpdateAnimation(entity,owner,velocity, maxseqgroundspeed)
end

function newsa:CalcMainActivity(entity,owner,velocity)

end


function newsa:DoAnimationEvent(entity,owner,event,data)
end

function newsa:BuildHandsPosition(entity,owner,handsent)
	
end

function newsa:OnViewModelChanged(entity,owner,viewmodel,oldmodel,newmodel)
	
end