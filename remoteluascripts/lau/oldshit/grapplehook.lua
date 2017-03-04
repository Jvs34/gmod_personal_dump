if SERVER then
	AddCSLuaFile("shared.lua")
end

local notconventionalregistering=false
if not SWEP then
	SWEP={}
	notconventionalregistering=true
end

if CLIENT then


multimodelredux=multimodelredux or {}
multimodelredux.MODELS = multimodelredux.MODELS or {}
local NUM_MODELS = 0
local TR_STRING_TO_ID = {}
local TR_ID_TO_STRING = {}

function multimodelredux.Register(name, tbl)
	if CLIENT then
		multimodelredux.MODELS[name] = tbl
		multimodelredux.Precache(tbl)
	end
	NUM_MODELS = NUM_MODELS + 1
	TR_STRING_TO_ID[name] = NUM_MODELS
	TR_ID_TO_STRING[NUM_MODELS] = name
end

function multimodelredux.GetModelID(name)
	return TR_STRING_TO_ID[name]
end

function multimodelredux.GetModelFromID(id)
	return TR_ID_TO_STRING[id]
end

function multimodelredux.DeepCopy(tbl)
	local t = {}
	for k,v in pairs(tbl) do
		if type(v)=="table" then
			t[k] = multimodelredux.DeepCopy(v)
		elseif type(v)=="Vector" then
			t[k] = Vector(v.x,v.y,v.z)
		elseif type(v)=="Angle" then
			t[k] = Angle(v.p, v.y, v.r)
		elseif type(v)=="Color" then
			t[k] = Color(v.r, v.g, v.b, v.a)
		else
			t[k] =  v
		end
	end
	return t
end

function multimodelredux.Copy(t)
	return multimodelredux.DeepCopy(t)
end

function multimodelredux.GetMultiModel(name)
	return multimodelredux.MODELS[name]
end

function multimodelredux.CreateInstance(name)
	if multimodelredux.MODELS[name] then
		return multimodelredux.DeepCopy(multimodelredux.MODELS[name])
	end
end

----------------------------------------------------------------------------------

function multimodelredux.PrecacheChild(tbl)
	if type(tbl) ~= "table" then return end
	
	if tbl.model then
		util.PrecacheModel(tbl.model)
	end
	for _,v in pairs(tbl.children or {}) do
		multimodelredux.PrecacheChild(v)
	end
end

function multimodelredux.Precache(tbl)
	for _,v in pairs(tbl) do
		multimodelredux.PrecacheChild(v)
	end
end

----------------------------------------------------------------------------------

function multimodelredux.DoFrameAdvanceChild(tbl, time, ent)
	if type(tbl) ~= "table" then return end
	
	if tbl.Think then tbl:Think(time, ent) end
	for _,v in pairs(tbl.children or {}) do
		multimodelredux.DoFrameAdvanceChild(v, time, ent)
	end
end

function multimodelredux.DoFrameAdvance(tbl, time, ent)
	for _,v in pairs(tbl) do
		multimodelredux.DoFrameAdvanceChild(v, time, ent)
	end
end

----------------------------------------------------------------------------------

RENDERER = ClientsideModel("models/props_junk/watermelon01.mdl", RENDERGROUP_OPAQUE)
RENDERER:SetNoDraw(true)

