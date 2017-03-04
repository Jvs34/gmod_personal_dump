AddCSLuaFile()

local VER = 2.6
if MODULE_MULTIMODEL_VERSION and MODULE_MULTIMODEL_VERSION >= VER then
	return
end
MODULE_MULTIMODEL_VERSION = VER

module("multimodel", package.seeall)

MODELS = {}
NUM_MODELS = 0
TR_STRING_TO_ID = {}
TR_ID_TO_STRING = {}

OUTPUT_TARGET = nil

function Register(name, tbl)
	if CLIENT then
		MODELS[name] = tbl
		Precache(tbl)
	end
	NUM_MODELS = NUM_MODELS + 1
	TR_STRING_TO_ID[name] = NUM_MODELS
	TR_ID_TO_STRING[NUM_MODELS] = name
end

function GetModelID(name)
	return TR_STRING_TO_ID[name]
end

function GetModelFromID(id)
	return TR_ID_TO_STRING[id]
end

if CLIENT then

local function DeepCopy(tbl)
	local t = {}
	for k,v in pairs(tbl) do
		if type(v)=="table" then
			t[k] = DeepCopy(v)
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

function Copy(t)
	return DeepCopy(t)
end

function GetMultiModel(name)
	return MODELS[name]
end

function CreateInstance(name)
	if MODELS[name] then
		return DeepCopy(MODELS[name])
	end
end

-- When rendering a multimodel, nodes with an outputname set will write their position and angle to the output table
-- This is useful for attaching effects to a multimodel after rendering it
function SetOutputTarget(tbl)
	if not tbl then
		OUTPUT_TARGET = nil
	elseif type(tbl) == "table" then
		OUTPUT_TARGET = tbl
	end
end

----------------------------------------------------------------------------------

local function PrecacheChild(tbl)
	if type(tbl) ~= "table" then return end
	
	if tbl.model then
		util.PrecacheModel(tbl.model)
	end
	for _,v in pairs(tbl.children or {}) do
		PrecacheChild(v)
	end
end

function Precache(tbl)
	for _,v in pairs(tbl) do
		PrecacheChild(v)
	end
end

----------------------------------------------------------------------------------

local function DoFrameAdvanceChild(tbl, time, ent)
	if type(tbl) ~= "table" then return end
	
	if tbl.Think then tbl:Think(time, ent) end
	for _,v in pairs(tbl.children or {}) do
		DoFrameAdvanceChild(v, time, ent)
	end
end

function DoFrameAdvance(tbl, time, ent)
	for _,v in pairs(tbl) do
		DoFrameAdvanceChild(v, time, ent)
	end
end

----------------------------------------------------------------------------------

RENDERER = ClientsideModel("models/props_junk/watermelon01.mdl", RENDERGROUP_OPAQUE)
RENDERER:SetNoDraw(true)
RENDERER:SetIK(false)

