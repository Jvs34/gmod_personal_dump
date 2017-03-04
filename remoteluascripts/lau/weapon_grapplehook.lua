local SWEP={}


if CLIENT then
language.Add("weapon_grapplehook","Grapple Hook")
multimodel.Register("GrappleHook", {
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

multimodel.Register("Hook", {
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


multimodel.Register("nade-can", {
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
SWEP.Spawnable                 = true
SWEP.AdminOnly          = true

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
	
	hook.Remove("PreDrawViewModel", "DRPPreDrawViewModel")
	
	function SWEP:DrawWorldModel()
		self:DrawGrappleHook(false)
	end
	
	function SWEP:DrawWorldModelTranslucent()
		self:DrawGrappleHook(false)
	end
	
	function SWEP:CreateMultiModels()
		self.MMHook=multimodel.CreateInstance("Hook")
		self.MMGrappleHook=multimodel.CreateInstance("GrappleHook")
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
		multimodel.DoFrameAdvance(self.MMGrappleHook, CurTime(), self)
		multimodel.Draw(self.MMGrappleHook,self,{origin=pos,angles=ang})
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
		multimodel.DoFrameAdvance(self.MMHook, CurTime(), self)
		multimodel.Draw(self.MMHook,self,{origin=grapplepos or Vector(0,0,0),angles=grappleang or Angle()})
	end
	
	function SWEP:FireAnimationEvent(pos, ang, event, options)
		return true
	end

end

function SWEP:StupidSPFix(FunctName)
end

function SWEP:PrimaryAttack()
	self:StupidSPFix("PrimaryAttack")
	if self.dt.NextGrapple>=CurTime() or self.dt.IsAttached then return end
	--we check if NextGrapple<CurTime()

	
	--do a trace, make it only hit the world, if it didn't, do nothing
	self.Owner:LagCompensation(true)
	local tr=self:DoGrappleTrace()
	self.Owner:LagCompensation(false)
	if --[[tr.HitWorld and ]] not tr.HitSky and tr.Hit then
		local len=(self.Owner:EyePos():Distance(self.dt.AttachedTo))/10000
		local timetoreach=Lerp(tr.Fraction,0.1,2.5)
		
		self.dt.AttachedTo=tr.HitPos
		self.dt.AttachTime=CurTime()+timetoreach
		self.dt.AttachStart=CurTime()
		--if it did, then set AttachedTo to the hitpos, calculate the delay from the distance between eyepos and hitpos and add it with CurTime() on AttachTime
		self.dt.IsAttached=true
		self.LaunchSound:Play()
		self.LaunchSound:ChangeVolume(4,0)
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
			self.ReelSound:ChangePitch(200,0)
			self.ReelSound:ChangeVolume(0.3,0)
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
	--tr.mask=MASK_SOLID_BRUSHONLY
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
				data:SetVelocity(wep:GetDirection()*1000)
			else
				--sorry, go suck a dick
				data:SetVelocity(data:GetVelocity()+wep:GetDirection()*1000*FrameTime())
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


weapons.Register(SWEP,"weapon_grapplehook",true)