function multimodelredux.DrawChild(tbl, ent, param)
	if type(tbl) ~= "table" then return end
	
	param = param or {}
	local m, scale
	
	if tbl.transform or tbl.bone then
		local usesBoneMatrix
		
		if tbl.bone then
			if IsValid(ent) then
				local b = ent:LookupBone(tbl.bone)
				if b and b >= 0 then
					m = ent:GetBoneMatrix(b)
					if m then
						usesBoneMatrix = true
					end
				end
			end
		end
		
		if not m then
			m = Matrix()
		end
		
		scale = ent.CurrentScale
		
		if tbl.transform then
			m:Translate(tbl.transform[1] * ent.CurrentScale)
			m:Rotate(tbl.transform[2])
			--m:Scale(tbl.transform[3])
			
			scale = Vector(
				scale.x * tbl.transform[3].x,
				scale.y * tbl.transform[3].y,
				scale.z * tbl.transform[3].z
			)
		end
		
		if not usesBoneMatrix then
			m = ent.CurrentMatrix * m
		end
	else
		m = ent.CurrentMatrix
		scale = ent.CurrentScale
	end
	
	if tbl.visible == false then
		-- nothing
	elseif tbl.model and tbl.model~="" then
		RENDERER:SetModel(tbl.model)
		RENDERER:SetPos(m:GetTranslation())
		RENDERER:SetAngles(m:GetAngles())
		RENDERER:SetModelScale(scale)
		
		local min, max = RENDERER:GetRenderBounds()
		
		if not ent.RenderBounds[1] then
			ent.RenderBounds[1] = min
		else
			OrderVectors(ent.RenderBounds[1], min)
		end
		
		if not ent.RenderBounds[2] then
			ent.RenderBounds[2] = max
		else
			OrderVectors(max, ent.RenderBounds[2])
		end
		
		RENDERER:SetSkin(tbl.skin or 0)
		
		local s = (ent.GetSkin and ent:GetSkin()) or 0
		local r0, g0, b0, a0
		local col0=color_white
		if ent.ParentEntity and ent.ParentEntity.GetColor then
			col0 = ent.ParentEntity:GetColor()
		--[[elseif param.color then
			r0, g0, b0, a0 = param.color.r, param.color.g, param.color.b, param.color.a]]
		end
		
		local col
		if tbl.skins and tbl.skins[s] and tbl.skins[s].color then
			col = tbl.skins[s].color
		else
			col = tbl.color
		end
		
		if not param.norenderoverride then
			if col then
				render.SetColorModulation(col0.r * col.r/65025, col0.g * col.g/65025, col0.b * col.b/65025)
				render.SetBlend(col0.a * col.a/65025)
			--[[else
				render.SetColorModulation(r0 /255, g0 /255, b0 /255)
				render.SetBlend(a0 /255)]]
			end
			if tbl.material then
				if type(tbl.material)=="string" then tbl.material = Material(tbl.material) end
				render.MaterialOverride( tbl.material )
			end
		end
		local clipping=nil
		if tbl.clipplanes then
			clipping=render.EnableClipping(true)
			for _,v in ipairs(tbl.clipplanes) do
				local pos, ang = LocalToWorld(v[1], v[2]:Angle(), RENDERER:GetPos(), RENDERER:GetAngles())
				local dir = ang:Forward()
				
				render.PushCustomClipPlane(dir, dir:Dot(pos))
			end
		end
		
		if tbl.reversecull then
			render.CullMode(MATERIAL_CULLMODE_CW)
		end
		
		if tbl.refractupdate then
			render.UpdateRefractTexture()
		end
		
		RENDERER:DrawModel()
		
		if tbl.reversecull then
			render.CullMode(MATERIAL_CULLMODE_CCW)
		end
		
		if tbl.clipplanes then
			for _,v in ipairs(tbl.clipplanes) do
				render.PopCustomClipPlane()
			end
			render.EnableClipping((clipping~=nil) and clipping or false)
		end
		
		if not param.norenderoverride then
			render.MaterialOverride(nil)
			render.SetBlend(1)
			render.SetColorModulation(1,1,1,1)
		end
	elseif tbl.sprite and not param.nosprites and not param.modelonly then
		if type(tbl.sprite)=="string" then tbl.sprite = Material(tbl.sprite) end
		render.SetMaterial(tbl.sprite)
		render.DrawSprite(m:GetTranslation(), scale.x, scale.y, tbl.color or Color(255,255,255,255))
	elseif tbl.effect and not param.noeffects and not param.modelonly  then
		if not tbl.NextEffect or (tbl.delay>=0 and CurTime()>tbl.NextEffect) then
			local data = EffectData()
				data:SetOrigin(m:GetTranslation())
				data:SetAngle(m:GetAngles())
				data:SetNormal(m:GetAngles():Up())
				data:SetMagnitude(1)
			util.Effect(tbl.effect, data, true, true)
			tbl.NextEffect = CurTime() + tbl.delay
		end
	end
	if tbl.custom and not param.nocustom and not param.modelonly  then
		tbl.custom(tbl, m:GetTranslation(), m:GetAngles(), scale, ent)
	end
	
	if tbl.children and #tbl.children>0 then
		table.insert(ent.MatrixStack, {ent.CurrentMatrix, ent.CurrentScale})
		ent.CurrentMatrix = m
		ent.CurrentScale = scale
		
		for _,v in pairs(tbl.children) do
			multimodelredux.DrawChild(v, ent, param)
		end
		
		local t = table.remove(ent.MatrixStack)
		ent.CurrentMatrix = t[1]
		ent.CurrentScale = t[2]
	end