local function DrawChild(tbl, ent, param)
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
	
	if tbl.outputname and OUTPUT_TARGET then
		if not OUTPUT_TARGET[tbl.outputname] then OUTPUT_TARGET[tbl.outputname] = {} end
		local tmp = OUTPUT_TARGET[tbl.outputname]
		tmp.pos = m:GetTranslation()
		tmp.ang = m:GetAngles()
		tmp.scl = scale
	end
	
	if tbl.visible == false or param.nodraw
	or (not tbl.translucent and param.rendergroup == RENDERGROUP_TRANSLUCENT)
	or (tbl.translucent and param.rendergroup == RENDERGROUP_OPAQUE)
	then
		-- nothing
	elseif tbl.model and tbl.model~="" then
		--[[Jvs: what I fear is that if the new model is the same as the old one, the RenderMultiply matrix
			won't actually get flushed, so to fix it we'll first set the model to a blank one and then to the one we want
		]]
		RENDERER:SetModel("models/Gibs/HGIBS.mdl")
		--[[
			Jvs:yes, as I suspected, it actually gets cached, setting it to a different model is the only way to fix it.
			(apparently disablematrix is not fast enough?)
		]]
		RENDERER:SetModel(tbl.model)
		RENDERER:SetPos(m:GetTranslation())
		RENDERER:SetAngles(m:GetAngles())
		--[[Jvs:R.I.P. old method of scaling
			RENDERER:SetModelScale(scale)
			
			I wonder if I can reuse m instead of creating a new Matrix
			Yes, I can reuse it, and it'll replace RENDERER:SetPos, but for some reason the angles are a bit off
			Maybe the pitch and yaw got inverted?
		]]
		local mat = Matrix() 
		mat:Scale( scale ) 
		RENDERER:EnableMatrix( "RenderMultiply",mat) --mat )
		
		
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
		local clipping=nil;
		if tbl.clipplanes then
			clipping=render.EnableClipping(true)
			for _,v in ipairs(tbl.clipplanes) do
				local pos, ang = LocalToWorld(v[1], v[2]:Angle(), RENDERER:GetPos(), RENDERER:GetAngles())
				local dir = ang:Forward()
				
				render.PushCustomClipPlane(dir, dir:Dot(pos))
			end
		end
		
		if tbl.selfillum then
			render.SuppressEngineLighting(true)
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
		
		if tbl.selfillum then
			render.SuppressEngineLighting(false)
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
		RENDERER:DisableMatrix("RenderMultiply")
	elseif tbl.sprite and not param.nosprites and not param.modelonly then
		if type(tbl.sprite)=="string" then tbl.sprite = Material(tbl.sprite) end
		render.SetMaterial(tbl.sprite)
		render.DrawSprite(m:GetTranslation(), scale.x, scale.y, tbl.color or Color(255,255,255,255))
	elseif tbl.effect and not param.noeffects and not param.modelonly  then
		if not tbl.NextEffect or (tbl.delay>=0 and CurTime()>tbl.NextEffect) then
			local data = EffectData()
				data:SetOrigin(m:GetTranslation())
				data:SetAngles(m:GetAngles())
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
			DrawChild(v, ent, param)
		end
		
		local t = table.remove(ent.MatrixStack)
		ent.CurrentMatrix = t[1]
		ent.CurrentScale = t[2]
	end
end

function Draw(tbl, ent, param)
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
			DrawChild(v, ent, param)
		end
		--[[
		if IsEntity(ent) and ent.RenderBounds[1] and ent.RenderBounds[2] then
			ent:SetRenderBounds(ent.RenderBounds[1], ent.RenderBounds[2])
		end
		
		elseif IsEntity(ent) then
		ent:DrawModel()]]
	end
end

local function FlattenChild(tbl, ent, result)
--[[
	if type(tbl) ~= "table" then return end
	
	local m, scale
	
	if tbl.transform then
		m = Matrix()
		m:Translate(tbl.transform[1])
		m:Rotate(tbl.transform[2])
		m:Scale(tbl.transform[3])
	
		m = ent.CurrentMatrix * m
		scale = Vector(
			ent.CurrentScale.x * tbl.transform[3].x,
			ent.CurrentScale.y * tbl.transform[3].y,
			ent.CurrentScale.z * tbl.transform[3].z
		)
	else
		m = ent.CurrentMatrix
		scale = ent.CurrentScale
	end
]]

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
		
	local t = {}
	for k,v in pairs(tbl) do
		if k=="children" or k=="Think" then
			
		elseif k=="transform" then
			t[k] = {m:GetTranslation(), m:GetAngles(), scale}
		else
			t[k] = v
		end
	end
	table.insert(result, t)
	
	if tbl.children and #tbl.children>0 then
		table.insert(ent.MatrixStack, {ent.CurrentMatrix, ent.CurrentScale})
		ent.CurrentMatrix = m
		ent.CurrentScale = scale
		
		for _,v in pairs(tbl.children) do
			FlattenChild(v, ent, result)
		end
		
		local t = table.remove(ent.MatrixStack)
		ent.CurrentMatrix = t[1]
		ent.CurrentScale = t[2]
	end
end

function Flatten(tbl)
	if tbl then
		local result = {}
		local ent = {}
		
		ent.MatrixStack = {}
		
		ent.CurrentMatrix = nil
		ent.RenderBounds = {}
		ent.ParentEntity = ent
		
		ent.CurrentMatrix = Matrix()
		ent.CurrentScale = Vector(1,1,1)
		
		for _,v in pairs(tbl) do
			FlattenChild(v, ent, result)
		end
		
		table.CopyFromTo(result, tbl)
		return tbl
	end
end

end