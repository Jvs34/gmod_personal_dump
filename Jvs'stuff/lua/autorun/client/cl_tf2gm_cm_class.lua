local PANEL = {}

local W = ScrW()
local H = ScrH()
local Scale = H/480

local character_bg = {
	surface.GetTextureID("hud/character_red_bg"),
	surface.GetTextureID("hud/character_blue_bg"),
}
local character_default = surface.GetTextureID("hud/class_scoutred")

local characters={
	spy={done=true,origin=Vector(-47.2455,2.6815,-60.1419),angle=Angle(5.381472,-2.155800,0.000000),weapons={tf_weapon_revolver="Stand_SECONDARY"}},
	pyro={done=true,origin=Vector(-74.1222,14.0894,-50.1657),angle=Angle(8.157065,-7.540892,0.000000),weapons={tf_weapon_flamethrower="Stand_PRIMARY"}},
	scout={done=true,origin=Vector(-44.6028,4.7088,-62.8036),angle=Angle(-7.564510,-5.381306,0.000000),weapons={tf_weapon_scattergun="selectionMenu_StartPose",tf_weapon_handgun_scout="Stand_SECONDARY"}},
	medic={done=true,origin=Vector(-61.2727,1.6354,-59.0804),angle=Angle(13.934922,-0.257668,0.000000),weapons={tf_weapon_medigun="Stand_SECONDARY"}},
	demoman={done=true,origin=Vector(-52.1277,5.8533,-56.3127),angle=Angle(-9.201838,6.664838,0.000000),weapons={tf_weapon_grenadelauncher="selectionMenu_Idle",tf_weapon_bottle="Stand_MELEE",tf_weapon_sword="Stand_MELEE",tf_weapon_katana="Stand_MELEE"}},
	heavy={done=true,origin=Vector(-62.733856,2.016050,-51.673973),angle=Angle(2.311801,25.845839,0.000000),weapons={tf_weapon_minigun="Stand_Deployed_PRIMARY"}},
	engineer={done=true,origin=Vector(-38.1834,7.0316,-55.1673),angle=Angle(-6.390630,1.186725,0.000000),weapons={tf_weapon_wrench="Stand_MELEE",tf_weapon_robot_arm="Stand_ITEM2"}},
	sniper={done=true,origin=Vector(-45.645893,5.006936,-60.115768),angle=Angle(4.468170,-11.349184,0.000000),weapons={tf_weapon_sniperrifle="Stand_PRIMARY",tf_weapon_compound_bow="Stand_ITEM2"}},
	soldier={done=true,origin=Vector(-71.597351,11.050127,-50.473473),angle=Angle(4.360923,-15.947369,0.000000),weapons={tf_weapon_rocketlauncher="Stand_PRIMARY",tf_weapon_rocketlauncher_dh="Stand_PRIMARY",tf_weapon_particle_cannon="Stand_PRIMARY"}},
}

function PANEL:Init()
	self:SetPaintBackgroundEnabled(false)
	self:ParentToHUD()
	self:SetVisible(true)
	self:MoveToBack( )
	self.LightColor=Color(0.6538,0.6716,0.7118)
	self.LightPos=Vector(0,0,50)
	self.LPDuplicate=ClientsideModel( "models/props_junk/watermelon01.mdl", RENDER_GROUP_OPAQUE_ENTITY )
	self.LPDuplicate:SetNoDraw(true)
	self.UpdateInterval=1;
	self.UpdateTime=CurTime()
	self.TFItems={}
end

function PANEL:PerformLayout()
	self:SetPos(0,0)
	self:SetSize(W,H)
end