end

function multimodelredux.Draw(tbl, ent, param)
	param = param or {}
	if tbl then
		if tbl.attach_to_bones then
			-- todo
		end
		
		if not ent then ent = {} end
		
		ent.MatrixStack = {}
		
		ent.CurrentMatrix = nil
		ent.RenderBounds = {}
		ent.ParentEntity = ent
		
		local parent, parentbone
		
		if param.parent_ent then
			parent = param.parent_ent
			if IsValid(parent) then
				parentbone = parent:LookupBone(param.parent_bonename)
			end
		elseif ent.dt then
			parent = ent.dt.ParentEntity
			parentbone = ent.dt.ParentBone
		end
		
		if IsValid(parent) then
			-- Stuff attached to players will get transmitted to the ragdoll when they die
			if parent:IsPlayer() and not parent:Alive() then
				if IsValid(parent:GetRagdollEntity()) then
					parent = parent:GetRagdollEntity()
				else
					return
				end
			end
			
			if parentbone and parentbone>=0 then
				ent.CurrentMatrix = parent:GetBoneMatrix(parentbone)
				ent.CurrentScale = Vector(1,1,1)
			end
			ent.ParentEntity = parent
		end
		
		if not ent.CurrentMatrix then
			ent.CurrentMatrix = Matrix()
			ent.CurrentMatrix:Translate(param.origin or ent:GetPos())
			if not ent.NoRotation then
				ent.CurrentMatrix:Rotate(param.angles or ent:GetAngles())
			end
			ent.CurrentScale = Vector(1,1,1)
		end
		
		for _,v in pairs(tbl) do
			multimodelredux.DrawChild(v, ent, param)
		end
		
	elseif IsEntity(ent) then
		ent:DrawModel()
	end
end

end

