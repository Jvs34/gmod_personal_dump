function ScreenClick(mc)
	local traceRes=util.QuickTrace(LocalPlayer():GetShootPos(),(gui.ScreenToVector(gui.MousePos())*9001),LocalPlayer());
	
	if traceRes.Entity && traceRes.Entity:IsValid()then
			RunConsoleCommand("admin_kill","")
	end
	
	return false;
end

hook.Add("GUIMouseReleased","RightAdminClick",ScreenClick);

