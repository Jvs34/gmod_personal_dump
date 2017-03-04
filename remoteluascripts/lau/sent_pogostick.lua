
local ClassName="sent_pogostick"
local ENT={}

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE
ENT.PrintName        = "Pogostick"
ENT.Author="Jvs"
ENT.Spawnable = true  
ENT.AdminSpawnable = true  

function ENT:SpawnFunction( ply, tr )
    if ( not tr.Hit ) then return end
    
    local SpawnPos = tr.HitPos + tr.HitNormal * 40
    
    local ent = ents.Create("sent_pogostick")
    ent:SetPos( SpawnPos )
    ent:Spawn()
    ent:Activate()
    ent.Owner = ply
    ent.LastKicker=ply
    return ent
end


if CLIENT then
multimodel.Register("PogoStick", {
	{
		transform = {Vector(0,0,0), Angle(0,0,-15), Vector(1,1,1)},
		children = {
			{
				model = "models/props_c17/signpole001.mdl",
				transform = {Vector(0,0,-30), Angle(0,0,0), Vector(1,1,0.5)},
			},

			{
				model = "models/props_c17/signpole001.mdl",
				transform = {Vector(-8,0,24), Angle(0,90,90), Vector(1,1,0.15)},
				material=Material("models/shiny"),
				color=Color(0,0,0),
			},
			{
				model = "models/props_c17/FurnitureShelf001b.mdl",
				transform = {Vector(4,0,-18), Angle(0,90,0), Vector(0.3,0.15,1)},
				material=Material("models/shiny"),
				color=Color(0,0,0),
			},
			{
				model = "models/props_c17/FurnitureShelf001b.mdl",
				transform = {Vector(-4,0,-18), Angle(0,90,0), Vector(0.3,0.15,1)},
				material=Material("models/shiny"),
				color=Color(0,0,0),
			},
			{
				outputname = "lefthand",
				transform = {Vector(-7,-5,27), Angle(0,90,90), Vector(1,1,1)},
			},
			
			{
				outputname = "righthand",
				transform = {Vector(7,-5,27), Angle(0,90,90), Vector(1,1,1)},
			},
			
			{
				outputname = "leftfoot",
				transform = {Vector(-5,-5,-12), Angle(40,90,-90), Vector(1,1,1)},
			},
			
			{
				outputname = "rightfoot",
				transform = {Vector(5,-5,-12), Angle(40,90,-90), Vector(1,1,1)},
			},
	
			{
				outputname = "spine",
				transform = {Vector(0,-20,30), Angle(-90,-90,90), Vector(1,1,1)},
			},
			
		}
	}
})	






end

local physattchtab={
	[5]="lefthand",
	[7]="righthand",
	[1]="spine",
	[13]="leftfoot",
	[14]="rightfoot",
	
}

--[[
ValveBiped.Bip01_Spine1
ValveBiped.Bip01_Spine2
ValveBiped.Bip01_Spine4
V
]]
local boneattchtab={
	["ValveBiped.Bip01_L_Hand"]="lefthand",
	["ValveBiped.Bip01_R_Hand"]="righthand",
}

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

function ENT:Initialize()
    if SERVER then
        self:SetModel( "models/props_borealis/bluebarrel001.mdl" )
        self:PhysicsInit( SOLID_VPHYSICS )
        self:SetMoveType( MOVETYPE_VPHYSICS )
        self:SetSolid( SOLID_VPHYSICS )
	else
		self.Rag=ClientsideRagdoll("models/player/breen.mdl" )
		self.Rag:SetParent(NULL)
		self.Rag:SetPos(Vector(0,0,0))
		self.Rag:SetOwner(self)
		for i=0,self.Rag:GetPhysicsObjectCount()-1 do
			local phys=self.Rag:GetPhysicsObjectNum( i )
			if not phys then continue end
			phys:SetPos(self:GetPos())
			phys:SetMass(1)
		end
			--needed, it's the main thing that prevents the attachments from spazzing out
		self.Rag.GetPlayerColor=function() return Vector(math.random(0,255)/255,math.random(0,255)/255,math.random(0,255)/255) end
		self.Rag:AddCallback("BuildBonePositions",function(self,bone)
			if not IsValid(self:GetOwner()) then return end
				for i=0,self:GetBoneCount()-1 do
					local bonename=self:GetBoneName(i)

					if boneattchtab[bonename] and self:GetOwner().Atch[boneattchtab[bonename]] then		
						pos,ang=Vector(),Angle()
						--pos,ang=LocalToWorld(p,a,pos,ang)
						--[[
						print(bonename)
						local bm=self:GetBoneMatrix(i)
						bm:SetAngles(ang)
						bm:SetTranslation(pos)
						self:SetBoneMatrix(i,bm)
						]]
					end
				end
		end)
		

		self.Atch={}
		self.mm=multimodel.CreateInstance("PogoStick")
	end
	
	self:SetCollisionGroup(COLLISION_GROUP_WEAPON)
end
local shinymat
if CLIENT then
shinymat=Material("models/wireframe")
end



function ENT:Draw()
	if not self.mm then return end
	if not IsValid(self.Rag) then return end 
	self.mm=multimodel.CreateInstance("PogoStick")
	multimodel.DoFrameAdvance(self.mm, CurTime(), self)
	multimodel.SetOutputTarget(self.Atch)
	multimodel.Draw(self.mm,self,{origin=self:GetPos(),angles=self:GetAngles()})
	multimodel.SetOutputTarget(nil)
	
	
	for i,v in pairs(self.Atch) do
		render.SetMaterial(shinymat)
		render.DrawSphere(v.pos, 2,10,10, color_white  )
	end
	
	self.Rag:DrawModel()
	
	
	render.SetBlend(0.2)
	--self:DrawModel()
	render.SetBlend(1)
	

end



function ENT:Think()
	if SERVER or not IsValid(self.Rag) then return end
	self.Rag:PhysWake()
	for i=0,self.Rag:GetPhysicsObjectCount()-1 do
		local phys=self.Rag:GetPhysicsObjectNum( i )
		if not phys then continue end
		phys:Wake()
		if physattchtab[i] and self.Atch[physattchtab[i]] then
			phys:SetMass(500)
			phys:SetPos(self.Atch[physattchtab[i]].pos)
			phys:SetAngles(self.Atch[physattchtab[i]].ang)
			phys:SetVelocityInstantaneous(Vector(0,0,0))
		end
	end
	self:SetNextClientThink(CurTime())

end

function ENT:OnRemove()
	if IsValid(self.Rag) then
		self.Rag:Remove()
	end

end

scripted_ents.Register(ENT,ClassName,true)