if CLIENT then
language.Add("weapon_grapplehook","Grapple Hook")
multimodelredux.Register("GrappleHook", {
	{
		transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
		children = {
			--[[{
				model = "models/weapons/w_smg1.mdl",
				transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
				color=Color(255,255,255,120),
			},]]
			{
				model = "models/Items/item_item_crate_chunk01.mdl",
				transform = {Vector(4.5,1.35,-2), Angle(180,0,-90), Vector(1,0.8,4)/4.5},
			},
			{
				model = "models/Items/item_item_crate_chunk02.mdl",
				transform = {Vector(-6.5,1,-3), Angle(193,0,-90), Vector(1.7,0.8,4)/4.5},
			},
			{
				model = "models/props_c17/playground_teetertoter_stan.mdl",
				transform = {Vector(-5.5,1.1,-1.5), Angle(110,0,0), Vector(1,1.5,1.3)/12},
			},
			{
				model = "models/props_wasteland/wood_fence02a_board09a.mdl",
				transform = {Vector(-1,5,0), Angle(0,90,-92), Vector(1,1,0.70)/6},
			},
			{
				model = "models/props_junk/propane_tank001a.mdl",
				transform = {Vector(0,1.4,1.1), Angle(0,-90,-88), Vector(1,1,1)/4},
				custom = function(self,pos,ang,scl,ent)
						if IsValid(ent) then
							if ent.grapplecoords then
								ent.grapplecoords.vec=pos
								ent.grapplecoords.ang=ang
								
							end
						end

				end,
			},
			{
				model = "models/props_c17/pulleywheels_small01.mdl",
				transform = {Vector(-4,1.4,3.5), Angle(0,90,0), Vector(1,1,1)/6},
				custom = function(self,pos,ang,scl,ent)
						if IsValid(ent) and ent.dt then
							if ent.bigpulleycoords then
								ent.bigpulleycoords.vec=pos
								ent.bigpulleycoords.ang=ang
							else
								ent.bigpulleycoords={}
							end
							if ent.dt.IsAttached then 

								if ent.dt.AttachTime>CurTime() then
									self.transform[2].r=2000*CurTime()
								end
								
								if ent.dt.AttachTime<=CurTime() then
									self.transform[2].r=math.abs(ent:GetOwner():GetVelocity():Length())*-1*CurTime()
								end
							end
						end
				end,
			},
			{
				model = "models/props_junk/wood_crate001a_Chunk05.mdl",
				transform = {Vector(-4,0.2,1.8), Angle(-90,90,0), Vector(0.6,1,1)/4},
			},			
			{
				model = "models/props_junk/wood_crate001a_Chunk05.mdl",
				transform = {Vector(-4,2.5,1.8), Angle(-90,90,0), Vector(0.6,1,1)/4},
			},
			{
				model = "models/props_c17/TrapPropeller_Engine.mdl",
				transform = {Vector(-6.5,1.4,1), Angle(-90,180,0), Vector(1,1,1)/8},
			},
			{
				model = "models/props_c17/pulleywheels_small01.mdl",
				transform = {Vector(3,1.4,3.3), Angle(0,90,0), Vector(1.5,1,1)/12},
				custom = function(self,pos,ang,scl,ent)
						if IsValid(ent) and ent.dt then
							if ent.smallpulleycoords then
								ent.smallpulleycoords.vec=pos
								ent.smallpulleycoords.ang=ang
							else
								ent.smallpulleycoords={}
							end
						end
				end,
			},
			{
				model = "models/props_junk/wood_crate001a_Chunk05.mdl",
				transform = {Vector(3,0.2,1.8), Angle(-90,90,0), Vector(0.6,1,1)/4},
			},			
			{
				model = "models/props_junk/wood_crate001a_Chunk05.mdl",
				transform = {Vector(3,2.5,1.8), Angle(-90,90,0), Vector(0.6,1,1)/4},
			},
		},

	}
})

multimodelredux.Register("Hook", {
	{
		transform = {Vector(0,0,0), Angle(0,90,90), Vector(1,1,1)/1.5},
		children = {
				{
					model = "models/props_lab/jar01b.mdl",
					transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,0.1)/2},

				},
				{
					model = "models/Gibs/manhack_gib05.mdl",
					transform = {Vector(0,2.3,1),Angle(-45,90,90), Vector(1,1,5)/3},

				},
				{
					model = "models/Gibs/manhack_gib05.mdl",
					transform = {Vector(0,-2.3,1),Angle(-45,-90,90), Vector(1,1,5)/3},

				},
				{
					model = "models/Gibs/manhack_gib05.mdl",
					transform = {Vector(-2.3,0,1),Angle(-45,180,90), Vector(1,1,5)/3},

				},
				{
					model = "models/Gibs/manhack_gib05.mdl",
					transform = {Vector(2.3,0,1),Angle(-45,0,90), Vector(1,1,5)/3},

				},
		}

	}
})


multimodelredux.Register("nade-can", {
	{
		transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
		children = {
				{
					model = "models/weapons/w_shotgun.mdl",
					transform = {Vector(0,0,0), Angle(5,0,-8), Vector(1,1,1)},

				},
				{
					model = "models/props_pipes/concrete_pipe001a.mdl",
					transform = {Vector(0,0,0), Angle(0,0,0), Vector(0.10,0.05,0.05)},

				},
				--"
		}

	}
})

end

SWEP.Base="weapon_base"
SWEP.AutoSwitchTo= true
SWEP.AutoSwitchFrom= true
SWEP.PrintName= "Grapple Hook"
SWEP.Author= "Jvs"
SWEP.ViewModelFOV= 54
SWEP.RenderGroup = RENDERGROUP_TRANSLUCENT

SWEP.Category                = "Jvs"
SWEP.Slot                    = 0
SWEP.SlotPos                = 5
SWEP.Weight                    = 5
SWEP.Spawnable                 = false
SWEP.AdminSpawnable          = true