function PANEL:Think()
	if self.UpdateTime > CurTime() then return end
	self.TFItems={}
	self.LPDuplicate=ClientsideModel(LocalPlayer():GetModel(), RENDER_GROUP_OPAQUE_ENTITY )
	self.LPDuplicate:SetNoDraw(true)
	self.LPDuplicate:SetModel(LocalPlayer():GetModel())
	self.LPDuplicate:SetSkin(LocalPlayer():GetSkin())
	--set the sequence depending on our LocalPlayer's class and to the first weapon in the weapons list,if it's not found then use an alternative
	local sequence="Stand_LOSER";--default sequence name
	local mainweapon=nil;
	--loop trough every weapon
	if characters[LocalPlayer():GetPlayerClass()].weapons then
		for i,v in pairs(LocalPlayer():GetWeapons())do
			if IsValid(v) and characters[LocalPlayer():GetPlayerClass()].weapons[v:GetClass()] then
				sequence=characters[LocalPlayer():GetPlayerClass()].weapons[v:GetClass()];
				mainweapon=v;
				//print(sequence,mainweapon,LocalPlayer():GetPlayerClass())
				break;
			end
		end
	end
	--we have our sequence (hopefully),let's apply it
	self.LPDuplicate:SetSequence(self.LPDuplicate:LookupSequence(sequence))
	
	--now let's create a clientside model of the main weapon we found,and of course of all the cosmetic items

	
	if mainweapon and mainweapon.GetVisuals and mainweapon:GetVisuals() then
		for i,v in pairs(mainweapon:GetVisuals()) do
			local bg=PlayerNamedBodygroups[LocalPlayer():GetPlayerClass()]
			if !bg then continue end
			if i=="hide_player_bodygroup_names" then
				for b,g in pairs(v) do if b and g and bg[g] then self.LPDuplicate:SetBodygroup(bg[g],1); end end
			elseif i=="show_player_bodygroup_names" then
				for b,g in pairs(v) do if b and g and bg[g] then self.LPDuplicate:SetBodygroup(bg[g],0); end end
			end
		end
	end
	
	local worldmodel=nil;
	local attachedwmodel=nil;
	
	if mainweapon then
		worldmodel=mainweapon.WorldModelOverride or mainweapon.WorldModel //attempt to pick the model from a swep
		attachedwmodel=mainweapon.AttachedWorldModel;
	end
	
	if mainweapon and worldmodel && worldmodel ~= "" then
		local clmw=ClientsideModel(worldmodel, RENDER_GROUP_OPAQUE_ENTITY )
		clmw:SetNoDraw(true)
		clmw:SetSkin(mainweapon:GetSkin())
		clmw:SetColor(mainweapon:GetColor())
		clmw:SetParent(self.LPDuplicate)
		clmw:AddEffects(EF_BONEMERGE|EF_BONEMERGE_FASTCULL|EF_PARENT_ANIMATES)
		
		if worldmodel == "models/weapons/w_models/w_shotgun.mdl" then
			clmw:SetMaterial("models/weapons/w_shotgun_tf/w_shotgun_tf")
		end
		
		if mainweapon.MaterialOverride || mainweapon:GetMaterial()!="" then
			clmw:SetMaterial(mainweapon.MaterialOverride || mainweapon:GetMaterial())
		end
		
		clmw.WModelAttachment=mainweapon.WModelAttachment
		clmw.WorldModelVisible=mainweapon.WorldModelVisible
		if attachedwmodel then
			clmw.AttachedModel=ClientsideModel(attachedwmodel,RENDERGROUP_OPAQUE)
			clmw.AttachedModel:SetNoDraw(true)
			clmw.AttachedModel:SetSkin(mainweapon:GetSkin())
			clmw.AttachedModel:SetParent(clmw)
			clmw.AttachedModel:AddEffects(EF_BONEMERGE|EF_BONEMERGE_FASTCULL|EF_PARENT_ANIMATES)
		end
		table.insert(self.TFItems,clmw)
		
	end
	
	for i,v in pairs(LocalPlayer():GetTFItems())do
		if IsValid(v) and not v:IsWeapon() then
			local mdl=nil;
			local item = v:GetItemData()
			
			if item.model_player then
				if item.model_player == "" then
					mdl = nil
				else
					mdl = item.model_player
				end
			elseif item.model_player_per_class and item.model_player_per_class[LocalPlayer():GetPlayerClass()] then
				mdl = item.model_player_per_class[LocalPlayer():GetPlayerClass()]
			end
			if v.GetVisuals and v:GetVisuals() then
					for j,k in pairs(v:GetVisuals()) do
						local bg=PlayerNamedBodygroups[LocalPlayer():GetPlayerClass()]
						if !bg then continue end
						if j=="hide_player_bodygroup_names" then
							for b,g in pairs(k) do if b and g and bg[g] then self.LPDuplicate:SetBodygroup(bg[g],1); end end
						elseif j=="show_player_bodygroup_names" then
							for b,g in pairs(k) do if b and g and bg[g]then self.LPDuplicate:SetBodygroup(bg[g],0); end end
						end
					end
			end
			
			if !mdl then 

			continue 
			end
			
			local clmw=ClientsideModel(mdl, RENDER_GROUP_OPAQUE_ENTITY )
			clmw:SetNoDraw(true);
			clmw:SetSkin(v:GetSkin());
			clmw:SetParent(self.LPDuplicate)
			clmw:AddEffects(EF_BONEMERGE|EF_BONEMERGE_FASTCULL|EF_PARENT_ANIMATES)
			clmw.ItemTint=v:GetItemTint()
			if item.set_sequence_to_class then
				clmw:AddEffects(EF_NOINTERP)
				clmw:ResetSequence(v:LookupSequence(LocalPlayer():GetPlayerClass()))
			end
			table.insert(self.TFItems,clmw)
		
		end
	end
	
	self.UpdateTime=CurTime()+self.UpdateInterval
