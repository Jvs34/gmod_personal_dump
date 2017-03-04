


function movefunct(ply,usercmd)
	usercmd:SetSideMove(500)
	
	
	usercmd:SetButtons(bit.bor(usercmd:GetButtons(),IN_ATTACK))
end

if CLIENT then
	hook.Add("CreateMove","dicss????",function(cmd)
		movefunct(LocalPlayer(),cmd)
	end)
else
	hook.Add("StartCommand","dicss????",function(ply,cmd)
			movefunct(ply,cmd)
			print("DICKS????")
	end)

end