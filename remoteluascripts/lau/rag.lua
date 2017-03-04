local p=Vector(-5,-3,0)
local a=Angle(90,0,0)
--offsets
util.PrecacheModel("models/props_c17/FurnitureMattress001a.mdl")

hook.Add("NetworkEntityCreated","CreateUpdateCape",function( ent )
	--[[
	if IsValid(ent) and ent:IsPlayer() and ent:IsAdmin() then
		CreateCape(ent,true)
	end
	]]
end)

hook.Add("Think","CapeCreateUpdate",function()
	for i,v in pairs(player.GetAll()) do
		if IsValid(v) and not IsValid(v.__cape)  then
			CreateCape(v,true)
			print("dicks")
		end
	end
end)


function CreateCape(ply,overridecape)	
	if IsValid(ply.__cape) and overridecape then
		ply.__cape:Remove()
	end
	
	ply.__cape=ClientsideRagdoll("models/props_c17/FurnitureMattress001a.mdl" )
	
	ply.__cape:SetNoDraw(false)
	ply.__cape:SetPos(ply:EyePos())
	ply.__cape:DrawShadow(true)
	ply.__cape:Spawn()
	ply.__cape:SetOwner(ply)
	ply.__cape:SetCollisionGroup(COLLISION_GROUP_INTERACTIVE)
	--ply.__cape:SetMaterial("models/props_c17/frostedglass_01a")
	
	ply.__cape:SetMaterial("models/debug/debugwhite")
	for i=0,ply.__cape:GetPhysicsObjectCount()-1 do
		local phys=ply.__cape:GetPhysicsObjectNum( i )
		if not phys then continue end
		phys:SetPos(ply:EyePos())
		phys:SetMass(1)
	end

	--quick hack to get the colors working because I couldn't be arsed otherwise
	ply.__cape.RenderOverride=function(self)
		if not IsValid(self:GetOwner()) then return end
		
		self:SetPos(self:GetOwner():GetPos())
		

		--I checked the main code, this isn't expensive at all, it actually checks if the shadow is valid
		--and it doesn't recreate it everyframe
		
		
		local ply=self:GetOwner()
		local ragd=ply.__cape
		local ent=ply
		
		if not ply:Alive() and IsValid(ply:GetRagdollEntity()) then
			ent=ply:GetRagdollEntity()
		end
		
		--here we are going to check if a few bones are really far away from the main cape, if they are teleport them
		

		
		
		self:PhysWake()
		local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine2"))
		if not matrix then return end
		local pos = matrix:GetTranslation()
		if not pos then return end
		local ang = matrix:GetAngles()
		if not ang then return end

		pos,ang=LocalToWorld(p,a,pos,ang)
		
		for i=0,self:GetPhysicsObjectCount()-1 do
			local phys=self:GetPhysicsObjectNum( i )
			--UpdateShadow( vecOrigin, vec3_angle, true, TICK_INTERVAL * 2.0f );
			--
			if not phys or i==4 or i==5 then continue end
			
			if pos:Distance(phys:GetPos())>500 then
				phys:SetPos(ply:EyePos())
				--phys:UpdateShadow(ply:EyePos(),Angle(0,0,0),0)
			end
		end
		
		local phys = self:GetPhysicsObjectNum( 4 )
		if not phys then return end
		phys:EnableGravity(false)
		phys:SetMass(5000)
		phys:SetPos(pos)
		phys:SetAngles(ang)
		--phys:UpdateShadow(pos,ang,0)
		phys:Wake()
		
		local phys = self:GetPhysicsObjectNum( 5 )
		if not phys then return end
		phys:EnableGravity(false)
		phys:SetMass(5000)
		phys:SetPos(pos)
		phys:SetAngles(ang)
		--phys:UpdateShadow(pos,ang,0)
		phys:Wake()
				
		self:CreateShadow()
		
		if self:GetOwner():GetNoDraw() then 
			self:DestroyShadow()
			return 
		end
		
		
		if self:GetOwner()==LocalPlayer() then
			if not self:GetOwner():ShouldDrawLocalPlayer() and not ent:IsRagdoll() then 
				--destroy the shadow unless we have the drawownshadow or fucking something
				self:DestroyShadow()
				return 
			end
		end
	
		local col=self:GetOwner():GetPlayerColor()
		
		local r,g,b=render.GetColorModulation()
		render.SetColorModulation( r*(0.25)+col.x,g*(0.25)+col.y,b*(0.25)+col.z )
		self:DrawModel()
		render.SetColorModulation( r,g,b )
	end
	
	--needed, it's the main thing that prevents the attachments from spazzing out
	ply.__cape:AddCallback("BuildBonePositions",function(self,bone1,physbone)
		if not IsValid(self:GetOwner()) then return end
		
		for i=0,self:GetBoneCount()-1 do
			--main attachments, shrink them more
			if i==2 or i==1 then
				local ply=self:GetOwner()
				local ent=ply
			
				if not ply:Alive() and IsValid(ply:GetRagdollEntity()) then
					ent=ply:GetRagdollEntity()
				end
		
				local matrix = ent:GetBoneMatrix(ent:LookupBone("ValveBiped.Bip01_Spine2"))
				if not matrix then continue end
				local pos = matrix:GetTranslation()
				if not pos then continue end
				local ang = matrix:GetAngles()
				if not ang then continue end
				
				pos,ang=LocalToWorld(p,a,pos,ang)
				
				self:ManipulateBoneScale(i,Vector(0.4,0.1,0.7))
				
				local bm=self:GetBoneMatrix(i)
				bm:SetAngles(ang)
				bm:SetTranslation(pos)
				self:SetBoneMatrix(i,bm)
			else
				--rest of the cape
				self:ManipulateBoneScale(i,Vector(0.6,0.05,0.7))
			end
		end
	end)
end

hook.Add("PostPlayerDraw","CapeDrawFailSafe",function(ply)
	if IsValid(ply.__cape) then
		ply.__cape:SetPos(ply:GetPos())
		ply.__cape:DrawModel()
	end
end)