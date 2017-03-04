--PrecacheParticleSystem("peejar_impact_milk")

local SWEP={}

SWEP.Base="weapon_base"
SWEP.HoldType = "shotgun"
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.ViewModel = "models/weapons/v_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.ShowViewModel = true
SWEP.ShowWorldModel = false
SWEP.ViewModelBonescales = {["ValveBiped.Gun"] = Vector(0.009, 0.009, 0.009)}
SWEP.AutoSwitchTo        = true
SWEP.AutoSwitchFrom        = true
SWEP.DrawAmmo            = false
SWEP.PrintName            = "Pump cockgun"
SWEP.Author                = "Jvs"
SWEP.DrawCrosshair        = true
SWEP.Category                = "Half Life 2" 
SWEP.Slot                    = 4
SWEP.SlotPos                = 5
SWEP.Weight                    = 5
SWEP.Spawnable                 = false
SWEP.AdminSpawnable          = true

SWEP.Primary={}
SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1    

SWEP.Primary.Ammo             = false
SWEP.Primary.Automatic        = false

SWEP.Secondary={}
SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Ammo         = false
SWEP.Secondary.Automatic     = false

SWEP.VElements = {
	["penis1"] = { type = "Model", model = "models/hunter/tubes/tube1x1x3.mdl", bone = "ValveBiped.Pump", pos = Vector(-0.764, 0.875, -11.469), angle = Angle(0, 0, 0), size = Vector(0.086, 0.086, 0.261), color = Color(255, 212, 134, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["penisball2"] = { type = "Model", model = "models/hunter/misc/shell2x2.mdl", bone = "ValveBiped.Pump", pos = Vector(-3, 0.875, -11.469), angle = Angle(0, 0, 0), size = Vector(0.064, 0.064, 0.064), color = Color(255, 212, 134, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["penisball1"] = { type = "Model", model = "models/hunter/misc/shell2x2.mdl", bone = "ValveBiped.Pump", pos = Vector(1.59, 0.875, -11.469), angle = Angle(0, 0, 0), size = Vector(0.064, 0.064, 0.064), color = Color(255, 212, 134, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["peniscock"] = { type = "Model", model = "models/hunter/misc/shell2x2.mdl", bone = "ValveBiped.Pump", pos = Vector(-0.764, 0.875, 27.181), angle = Angle(0, 0, 0), size = Vector(0.059, 0.059, 0.059), color = Color(255, 74, 194, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} }
}
SWEP.WElements = {
	["penisball2"] = { type = "Model", model = "models/hunter/misc/shell2x2.mdl", pos = Vector(1.45, 0, -4.331), angle = Angle(0, 0, 0), size = Vector(0.05, 0.05, 0.05), color = Color(255, 212, 134, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["penis1"] = { type = "Model", model = "models/hunter/tubes/tube1x1x3.mdl", pos = Vector(3.112, 1.375, -3.876), angle = Angle(-95.82, 0, 0), size = Vector(0.059, 0.059, 0.153), color = Color(255, 212, 134, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["penisball1"] = { type = "Model", model = "models/hunter/misc/shell2x2.mdl", pos = Vector(1.45, 2.424, -4.331), angle = Angle(0, 0, 0), size = Vector(0.05, 0.05, 0.05), color = Color(255, 212, 134, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} },
	["peniscock"] = { type = "Model", model = "models/hunter/misc/shell2x2.mdl", pos = Vector(24.919, 1.375, -6.081), angle = Angle(0, 0, 0), size = Vector(0.041, 0.041, 0.041), color = Color(255, 74, 194, 255), surpresslightning = false, material = "models/debug/debugwhite", skin = 0, bodygroup = {} }
}

local function BuildBonePositions(s)
	if(LocalPlayer():GetName() ~= "Gran PC") then return end
	--if(s:GetWeapon():GetClass() ~= "penisshotgun") then return end
	local bone = s:LookupBone(Bone or "ValveBiped.Bip01_L_UpperArm")
	if(not bone) then return end
	local m = s:GetBoneMatrix(bone)
	if(not m) then return end
	m:Rotate(Angle(0, 0, -18))--*math.abs(math.sin(CurTime()*8)))
	s:SetBoneMatrix(bone, m)
	
	bone = s:LookupBone("ValveBiped.Bip01_L_Forearm")
	if(not bone) then return end
	m = s:GetBoneMatrix(bone)
	if(not m) then return end
	m:Rotate(m:GetAngle()*0.2)
	m:Rotate(Angle(-20, 40, 13))--*math.abs(math.sin(CurTime()*8)))
	s:SetBoneMatrix(bone, m)
	
	bone = s:LookupBone("ValveBiped.Bip01_L_Hand")
	if(not bone) then return end
	m = s:GetBoneMatrix(bone)
	if(not m) then return end
	m:Rotate(Angle(32, 2, 0))--*math.abs(math.sin(CurTime()*8)))
	m:Translate(Vector(0, 0, 0.8))
	s:SetBoneMatrix(bone, m)
end
//Entity(1).BuildBonePositions= BuildBonePositions
function SWEP:Initialize()
 
    -- other initialize code goes here
 
    if CLIENT then
     
        self:CreateModels(self.VElements) -- create viewmodels
        self:CreateModels(self.WElements) -- create worldmodels
        
        -- init view model bone build function
        self.BuildViewModelBones = function( s )
            if LocalPlayer():GetActiveWeapon() == self and self.ViewModelBonescales then
                for k, v in pairs( self.ViewModelBonescales ) do
                    local bone = s:LookupBone(k)
                    if (!bone) then continue end
                    local m = s:GetBoneMatrix(bone)
                    if (!m) then continue end
                    m:Scale(v)
                    s:SetBoneMatrix(bone, m)
                end
				local bone = s:LookupBone("ValveBiped.Bip01_L_Forearm")
				if(not bone) then return end
				local m = s:GetBoneMatrix(bone)
				if(not m) then return end
				m:Translate(Vector(13, 9, 8)*math.abs(math.sin(CurTime()*8)))
				s:SetBoneMatrix(bone, m)
            end
        end
         
    end
	self.FapDelta = CurTime()
	self:GetOwner().BuildBonePositions = BuildBonePositions
	self:SetWeaponHoldType(self.HoldType)
end

function SWEP:StupidSPFix(FunctName)
    if SERVER && game.SinglePlayer() then
    self:CallOnClient(FunctName,"")
    end
end
 
function SWEP:OnRemove()
     
    -- other onremove code goes here
     
    if CLIENT then
        self:RemoveModels()
    end
     
end
     
 
if CLIENT then
 
    SWEP.vRenderOrder = nil
    function SWEP:ViewModelDrawn()
        local vm = self.Owner:GetViewModel()
        if !IsValid(vm) then return end
		vm.FapDelta = self.FapDelta+FrameTime()
         
        if (!self.VElements) then return end
         
        if vm.BuildBonePositions ~= self.BuildViewModelBones then
            vm.BuildBonePositions = self.BuildViewModelBones
        end
 
        if (self.ShowViewModel == nil or self.ShowViewModel) then
            vm:SetColor(Color(255,255,255,255))
        else
            -- we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
            vm:SetColor(Color(255,255,255,1))
        end
         
        if (!self.vRenderOrder) then
             
            -- we build a render order because sprites need to be drawn after models
            self.vRenderOrder = {}
 
            for k, v in pairs( self.VElements ) do
                if (v.type == "Model") then
                    table.insert(self.vRenderOrder, 1, k)
                elseif (v.type == "Sprite" or v.type == "Quad") then
                    table.insert(self.vRenderOrder, k)
                end
            end
             
        end
 
        for k, name in ipairs( self.vRenderOrder ) do
         
            local v = self.VElements[name]
            if (!v) then self.vRenderOrder = nil break end
         
            local model = v.modelEnt
            local sprite = v.spriteMaterial
             
            if (!v.bone) then continue end
            local bone = vm:LookupBone(v.bone)
            if (!bone) then continue end
             
            local pos, ang = Vector(0,0,0), Angle(0,0,0)
            local m = vm:GetBoneMatrix(bone)
            if (m) then
                pos, ang = m:GetTranslation(), m:GetAngle()
            end
             
            if (self.ViewModelFlip) then
                ang.r = -ang.r -- Fixes mirrored models
            end
             
            if (v.type == "Model" and IsValid(model)) then
 
                model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
 
                model:SetAngles(ang)
                model:SetModelScale(v.size)
                 
                if (v.material == "") then
                    model:SetMaterial("")
                elseif (model:GetMaterial() != v.material) then
                    model:SetMaterial( v.material )
                end
                 
                if (v.skin and v.skin != model:GetSkin()) then
                    model:SetSkin(v.skin)
                end
                 
                if (v.bodygroup) then
                    for k, v in pairs( v.bodygroup ) do
                        if (model:GetBodygroup(k) != v) then
                            model:SetBodygroup(k, v)
                        end
                    end
                end
                 
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(true)
                end
                 
                render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
                render.SetBlend(v.color.a/255)
                model:DrawModel()
                render.SetBlend(1)
                render.SetColorModulation(1, 1, 1)
                 
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(false)
                end
                 
            elseif (v.type == "Sprite" and sprite) then
                 
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                render.SetMaterial(sprite)
                render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
                 
            elseif (v.type == "Quad" and v.draw_func) then
                 
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
                 
                cam.Start3D2D(drawpos, ang, v.size)
                    v.draw_func( self )
                cam.End3D2D()
 
            end
             
        end
         
    end
 
    SWEP.wRenderOrder = nil
    function SWEP:DrawWorldModel()
        if (self.ShowWorldModel == nil or self.ShowWorldModel) then
            self:DrawModel()
        end
         
        if (!self.WElements) then return end
         
        if (!self.wRenderOrder) then
 
            self.wRenderOrder = {}
 
            for k, v in pairs( self.WElements ) do
                if (v.type == "Model") then
                    table.insert(self.wRenderOrder, 1, k)
                elseif (v.type == "Sprite" or v.type == "Quad") then
                    table.insert(self.wRenderOrder, k)
                end
            end
 
        end
         
        local opos, oang = self:GetPos(), self:GetAngles()
        local bone_ent
 
        if (IsValid(self.Owner)) then
            bone_ent = self.Owner
        else
            -- when the weapon is dropped
            bone_ent = self
        end
         
        local bone = bone_ent:LookupBone("ValveBiped.Bip01_R_Hand")
        if (bone) then
            local m = bone_ent:GetBoneMatrix(bone)
            if (m) then
                opos, oang = m:GetTranslation(), m:GetAngle()
            end
        end
         
        for k, name in pairs( self.wRenderOrder ) do
         
            local v = self.WElements[name]
            if (!v) then self.wRenderOrder = nil break end
         
            local model = v.modelEnt
            local sprite = v.spriteMaterial
 
            local pos, ang = Vector(opos.x, opos.y, opos.z), Angle(oang.p, oang.y, oang.r)
 
            if (v.type == "Model" and IsValid(model)) then
 
                model:SetPos(pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z )
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
 
                model:SetAngles(ang)
                model:SetModelScale(v.size)
                 
                if (v.material == "") then
                    model:SetMaterial("")
                elseif (model:GetMaterial() != v.material) then
                    model:SetMaterial( v.material )
                end
                 
                if (v.skin and v.skin != model:GetSkin()) then
                    model:SetSkin(v.skin)
                end
                 
                if (v.bodygroup) then
                    for k, v in pairs( v.bodygroup ) do
                        if (model:GetBodygroup(k) != v) then
                            model:SetBodygroup(k, v)
                        end
                    end
                end
                 
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(true)
                end
                 
                render.SetColorModulation(v.color.r/255, v.color.g/255, v.color.b/255)
                render.SetBlend(v.color.a/255)
                model:DrawModel()
                render.SetBlend(1)
                render.SetColorModulation(1, 1, 1)
                 
                if (v.surpresslightning) then
                    render.SuppressEngineLighting(false)
                end
                 
            elseif (v.type == "Sprite" and sprite) then
                 
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                render.SetMaterial(sprite)
                render.DrawSprite(drawpos, v.size.x, v.size.y, v.color)
                 
            elseif (v.type == "Quad" and v.draw_func) then
                 
                local drawpos = pos + ang:Forward() * v.pos.x + ang:Right() * v.pos.y + ang:Up() * v.pos.z
                ang:RotateAroundAxis(ang:Up(), v.angle.y)
                ang:RotateAroundAxis(ang:Right(), v.angle.p)
                ang:RotateAroundAxis(ang:Forward(), v.angle.r)
                 
                cam.Start3D2D(drawpos, ang, v.size)
                    v.draw_func( self )
                cam.End3D2D()
 
            end
             
        end
         
    end
 
    function SWEP:CreateModels( tab )
 
        if (!tab) then return end
 
        -- Create the clientside models here because Garry says we can't do it in the render hook
        for k, v in pairs( tab ) do
            if (v.type == "Model" and v.model and v.model != "" and (!IsValid(v.modelEnt) or v.createdModel != v.model) and
                    string.find(v.model, ".mdl") and file.Exists ("../"..v.model) ) then
                 
                v.modelEnt = ClientsideModel(v.model, RENDER_GROUP_VIEW_MODEL_OPAQUE)
                if (IsValid(v.modelEnt)) then
                    v.modelEnt:SetPos(self:GetPos())
                    v.modelEnt:SetAngles(self:GetAngles())
                    v.modelEnt:SetParent(self)
                    v.modelEnt:SetNoDraw(true)
                    v.createdModel = v.model
                else
                    v.modelEnt = nil
                end
                 
            elseif (v.type == "Sprite" and v.sprite and v.sprite != "" and (!v.spriteMaterial or v.createdSprite != v.sprite)
                and file.Exists ("../materials/"..v.sprite..".vmt")) then
                 
                local name = v.sprite.."-"
                local params = { ["$basetexture"] = v.sprite }
                -- make sure we create a unique name based on the selected options
                local tocheck = { "nocull", "additive", "vertexalpha", "vertexcolor", "ignorez" }
                for i, j in pairs( tocheck ) do
                    if (v[j]) then
                        params["$"..j] = 1
                        name = name.."1"
                    else
                        name = name.."0"
                    end
                end
 
                v.createdSprite = v.sprite
                v.spriteMaterial = CreateMaterial(name,"UnlitGeneric",params)
                 
            end
        end
         
    end
 
    function SWEP:RemoveModels()
        if (self.VElements) then
            for k, v in pairs( self.VElements ) do
                if (IsValid( v.modelEnt )) then v.modelEnt:Remove() end
            end
        end
        if (self.WElements) then
            for k, v in pairs( self.WElements ) do
                if (IsValid( v.modelEnt )) then v.modelEnt:Remove() end
            end
        end
        self.VElements = nil
        self.WElements = nil
    end
 
end

function SWEP:FireAnimationEvent(pos,ang,event)
return true
end

function SWEP:CheckThrowPosition( pPlayer, vecEye, vecSrc )

    local tr;

    tr = {}
    tr.start = vecEye
    tr.endpos = vecSrc
    tr.mins = Vector(6,6,6)*-1
    tr.maxs = Vector(6,6,6)
    tr.mask = MASK_PLAYERSOLID
    tr.filter = pPlayer
    tr.collision = pPlayer:GetCollisionGroup()
    local trace = util.TraceHull( tr );

    if ( trace.Hit ) then
        vecSrc = tr.endpos;
    end

    return vecSrc

end

function SWEP:PrimaryAttack()
	self.Weapon:SendWeaponAnim( ACT_SHOTGUN_PUMP );
	self:EmitSound( "physics/flesh/flesh_squishy_impact_hard3.wav" )
	self.Owner:DoAttackEvent()
	self:SetNextPrimaryFire(CurTime()+0.3)
	if SERVER then
	
	local    vecEye = self.Owner:EyePos();
    local    vForward, vRight,vUp;
    vForward = self.Owner:GetForward();
    vRight = self.Owner:GetRight();
	vUp = self.Owner:GetUp();
    local vecSrc = vecEye + vForward * 18.0 + vRight * 8.0 +vUp*-3.0;
    vecSrc = self:CheckThrowPosition( self.Owner, vecEye, vecSrc );
    local vecThrow;
    vecThrow = self.Owner:GetVelocity();
    
    local throwspeeddamnit=600
    vecThrow = vecThrow + vForward * throwspeeddamnit;
    local can = ents.Create("penisshotgun_sperm");
    if !can || !IsValid(can) then return end
    can:SetPos( vecSrc );
    can:SetAngles( Angle(0,0,0) );
    can:SetOwner( self.Owner );
    can:Spawn()
    can:Activate()
    can:GetPhysicsObject():SetVelocity( vecThrow );
    can:GetPhysicsObject():AddAngleVelocity( Angle(600,math.random(-1200,1200),0) );
    end
	
end

function SWEP:SecondaryAttack()
end

function SWEP:Reload()
end

local e={}
e.RenderGroup = RENDERGROUP_TRANSLUCENT
e.Type             = "anim"
e.Base             = "base_anim"
e.PrintName        = "Cannade"
e.Author            = "Jvs"
e.Information        = ""
e.Category        = "Other"

e.Spawnable            = false
e.AdminSpawnable        = false
e.Detonated=false;
function e:Initialize()
    if(SERVER)then
    self:SetModel( "models/hunter/misc/sphere025x025.mdl" )
    	
	self.Entity:PhysicsInitSphere( 4, "metal_bouncy" )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	
	self.Entity:SetCollisionBounds( Vector( -4, -4, -4 ), Vector( 4, 4, 4 ) )
    self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG );
    self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG );
    self:PhysWake()
    self:SetMaterial("models/debug/debugwhite")
	else
		self:SetModelScale(Vector(0.5,0.5,0.5))
	end
end

function e:Draw()
	
    self:DrawModel();
end

function e:PhysicsCollide( data, physobj )
    if IsValid(data.HitEntity) && (data.HitEntity==self:GetOwner() ||  data.HitEntity:GetClass()==self:GetClass()) then return end
	if self.Detonated then return end
	self:EmitSound( "physics/flesh/flesh_squishy_impact_hard3.wav" )
	--ParticleEffect("peejar_impact_milk",data.HitPos,Angle(0,0,0),nil)
	if data then
        local Pos1 = data.HitPos + data.HitNormal
        local Pos2 = data.HitPos - data.HitNormal
        util.Decal("paintsplatpink",Pos1,Pos2)
    end
	self.Detonated=true;
    self:Remove();
end
scripted_ents.Register(e,"penisshotgun_sperm",true)
weapons.Register(SWEP,"penisshotgun",true)