end

local function StartDrawing3d(vCamPos,vLookAngle,fov,x,y,w,h,lightingposition,col,lightslighting)
	cam.Start3D( vCamPos, vLookAngle, fov, x,y,w,h)
	cam.IgnoreZ( true )

	render.SuppressEngineLighting( true )
	render.SetLightingOrigin( lightingposition)
	render.ResetModelLighting( col.r, col.g, col.b )
	
	render.SetModelLighting( BOX_TOP, col.r, col.g, col.b )
	if lightslighting then
	--blend the new color with the current lighting
	render.SetModelLighting( BOX_FRONT, col.r+lightslighting.r,col.g+lightslighting.g,col.b+lightslighting.b)
	else
	render.SetModelLighting( BOX_FRONT, col.r, col.g, col.b )
	end
end

local function StopDrawing3d()
	render.SuppressEngineLighting( false )
	cam.IgnoreZ( false )
	cam.End3D()
end

function PANEL:Paint()
	if not LocalPlayer():Alive() or LocalPlayer():IsHL2() or GAMEMODE.ShowScoreboard or GetConVarNumber("cl_drawhud")==0 then return end
	self.LightPos2=characters[LocalPlayer():GetPlayerClass()].origin + self.LightPos
	local t = LocalPlayer():Team()
	local tbl = LocalPlayer():GetPlayerClassTable()
	
	local tex = character_bg[t] or character_bg[1]
	surface.SetTexture(tex)
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect(9*Scale, (480-60)*Scale, 100*Scale, 50*Scale)
	
	tex = character_default
	if tbl and tbl.CharacterImage and tbl.CharacterImage[1] then
		tex = tbl.CharacterImage[t] or tbl.CharacterImage[1]
	end
	--this will be shown if the duplicated model of the localplayer is not available
	if !characters[LocalPlayer():GetPlayerClass()] then
		surface.SetTexture(tex)
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect(25*Scale, (480-88)*Scale, 75*Scale, 75*Scale)
		return
	end
	
	if !IsValid(self.LPDuplicate) then return end
	StartDrawing3d(Vector( 18.5,1, 0 ),Angle(0,180,0),54,25*Scale, (480-88)*Scale,75*Scale, 75*Scale,self.LightPos2,self.LightColor)
		self.LPDuplicate:SetRenderOrigin(characters[LocalPlayer():GetPlayerClass()].origin)
		self.LPDuplicate:SetRenderAngles(characters[LocalPlayer():GetPlayerClass()].angle)
		self.LPDuplicate:SetupBones()
		self.LPDuplicate:DrawModel()
		for i,v in pairs(self.TFItems) do
			if IsValid(v) then
				if v.ItemTint then
					v:StartVisualOverrides()
					v:StartItemTint(v.ItemTint)
					v:DrawModel(); 
					v:EndItemTint()
					v:EndVisualOverrides()
				else
					v:DrawModel(); 
				end
				if IsValid(v.AttachedModel) then
					v.AttachedModel:DrawModel();
				end
			end
		end
		
	StopDrawing3d()
end



if HudPlayerClass then HudPlayerClass:Remove() end
HudPlayerClass = vgui.CreateFromTable(vgui.RegisterTable(PANEL, "DPanel"))