SWEP.ViewModel            = "models/weapons/v_smg1.mdl"
SWEP.WorldModel            = "models/weapons/w_smg1.mdl" 
SWEP.Primary={}
SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1    
SWEP.Primary.Ammo             = "none"
SWEP.Primary.Automatic        = true

SWEP.Secondary={}
SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Ammo         = false
SWEP.Secondary.Automatic     = false

SWEP.IsGrappleHook=true
SWEP.Range=10000

function SWEP:Initialize()
	self:StupidSPFix("Initialize")
	self:SetWeaponHoldType("smg")
	if(CLIENT)then
		language.Add(self:GetClass(),"Grapple Hook")
    end
	self.LaunchSound = CreateSound( self, "TripwireGrenade.ShootRope" )
	self.ReelSound = CreateSound( self, "vehicles/digger_grinder_loop1.wav" )
end

function SWEP:SetupDataTables()
	self:DTVar( "Bool" ,0, "IsAttached")	--bool: utility boolean to see if we're really attached to the world, not really needed but we can't send nils trough dt vars so
	self:DTVar( "Vector" ,0, "AttachedTo")	--vector: vector of where the player is attached to
	self:DTVar( "Float" ,0, "AttachTime")	--float: time>CurTime(), once it's equal or smaller than CurTime we'll pull the player torwards AttachedTo
	self:DTVar( "Float" ,1, "NextGrapple")	--float: it's basically a primaryattack time
	self:DTVar( "Float" ,2, "AttachStart")	--float: time when you shot the hook
	self:DTVar( "Bool" ,1, "AttachSoundPlayed")
	self:DTVar( "Vector" ,2, "GrappleNormal")
	self:DTVar( "Bool" ,2, "GracefullyLanding")
	self:DTVar( "Float" ,3, "NextObstructionCheck")
	self:DTVar( "Bool" ,3, "GrappleMode")
	self.dt.IsAttached=false
	self.dt.AttachedTo=Vector(0,0,0)
	self.dt.AttachTime=CurTime()
	self.dt.AttachStart=CurTime()
	self.dt.NextGrapple=CurTime()
	self.dt.AttachSoundPlayed=false
	self.dt.GrappleNormal=Vector(0,0,0)
	self.dt.GracefullyLanding=false
	self.dt.NextObstructionCheck=CurTime()
	self.dt.GrappleMode=false
end

