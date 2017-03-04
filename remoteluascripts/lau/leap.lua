if SERVER then AddCSLuaFile() return end
require"leap"

local bones = {
	METACARPAL = 0,
	PROXIMAL = 1,
	INTERMEDIATE = 2,
	DISTAL = 3
}

local bpos = Vector(0, 0, -80)
hook.Add("PostDrawTranslucentRenderables", "LeapDebug", function()
	local hands = leap.Frame():GetHands()
	if not hands then return end

	for i, hand in ipairs(hands) do

		render.SetMaterial(Material("debugoverlay"))

		local fingers = hand:GetFingers()
		if not fingers then continue end
		for ii, finger in ipairs(fingers) do
			for iii, bone in pairs(finger:GetBones()) do
				render.DrawWireframeBox(bone:Center() + bpos, finger:Direction():Angle(), Vector(bone:Length()*.5, bone:Width()*.5, bone:Width()*.5), Vector(-bone:Length()*.5, -bone:Width()*.5, -bone:Width()*.5), Color(0, hand:IsLeft() and 255 or 0, hand:IsRight() and 255 or 0))
			end
		end
	end
end)