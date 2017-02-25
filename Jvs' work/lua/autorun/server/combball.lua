//The combine ball will kill his own attacker
//By Jvs
local enabled=false;
if !enabled then return end
local function BallAttacker() 
	for _, Entity in pairs(ents.FindByClass("prop_combine_ball")) do
			Entity:SetOwner(nil)
	end
end
hook.Add("Think","BallAttacker",BallAttacker)
