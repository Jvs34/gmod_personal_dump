if SERVER then
	AddCSLuaFile("jetpackinh.lua")
end

if CLIENT and not multimodelredux then
multimodelredux=multimodelredux or {}
multimodelredux.MODELS = {}
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
		local clipping=nil;
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
		
	end
end

end

if CLIENT then

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

local matHeatWave		= Material( "sprites/heatwave" )
local matFire			= Material( "effects/fire_cloud1" )

local function drawFire(ent,pos,normal,scale)
	local vOffset = pos or vector_origin
	local vNormal = normal or vector_origin

	local scroll = math.random(50,1000)
	
	local Scale = scale or 1
		
	render.SetMaterial( matFire )
	
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) )
		render.AddBeam( vOffset + vNormal * 60 * Scale, 32 * Scale, scroll + 1, Color( 255, 255, 255, 128) )
		render.AddBeam( vOffset + vNormal * 148 * Scale, 32 * Scale, scroll + 3, Color( 255, 255, 255, 0) )
	render.EndBeam()
	
	scroll = scroll * 0.5
	
	render.UpdateRefractTexture()
	render.SetMaterial( matHeatWave )
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) )
		render.AddBeam( vOffset + vNormal * 32 * Scale, 32 * Scale, scroll + 2, Color( 255, 255, 255, 255) )
		render.AddBeam( vOffset + vNormal * 128 * Scale, 48 * Scale, scroll + 5, Color( 0, 0, 0, 0) )
	render.EndBeam()
	
	
	scroll = scroll * 1.3
	render.SetMaterial( matFire )
	render.StartBeam( 3 )
		render.AddBeam( vOffset, 8 * Scale, scroll, Color( 0, 0, 255, 128) )
		render.AddBeam( vOffset + vNormal * 60 * Scale, 16 * Scale, scroll + 1, Color( 255, 255, 255, 128) )
		render.AddBeam( vOffset + vNormal * 148 * Scale, 16 * Scale, scroll + 3, Color( 255, 255, 255, 0) )
	render.EndBeam()

	
	if !ent.ParticleEmitter then 
		ent.ParticleEmitter = ParticleEmitter( pos )
	return 
	end
	
	local particle = ent.ParticleEmitter:Add("particle/particle_noisesphere", vOffset)
    if not particle then return end
	particle:SetVelocity(Vector(0,0,0))
	particle:SetDieTime(0.5)
	particle:SetStartAlpha(200)
	particle:SetEndAlpha(0)
	particle:SetStartSize(3)
	particle:SetEndSize( 16 )
	particle:SetRoll( math.Rand( -10,10  ) )
	particle:SetRollDelta(math.Rand( -0.2, 0.2 ))
	particle:SetColor(200,200,200)
	
end

multimodelredux.Register("WOODENJETPACK", {
	{
		transform = {Vector(0,-5,0), Angle(0,265,-90), Vector(1,1,1)/1.5},
		children = {
			{
				model = "models/props_junk/cardboard_box001a.mdl",
				transform = {Vector(0,0,0), Angle(0,90,90), Vector(0.5,0.7,0.4)},

			},
			{
				model = "models/props_junk/garbage_carboard001a.mdl",
				transform = {Vector(0,-16,-5), Angle(90,0,180), Vector(1,1,1)/2},
	
			},
			{
				model = "models/props_junk/garbage_carboard001a.mdl",
				transform = {Vector(0,16,-5), Angle(-90,0,180), Vector(1,1,1)/2},
	
			},
			{
				model = "models/dav0r/thruster.mdl",
				transform = {Vector(0,5,-12), Angle(180,0,0), Vector(1,1,1)},
				custom=function(self,pos,ang,scl,ent)
					if IsValid(ent) and IsValid(ent:GetNWEntity("JetPack")) and ent:GetNWEntity("JetPack").dt and ent:GetNWEntity("JetPack").dt.IsJetPacking then
						drawFire(ent,pos,ang:Up(),0.2)
					end
				end
			},
			{
				model = "models/dav0r/thruster.mdl",
				transform = {Vector(0,-5,-12), Angle(180,0,0), Vector(1,1,1)},
				custom=function(self,pos,ang,scl,ent)
					if IsValid(ent) and IsValid(ent:GetNWEntity("JetPack")) and ent:GetNWEntity("JetPack").dt and ent:GetNWEntity("JetPack").dt.IsJetPacking then
						drawFire(ent,pos,ang:Up(),0.2)
					end
				end
			},
			{
				model = "models/props_canal/mattpipe.mdl",
				transform = {Vector(8,3.5,-3), Angle(180,0,0), Vector(1.3,1,0.7)},
			},
			{
				model = "models/props_junk/propane_tank001a.mdl",
				transform = {Vector(7.5,3.5,-6), Angle(0,90,0), Vector(1,1,0.7)/1.3},
			},
			{
				model = "models/props_canal/mattpipe.mdl",
				transform = {Vector(8,-3.5,-3), Angle(180,0,0), Vector(1.3,1,0.7)},
			},
			{
				model = "models/props_junk/propane_tank001a.mdl",
				transform = {Vector(7.5,-3.5,-6), Angle(0,90,0), Vector(1,1,0.7)/1.3},
			},			
		},
		Think = function(self, time, ent)
			if IsValid(ent) then

			end
		end,

	}
})


