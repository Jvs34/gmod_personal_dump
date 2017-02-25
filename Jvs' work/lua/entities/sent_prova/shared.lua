
ENT.Type			= "anim"
ENT.Base			= "base_anim"--"base_gmodentity"

ENT.PrintName		= "Billboard"
ENT.Author			= "Matt"
ENT.Contact			= ""
ENT.Purpose			= ""
ENT.Instructions	= ""

ENT.Spawnable		= true
ENT.AdminSpawnable	= true
ENT.RenderGroup		= RENDERGROUP_TRANSLUCENT;

if SERVER then
	AddCSLuaFile( "shared.lua" )
	AddCSLuaFile( "cl_init.lua" )
	function ENT:SpawnFunction( ply, tr )
		if not ( tr.Hit and ValidEntity(tr.Entity) and tr.Entity:GetModel():find"billboard") then return end
		local ent = ents.Create"sent_billboard"
		ent:SetPos( tr.Entity:GetPos() )
		ent:SetAngles( tr.Entity:GetAngles() )
		ent:Spawn()
		ent:Activate()
		local phys = ent:GetPhysicsObject()
		if (phys:IsValid()) then
			phys:EnableMotion(false)
		end
		ent:SetParent(tr.Entity)
		return ent
	end 

	function ENT:Initialize()
		self.Entity:SetModel"models/props_wasteland/interior_fence002d.mdl"
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid( SOLID_VPHYSICS )
		self.Entity:DrawShadow(false)
		self.Entity:SetNWString("bb_Text1","Test Billboard")
		self.Entity:SetNWString("bb_Text2","May be buggy")
	end
	return
end

local rot = Vector(-90, 90, 0)
local width,height = 222,122
local borderw,borderh = 5,5
local mat = surface.GetTextureID("models/debug/debugwhite")--"models/farp/whitemat"
local function gettextsize(text,width,height)
	local w,h,n = 0,0,0
	for i = 50,20,-1 do
		n = i
		surface.CreateFont("coolvetica", i, 400, true, false, "bb"..i )
		surface.SetFont("bb"..i)
		w,h = surface.GetTextSize(text)
		if not (w and h) then
			error("wtf?",w,h,n)
		end
		if w < width - 5 then
			break
		end
	end
	return w,h,n
end
function ENT:Draw()

	local pos = self.Entity:GetPos() + (self.Entity:GetForward() * 2.1)
	local ang = self.Entity:GetAngles()
	ang:RotateAroundAxis(ang:Right(), 	rot.x)
	ang:RotateAroundAxis(ang:Up(), 		rot.y)
	ang:RotateAroundAxis(ang:Forward(), rot.z)
	cam.Start3D2D(pos, ang,1)
		surface.SetDrawColor(225, 225, 225, 255)
		surface.SetTexture(mat)
		surface.DrawTexturedRect(width * -0.5,height * -0.5,width,height)
		surface.SetTextColor(0,0,0,255)
		local text = self.Entity:GetNWString("bb_Text1")
		if self.text1 ~= text then
			self.t1 = {gettextsize(text,width,height)}
			if self.t1[1] == 0 or self.t1[2] == 0 or self.t1[3] == 0 then
				error("gettextsize fail t1")
			end
			self.text1 = text
		end
		if self.t1[1] == 0 or self.t1[2] == 0 or self.t1[3] == 0 then
			return
		end
		surface.SetFont("bb"..self.t1[3])
		surface.SetTextPos(self.t1[1] * -0.5,self.t1[2] * -1 - 10)
		surface.DrawText(text)
		local text = self.Entity:GetNWString("bb_Text2")
		if self.text2 ~= text then
			self.t2 = {gettextsize(text,width,height)}
			if self.t2[1] == 0 or self.t2[2] == 0 or self.t2[3] == 0 then
				error("gettextsize fail t2")
			end
			self.text2 = text
		end
		if self.t2[1] == 0 or self.t2[2] == 0 or self.t2[3] == 0 then
			return
		end
		surface.SetFont("bb"..self.t2[3])
		surface.SetTextPos(self.t2[1] * -0.5,10)
		surface.DrawText(text)
	cam.End3D2D()

end
