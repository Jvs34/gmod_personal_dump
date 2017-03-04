inputsystem={}

if SERVER and game.SinglePlayer() then
	util.AddNetworkString("is_button")
end

function inputsystem:isButtonDown(ply,btn)
	if not ply._buttons then ply._buttons={} end
	return (ply._buttons[btn] ~= nil ) and ply._buttons[btn] or false
end

function inputsystem:clearButtons(ply,btn)
	ply._buttons={}
end

local function sendtosp() end
if SERVER and game.SinglePlayer() then
	sendtosp=function(ply,btn,state)
		net.Start("is_button")
			net.WriteLong(btn)
			net.WriteBit((state) and 1 or 0)
		net.Send(ply)
	end
end
--state,true=down,false=up
function inputsystem:sendButton(ply,btn,state)
	state = (state==nil) and true or state
	if not ply._buttons then ply._buttons={} end
	ply._buttons[btn]=state;
	--only send them to the client if it's singleplayer
	sendtosp(ply,btn,state)
end

hook.Add("PlayerButtonDown","is_buttondown",function( ply, btn ) 
	inputsystem:sendButton(ply,btn,true)
end)

hook.Add("PlayerButtonUp","is_buttonup",function( ply, btn ) 
	inputsystem:sendButton(ply,btn,false)
end)


if CLIENT and game.SinglePlayer() then
	--if it's singleplayer then we sadly need to get the buttons from the server as they are not predicted
	net.Receive("is_button",function(len)
		local btn=net.ReadLong()
		local state=net.ReadBit()
		inputsystem:sendButton(LocalPlayer(),btn,tobool(state))
	end)
end