multimodelredux.Register("JETPACK", {
	{
		transform = {Vector(0,-5,0), Angle(0,265,-90), Vector(1,1,1)/1.5},
		children = {
			{
				model = "models/props_junk/metalgascan.mdl",
				transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
				children={
					{
						model = "models/XQM/jettailpiece1.mdl",
						transform = {Vector(0,-16,-5), Angle(0,180,-90), Vector(1,1,1)/1.3},
			
					},
					{
						model = "models/XQM/jettailpiece1.mdl",
						transform = {Vector(0,16,-5), Angle(0,0,-90), Vector(1,1,1)/1.3},
					},
					{
						model = "models/dav0r/thruster.mdl",
						transform = {Vector(0,5,-12), Angle(180,0,0), Vector(1,1,1)},
						custom=function(self,pos,ang,scl,ent)
							if IsValid(ent) and IsValid(ent:GetNWEntity("JetPack")) and ent:GetNWEntity("JetPack").dt and ent:GetNWEntity("JetPack").dt.IsJetPacking then
								drawFire(ent,pos,ang:Up(),0.2)
							end
						end
					},
					{
						model = "models/dav0r/thruster.mdl",
						transform = {Vector(0,-5,-12), Angle(180,0,0), Vector(1,1,1)},
						custom=function(self,pos,ang,scl,ent)
							if IsValid(ent) and IsValid(ent:GetNWEntity("JetPack")) and ent:GetNWEntity("JetPack").dt and ent:GetNWEntity("JetPack").dt.IsJetPacking then
								drawFire(ent,pos,ang:Up(),0.2)
							end
						end
					},
					{
						model = "models/props_canal/mattpipe.mdl",
						transform = {Vector(8,3.5,-3), Angle(180,0,0), Vector(1.3,1,0.7)},
					},
					{
						model = "models/props_junk/propane_tank001a.mdl",
						transform = {Vector(7.5,3.5,-6), Angle(0,90,0), Vector(1,1,0.7)/1.3},
					},
					{
						model = "models/props_canal/mattpipe.mdl",
						transform = {Vector(8,-3.5,-3), Angle(180,0,0), Vector(1.3,1,0.7)},
					},
					{
						model = "models/props_junk/propane_tank001a.mdl",
						transform = {Vector(7.5,-3.5,-6), Angle(0,90,0), Vector(1,1,0.7)/1.3},
					},
					--
				},

			},
			
		},
		Think = function(self, time, ent)
			if IsValid(ent) then

			end
		end,

	}
})


local jetpacks={}
jetpacks[0]=multimodelredux.CreateInstance("JETPACK")
jetpacks[1]=multimodelredux.CreateInstance("WOODENJETPACK")

hook.Add("PostPlayerDraw", "Jetpack", function(ply)
		if not IsValid(ply:GetNWEntity("JetPack")) then return end
		local matrix = ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_Spine2"))
		if !matrix then return end
		local pos = matrix:GetTranslation()
		if !pos then return end
		local ang = matrix:GetAngles()
		if !ang then return end
		
		multimodelredux.DoFrameAdvance(jetpacks[ply:GetNWInt("JetPackType") or 0] or jetpacks[0], CurTime(), ply)
		multimodelredux.Draw(jetpacks[ply:GetNWInt("JetPackType") or 0] or jetpacks[0],ply,{origin=pos,angles=ang})
		
end)

