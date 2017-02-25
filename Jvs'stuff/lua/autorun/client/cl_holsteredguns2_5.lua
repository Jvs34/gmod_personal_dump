/*
	Jvs:this script will allow you to see your/others weapons directly on the body when in thirdperson
	every weapon needs a different bone/drawfunction/boneoffset,however,drawfunction can be nil
	boneoffsets will be retrieved from a custom table,so,if there's a pistol,it will draw it on the hips,heavy weapons on the back etc etc
	WARNING:drawfunction will NOT draw the model,it will draw an effect or whatever you want,the model is drawn before this function gets called
	i know,there's no gui/derma to modify the bones,i'm used to modify them directly in the .lua file,just look at the these hl2 weapons examples
*/

local holsteredgunsconvar = CreateConVar( "cl_holsteredguns", "1", { FCVAR_ARCHIVE, }, "Enable/Disable the rendering of the weapons on any player" )

local NEXT_WEAPONS_UPDATE=CurTime();

local physgunmat=Material("sprites/physg_glow1")
local physgunmat1=Material("sprites/physg_glow2")

local weaponsinfos={}
weaponsinfos["weapon_physcannon"]={}
weaponsinfos["weapon_physcannon"].Model="models/weapons/w_physics.mdl"
weaponsinfos["weapon_physcannon"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["weapon_physcannon"].BoneOffset={Vector(6,15,0),Angle(90,180,0)}//offset,weapon angle
weaponsinfos["weapon_physcannon"].Priority="weapon_physgun" //this means that if the weapon_physgun can be drawn,we will not

weaponsinfos["weapon_physgun"]={}
weaponsinfos["weapon_physgun"].Model="models/weapons/w_physics.mdl"
weaponsinfos["weapon_physgun"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["weapon_physgun"].DrawFunction=function(ent) end /* draw custom core to make it look like it's on */ 
weaponsinfos["weapon_physgun"].BoneOffset={Vector(6,15,0),Angle(90,180,0)}//offset,weapon angle
weaponsinfos["weapon_physgun"].Skin=1;	//we can set custom skin too,but only once,remember that


weaponsinfos["weapon_physgun"].DrawFunction=function(ent)
	local attachment=ent:GetAttachment( 1)
	local StartPos = attachment.Pos + attachment.Ang:Forward()*4
	render.SetMaterial(physgunmat)
	render.DrawSprite(attachment.Pos,20,20,Color(255,255,255,255));
	render.SetMaterial(physgunmat1)
	render.DrawSprite(StartPos,20,20,Color(255,255,255,255));	
end


weaponsinfos["weapon_pistol"]={}
weaponsinfos["weapon_pistol"].Model="models/weapons/W_pistol.mdl"
weaponsinfos["weapon_pistol"].Bone="ValveBiped.Bip01_Pelvis"
weaponsinfos["weapon_pistol"].BoneOffset={Vector(0,-8,0),Angle(0,90,0)}//offset,weapon angle

weaponsinfos["weapon_357"]={}
weaponsinfos["weapon_357"].Model="models/weapons/W_357.mdl"
weaponsinfos["weapon_357"].Bone="ValveBiped.Bip01_Pelvis"
weaponsinfos["weapon_357"].BoneOffset={Vector(-5,8,0),Angle(0,270,0)}//offset,weapon angle
weaponsinfos["weapon_357"].Priority="gmod_tool"

weaponsinfos["gmod_tool"]={}
weaponsinfos["gmod_tool"].Bone="ValveBiped.Bip01_Pelvis"
weaponsinfos["gmod_tool"].BoneOffset={Vector(-5,8,0),Angle(0,270,0)}//offset,weapon angle


weaponsinfos["weapon_frag"]={}
weaponsinfos["weapon_frag"].Model="models/Items/grenadeAmmo.mdl"
weaponsinfos["weapon_frag"].Bone="ValveBiped.Bip01_Pelvis"
weaponsinfos["weapon_frag"].BoneOffset={Vector(3,-5,6),Angle(-95,0,0)}//offset,weapon angle

weaponsinfos["weapon_slam"]={}
weaponsinfos["weapon_slam"].Model="models/weapons/w_slam.mdl"
weaponsinfos["weapon_slam"].Bone="ValveBiped.Bip01_Spine2"
weaponsinfos["weapon_slam"].BoneOffset={Vector(-9,0,-7),Angle(270,90,-25)}//offset,weapon angle

weaponsinfos["weapon_crowbar"]={}
weaponsinfos["weapon_crowbar"].Model="models/weapons/w_crowbar.mdl"
weaponsinfos["weapon_crowbar"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["weapon_crowbar"].BoneOffset={Vector(3,0,0),Angle(0,0,45)}//offset,weapon angle

weaponsinfos["weapon_stunstick"]={}
weaponsinfos["weapon_stunstick"].Model="models/weapons/W_stunbaton.mdl"
weaponsinfos["weapon_stunstick"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["weapon_stunstick"].BoneOffset={Vector(3,0,0),Angle(0,0,-45)}//offset,weapon angle

weaponsinfos["weapon_shotgun"]={}
weaponsinfos["weapon_shotgun"].Model="models/weapons/W_shotgun.mdl"
weaponsinfos["weapon_shotgun"].Bone="ValveBiped.Bip01_R_Clavicle"
weaponsinfos["weapon_shotgun"].BoneOffset={Vector(10,5,2),Angle(0,90,0)}//offset,weapon angle

weaponsinfos["weapon_rpg"]={}
weaponsinfos["weapon_rpg"].Model="models/weapons/w_rocket_launcher.mdl"
weaponsinfos["weapon_rpg"].Bone="ValveBiped.Bip01_L_Clavicle"
weaponsinfos["weapon_rpg"].BoneOffset={Vector(-16,5,0),Angle(90,90,90)}//offset,weapon angle

weaponsinfos["weapon_smg1"]={}
weaponsinfos["weapon_smg1"].Model="models/weapons/w_smg1.mdl"
weaponsinfos["weapon_smg1"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["weapon_smg1"].BoneOffset={Vector(5,0,-5),Angle(0,0,230)}//offset,weapon angle

weaponsinfos["weapon_ar2"]={}
weaponsinfos["weapon_ar2"].Model="models/weapons/W_irifle.mdl"
weaponsinfos["weapon_ar2"].Bone="ValveBiped.Bip01_R_Clavicle"
weaponsinfos["weapon_ar2"].BoneOffset={Vector(-5,0,7),Angle(0,270,0)}//offset,weapon angle

weaponsinfos["weapon_crossbow"]={}
weaponsinfos["weapon_crossbow"].Model="models/weapons/W_crossbow.mdl"
weaponsinfos["weapon_crossbow"].Bone="ValveBiped.Bip01_L_Clavicle"
weaponsinfos["weapon_crossbow"].BoneOffset={Vector(0,5,-5),Angle(180,90,0)}//offset,weapon angle

//drp weapons

weaponsinfos["drp_weapon_canminigun"]={}
weaponsinfos["drp_weapon_canminigun"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["drp_weapon_canminigun"].BoneOffset={Vector(6,15,0),Angle(90,180,0)}//offset,weapon angle



weaponsinfos["drp_weapon_potatocannon"]={}
weaponsinfos["drp_weapon_potatocannon"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["drp_weapon_potatocannon"].BoneOffset={Vector(-2,25,5),Angle(90,180,0)}//offset,weapon angle

weaponsinfos["drp_weapon_woodpistol"]={}
weaponsinfos["drp_weapon_woodpistol"].Model="models/weapons/W_pistol.mdl"
weaponsinfos["drp_weapon_woodpistol"].Bone="ValveBiped.Bip01_Pelvis"
weaponsinfos["drp_weapon_woodpistol"].BoneOffset={Vector(0,-8,0),Angle(0,90,0)}//offset,weapon angle

weaponsinfos["drp_weapon_melongun"]={}
weaponsinfos["drp_weapon_melongun"].Model="models/weapons/W_357.mdl"
weaponsinfos["drp_weapon_melongun"].Bone="ValveBiped.Bip01_Pelvis"
weaponsinfos["drp_weapon_melongun"].BoneOffset={Vector(-5,8,0),Angle(0,270,0)}//offset,weapon angle

weaponsinfos["drp_weapon_ddrsmg"]={}
weaponsinfos["drp_weapon_ddrsmg"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["drp_weapon_ddrsmg"].BoneOffset={Vector(5,0,-5),Angle(0,0,230)}//offset,weapon angle

weaponsinfos["drp_weapon_brickhammer"]={}
weaponsinfos["drp_weapon_brickhammer"].Bone="ValveBiped.Bip01_Spine1"
weaponsinfos["drp_weapon_brickhammer"].BoneOffset={Vector(3,0,0),Angle(0,0,45)}//offset,weapon angle



//tf2 weapons
//sniper
weaponsinfos["tf_weapon_sniperrifle"]={}
weaponsinfos["tf_weapon_sniperrifle"]["sniper"]={}
weaponsinfos["tf_weapon_sniperrifle"]["sniper"].Bone="bip_spine_3"
weaponsinfos["tf_weapon_sniperrifle"]["sniper"].BoneOffset={Vector(-14,5,3.5),Angle(75,0,-90)}//offset,weapon angle

weaponsinfos["tf_weapon_smg"]={}
weaponsinfos["tf_weapon_smg"]["sniper"]={}
weaponsinfos["tf_weapon_smg"]["sniper"].Bone="bip_hip_R"
weaponsinfos["tf_weapon_smg"]["sniper"].BoneOffset={Vector(6,-3,0),Angle(0,0,0)}//offset,weapon angle

weaponsinfos["tf_weapon_compound_bow"]={}
weaponsinfos["tf_weapon_compound_bow"]["sniper"]={}
weaponsinfos["tf_weapon_compound_bow"]["sniper"].Bone="bip_spine_3"
weaponsinfos["tf_weapon_compound_bow"]["sniper"].BoneOffset={Vector(-7,-8,5),Angle(70,180,0)}//offset,weapon angle
weaponsinfos["tf_weapon_compound_bow"]["sniper"].BBP=function(self)
	local bonename="weapon_bone_4"
	local bm = self:GetBoneMatrix( self:LookupBone(bonename) )
	bm:Scale( vector_origin ) -- Deflates the bone
	self:SetBoneMatrix(self:LookupBone(bonename), bm )
end

weaponsinfos["tf_weapon_club"]={}
weaponsinfos["tf_weapon_club"]["sniper"]={}
weaponsinfos["tf_weapon_club"]["sniper"].Bone="bip_hip_L"
weaponsinfos["tf_weapon_club"]["sniper"].BoneOffset={Vector(-5,0,0),Angle(180,0,0)}//offset,weapon angle

weaponsinfos["tf_weapon_jar"]={}
weaponsinfos["tf_weapon_jar"]["sniper"]={}
weaponsinfos["tf_weapon_jar"]["sniper"].Bone="bip_hip_R"
weaponsinfos["tf_weapon_jar"]["sniper"].BoneOffset={Vector(5,0,0),Angle(0,0,0)}//offset,weapon angle

//spy
weaponsinfos["tf_weapon_revolver"]={}
weaponsinfos["tf_weapon_revolver"]["spy"]={}
weaponsinfos["tf_weapon_revolver"]["spy"].Bone="bip_hip_L"
weaponsinfos["tf_weapon_revolver"]["spy"].BoneOffset={Vector(-4.5,0,0),Angle(0,0,0)}//offset,weapon angle

weaponsinfos["tf_weapon_builder"]={}
weaponsinfos["tf_weapon_builder"]["spy"]={}
weaponsinfos["tf_weapon_builder"]["spy"].Bone="bip_hip_R"
weaponsinfos["tf_weapon_builder"]["spy"].BoneOffset={Vector(0,7,-4.5),Angle(180,0,0)}//offset,weapon angle

--weaponsinfos["tf_weapon_knife"]={}
--weaponsinfos["tf_weapon_knife"]["spy"]={}
--weaponsinfos["tf_weapon_knife"]["spy"].Bone="bip_lowerArm_R"
--weaponsinfos["tf_weapon_knife"]["spy"].BoneOffset={Vector(0,6,-2.5),Angle(90,0,90)}//offset,weapon angle


//medic
weaponsinfos["tf_weapon_bonesaw"]={}
weaponsinfos["tf_weapon_bonesaw"]["medic"]={}
weaponsinfos["tf_weapon_bonesaw"]["medic"].Bone="bip_hip_L"
weaponsinfos["tf_weapon_bonesaw"]["medic"].BoneOffset={Vector(0,0,-5),Angle(270,0,0)}//offset,weapon angle

weaponsinfos["tf_weapon_syringegun_medic"]={}
weaponsinfos["tf_weapon_syringegun_medic"]["medic"]={}
weaponsinfos["tf_weapon_syringegun_medic"]["medic"].Bone="bip_hip_R"
weaponsinfos["tf_weapon_syringegun_medic"]["medic"].BoneOffset={Vector(6,8,0),Angle(0,-5,0)}//offset,weapon angle

weaponsinfos["tf_weapon_crossbow"]={}
weaponsinfos["tf_weapon_crossbow"]["medic"]={}
weaponsinfos["tf_weapon_crossbow"]["medic"].Bone="bip_hip_R"
weaponsinfos["tf_weapon_crossbow"]["medic"].BoneOffset={Vector(6,8,0),Angle(0,-5,0)}//offset,weapon angle


weaponsinfos["tf_weapon_medigun"]={}
weaponsinfos["tf_weapon_medigun"]["medic"]={}
weaponsinfos["tf_weapon_medigun"]["medic"].Bone="bip_spine_2"
weaponsinfos["tf_weapon_medigun"]["medic"].BoneOffset={Vector(-11,-11,6),Angle(90,180,90)}//offset,weapon angle
weaponsinfos["tf_weapon_medigun"]["medic"].BBP=function(self) 
	local bonename="joint_hose01"
	local bm = self:GetBoneMatrix( self:LookupBone(bonename) )
	bm:Rotate( Angle(0,30,0) ) -- Deflates the bone
	self:SetBoneMatrix(self:LookupBone(bonename), bm )
	
	bonename="joint_hose02"
	bm = self:GetBoneMatrix( self:LookupBone(bonename) )
	bm:Rotate( Angle(0,60,0) ) -- Deflates the bone
	self:SetBoneMatrix(self:LookupBone(bonename), bm )
	
	bonename="joint_hose03"
	bm = self:GetBoneMatrix( self:LookupBone(bonename) )
	bm:Rotate( Angle(0,70,0) ) -- Deflates the bone
	self:SetBoneMatrix(self:LookupBone(bonename), bm )
	
	bonename="joint_hose04"
	bm = self:GetBoneMatrix( self:LookupBone(bonename) )
	bm:Rotate( Angle(0,50,0) ) -- Deflates the bone
	self:SetBoneMatrix(self:LookupBone(bonename), bm )

	bonename="joint_hose05"
	bm = self:GetBoneMatrix( self:LookupBone(bonename) )
	bm:Rotate( Angle(0,-10,0) ) -- Deflates the bone
	self:SetBoneMatrix(self:LookupBone(bonename), bm )
	
end


//engineer
weaponsinfos["tf_weapon_wrench"]={}
weaponsinfos["tf_weapon_wrench"]["engineer"]={}
weaponsinfos["tf_weapon_wrench"]["engineer"].Bone="bip_hip_L"
weaponsinfos["tf_weapon_wrench"]["engineer"].BoneOffset={Vector(-5,0,0),Angle(0,0,230)}//offset,weapon angle

weaponsinfos["tf_weapon_shotgun_primary"]={}
weaponsinfos["tf_weapon_shotgun_primary"]["engineer"]={}
weaponsinfos["tf_weapon_shotgun_primary"]["engineer"].Bone="bip_spine_0"
weaponsinfos["tf_weapon_shotgun_primary"]["engineer"].BoneOffset={Vector(20,-5,5),Angle(-90,0,90)}//offset,weapon angle

weaponsinfos["tf_weapon_sentry_revenge"]={}
weaponsinfos["tf_weapon_sentry_revenge"]["engineer"]={}
weaponsinfos["tf_weapon_sentry_revenge"]["engineer"].Bone="bip_spine_0"
weaponsinfos["tf_weapon_sentry_revenge"]["engineer"].BoneOffset={Vector(20,-5,5),Angle(-90,0,90)}//offset,weapon angle

weaponsinfos["tf_weapon_pistol"]={}
weaponsinfos["tf_weapon_pistol"]["engineer"]={}
weaponsinfos["tf_weapon_pistol"]["engineer"].Bone="bip_hip_R"
weaponsinfos["tf_weapon_pistol"]["engineer"].BoneOffset={Vector(6,2,0),Angle(0,-5,0)}//offset,weapon angle


weaponsinfos["tf_weapon_pda_engineer_build"]={}
weaponsinfos["tf_weapon_pda_engineer_build"]["engineer"]={}
weaponsinfos["tf_weapon_pda_engineer_build"]["engineer"].Bone="prp_legPouch"
weaponsinfos["tf_weapon_pda_engineer_build"]["engineer"].BoneOffset={Vector(5,0,1),Angle(-90,270,0)}//offset,weapon angle
weaponsinfos["tf_weapon_pda_engineer_build"]["engineer"].Scale=Vector(0.9,0.9,0.9)

//pyro

weaponsinfos["tf_weapon_flaregun"]={}
weaponsinfos["tf_weapon_flaregun"]["pyro"]={}
weaponsinfos["tf_weapon_flaregun"]["pyro"].Bone="bip_hip_L"
weaponsinfos["tf_weapon_flaregun"]["pyro"].BoneOffset={Vector(-6,0,4),Angle(0,5,-20)}//offset,weapon angle

weaponsinfos["tf_weapon_fireaxe"]={}
weaponsinfos["tf_weapon_fireaxe"]["pyro"]={}
weaponsinfos["tf_weapon_fireaxe"]["pyro"].Bone="bip_hip_R"
weaponsinfos["tf_weapon_fireaxe"]["pyro"].BoneOffset={Vector(6,0,0),Angle(0,0,-135)}//offset,weapon angle

weaponsinfos["tf_weapon_flamethrower"]={}
weaponsinfos["tf_weapon_flamethrower"]["pyro"]={}
weaponsinfos["tf_weapon_flamethrower"]["pyro"].Bone="bip_spine_1"
weaponsinfos["tf_weapon_flamethrower"]["pyro"].BoneOffset={Vector(-20,-11,8.5),Angle(90,130,90)}//offset,weapon angle

weaponsinfos["tf_weapon_shotgun_pyro"]={}
weaponsinfos["tf_weapon_shotgun_pyro"]["pyro"]={}
weaponsinfos["tf_weapon_shotgun_pyro"]["pyro"].Bone="bip_spine_0"
weaponsinfos["tf_weapon_shotgun_pyro"]["pyro"].BoneOffset={Vector(20,8,5),Angle(-90,0,90)}//offset,weapon angle

//scout
weaponsinfos["tf_weapon_pistol_scout"]={}
weaponsinfos["tf_weapon_pistol_scout"]["scout"]={}
weaponsinfos["tf_weapon_pistol_scout"]["scout"].Bone="bip_hip_L"
weaponsinfos["tf_weapon_pistol_scout"]["scout"].BoneOffset={Vector(-4,-2,0),Angle(20,0,-20)}//offset,weapon angle

weaponsinfos["tf_weapon_pistol"]["scout"]={}
weaponsinfos["tf_weapon_pistol"]["scout"].Bone="bip_hip_L"
weaponsinfos["tf_weapon_pistol"]["scout"].BoneOffset={Vector(-4,-2,0),Angle(20,0,-20)}//offset,weapon angle


weaponsinfos["tf_weapon_bat"]={}
weaponsinfos["tf_weapon_bat"]["scout"]={}
weaponsinfos["tf_weapon_bat"]["scout"].Bone="bip_packmiddle"
weaponsinfos["tf_weapon_bat"]["scout"].WeaponBone="weapon_bone"
weaponsinfos["tf_weapon_bat"]["scout"].BoneOffset={Vector(3,0,-1.5),Angle(300,0,0)}//offset,weapon angle

weaponsinfos["tf_weapon_bat_wood"]={}
weaponsinfos["tf_weapon_bat_wood"]["scout"]={}
weaponsinfos["tf_weapon_bat_wood"]["scout"].Bone="bip_packmiddle"
weaponsinfos["tf_weapon_bat_wood"]["scout"].BoneOffset={Vector(3,0,-1.5),Angle(300,0,0)}//offset,weapon angle

weaponsinfos["tf_weapon_bat_fish"]={}
weaponsinfos["tf_weapon_bat_fish"]["scout"]={}
weaponsinfos["tf_weapon_bat_fish"]["scout"].Bone="bip_packmiddle"
weaponsinfos["tf_weapon_bat_fish"]["scout"].BoneOffset={Vector(3,0,-1.5),Angle(300,0,0)}//offset,weapon angle

weaponsinfos["tf_weapon_handgun_scout"]={}
weaponsinfos["tf_weapon_handgun_scout"]["scout"]={}
weaponsinfos["tf_weapon_handgun_scout"]["scout"].Bone="bip_hip_R"
weaponsinfos["tf_weapon_handgun_scout"]["scout"].BoneOffset={Vector(0,-2,-4),Angle(90,0,0)}//offset,weapon angle

weaponsinfos["tf_weapon_scattergun"]={}
weaponsinfos["tf_weapon_scattergun"]["scout"]={}
weaponsinfos["tf_weapon_scattergun"]["scout"].Bone="bip_spine_2"
weaponsinfos["tf_weapon_scattergun"]["scout"].BoneOffset={Vector(-3,-7,2),Angle(0,-45,0)}//offset,weapon angle

//soldier
weaponsinfos["tf_weapon_shotgun_soldier"]={}
weaponsinfos["tf_weapon_shotgun_soldier"]["soldier"]={}
weaponsinfos["tf_weapon_shotgun_soldier"]["soldier"].Bone="bip_spine_1"
weaponsinfos["tf_weapon_shotgun_soldier"]["soldier"].BoneOffset={Vector(20,8,5),Angle(-90,0,90)}//offset,weapon angle

weaponsinfos["tf_weapon_rocketlauncher"]={}
weaponsinfos["tf_weapon_rocketlauncher"]["soldier"]={}
weaponsinfos["tf_weapon_rocketlauncher"]["soldier"].Bone="bip_spine_1"
weaponsinfos["tf_weapon_rocketlauncher"]["soldier"].BoneOffset={Vector(15,0,9),Angle(90,0,90)}//offset,weapon angle

weaponsinfos["tf_weapon_rocketlauncher_dh"]={}
weaponsinfos["tf_weapon_rocketlauncher_dh"]["soldier"]={}
weaponsinfos["tf_weapon_rocketlauncher_dh"]["soldier"].Bone="bip_spine_1"
weaponsinfos["tf_weapon_rocketlauncher_dh"]["soldier"].BoneOffset={Vector(15,0,9),Angle(90,0,90)}//offset,weapon angle

weaponsinfos["tf_weapon_shovel"]={}
weaponsinfos["tf_weapon_shovel"]["soldier"]={}
weaponsinfos["tf_weapon_shovel"]["soldier"].Bone="bip_hip_R"
weaponsinfos["tf_weapon_shovel"]["soldier"].BoneOffset={Vector(5,0,-5),Angle(0,0,-90)}//offset,weapon angle

//demoman

weaponsinfos["tf_weapon_bottle"]={}
weaponsinfos["tf_weapon_bottle"]["demoman"]={}
weaponsinfos["tf_weapon_bottle"]["demoman"].Bone="bip_hip_L"
weaponsinfos["tf_weapon_bottle"]["demoman"].BoneOffset={Vector(-5,0,0),Angle(0,180,40)}//offset,weapon angle

weaponsinfos["tf_weapon_grenadelauncher"]={}
weaponsinfos["tf_weapon_grenadelauncher"]["demoman"]={}
weaponsinfos["tf_weapon_grenadelauncher"]["demoman"].Bone="bip_spine_1"
weaponsinfos["tf_weapon_grenadelauncher"]["demoman"].BoneOffset={Vector(5,-7,9),Angle(90,0,45)}//offset,weapon angle

weaponsinfos["tf_weapon_grenadelauncher_test"]={}
weaponsinfos["tf_weapon_grenadelauncher_test"]["demoman"]={}
weaponsinfos["tf_weapon_grenadelauncher_test"]["demoman"].Bone="bip_spine_1"
weaponsinfos["tf_weapon_grenadelauncher_test"]["demoman"].BoneOffset={Vector(5,-7,9),Angle(90,0,45)}//offset,weapon angle

weaponsinfos["tf_weapon_pipebomblauncher"]={}
weaponsinfos["tf_weapon_pipebomblauncher"]["demoman"]={}
weaponsinfos["tf_weapon_pipebomblauncher"]["demoman"].Bone="bip_spine_1"
weaponsinfos["tf_weapon_pipebomblauncher"]["demoman"].BoneOffset={Vector(-15,-7,9),Angle(90,0,45)}//offset,weapon angle

weaponsinfos["tf_weapon_shovel"]["demoman"]={}
weaponsinfos["tf_weapon_shovel"]["demoman"].Bone="bip_hip_L"
weaponsinfos["tf_weapon_shovel"]["demoman"].BoneOffset={Vector(-5,0,0),Angle(0,180,130)}//offset,weapon angle

weaponsinfos["tf_weapon_stickbomb"]={}
weaponsinfos["tf_weapon_stickbomb"]["demoman"]={}
weaponsinfos["tf_weapon_stickbomb"]["demoman"].Bone="bip_hip_L"
weaponsinfos["tf_weapon_stickbomb"]["demoman"].BoneOffset={Vector(-5,0,0),Angle(0,180,130)}//offset,weapon angle


weaponsinfos["tf_weapon_sword"]={}
weaponsinfos["tf_weapon_sword"]["demoman"]={}
weaponsinfos["tf_weapon_sword"]["demoman"].Bone="bip_spine_1"
weaponsinfos["tf_weapon_sword"]["demoman"].BoneOffset={Vector(-5,-8,5),Angle(90,90,0)}//offset,weapon angle

//heavy
weaponsinfos["tf_weapon_shotgun_hwg"]={}
weaponsinfos["tf_weapon_shotgun_hwg"]["heavy"]={}
weaponsinfos["tf_weapon_shotgun_hwg"]["heavy"].Bone="bip_spine_1"
weaponsinfos["tf_weapon_shotgun_hwg"]["heavy"].BoneOffset={Vector(20,-8,5),Angle(-90,0,90)}//offset,weapon angle

weaponsinfos["tf_weapon_minigun"]={}
weaponsinfos["tf_weapon_minigun"]["heavy"]={}
weaponsinfos["tf_weapon_minigun"]["heavy"].Bone="bip_spine_2"
weaponsinfos["tf_weapon_minigun"]["heavy"].BoneOffset={Vector(14,-7,9),Angle(90,180,270)}//offset,weapon angle

weaponsinfos["tf_weapon_fists"]={}
weaponsinfos["tf_weapon_fists"]["heavy"]={}
weaponsinfos["tf_weapon_fists"]["heavy"].Bone="bip_hip_L"
weaponsinfos["tf_weapon_fists"]["heavy"].BoneOffset={Vector(0,5,-9),Angle(0,180,130)}//offset,weapon angle
weaponsinfos["tf_weapon_fists"]["heavy"].BBP=function(self)
	local bonename="vm_weapon_bone"
	local bm = self:GetBoneMatrix( self:LookupBone(bonename) )
	bm:Rotate( Angle(-50,0,0) ) -- Deflates the bone
	bm:Translate( Vector(0,0,-10) )
	self:SetBoneMatrix(self:LookupBone(bonename), bm )
	
	bonename="vm_weapon_bone_L"
	bm = self:GetBoneMatrix( self:LookupBone(bonename) )
	bm:Rotate( Angle(-50,0,0) ) -- Deflates the bone
	bm:Translate( Vector(0,0,10) )
	self:SetBoneMatrix(self:LookupBone(bonename), bm )
end

	


	
function LPGB(dotrace)
	if !dotrace then
	for i=0,LocalPlayer():GetBoneCount()-1 do
		print(LocalPlayer():GetBoneName(i))
	end
	else
	local entity=LocalPlayer():GetEyeTrace().Entity
	if !IsValid(entity) then return end
	for i=0,entity:GetBoneCount()-1 do
		print(entity:GetBoneName(i))
	end
	end
end

local function CalcOffset(pos,ang,off)
		return pos + ang:Right() * off.x + ang:Forward() * off.y + ang:Up() * off.z;
end
	
local function clhasweapon(pl,weaponclass)
	for i,v in pairs(pl:GetWeapons()) do
		if string.lower(v:GetClass())==string.lower(weaponclass) then return true end
	end
	
	return false;
end

local function clgetweapon(pl,weaponclass)
	for i,v in pairs(pl:GetWeapons()) do
		if string.lower(v:GetClass())==string.lower(weaponclass) then return v end
	end
	
	return nil;
end

local function playergettf2class(ply)
	return ply:GetPlayerClass()
end

local function IsTf2Class(ply)
	return LocalPlayer().IsHL2 && !LocalPlayer():IsHL2()
end

local function GetHolsteredWeaponTable(ply,indx)
	local class=IsTf2Class(ply) and playergettf2class(ply) or nil
	if !class then	return weaponsinfos[indx]
	else return (weaponsinfos[indx] && weaponsinfos[indx][class]) and weaponsinfos[indx][class] or nil
	end
end

local function thinkdamnit()
	if !holsteredgunsconvar:GetBool() then return end
	
	if NEXT_WEAPONS_UPDATE<CurTime() then 
		NEXT_WEAPONS_UPDATE=CurTime()+5
	else return end
	for _,pl in pairs(player.GetAll()) do
		if !IsValid(pl) then continue end
		
		if !pl.CL_CS_WEPS then
			pl.CL_CS_WEPS={}
		end
		
		if !pl:Alive() then pl.CL_CS_WEPS={} continue end
		pl.CL_CS_WEPS={} 

		
		for i,v in pairs(pl:GetWeapons())do
			if !IsValid(v) then continue; end
			
			if pl.CL_CS_WEPS[v:GetClass()] then continue end
			
			if !pl.CL_CS_WEPS[v:GetClass()] then
				local worldmodel=v.WorldModelOverride or v.WorldModel //attempt to pick the model from a swep
				local attachedwmodel=v.AttachedWorldModel;
				
				if GetHolsteredWeaponTable(pl,v:GetClass()) && GetHolsteredWeaponTable(pl,v:GetClass()).Model then //damnit,it's not a swep,then try to get it from our local table
					worldmodel=GetHolsteredWeaponTable(pl,v:GetClass()).Model
				end
				if !worldmodel || worldmodel=="" then continue end;	//allright,this weapon is not supposed to show up
				
				
				pl.CL_CS_WEPS[v:GetClass()]=ClientsideModel(worldmodel,RENDERGROUP_OPAQUE)
				pl.CL_CS_WEPS[v:GetClass()]:SetNoDraw(true)
				pl.CL_CS_WEPS[v:GetClass()]:SetSkin(v:GetSkin())
				pl.CL_CS_WEPS[v:GetClass()]:SetColor(v:GetColor())
				
				if GetHolsteredWeaponTable(pl,v:GetClass()) && GetHolsteredWeaponTable(pl,v:GetClass()).Scale then
					pl.CL_CS_WEPS[v:GetClass()]:SetModelScale(GetHolsteredWeaponTable(pl,v:GetClass()).Scale);
				end
				
				if GetHolsteredWeaponTable(pl,v:GetClass()) && GetHolsteredWeaponTable(pl,v:GetClass()).BBP then
					pl.CL_CS_WEPS[v:GetClass()].BuildBonePositions=GetHolsteredWeaponTable(pl,v:GetClass()).BBP;
				end
				
				if v.MaterialOverride || v:GetMaterial() then
					pl.CL_CS_WEPS[v:GetClass()]:SetMaterial(v.MaterialOverride || v:GetMaterial())
				end
				if worldmodel == "models/weapons/w_models/w_shotgun.mdl" then
					pl.CL_CS_WEPS[v:GetClass()]:SetMaterial("models/weapons/w_shotgun_tf/w_shotgun_tf")
				end
				
				pl.CL_CS_WEPS[v:GetClass()].WModelAttachment=v.WModelAttachment
				pl.CL_CS_WEPS[v:GetClass()].WorldModelVisible=v.WorldModelVisible
				
				
				if attachedwmodel then
					pl.CL_CS_WEPS[v:GetClass()].AttachedModel=ClientsideModel(attachedwmodel,RENDERGROUP_OPAQUE)
					pl.CL_CS_WEPS[v:GetClass()].AttachedModel:SetNoDraw(true)
					pl.CL_CS_WEPS[v:GetClass()].AttachedModel:SetSkin(v:GetSkin())
					pl.CL_CS_WEPS[v:GetClass()].AttachedModel:SetParent(pl.CL_CS_WEPS[v:GetClass()])
					pl.CL_CS_WEPS[v:GetClass()].AttachedModel:AddEffects(EF_BONEMERGE|EF_BONEMERGE_FASTCULL|EF_PARENT_ANIMATES)
				end
			end
		end
	end
end

local function playerdrawdamnit(pl,legs)
	if !holsteredgunsconvar:GetBool() then return end
	if !IsValid(pl) then return end
	if !pl.CL_CS_WEPS then return end
	for i,v in pairs(pl.CL_CS_WEPS) do

			
		if GetHolsteredWeaponTable(pl,i) && (pl:GetActiveWeapon()==NULL || pl:GetActiveWeapon():GetClass()~=i) && clhasweapon(pl,i) then
			if GetHolsteredWeaponTable(pl,i).Priority then
				local priority=GetHolsteredWeaponTable(pl,i).Priority
				local bol=GetHolsteredWeaponTable(pl,priority) && (pl:GetActiveWeapon()==NULL || pl:GetActiveWeapon():GetClass()!=priority) && clhasweapon(pl,priority)
				if bol then continue; end
			end
			
			local oldpl=pl;
			local wep=clgetweapon(oldpl,i)
			
			if legs && IsValid(legs) then
			pl=legs;
			end
			
			if legs && IsValid(legs) && (string.find(string.lower(GetHolsteredWeaponTable(oldpl,i).Bone),"spine") or string.find(string.lower(GetHolsteredWeaponTable(oldpl,i).Bone),"clavi") ) then
			pl=oldpl;
			continue;
			end
			
			local bone=pl:LookupBone(GetHolsteredWeaponTable(oldpl,i).Bone or "")
			if !bone then pl=oldpl;continue; end

			
			local matrix = pl:GetBoneMatrix(bone)
			if !matrix then pl=oldpl;continue; end
			local pos = matrix:GetTranslation()
			local ang = matrix:GetAngle()
			local pos=CalcOffset(pos,ang,GetHolsteredWeaponTable(oldpl,i).BoneOffset[1])
			if GetHolsteredWeaponTable(oldpl,i).Skin then v:SetSkin(GetHolsteredWeaponTable(oldpl,i).Skin) end
			
			v:SetRenderOrigin(pos)
			
			ang:RotateAroundAxis(ang:Forward(),GetHolsteredWeaponTable(oldpl,i).BoneOffset[2].p)
			ang:RotateAroundAxis(ang:Up(),GetHolsteredWeaponTable(oldpl,i).BoneOffset[2].y)
			ang:RotateAroundAxis(ang:Right(),GetHolsteredWeaponTable(oldpl,i).BoneOffset[2].r)
			
		    v:SetRenderAngles(ang)
			if v.WorldModelVisible==nil || (v.WorldModelVisible!=false) then
				v:DrawModel();
			end
			
			if IsValid(v.AttachedModel) then
				v.AttachedModel:DrawModel();
			end
			if v.WModelAttachment && multimodel then
				multimodel.Draw(v.WModelAttachment, wep, {origin=pos, angles=ang})
				multimodel.DoFrameAdvance(v.WModelAttachment, CurTime(),wep)
			end
			
			if GetHolsteredWeaponTable(oldpl,i).DrawFunction then
				GetHolsteredWeaponTable(oldpl,i).DrawFunction(v,oldpl)
			end
			pl=oldpl;
		end
	end
end

local function drawlegsdamnit(legs)
	playerdrawdamnit(LocalPlayer(),legs)
end

hook.Add("PostLegsDraw","HG_DrawOnLegs",drawlegsdamnit)
hook.Add("Think","HG_Think",thinkdamnit)
hook.Add("PostPlayerDraw","HG_Draw",playerdrawdamnit)