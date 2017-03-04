
--local ttslink="http://translate.google.com/translate_tts?tl=en&q="
ttslink="http://tts.peniscorp.com/speak.lua?"
--[[
0	BASS_OK
1	BASS_ERROR_MEM
2	BASS_ERROR_FILEOPEN
3	BASS_ERROR_DRIVER
4	BASS_ERROR_BUFLOST
5	BASS_ERROR_HANDLE
6	BASS_ERROR_FORMAT
7	BASS_ERROR_POSITION
8	BASS_ERROR_INIT
9	BASS_ERROR_START
14	BASS_ERROR_ALREADY
18	BASS_ERROR_NOCHAN
19	BASS_ERROR_ILLTYPE
20	BASS_ERROR_ILLPARAM
21	BASS_ERROR_NO3D
22	BASS_ERROR_NOEAX
23	BASS_ERROR_DEVICE
24	BASS_ERROR_NOPLAY
25	BASS_ERROR_FREQ
27	BASS_ERROR_NOTFILE
29	BASS_ERROR_NOHW
31	BASS_ERROR_EMPTY
32	BASS_ERROR_NONET
33	BASS_ERROR_CREATE
34	BASS_ERROR_NOFX
37	BASS_ERROR_NOTAVAIL
38	BASS_ERROR_DECODE
39	BASS_ERROR_DX
40	BASS_ERROR_TIMEOUT
41	BASS_ERROR_FILEFORM
42	BASS_ERROR_SPEAKER
43	BASS_ERROR_VERSION
44	BASS_ERROR_CODEC
45	BASS_ERROR_ENDED
46	BASS_ERROR_BUSY
-1	BASS_ERROR_UNKNOWN

]]
if CLIENT then
	sndchannel={
	}
	
	local modifier=CreateClientConVar( "sndplayer_modifier", "", true, true )
	--for instance [:nr]
	
	local function stopsndplay(ent)
		if not ent then
			for i,v in pairs(sndchannel) do
				if v and v:IsValid() then
					v:Stop()
					v=nil
				end
			end
		else
			if sndchannel[ent] and sndchannel[ent]:IsValid() then
				sndchannel[ent]:Stop()
				sndchannel[ent]=nil
			end
		end
	end
	
	
	
	concommand.Add("stopplayurl_cl", function(ply,command,args)
		stopsndplay()
	end)
	
	net.Receive("stopsndplayer", function(len)
		stopsndplay()
	end)
	
	net.Receive("sndplayer", function(len)
		
		local str=net.ReadString()
		local ent=net.ReadEntity()
		if not IsValid(ent) then
			ent=Entity(0)
		end
		stopsndplay(ent)
		sound.PlayURL(str or "","",function(snd)
			if snd and snd:IsValid() then
				sndchannel[ent]=snd
				sndchannel[ent]:SetVolume(1)
			else
				MsgN("There was a problem playing "..str)
			end
		end)
	end)
	


else

	function escape(s)
		return string.gsub(s, "(.)", function(c)
			return string.format("%%%02x", string.byte(c))
		end)
	end

	local function make_set(t)
		local s = {}
		for i = 1, table.getn(t) do
			s[t[i]] = 1
		end
		return s
	end

	-- these are allowed withing a path segment, along with alphanum
	-- other characters must be escaped
	local segment_set = make_set {
		"-", "_", ".", "!", "~", "*", "'", "(", 
		")", ":", "@", "&", "=", "+", "$", ",", "?",
	}

	function protect_segment(s)
		return string.gsub(s, "(%W)", function (c) 
			if segment_set[c] then return c
			else return escape(c) end
		end)
	end

	function unescape(s)
		return string.gsub(s, "%%(%x%x)", function(hex)
			return string.char(tonumber(hex, 16))
		end)
	end


	umsg.PoolString("sndplayer")
	umsg.PoolString("stopsndplayer")

	ttsenabled=CreateConVar("sndplayer_tts",1,{
		FCVAR_ARCHIVE,FCVAR_NOTIFY
	})

	hook.Add("PlayerSay","TTS",function( sender, messageContent, isTeamChat )
		if not ttsenabled:GetBool() or not IsValid(sender) then return end
		if sender:IsAdmin() and messageContent[1]=="!" and #messageContent > 1 then
			local str=string.sub( messageContent, 2) 
			local modifier=sender:GetInfo("sndplayer_modifier", "" )
			net.Start("sndplayer")
				net.WriteString(ttslink..protect_segment(modifier..str))
				net.WriteEntity(sender)
			net.Broadcast()
			return str
		end
	end)


	concommand.Add("sendplayurl", function(ply,command,args)
		if not IsValid(ply) or not ply:IsAdmin() or not args[1] then return end
		net.Start("sndplayer")
			net.WriteString(args[1] or "")
			net.WriteEntity(ply)
		net.Broadcast()
	end)
	
	concommand.Add("stopplayurl_sv", function(ply,command,args)
		if not IsValid(ply) or not ply:IsAdmin() then return end
		net.Start("stopsndplayer")
		net.Broadcast()
	end)

	
end