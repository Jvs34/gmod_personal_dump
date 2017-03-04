local breensound = "breencast.br_welcome02"

if SERVER then
	
	local ply = player.GetAll()[1]
	
	--don't use CurTime, as it's affected by timescale
	local nexttimescale = SysTime()
		
	local trackedsounds = {}
	local lasttimescale = 1
	local manipulat = false
	
	hook.Add( "Think" , "Change timescale test" , function()
		if IsValid( ply ) then
			if nexttimescale < SysTime() then
				game.SetTimeScale( math.abs( math.sin( SysTime() * 2 ) ) + 0.1 )
				nexttimescale = SysTime() + 0.1
			end
		end
		
		--iterate over all our sounds, if they're expired, remove them from the table
		for i , v in pairs( trackedsounds ) do
			--THIS IS LAME A SHIT, WE SHOULD BE ABLE TO CHECK IF THIS SOUND IS LOOPING
			if v.ExpiresIn < SysTime() then
				trackedsounds[i] = nil
				print( "SOUND EXPIRED, FUCK OFF" )
			end
		
		end
		
		local newtimescale = game.GetTimeScale()
		
		if newtimescale ~= lasttimescale then
			--change the pitch of the trackedsounds
			for i , v in pairs( trackedsounds ) do
				--EmitSound( string soundName, Vector position, number entity, number channel=CHAN_AUTO, number volume=1, number soundLevel=75, number soundFlags=0, number pitch=100 )
				local newflags = bit.bor( v.Flags , SND_CHANGE_PITCH )
				local pitch = v.Pitch * newtimescale
				print( v.Entity )
				manipulat = true
				EmitSound( v.OriginalSoundName , v.Pos or v.Entity:EyePos() , v.Entity:EntIndex() , v.Channel , v.Volume , v.SoundLevel , newflags , pitch )
				manipulat = false
			end
			
		end
		
		lasttimescale = newtimescale
	end)

	
	hook.Add( "EntityEmitSound" , "Change timescale test" , function( data )
		--ONLY TRACK THE BREEN SOUND FOR NOW
		if data.OriginalSoundName == breensound and not manipulat then
			
			local tsnd = data
			tsnd.ExpiresIn = SysTime() + 20
			
			--this is a looping sound which was forced to be stopped, remove the entry
			if bit.band( data.Flags , SND_STOP ) ~= 0 then
				tsnd = nil
				print( "REMOVING SOUND FROM QUEUE" )
			end
			
			print( "BEGINNING TO TRACK "..data.OriginalSoundName )
			trackedsounds[data.OriginalSoundName] = tsnd
		end
	end)
	
	
	--[[
	hook.Add( "Think" , "Change timescale test" , function()

	end)
	]]
	
	ply:EmitSound( breensound )
else

	
end