end

hook.Add("Move","Jetpack",function(ply,data)
	if not ply:Alive() or ply:WaterLevel()>0 then return end
	if not IsValid(ply:GetNWEntity("JetPack")) then return end
	if data:KeyDown(IN_JUMP) then
		ply:SetGroundEntity(NULL)
		local oldspeed=data:GetVelocity()
		local sight=ply:EyeAngles()
		local sidespeed=data:GetSideSpeed()
		local forwardspeed=data:GetForwardSpeed()
		local upspeed=data:GetVelocity().z
		sidespeed=math.Clamp(data:GetSideSpeed(),-700,700)
		forwardspeed=math.Clamp(data:GetForwardSpeed(),-700,700)
		sight.pitch=0;
		sight.roll=0;
		sight.yaw=sight.yaw-90;
		local afterburnerspeed=(upspeed<=-100) and 20 or 0
		local upspeed=(sidespeed<=200 and forwardspeed<=100) and 22 or 12
		upspeed=upspeed+afterburnerspeed
		
		local moveang=Vector(sidespeed/35,forwardspeed/35,upspeed)
		
		moveang:Rotate(sight)
		local horizontalspeed=moveang
		data:SetVelocity(oldspeed+horizontalspeed)
		return
	end
end)


if SERVER then
	concommand.Add("givejetpack", function(ply, command, arguments)
		if not IsValid(ply) or IsValid(ply:GetNWEntity("JetPack")) then return end
		local jet = ents.Create( "jetpack" )
		if !IsValid(jet) then return end
		ply:SetNWInt("JetPackType",0)
		jet:SetOwner(ply)
		jet:Spawn()
		
	end)
	concommand.Add("givewoodenjetpack", function(ply, command, arguments)
		if not IsValid(ply) or IsValid(ply:GetNWEntity("JetPack")) then return end
		local jet = ents.Create( "jetpack" )
		if !IsValid(jet) then return end
		ply:SetNWInt("JetPackType",1)
		jet:SetOwner(ply)
		jet:Spawn()
		
	end)
	concommand.Add("removejetpack", function(ply, command, arguments)
		if not IsValid(ply) or not IsValid(ply:GetNWEntity("JetPack")) then return end
		ply:GetNWEntity("JetPack"):Remove()
	end)
end
if SERVER then
end

local e={}
e.RenderGroup = RENDERGROUP_TRANSLUCENT
e.Type             = "anim"
e.Base             = "base_anim"
e.PrintName        = "Jetpack"
e.Author            = "Jvs"
e.Information        = ""
e.Category        = "Other"
e.Spawnable            = false
e.AdminSpawnable        = false

util.PrecacheSound("Missile.Ignite")
util.PrecacheSound("Weapon_PhysCannon.Launch")

function e:Initialize()
    if SERVER and IsValid(self:GetOwner()) then
		self:SetPos(self:GetOwner():GetPos())
		self:SetParent(self:GetOwner())
		self:GetOwner():SetNWEntity("JetPack",self)
	end
	self:DrawShadow(false)

	self.missilesound=CreateSound( self, "Missile.Ignite" )
	
end

function e:SetupDataTables()
    self:DTVar( "Int", 0, "Fuel" );
	self:DTVar( "Bool", 0, "IsJetPacking" );
end

function e:Draw()
end

function e:Think()
	if not self.dt then return end
	local ply=self:GetOwner()
	if not IsValid(ply) then return end
	if ply:Alive() and ply:KeyDown(IN_JUMP) and ply:WaterLevel()<=0 then 
		if SERVER or  (CLIENT and LocalPlayer()==self:GetOwner()) then 
			self.missilesound:PlayEx(0.2,250)
			self.dt.IsJetPacking=true
		end
	elseif (not ply:Alive() or not ply:KeyDown(IN_JUMP) or ply:WaterLevel()>1) then
		if SERVER or  (CLIENT and LocalPlayer()==self:GetOwner()) then 
			self.missilesound:Stop()
			self.dt.IsJetPacking=false
		end
	end
	
	
	self:NextThink( CurTime())
    return true
end

function e:UpdateTransmitState() return TRANSMIT_ALWAYS end; 

function e:OnRemove()
	if self.missilesound then
		self.missilesound:Stop()
	end
end

scripted_ents.Register(e,"jetpack",true)