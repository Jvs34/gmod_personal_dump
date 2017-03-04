local p=Vector(-5,-3,0)
local a=Angle(90,0,0)
--offsets
util.PrecacheModel("models/props_c17/FurnitureMattress001a.mdl")
 
for i,v in pairs(player.GetAll()) do
       
        if IsValid(v.rag) then
                v.rag:Remove()
        end
       
        v.rag=ClientsideRagdoll("models/props_c17/FurnitureMattress001a.mdl" )
       
        --v.rag:SetNoDraw(false)
        v.rag:SetParent(NULL)
        v.rag:SetPos(Vector(0,0,0))
        v.rag:Spawn()
        v.rag:SetOwner(v)
        v.rag:SetCollisionGroup(0)
        v.rag:SetMaterial("models/debug/debugwhite")
        for i=0,v.rag:GetPhysicsObjectCount()-1 do
                local phys=v.rag:GetPhysicsObjectNum( i )
                if not phys then continue end
                phys:SetPos(v:EyePos())
                phys:SetMass(1)
        end
 
        --quick hack to get the colors working because I couldn't be arsed otherwise
        v.rag.RenderOverride=function(self)
                if not IsValid(self:GetOwner()) then return end
               
                local col=v:GetPlayerColor()
               
                local r,g,b=render.GetColorModulation()
                render.SetColorModulation( r*(0.25)+col.x,g*(0.25)+col.y,b*(0.25)+col.z )
                self:DrawModel()
                render.SetColorModulation( r,g,b )
        end
       
        --needed, it's the main thing that prevents the attachments from spazzing out
        v.rag:AddCallback("BuildBonePositions",function(self,bone1,physbone)
                if not IsValid(self:GetOwner()) then return end
               
                for i=0,self:GetBoneCount()-1 do
                        --main attachments, shrink them more
                        if i==2 or i==1 then
                                local matrix = self:GetOwner():GetBoneMatrix(self:GetOwner():LookupBone("ValveBiped.Bip01_Spine2"))
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
                                self:ManipulateBoneScale(i,Vector(0.6,0.1,0.7))
                        end
                end
        end)
 
        v.rag:Activate()
end
 
 
hook.Add("PostPlayerDraw","CapeDraw",function(ply)
        if not IsValid(ply.rag) then return end
        ply.rag:DrawModel()
end)
 
hook.Add("UpdateAnimation","CapeThink",function( ply, velocity, maxseqgroundspeed )
       
        if not IsValid(ply.rag) then return end
       
        ply.rag:PhysWake()
        local matrix = ply:GetBoneMatrix(ply:LookupBone("ValveBiped.Bip01_Spine2"))
        if not matrix then return end
        local pos = matrix:GetTranslation()
        if not pos then return end
        local ang = matrix:GetAngles()
        if not ang then return end
 
        pos,ang=LocalToWorld(p,a,pos,ang)
       
       
        local phys = ply.rag:GetPhysicsObjectNum( 4 )
        if not phys then return end
        phys:EnableGravity(false)
        phys:SetPos(pos)
        phys:SetAngles(ang)
        phys:Wake()
       
        local phys = ply.rag:GetPhysicsObjectNum( 5 )
        if not phys then return end
        phys:EnableGravity(false)
        phys:SetPos(pos)
        phys:SetAngles(ang)
        phys:Wake()
       
end)