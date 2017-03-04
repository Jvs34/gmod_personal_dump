if ValidPanel(g_ContextMenu) then
	spawnmenu.SetActiveControlPanel(nil)
	g_ContextMenu:Remove()
	g_ContextMenu=nil
	menubar.Control:Remove()
	menubar.Control=nil
	CreateContextMenu()
	menubar.Init()
end

list.Set( "DesktopWindows", "NoTest", {

	title		= "Edit Special action",
	icon		= "icon64/tool.png",
	width		= 320,
	height		= 400,
	onewindow	= true,
	init		= function( icon, window )
		
		if not IsValid(LocalPlayer():GetDTEntity(3)) then
			window:Remove()
			return
		end
		
		local control = window:Add( "DEntityProperties" )
		control:SetEntity( LocalPlayer():GetDTEntity(3) )
		control:Dock( FILL )

		control.OnEntityLost = function()

			window:Remove()

		end
	end
})