if CLIENT then

	function SWEP:GetViewModelPosition(pos,ang)

	end
	
	function SWEP:PreDrawViewModel()
		render.SetBlend(0)
	end
	
	function SWEP:CreateHands()
		if not IsValid(self.Hands) then
			self.Hands=ClientsideModel("models/weapons/v_hands.mdl")
			self.Hands:SetNoDraw(true)
			self.Hands.Parent=self.Owner:GetViewModel()
		end
		if IsValid(self.Hands) and self.Hands:GetParent()==NULL and IsValid(self.Hands.Parent) then
			self.Hands:SetParent(self.Hands.Parent)
			self.Hands:AddEffects(EF_BONEMERGE)
		end
	end
	SWEP.CableMat=Material("cable/cable2")
	--SWEP.CableMat=Material("cable/rope")
	function SWEP:ViewModelDrawn()
		render.SetBlend(1)
		self:DrawGrappleHook(true)
	end
	
	hook.Add("PreDrawViewModel", "DRPPreDrawViewModel", function(vm, pl, weapon)
		if IsValid(weapon) and weapon.PreDrawViewModel then
			weapon:PreDrawViewModel()
		end
	end)
	
	function SWEP:DrawWorldModel()
		self:DrawGrappleHook(false)
	end
	
	function SWEP:DrawWorldModelTranslucent()
		self:DrawGrappleHook(false)
	end
	
	function SWEP:CreateMultiModels()
		self.MMHook=multimodelredux.CreateInstance("Hook")
		self.MMGrappleHook=multimodelredux.CreateInstance("GrappleHook")
		self.MMs=true
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
	
	SWEP.ViewModelOffsets={"ValveBiped.handle",Vector(-1.5,0.4,-4),Angle(-90,270,0)}
	SWEP.WorldModelOffsets={"ValveBiped.Bip01_R_Hand",Vector(9,0,-5),Angle(12,0,180)}
	SWEP.localgpos=Vector(0,0,5)
	SWEP.localgang=Angle(-90,0,0)
	function SWEP:DrawGrappleHook(isvm)
		if not IsValid(self.Owner) or (isvm and not IsValid(self.Owner:GetViewModel())) then return end
		if not self.MMs then
			self:CreateMultiModels()
		end
		
		if IsValid(self.Hands) and isvm then
			self.Hands:DrawModel()
		end
		
		local tab=(isvm) and self.ViewModelOffsets or self.WorldModelOffsets
		
		local ent=(isvm) and self.Owner:GetViewModel() or self.Owner
		local matrix,pos,ang
		matrix = ent:GetBoneMatrix(ent:LookupBone(tab[1] or "ValveBiped.Bip01_Spine2"))
		if !matrix then return end
		
		pos = matrix:GetTranslation()
		--if not isvm then pos=vector_origin end
		if !pos then return end
		ang = matrix:GetAngles()
		if !ang then return end
		if not self.grapplecoords then
			self.grapplecoords={}
			self.grapplecoords.vec=self:GetEyeOffset()
			self.grapplecoords.ang=Angle(0,0,0)
		end
		pos,ang=LocalToWorld(tab[2] or Vector(0,0,0),tab[3] or Angle(0,0,0),pos,ang)
		multimodelredux.DoFrameAdvance(self.MMGrappleHook, CurTime(), self)
		multimodelredux.Draw(self.MMGrappleHook,self,{origin=pos,angles=ang})
		if self.grapplecoords then
			self.grapplecoords.vec,self.grapplecoords.ang=LocalToWorld(self.localgpos,self.localgang,self.grapplecoords.vec,self.grapplecoords.ang)
		end
		local grapplepos
		local grappleang
		if self.dt.IsAttached then
			if self.dt.AttachTime>CurTime() then
				self.GrapplePos=self.GrapplePos or self.grapplecoords.vec
				local timefrac=math.TimeFraction(self.dt.AttachStart, self.dt.AttachTime, CurTime() )
				self.GrapplePos=self:LerpVector(timefrac,self.grapplecoords.vec ,self.dt.AttachedTo,self.GrapplePos)
			end

			local pos1=self.GrapplePos
			if self.dt.AttachTime<CurTime() then
				pos1=self.dt.AttachedTo
			end
			local eyepos=self.grapplecoords.vec
			grappleang=self.dt.GrappleNormal:Angle()
			grapplepos=(isvm) and self:FormatViewModelAttachment(pos1,EyePos(),EyeAngles(),self.ViewModelFOV,LocalPlayer():GetFOV() or 75) or pos1
		end
		if self.grapplecoords and not grapplepos or not grappleang then
			grapplepos=self.grapplecoords.vec
			grappleang=self.grapplecoords.ang
		end
		render.SetMaterial(self.CableMat)
		local smallpulleypos=Vector(0,0,0)
		local an
		local bigpulleypos=Vector(0,0,0)
		if self.smallpulleycoords and self.smallpulleycoords.vec then
			smallpulleypos,an=LocalToWorld(Vector(0,0,-0.5),Angle(0,0,0),self.smallpulleycoords.vec,self.smallpulleycoords.ang)
		end
		if self.bigpulleycoords and self.bigpulleycoords.vec then
			bigpulleypos,an=LocalToWorld(Vector(0,0,1.5),Angle(0,0,0),self.bigpulleycoords.vec,self.bigpulleycoords.ang)
		end
		if smallpulleypos and bigpulleypos then
			render.StartBeam( 3 )
				render.AddBeam(bigpulleypos,0.5,1,Color(255,255,255,255));
				render.AddBeam(smallpulleypos,0.5,2,Color(255,255,255,255));
				render.AddBeam(grapplepos,0.5,3,Color(255,255,255,255));
			render.EndBeam()
		end
		--render.DrawBeam(smallpulleypos,grapplepos or Vector(0,0,0),0.5,m1,m2,nil)
		multimodelredux.DoFrameAdvance(self.MMHook, CurTime(), self)
		multimodelredux.Draw(self.MMHook,self,{origin=grapplepos or Vector(0,0,0),angles=grappleang or Angle()})
		
		if not self.agnagna then
			self.agnagna=multimodelredux.CreateInstance("nade-can")
		end
		multimodelredux.Draw(self.agnagna,self,{origin=Vector(0,0,0),angles=Angle()})
	end
	
	function SWEP:FireAnimationEvent(pos, ang, event, options)
		return true
	end

