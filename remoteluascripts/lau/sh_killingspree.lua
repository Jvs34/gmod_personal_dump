





--[[
	https://dl.dropbox.com/u/20140357/filessharex/announcer_kill_dominate_01.mp3
	https://dl.dropbox.com/u/20140357/filessharex/announcer_kill_godlike_01.mp3
	https://dl.dropbox.com/u/20140357/filessharex/announcer_kill_holy_01.mp3
	https://dl.dropbox.com/u/20140357/filessharex/announcer_kill_mega_01.mp3
	https://dl.dropbox.com/u/20140357/filessharex/announcer_kill_monster_01.mp3
	https://dl.dropbox.com/u/20140357/filessharex/announcer_kill_rampage_01.mp3
	https://dl.dropbox.com/u/20140357/filessharex/announcer_kill_spree_01.mp3
	https://dl.dropbox.com/u/20140357/filessharex/announcer_kill_triple_01.mp3
	https://dl.dropbox.com/u/20140357/filessharex/announcer_kill_ultra_01.mp3
	https://dl.dropbox.com/u/20140357/filessharex/announcer_kill_unstop_01.mp3
	https://dl.dropbox.com/u/20140357/filessharex/announcer_kill_wicked_01.mp3
	https://dl.dropbox.com/u/20140357/filessharex/announcer_ownage_01.mp3
]]

--https://dl.dropbox.com/u/20140357/filessharex/announcer_kill_double_01.mp3
	

if SERVER then
	hook.Add("PlayerDeath","killingspreeshit",( ply, inflictor, attacker )
		if not ply._mkills then ply._mkills=0 end
		ply._mkills=0
		if not attacker._mkills then attacker._mkills=0 end
		attacker._mkills=attacker._mkills=+1
	end)

end