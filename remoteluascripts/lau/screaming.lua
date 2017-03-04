if not CLIENT then return end
hook.Add("UpdateAnimation","screamingAAAAAH",function( ply, velocity, maxseqgroundspeed )
	local headbone="ValveBiped.Bip01_Head1"
	local boneid=ply:LookupBone(headbone)
	if not boneid or not ply:IsSpeaking() or not ply:Alive() or not ply:IsVoiceAudible() then return end
	local scale=Lerp(ply:VoiceVolume(),1,3)
	
	--ply:ManipulateBoneScale( boneid, Vector(1,1,1)*scale )
	
	util.ScreenShake( ply:EyePos(), 50 * ply:VoiceVolume() , 1, 0.1, 200 )
	
	
end)