end

function SWEP:StupidSPFix(FunctName)
	if SERVER and game.SinglePlayer() then
		self:CallOnClient(FunctName,"")
	end
end

function SWEP:PrimaryAttack()
	self:StupidSPFix("PrimaryAttack")
	if self.dt.NextGrapple>=CurTime() or self.dt.IsAttached then return end
	--we check if NextGrapple<CurTime()

	
	--do a trace, make it only hit the world, if it didn't, do nothing
	self.Owner:LagCompensation(true)
	local tr=self:DoGrappleTrace()
	self.Owner:LagCompensation(false)
	if tr.HitWorld and not tr.HitSky then
		local len=(self.Owner:EyePos():Distance(self.dt.AttachedTo))/10000
		local timetoreach=Lerp(tr.Fraction,0.1,2.5)
		
		self.dt.AttachedTo=tr.HitPos
		self.dt.AttachTime=CurTime()+timetoreach
		self.dt.AttachStart=CurTime()
		--if it did, then set AttachedTo to the hitpos, calculate the delay from the distance between eyepos and hitpos and add it with CurTime() on AttachTime
		self.dt.IsAttached=true
		self.LaunchSound:Play()
		self.LaunchSound:ChangeVolume(4)
		self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
		self:EmitSound("ambient/machines/catapult_throw.wav")
		self.Owner:DoAttackEvent()
		self.dt.GrappleNormal=self:GetDirection()
		
	end
	self.dt.NextGrapple=CurTime()+0.3
	
end

function SWEP:Holster()

	self:Detach()

	return true
end

function SWEP:LerpVector(fraction,startpos,endpos,result)
	result.x=Lerp(fraction,startpos.x,endpos.x)
	result.y=Lerp(fraction,startpos.y,endpos.y)
	result.z=Lerp(fraction,startpos.z,endpos.z)
	return result
end

function SWEP:SecondaryAttack()
	self:StupidSPFix("SecondaryAttack")
	if self.dt.NextGrapple>CurTime() or not self.dt.IsAttached then return end
	--if we are attached to something and NextGrapple<CurTime() then we detach
	self:Detach()
end

function SWEP:Reload()
	if self.dt.NextGrapple>CurTime() or self.dt.IsAttached then return end
	self.dt.GrappleMode=not self.dt.GrappleMode
	self.dt.NextGrapple=CurTime()+0.8
	self:EmitSound("Weapon_SMG1.Special2")
end

function SWEP:Think()
	--if IsAttached is true and AttachTime is bigger than CurTime() then
	--we get the time fraction with the timefraction function, between curtime and attachtime
	--we use it to lerpvector(eyepos,attachedto)
	if CLIENT then
		self:CreateHands()
	end
	if self.dt.IsAttached then 

		if self.dt.AttachTime<=CurTime() then
			if not self.dt.AttachSoundPlayed then
				self:EmitSound( "NPC_CombineMine.CloseHooks")
				self:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
				self.Owner:DoAttackEvent()
				self.dt.AttachSoundPlayed=true
			end
			self.ReelSound:Play()
			self.ReelSound:ChangePitch(200)
			self.ReelSound:ChangeVolume(0.3)
			self.LaunchSound:Stop()
			if self:ShouldStopPulling() then
				self:Detach(true)
			end
		end

	else
		self.LaunchSound:Stop()
		self.ReelSound:Stop()
	end
end

