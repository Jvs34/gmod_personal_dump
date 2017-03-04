if not SA then return end

local newsa=SA:New("Special action test","sa_foldertest","FOLDER TEST?????")

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

function newsa:FinishMove(entity,owner,movedata)
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