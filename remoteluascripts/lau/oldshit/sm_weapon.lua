--[[	This file defines the metatable of a modular weapon and loads them	from the modular_weapons folder inside the gamemode	It should probably be used as a module with module("modularweapon") and such	but I'll fix that later on]]MW={}MW.mwlist={}MW.LEFT=0MW.RIGHT=1MW.BACKPACK=2MW.VIEWMODEL=1MW.WORLDMODEL=2MW.DEFAULTMW=nilMW.ID=1--[[	Gets a modular weapon object to the caller,returns the default one if not found]]function MW:GetMWById(id)	return MW.mwlist[id] and MW.mwlist[id] or MW.mwlist[MW.DEFAULTMW]end--[[	Gets the id of a modular weapon given the class	returns the base weapon id if not found]]function MW:GetIdByClass(mwclass)	local _mw=nil	for i,v in pairs(MW.mwlist) do		if v.Class==mwclass then 			_mw=v.ID 		end	end	return _mw or MW.DEFAULTMWend--[[	Creates a new modular weapon and adds it to the mwlist table for easy access]]function MW:New(name,class)	local newmodularweapon={}	setmetatable(newmodularweapon, self)	self.__index = self	self.Name=name	self.Class=class		local idfound=MW:GetIdByClass(class) or "null"	print("ID FOUND "..idfound)	if MW.DEFAULTMW and idfound>MW.DEFAULTMW then		newmodularweapon:InternalInitialize(true,idfound)		MW.mwlist[idfound]=newmodularweapon		print("RELOADING "..name,class)	else		newmodularweapon:InternalInitialize()		table.insert(MW.mwlist,newmodularweapon)	end	return newmodularweaponend--[[	Internal stuff,this shouldn't be touched]]function MW:InternalInitialize(noidincrease,idfound)	if not noidincrease then		self.ID=MW.ID		MW.ID=MW.ID+1	else		self.ID=idfound	end	self.Name=self.Name or "Name not defined"	self.Class=self.Class or "mw_classnotdefined"endMW.DEFAULTMW=MW:New("Base Weapon","mw_baseweapon").ID--[[	Includes modular weapons	P.S. this is actually stolen from kilburn's tf2 gamemode,precisely from the classes 	loading	module			REMINDER:Rewrite this function yourself when you've got time]]--[[function MW:IncludeModularWeapons()	local path = string.Replace(GM.Folder, "gamemodes/", "").."/gamemode/modular_weapons/"	for _,f in pairs(file.FindInLua(path.."*.lua")) do		AddCSLuaFile(path..f)		include(path..f)		if SERVER then			Msg("loaded \""..path..f.."\"\n")		end	endendfunction MW:IncludeModularWeapon(weapon)	if not weapon then return end	local path = string.Replace(GAMEMODE.Folder, "gamemodes/", "").."/gamemode/modular_weapons/"	include(path..weapon)	Msg("loaded \""..path..weapon.."\"\n")endlocal appendedstate=(CLIENT) and "cl" or "sv"concommand.Add("mw_reload_"..appendedstate, function(ply,command,args)	MW:IncludeModularWeapon(args[1])end)]]--[[	Called by the weapon when it obtains this modular weapon	Do everything on the weapon and owner entities,never save something	on the modular weapon itself]]function MW:Initialize(weapon,owner,leftorright)	end--[[	Called by the weapon when it wants to discard a modular weapon	Destroy our stuff that was saved on the weapon here]]function MW:Uninitialize(weapon,owner,leftorright)end--[[	Called by the swep's think hook (which is called every tick)]]function MW:Think(weapon,owner,leftorright)end--[[	Called by either PrimaryAttack and SecondaryAttack	Bear in mind that on gmod 129 there's no lag compensation on secondary attack]]function MW:Attack(weapon,owner,leftorright,switched) end--[[	Called by ViewModelDrawn and DrawWorldModel,which is which is specified by the 	vieworworld integer that may return MW.VIEWMODEL or MW.WORLDMODEL	It's obviously a 3d draw hook]]function MW:Draw(weapon,owner,leftorright,vieworworld)end--[[	This is called by the multimodel table right inside MW:Draw.	It's used to draw 2d3d stuff on the weapon or just draw effects on it	It also doesn't give a fuck if the weapon is on the right or on the left		WARNING: CURRENTLY NOT IMPLEMENTED]]function MW:WeaponDraw(weapon,owner,pos,ang)end--[[	Called by the swep's huddraw,this is probably not going to be used that much]]function MW:HUDDraw(weapon,owner,leftorright)end--[[	Internal stuff,this shouldn't be touched]]function MW:__tostring()	return "[MW/"..self.ID.."/"..self.Class.."]"end--we don't need this anymore--MW:IncludeModularWeapons()local weapon=MW:New("Blaster","mw_blaster")function weapon:Initialize(weapon,owner,leftorright)	if CLIENT then		--weapon:GetMWData(leftorright).mm=multimodel.CreateInstance("sm_blaster")			end	weapon:SetNWMWData(leftorright,"Float",CurTime())endfunction weapon:Unitialize(weapon,owner,leftorright)	if CLIENT then		--weapon:GetMWData(leftorright).mm=multimodel.CreateInstance("sm_blaster")			end	weapon:SetNWMWData(leftorright,"Float",CurTime()+1)endlocal shootoffsets={	[MW.LEFT]=Vector(0,3,-4),	[MW.RIGHT]=Vector(0,-4,-4),}function weapon:Attack(weapon,owner,leftorright,switched) 	if weapon:GetNWMWData(leftorright,"Float")>CurTime() then return end	if SERVER then		owner:EmitSound("citadel.br_no")	end	if CLIENT and IsFirstTimePredicted() then		owner:EmitSound("citadel.br_no")	end	weapon:SendWeaponAnimation( ACT_VM_PRIMARYATTACK, leftorright, 1.0 )	if SERVER then		--[[local blastshot=ents.Create("sm_blaster_shot")		blastshot:SetOwner(owner)		local pos,ang=LocalToWorld(shootoffsets[leftorright],Angle(90,0,0),owner:GetShootPos(),owner:EyeAngles())		blastshot:SetPos(pos)		blastshot:SetAngles(ang)		blastshot:Spawn()		]]	end	--weapon:SetNextAttackFire(leftorright,CurTime()+1,switched)	weapon:SetNWMWData(leftorright,"Float",CurTime()+0.5)endif CLIENT then	function weapon:Draw(weapon,owner,leftorright,vieworworld)	end	function weapon:WeaponDraw(weapon,leftorright,owner,pos,ang)		endendweapon=MW:New("Minigun","mw_minigun")function weapon:Initialize(weapon,owner,leftorright)	if CLIENT then		--weapon:GetMWData(leftorright).mm=multimodel.CreateInstance("sm_blaster")			end	weapon:SetNWMWData(leftorright,"Float",CurTime())endfunction weapon:Unitialize(weapon,owner,leftorright)	if CLIENT then		--weapon:GetMWData(leftorright).mm=multimodel.CreateInstance("sm_blaster")			end	weapon:SetNWMWData(leftorright,"Float",CurTime()+1)endfunction weapon:Attack(weapon,owner,leftorright,switched) 	if weapon:GetNWMWData(leftorright,"Float")>CurTime() then return end	if SERVER then		owner:EmitSound("Weapon_SMG1.NPC_Single")	end	if CLIENT and IsFirstTimePredicted() then		owner:EmitSound("Weapon_SMG1.NPC_Single")	end	weapon:SendWeaponAnimation( ACT_VM_PRIMARYATTACK, leftorright, 1.0 )	if SERVER then	end	--weapon:SetNextAttackFire(leftorright,CurTime()+1,switched)	weapon:SetNWMWData(leftorright,"Float",CurTime()+0.1)endif CLIENT then	function weapon:Draw(weapon,owner,leftorright,vieworworld)	end	function weapon:WeaponDraw(weapon,leftorright,owner,pos,ang)		endend--[[	This is the only weapon the player will have,and it's basically his two arms,left and right	Basically,this weapon will call external functions from another file that will dictate how the weapon will work	For instance,the player has initially a little blaster defined in another file	This weapon can hold two modular weapons (left and right) and will shoot the weapons when the player presses the respective buttons]]AddCSLuaFile("shared.lua")local notconventionalregistering=falseif not SWEP then	SWEP={}	notconventionalregistering=trueendSWEP.Base="weapon_base"SWEP.AutoSwitchTo=trueSWEP.AutoSwitchFrom=trueSWEP.DrawAmmo=trueSWEP.PrintName="Multi weapon"SWEP.Author="Jvs"SWEP.DrawCrosshair= trueSWEP.ViewModelFOV= 54SWEP.RenderGroup = RENDERGROUP_BOTHSWEP.Category= "" SWEP.Slot= 0SWEP.SlotPos= 5SWEP.Weight= 5SWEP.Spawnable = falseSWEP.AdminSpawnable  = trueSWEP.ViewModel= "models/weapons/v_pistol.mdl"SWEP.WorldModel="models/weapons/w_crowbar.mdl"SWEP.Primary={}SWEP.Primary.ClipSize= -1SWEP.Primary.DefaultClip= -1SWEP.Primary.Ammo = falseSWEP.Primary.Automatic= trueSWEP.Secondary={}SWEP.Secondary.ClipSize= -1SWEP.Secondary.DefaultClip= -1SWEP.Secondary.Ammo = falseSWEP.Secondary.Automatic = trueSWEP.VM_posoffset=Vector(-14,-1.4,-32)SWEP.VM_angoffset=Angle(0,0,0)SWEP.ViewModelFlip                    = trueSWEP.ViewModelFlip1                    = falselocal ShrinkBones={"ValveBiped.Bip01_Pelvis","ValveBiped.Bip01_Spine","ValveBiped.Bip01_Spine1","ValveBiped.Bip01_Spine2","ValveBiped.Bip01_Spine4","ValveBiped.Bip01_Neck1","ValveBiped.Bip01_Head1"}function SWEP:Initialize()	self:SetWeaponHoldType("duel")	self.mw_data={}	self.mw_data[MW.LEFT]={}	self.mw_data[MW.RIGHT]={}	self:SetSwitchedAttacks(true)		self:SetLeftMW("mw_blaster")	self:SetRightMW("mw_minigun")			--[[		These are set to MW.DEFAULTMW so the think function will initialize the		weapons automatically	]]		self:SendWeaponAnimation( ACT_VM_DEPLOY, 0, 1.0 )	self:SendWeaponAnimation( ACT_VM_DEPLOY, 1, 1.0 )		self.old_leftmw=MW.DEFAULTMW	self.old_rightmw=MW.DEFAULTMW	self.Initialized=trueendfunction SWEP:MWDTVar(vartype,id,name,leftorright)	if leftorright~=nil then		self.nwmw_data[leftorright][vartype]=name	end	self:DTVar(vartype,id,name)endfunction SWEP:SetupDataTables()	self.nwmw_data={}	self.nwmw_data[MW.LEFT]={}	self.nwmw_data[MW.RIGHT]={}	self.nwmw_data[MW.BACKPACK]={}		--these ones should only be set by the weapon itself	self:DTVar("Bool", 0, "SwitchedInput")	self:DTVar("Int", 0, "mw_leftweapon")	self:DTVar("Int", 1, "mw_rightweapon")		--left weapon	self:MWDTVar("Int", 2, "MW.LEFT_Intvar",MW.LEFT)	self:MWDTVar("Float", 0, "MW.LEFT_Floatvar",MW.LEFT)	self:MWDTVar("Bool", 1, "MW.LEFT_Boolvar",MW.LEFT)	self:MWDTVar("Entity", 0, "MW.LEFT_Entityvar",MW.LEFT)	self:MWDTVar("String", 0, "MW.LEFT_Stringvar",MW.LEFT)	self:MWDTVar("Angle", 0, "MW.LEFT_Anglevar",MW.LEFT)		--right weapon	self:MWDTVar("Int", 3, "MW.RIGHT_Intvar",MW.RIGHT)	self:MWDTVar("Float", 1, "MW.RIGHT_Floatvar",MW.RIGHT)	self:MWDTVar("Bool", 2, "MW.RIGHT_Boolvar",MW.RIGHT)	self:MWDTVar("Entity", 1, "MW.RIGHT_Entityvar",MW.RIGHT)	self:MWDTVar("String", 1, "MW.RIGHT_Stringvar",MW.RIGHT)	self:MWDTVar("Angle", 1, "MW.RIGHT_Anglevar",MW.RIGHT)		--unused, backpack	self:MWDTVar("Float", 2, "MW.BACKPACK_Floatvar",MW.BACKPACK)	self:MWDTVar("Bool", 3, "MW.BACKPACK_Boolvar",MW.BACKPACK)	self:MWDTVar("Entity", 2, "MW.BACKPACK_Entityvar",MW.BACKPACK)	self:MWDTVar("String", 2, "MW.BACKPACK_Stringvar",MW.BACKPACK)	self:MWDTVar("Angle", 2, "MW.BACKPACK_Anglevar",MW.BACKPACK)endfunction SWEP:GetMW(leftorright)	return MW:GetMWById( (leftorright==MW.LEFT) and self:GetLeftMWID() or self:GetRightMWID() )endfunction SWEP:GetMWData(leftorright)	return self.mw_data[leftorright]endfunction SWEP:GetNWMWData(leftorright,vartype)	return self.dt[self.nwmw_data[leftorright][vartype]]endfunction SWEP:SetNWMWData(leftorright,vartype,value)	if not value then return end	self.dt[self.nwmw_data[leftorright][vartype]]=valueendfunction SWEP:SetSwitchedAttacks(bool)	if not self.dt then return end	self.dt.SwitchedInput=boolendfunction SWEP:GetSwitchedAttacks()	if not self.dt then return end	return self.dt.SwitchedInputend--unusedfunction SWEP:SetNextAttackFire(leftorright,firetime,switched)	if switched then		leftorright=(leftorright==MW.LEFT) and MW.RIGHT or MW.LEFT	end		if leftorright==MW.LEFT then		self:SetNextPrimaryFire(firetime)	else		self:SetNextSecondaryFire(firetime)	endendfunction SWEP:SetLeftMW(argument)	if not self.dt then return end	local id=MW.DEFAULTMW	if type(argument)=="string" then		id=MW:GetIdByClass(argument)	elseif type(argument)=="number" then		id=argument	else		print("I am afraid that is not a valid weapon inputted to SetLeftMW")		return	end	print("Left modular weapon set to "..MW:GetMWById(id).Name.."\n")	self.dt.mw_leftweapon=idendfunction SWEP:SetRightMW(argument)	if not self.dt then return end	local id=MW.DEFAULTMW	if type(argument)=="string" then		id=MW:GetIdByClass(argument)	elseif type(argument)=="number" then		id=argument	else		print("I am afraid that is not a valid weapon inputted to SetRightMW")		return	end	print("Right modular weapon set to "..MW:GetMWById(id).Name.."\n")	self.dt.mw_rightweapon=idendfunction SWEP:GetLeftMWID()	if not self.dt then return end	return self.dt.mw_leftweapon or MW.DEFAULTMWendfunction SWEP:GetRightMWID()	if not self.dt then return end	return self.dt.mw_rightweapon or MW.DEFAULTMWendfunction SWEP:GetViewModelPosition(pos,ang)endfunction SWEP:GetMWWeapons()	return "LEFT "..tostring(self:GetMW(MW.LEFT)).."   "..tostring(self:GetMW(MW.RIGHT)).." RIGHT"endfunction SWEP:CreateHands()	if IsValid(self.Hands) then return end	self.Hands=ClientsideModel("models/player/Kleiner.mdl")	self.Hands:SetNoDraw(true)	self.Hands:Spawn()	self.Hands:ClearPoseParameters()	self.Hands:SetSequence(self.Hands:LookupSequence("idle_duel"))	self.Hands:FrameAdvance(FrameTime())		function self.Hands:BuildBonePositions()		local bone		local bm		for i,v in pairs(ShrinkBones)do			bone=self:LookupBone(v)			bm=self:GetBoneMatrix(bone)			if bm then				bm:Scale(Vector(0.001,0.001,0.001))				self:SetBoneMatrix(bone,bm)			end			bone=nil			bm=nil		end	endendfunction SWEP:ViewModelDrawn(viewmodel)	if not self.Initialized then return end	--if not IsValid(self.Hands) then return end	--[[	self.Hands:ClearPoseParameters()	self.Hands:DrawModel()	]]	self:GetMW(MW.LEFT):Draw(self,self.Owner,MW.LEFT,MW.VIEWMODEL)	self:GetMW(MW.RIGHT):Draw(self,self.Owner,MW.RIGHT,MW.VIEWMODEL)end--[[function SWEP:ExtraViewModelDrawn()	if not self.Initialized then return end	if not IsValid(self.Hands) then return end	local bobvec=self.BobVector or Angle()	local bobang=self.BobAngle or Angle()	local lightcol=render.GetLightColor(self.Owner:EyePos()+Vector(0,0,10))	cam.Start3D(Vector(-1.0234,2,60.0414),Angle(0,0,0) )		cam.IgnoreZ(true)		    render.SuppressEngineLighting( true )			render.SetLightingOrigin( Vector(0,0,10) )			render.ResetModelLighting( lightcol.x*1.5, lightcol.y*1.5, lightcol.z*1.5 )			render.SetColorModulation( lightcol.x*1.5, lightcol.y*1.5, lightcol.z *1.5)				self.Hands:ClearPoseParameters()			self.Hands:DrawModel()			self:GetMW(MW.LEFT):Draw(self,self.Owner,MW.LEFT,MW.VIEWMODEL)			self:GetMW(MW.RIGHT):Draw(self,self.Owner,MW.RIGHT,MW.VIEWMODEL)			render.SuppressEngineLighting(false)		cam.IgnoreZ(false)	cam.End3D()endhook.Add( "RenderScreenspaceEffects", "sm_viewmodel", function()	if IsValid(LocalPlayer()) and LocalPlayer():Alive() and not LocalPlayer():ShouldDrawLocalPlayer() and IsValid(LocalPlayer():GetActiveWeapon())	and LocalPlayer():GetActiveWeapon().ExtraViewModelDrawn then		LocalPlayer():GetActiveWeapon():ExtraViewModelDrawn()	endend)]]function SWEP:DrawWorldModel()endfunction SWEP:DrawWorldModelTranslucent()	if not self.Initialized then return end	self:GetMW(MW.LEFT):Draw(self,self.Owner,MW.LEFT,MW.WORLDMODEL)	self:GetMW(MW.RIGHT):Draw(self,self.Owner,MW.RIGHT,MW.WORLDMODEL)endfunction SWEP:Deploy()	self:GetMW(MW.LEFT):Initialize(self,self.Owner,MW.LEFT)	self:GetMW(MW.RIGHT):Initialize(self,self.Owner,MW.RIGHT)		local vm = self.Owner:GetViewModel( 1 )	vm:SetWeaponModel( self.ViewModel, self )	self:SendWeaponAnimation( ACT_VM_DEPLOY, 1, 1.0 )	self.ViewModelFlip1 = not self.ViewModelFlip        local deployTime = self:SendWeaponAnimation( ACT_VM_DEPLOY, 0, 1.0 ) // override 4x default	return trueendfunction SWEP:Holster()    self:GetMW(MW.LEFT):Uninitialize(self,self.Owner,MW.LEFT)	self:GetMW(MW.RIGHT):Uninitialize(self,self.Owner,MW.RIGHT)	    local owner = self:GetOwner()        if( owner and IsValid(owner) and owner:IsPlayer() and IsValid(owner:GetViewModel( 1 )) ) then        owner:GetViewModel( 1 ):AddEffects( EF_NODRAW )    end            return trueend--credits to steveukfunction SWEP:SendWeaponAnimation( anim, idx, pbr )    idx = idx or 0    pbr = pbr or 1.0        local owner = self:GetOwner()            if( owner and IsValid(owner) and owner:IsPlayer() ) then            local vm = owner:GetViewModel( idx )		if not IsValid(vm) then return end        local idealSequence = self:SelectWeightedSequence( anim )        local nextSequence = self:FindTransitionSequence( self:GetSequence(), idealSequence )               vm:RemoveEffects( EF_NODRAW )        vm:SetPlaybackRate( pbr )        if( nextSequence > 0 ) then            vm:SendViewModelMatchingSequence( nextSequence )        else            vm:SendViewModelMatchingSequence( idealSequence )        end        return vm:SequenceDuration( vm:GetSequence() )    end    endfunction SWEP:StupidSPFix(FunctName)	if SERVER and game.SinglePlayer() then		self:CallOnClient(FunctName,"")	endendfunction SWEP:Reload()	--Jvs:what could be the reload used for? it has no lag compensation but it's predicted,so think of something kay?	--maybe it could switch the attacks from left to right over to right to left?	--make it so the user can only do it every n secondsendfunction SWEP:DoImpactEffect( trace, nDamageType )endfunction SWEP:PrimaryAttack()	self:StupidSPFix("PrimaryAttack")	local leftorright=(self:GetSwitchedAttacks()==true) and MW.LEFT or MW.RIGHT	local switched=not self:GetSwitchedAttacks()	self:GetMW(leftorright):Attack(self,self.Owner,leftorright,switched)endfunction SWEP:SecondaryAttack()	self:StupidSPFix("SecondaryAttack")	local leftorright=(self:GetSwitchedAttacks()==true) and MW.RIGHT or MW.LEFT	local switched=not self:GetSwitchedAttacks()	self:GetMW(leftorright):Attack(self,self.Owner,leftorright,switched)endfunction SWEP:OnRemove()	self:GetMW(MW.LEFT):Uninitialize(self,self.Owner,MW.LEFT)	self:GetMW(MW.RIGHT):Uninitialize(self,self.Owner,MW.RIGHT)endfunction SWEP:Think()	if not self.dt then return end	if not self.Initialized then return end		if CLIENT and self.Owner==LocalPlayer() then		self:CreateHands()		if IsValid(self.Hands)then		end	end		if self:GetLeftMWID() ~=self.old_leftmw then		MW:GetMWById(self.old_leftmw):Uninitialize(self,self.Owner,MW.LEFT)		self:GetMW(MW.LEFT):Initialize(self,self.Owner,MW.LEFT)	end		if self:GetRightMWID() ~=self.old_rightmw then		MW:GetMWById(self.old_rightmw):Uninitialize(self,self.Owner,MW.RIGHT)		self:GetMW(MW.RIGHT):Initialize(self,self.Owner,MW.RIGHT)	end	self.old_leftmw=self:GetLeftMWID()	self.old_rightmw=self:GetRightMWID()		self:GetMW(MW.LEFT):Think(self,self.Owner,MW.LEFT)	self:GetMW(MW.RIGHT):Think(self,self.Owner,MW.RIGHT)endif CLIENT then	--This is a stupid fix to the clientside think/initialize of sweps not being called on other clients but localplayer's	local wep=nil	hook.Add("Tick","Fixclientsideswepthink",function()		for i,v in pairs(player.GetAll()) do			if IsValid(v) and v~=LocalPlayer() and v:Alive() then				wep=v:GetActiveWeapon()				if wep~=NULL and IsValid(wep) and wep.Think then					if not wep.Initialized and wep.SetupDataTables then						wep:SetupDataTables()						wep:Initialize()					end				wep:Think() 				end				wep=nil			end		end	end)endif notconventionalregistering then	weapons.Register(SWEP,"sm_weapon",true)	SWEP=nilend