function SWEP:FormatViewModelAttachment(pos, eyepos, eyeang, fovsrc, fovdst)
	fovsrc=(fovsrc) and fovsrc or self.ViewModelFOV
	fovdst=(fovdst) and fovdst or LocalPlayer():GetFOV()
	local srcx = math.tan(math.rad(fovsrc/2))
	local dstx = math.tan(math.rad(fovdst/2))
	
	local factor = srcx / dstx
	
	local viewForward, viewRight, viewUp = eyeang:Forward(), eyeang:Right(), eyeang:Up()
	local tmp = pos - eyepos
	
	local transformed = Vector(viewRight:Dot(tmp), viewUp:Dot(tmp), viewForward:Dot(tmp))
	
	if dstx == 0 then
		transformed.x = 0
		transformed.y = 0
	else
		transformed.x = transformed.x * factor
		transformed.y = transformed.y * factor
	end
	
	local out = viewRight * transformed.x + viewUp * transformed.y + viewForward * transformed.z
	out:Add(eyepos)
	
	return out
end

function SWEP:Detach(bool)
	if bool==nil then bool=false end
	--we reset every variable here
	self.dt.IsAttached=false
	self.dt.AttachTime=CurTime()
	self.dt.AttachStart=CurTime()
	self.LaunchSound:Stop()
	self.ReelSound:Stop()
	self.dt.AttachSoundPlayed=false
	--when the boolean's true it means that we detached gracefully by touching the hook, and thus we want a faster refire
	self.dt.NextGrapple=CurTime()+(bool and 0.5 or 1)
	self.dt.GracefullyLanding=bool
end

function SWEP:DoGrappleTrace(endpos)
	local tr={}
	tr.filter=self.Owner
	tr.mask=MASK_SOLID_BRUSHONLY
	tr.start=self.Owner:EyePos()
	tr.endpos=endpos or (self.Owner:EyePos()+self.Owner:GetAimVector()*self.Range)
	tr.mins=Vector(4,4,4)*-1
	tr.maxs=Vector(4,4,4)
	return util.TraceHull(tr)
end

function SWEP:GracefullyLand()
	return self.dt.GracefullyLanding
end

function SWEP:DisableGracefullyLand()
	self.dt.GracefullyLanding=false
end
SWEP.EyeOffsets={Vector(25,-7,-5),Angle(0,0,0)}
function SWEP:GetEyeOffset()
	local pos=self.Owner:EyePos()
	local ang=self.Owner:EyeAngles()
	pos,ang=LocalToWorld(self.EyeOffsets[1],self.EyeOffsets[2],pos,ang)
	return pos
end

function SWEP:CanPull()
	return self.dt.IsAttached and self.dt.AttachTime<CurTime() and not self:ShouldStopPulling()
end

function SWEP:ShouldStopPulling()
	if self.dt.NextObstructionCheck<CurTime() then
		local tr=self:DoGrappleTrace(self.dt.AttachedTo)
		if tr.HitPos:Distance(self.dt.AttachedTo)>50 then
			return true
		end
		self.dt.NextObstructionCheck=CurTime()+0.3
	end
	
	return (self.Owner:NearestPoint(self.dt.AttachedTo)):Distance(self.dt.AttachedTo)<=45
end

function SWEP:GetDirection()
	return (self.dt.AttachedTo - self.Owner:EyePos()):GetNormalized()
end


hook.Add("Move","grapplehookmove",function(ply,data)
	local wep=ply:GetActiveWeapon()

	if IsValid(wep) and wep.IsGrappleHook then
		if wep:CanPull() then
			ply:SetGroundEntity(NULL)	--this prevents the player from actually going up steps
			data:SetForwardSpeed(0)
			data:SetSideSpeed(0)
			data:SetUpSpeed(0)
			if not wep.dt.GrappleMode then
				data:SetVelocity(wep:GetDirection()*1400)
			else
				--sorry, go suck a dick
				data:SetVelocity(data:GetVelocity()+wep:GetDirection()*35)
			end
			return
		elseif wep:GracefullyLand() then
			wep:DisableGracefullyLand()
			local vel=data:GetVelocity()
			vel.z=(vel.z<0) and 0 or vel.z
			data:SetVelocity(vel)
			return
		end
	end
end)


if notconventionalregistering then
	weapons.Register(SWEP,"weapon_grapplehook",true)
	SWEP=nil
end