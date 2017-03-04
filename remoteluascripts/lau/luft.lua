if SERVER then return end

local basesound = "data/luft/luftrauser_"


local channels = {

}

local function handlesound( snd , err )
	channels[#channels] = snd
	
	snd:Play()
end

concommand.Add("luft", function(ply,command,args)

	for i,v in pairs( channels ) do
		v:Pause()
		v:Stop()
		channels[i] = nil
	end
	
	
	
	sound.PlayFile( basesound.."drums"..math.random( 1, 5 )..".ogg" , "", handlesound )
	sound.PlayFile( basesound.."bass"..math.random( 1, 5 )..".ogg" , "", handlesound )
	sound.PlayFile( basesound.."lead"..math.random( 1, 5 )..".ogg" , "", handlesound )

end,nil, "", 0 )