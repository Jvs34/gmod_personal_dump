
newsa=nil
newsa=SA:New("Shoulder mounted Laser","sa_laser","Imma firing ma- nah fuck off")

if CLIENT then
local arm_angle_1 = 45
local arm_angle_2 = 60
local arm_angle_3 = 45
-- it's the same as the one from the rocket launcher
local sa_rocket_laserglow = CreateMaterial("sa_rocket_laserglow","UnlitGeneric",{
	["$basetexture"] = "sprites/light_glow02",
	["$nocull"] = 1,
	["$additive"] = 1,
	["$vertexalpha"] = 1,
	["$vertexcolor"] = 1,
	["$spriterendermode"] = RENDERMODE_GLOW,
})

local sa_laser_color = Color(150, 200, 255, 255)

local sa_laser_dotlight = {
	{
		model = "models/props_c17/light_domelight02_on.mdl",
		transform = {Vector(0, 0, -40), Angle(0,0,0), Vector(0.5,0.5,0.5)},
		color = sa_laser_color,
	},
	{
		transform = {Vector(0,0,-43),Angle(0,0,0),Vector(40,40,40)},
		sprite = sa_rocket_laserglow,
		color = sa_laser_color,
		translucent = true,
	},
}

local sa_lasercannon_body = {
	{
		-- main body
		model = "models/props_wasteland/laundry_basket001.mdl",
		transform = {Vector(11.5, -0.3, 0), Angle(0,90,0), Vector(0.48,0.48,0.3)},
		
		-- circular lights
		children = {
			{
				transform = {Vector(0, 0, 0), Angle(90,45,0), Vector(1,1,1)},
				children = sa_laser_dotlight,
			},
			{
				transform = {Vector(0, 0, 0), Angle(90,45+90,0), Vector(1,1,1)},
				children = sa_laser_dotlight,
			},
			{
				transform = {Vector(0, 0, 0), Angle(90,45+180,0), Vector(1,1,1)},
				children = sa_laser_dotlight,
			},
			{
				transform = {Vector(0, 0, 0), Angle(90,45-90,0), Vector(1,1,1)},
				children = sa_laser_dotlight,
			},
		},
	},
	{
		-- back
		model = "models/props_wasteland/light_spotlight02_lamp.mdl",
		transform = {Vector(11.5, -0.5, 10), Angle(90,90,0), Vector(1,2.5,2.5)},
		color = Color(230, 210, 190, 255),
	},
	{
		-- barrel
		model = "models/props_wasteland/buoy01.mdl",
		transform = {Vector(11.5, -0.5, -15), Angle(180,90,0), Vector(0.4,0.4,0.2)},
		children = {
			{
				model = "models/props_wasteland/coolingtank02.mdl",
				transform = {Vector(0, 0, 20), Angle(0,90,0), Vector(0.2,0.2,0.32)},
				color = sa_laser_color,
				selfillum = true,
			},
			{
				model = "models/props_rooftop/roof_vent001.mdl",
				transform = {Vector(0, 0, 82), Angle(0,90,0), Vector(1.5,1.5,1.5)},
			},
			{
				model = "models/hunter/tubes/circle2x2.mdl",
				transform = {Vector(0, 0, 146), Angle(0,0,0), Vector(0.1,0.1,0.1)},
				outputname="laser_muzzle",
				material = "models/debug/debugwhite",
				color = sa_laser_color,
				selfillum = true,
			},
			{
				transform = {Vector(0,0,150),Angle(0,0,0),Vector(40,40,40)},
				sprite = sa_rocket_laserglow,
				color = sa_laser_color,
				translucent = true,
			},
		},
	},
	
	-- barrel glow
	{
		transform = {Vector(11.5,-0.5,-18),Angle(0,0,0),Vector(40,40,40)},
		sprite = sa_rocket_laserglow,
		color = sa_laser_color,
		translucent = true,
	},
	{
		transform = {Vector(11.5,-0.5,-24),Angle(0,0,0),Vector(40,40,40)},
		sprite = sa_rocket_laserglow,
		color = sa_laser_color,
		translucent = true,
	},
	{
		transform = {Vector(11.5,-0.5,-30),Angle(0,0,0),Vector(40,40,40)},
		sprite = sa_rocket_laserglow,
		color = sa_laser_color,
		translucent = true,
	},
}

local sa_lasercannon = {
	{
		transform = {Vector(0,0,0), Angle(200,0,0), Vector(1,1,1)},
		children = {
			{
				transform = {Vector(-5.4,-2,-2.2),Angle(60,90,0),Vector(1,1,1)},
				children = {
					{
						-- front plate
						model = "models/props_combine/combine_barricade_med01a.mdl",
						transform = {Vector(0, 0, 0), Angle(0,0,0), Vector(0.07,0.07,0.07)},
					},
					{
						-- back plate
						model = "models/props_combine/combine_emitter01.mdl",
						transform = {Vector(-2, 0, 0), Angle(100,180,0), Vector(0.3,0.2,0.3)},
					},
					{
						-- main axis
						model = "models/props_pipes/valve001.mdl",
						transform = {Vector(-1, 0, 6), Angle(180,0,0), Vector(0.18,0.18,0.18)},
						children = {
							{
								-- right arm
								model = "models/props_wasteland/gear02.mdl",
								transform = {Vector(0, -6, 7), Angle(-arm_angle_1,180,0), Vector(2,2,2)},
								children = {
									{
										model = "models/props_trainstation/pole_448Connection002b.mdl",
										transform = {Vector(0, 2, -10), Angle(0,90,180), Vector(0.06,0.06,0.06)},
										material = "models/props_pipes/GutterMetal01a",
									},
									{
										model = "models/props_wasteland/gear02.mdl",
										transform = {Vector(0, 0, -25), Angle(-arm_angle_2,0,0), Vector(1,1,1)},
										children = {
											{
												model = "models/props_trainstation/pole_448Connection002b.mdl",
												transform = {Vector(0, 2, -10), Angle(0,90,180), Vector(0.06,0.06,0.06)},
												material = "models/props_pipes/GutterMetal01a",
											},
											{
												model = "models/props_wasteland/gear02.mdl",
												transform = {Vector(0, 0, -25), Angle(-arm_angle_3,0,0), Vector(1,1,1)},
											},
											{
												-- laser cannon
												transform = {Vector(3, -1.9, -25), Angle(0,0,0), Vector(1,1,1)},
												children = sa_lasercannon_body,
											},
										}
									},
								}
							},
							{
								-- left arm
								model = "models/props_wasteland/gear02.mdl",
								transform = {Vector(0, 4, 7), Angle(arm_angle_1,0,0), Vector(2,2,2)},
								children = {
									{
										model = "models/props_trainstation/pole_448Connection002b.mdl",
										transform = {Vector(0, 2, -10), Angle(0,90,180), Vector(0.06,0.06,0.06)},
										material = "models/props_pipes/GutterMetal01a",
									},
									{
										model = "models/props_wasteland/gear02.mdl",
										transform = {Vector(0, 0, -25), Angle(arm_angle_2,0,0), Vector(1,1,1)},
										children = {
											{
												model = "models/props_trainstation/pole_448Connection002b.mdl",
												transform = {Vector(0, 2, -10), Angle(0,90,180), Vector(0.06,0.06,0.06)},
												material = "models/props_pipes/GutterMetal01a",
											},
											{
												model = "models/props_wasteland/gear02.mdl",
												transform = {Vector(0, 0, -25), Angle(arm_angle_3,0,0), Vector(1,1,1)},
											},
										}
									},
								}
							},
						},
					},
				},
			},
		},
	},
}

multimodel.Register("sa_lasercannon", sa_lasercannon)

--[[
-- you can do this instead if the model is never going to be animated, makes rendering a bit faster

multimodel.Register("sa_lasercannon", multimodel.Flatten(sa_lasercannon))
]]


--[[
-- this draws the opaque part of the model, and then the translucent part, making sure that all the
-- glows and shit render in front of everything else
-- FAGGOT

multimodel.Draw(entity.mm,owner,{origin=pos,angles=ang,rendergroup=RENDERGROUP_OPAQUE})
multimodel.Draw(entity.mm,owner,{origin=pos,angles=ang,rendergroup=RENDERGROUP_TRANSLUCENT})

]]

	local da_centerglow = CreateMaterial("sa_muzzlecore",
				"UnlitGeneric",{
					['$basetexture' ] = "sprites/physcannon_bluecore1b",//"effects/fluttercore"
					[ '$additive' ] = "1",
					[ '$vertexcolor' ] = "1",
					[ '$vertexalpha' ] = "1",
				}
	)
	local da_beam =CreateMaterial("laserbem",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/laserbeam",//"sprites/physcannon_bluelight1b",
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
	//effect register
    local EFFECT={}
    EFFECT.Mat = da_beam
    EFFECT.DieT=0.1
    EFFECT.Color=Color(100,160,255,255)
	/*---------------------------------------------------------
       Init( data table )
    ---------------------------------------------------------*/
    function EFFECT:Init( data )
		self.Size=20
        self.EndPos     = data:GetOrigin()
		
		--self.Atchpos  = data:GetStart()
		--[[
		if self.Atchpos==vector_origin then
			self.Atchpos=nil
		end
		]]
		
        self.Ent =    data:GetEntity()
        if not IsValid(self.Ent) then return end
		self:SetRenderBoundsWS( self.Ent:GetPos(), self.EndPos )
        self.DieTime = CurTime() + self.DieT
        self.StartTime = CurTime()
     
		 local effectdata = EffectData()
            effectdata:SetOrigin( self.EndPos )
            effectdata:SetMagnitude( 3 )
            effectdata:SetScale( data:GetScale()/20 )
            effectdata:SetRadius( 30 )
        util.Effect( "Sparks", effectdata )
	 
		local emitter = ParticleEmitter(self.EndPos )
        local particle = emitter:Add("effects/blueflare1.vtf",self.EndPos)
        particle:SetVelocity(Vector(0,0,0))
        particle:SetLifeTime(0)
        particle:SetDieTime(self.DieT)
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(255)
        particle:SetStartSize(24+self.Size)
        particle:SetEndSize(0)
        particle:SetRoll( math.random( 0, 360 ))
        particle:SetRollDelta( 0.0 )
        particle:SetColor( self.Color.r, self.Color.g, self.Color.b )
        emitter:Finish()    

        local dlight = DynamicLight( self:EntIndex() )
        if ( dlight ) then
            dlight.r = self.Color.r
            dlight.g = self.Color.g
            dlight.b = self.Color.b
            dlight.Pos =  self.EndPos
            dlight.Brightness = 4
            dlight.Size =100
            dlight.Decay = 100
            dlight.DieTime = CurTime() + self.DieT
        end
    end

    /*---------------------------------------------------------
       THINK
    ---------------------------------------------------------*/
    function EFFECT:Think( )

        if ( CurTime() > self.DieTime and IsValid(self.Ent) ) then return false
        end
        return true

    end

    /*---------------------------------------------------------
       Draw the effect
    ---------------------------------------------------------*/
    function EFFECT:Render( )
        if(not IsValid(self.Ent))then return end
		local ent=self.Ent
		if not ent.LaserAtch or not ent.LaserAtch.laser_muzzle then return end
		
		local attachment=ent.LaserAtch.laser_muzzle
		
		if !attachment then return end
		
		if self.Ent==LocalPlayer() and not self.Ent:ShouldDrawLocalPlayer() then
			attachment.pos=FormatViewModelAttachment(attachment.pos,EyePos(),EyeAngles())
		end
		
		--if not self.Atchpos then
			self.Atchpos=attachment.pos
		--end
		
		local size=Lerp(math.TimeFraction(self.StartTime,self.DieTime, CurTime() ),self.Size,self.Size/4)
		
		local alphadecay=Lerp(math.TimeFraction(self.StartTime,self.DieTime, CurTime() ),255,120)
		
		self.Color.a=alphadecay
		
		render.SetMaterial(self.Mat)
		
		
		
		
		
		render.DrawBeam(self.Atchpos,self.EndPos,size,1,0,self.Color )
        render.SetMaterial(da_centerglow)
		render.DrawSprite(self.EndPos,size,size,self.Color)
		render.DrawSprite(self.Atchpos,size,size,self.Color)
		                            
    end
    effects.Register(EFFECT,"salaserbeam")


end

function newsa:Initialize(entity,owner)
	if CLIENT then
		entity.mm=multimodel.CreateInstance("sa_lasercannon")
	end
	entity.chargesound=CreateSound(entity,"SuitRecharge.ChargingLoop")
	
end


function newsa:Deinitialize(entity,owner)
	if entity.chargesound then
		entity.chargesound:Stop()
	end
end



newsa.NextAttackDelay=1
newsa.MaxCharge = 100	--equals to max damage too in this case
newsa.ChargeRate = 5	--reach 100 in 5 seconds
newsa.MaxPenetration = 3
function newsa:ResetVars(entity,owner)
	entity:SetActionBool1(false)	--charging
	entity:SetActionFloat1(CurTime()+self.NextAttackDelay)
	entity:SetActionFloat2(0)	--charge
end

function newsa:HUDDraw(entity,owner)
	local fuel=(entity:GetActionFloat2())--math.Round
	local x=ScrW()/2
	local y=ScrH()-(ScrH()/10)
	local maxw=ScrW()/4
	local maxh=ScrH()/25
	surface.SetDrawColor( 0,0,255,255 )
	surface.DrawRect( x-(maxw/2), y, maxw, maxh )
	
	surface.SetDrawColor( 0,250,255,255 )
	surface.DrawRect( x-(maxw/2), y, (maxw *fuel)/100, maxh )
end

function newsa:Attack(entity,owner)

end

function newsa:Think(entity,owner)
	entity:SetActionBool1(entity:IsKeyDown() and entity:GetActionFloat1()<CurTime())

	if entity:IsKeyDown() and entity:GetActionFloat1()<CurTime() then
		--we're clearly charging, do it if we can
		
		--we need to charge for self.MaxCharge/self.ChargeRate every second

		if entity.chargesound then
			local extrapitch=Lerp(entity:GetActionFloat2()/self.MaxCharge,0,50)
			entity.chargesound:PlayEx(0.6,100+extrapitch)
		end
		
		if entity:GetActionFloat2() < self.MaxCharge then
			local current=entity:GetActionFloat2()
			local add=(self.MaxCharge/self.ChargeRate)*((self.MaxCharge/self.ChargeRate)*engine.TickInterval())
			local finaladd=math.Clamp(current+add,0,self.MaxCharge)
			entity:SetActionFloat2(finaladd)
			
		end
		
	else
		if entity.chargesound then
			entity.chargesound:Stop()
		end
		if entity:GetActionFloat2()>0 then
			--release the shot, reset vars and add a cooldown
			local tr=nil
			
			
			--for i=0,2 do 
			tr=self:DoLaserTrace(entity,owner,owner:GetShootPos(),owner:GetAimVector())
			
			
			if IsFirstTimePredicted() then
				local effectdata = EffectData()
				effectdata:SetEntity(owner)
				effectdata:SetScale(entity:GetActionFloat2())
				--effectdata:SetStart( owner:GetShootPos() )
				effectdata:SetOrigin( tr.HitPos )
				util.Effect( "salaserbeam", effectdata )
				owner:EmitSound("PropJeep.FireCannon")
			end
			--end
			
			if tr.Hit then
				local punchlerp=Lerp(entity:GetActionFloat2()/self.MaxCharge,0,10)
				owner:ViewPunch(Angle(-punchlerp,0,0))
			end
			
			
			if SERVER and IsValid(tr.Entity) then
				self:LaserTraceCallback(entity,owner,tr.Entity)
			end
			
			
			
			entity:SetActionFloat2(0)
			entity:SetActionFloat1(CurTime()+self.NextAttackDelay)
	
		end
		
	end


end

function newsa:LaserTraceCallback(entity,owner,hitent)
	if SERVER then
		if not IsValid(hitent) then return end
		local dmgnf=DamageInfo()
		local dmg=5+Lerp(entity:GetActionFloat2()/self.MaxCharge,5,105)
		dmgnf:SetAttacker(owner)
		dmgnf:SetDamage(dmg)
		dmgnf:SetInflictor(entity)
		dmgnf:SetDamageType(DMG_SHOCK)
		dmgnf:SetDamagePosition(owner:GetShootPos())
		dmgnf:SetDamageForce(owner:GetAimVector() * dmg * 20)
		hitent:TakeDamageInfo(dmgnf)
	end
end

function newsa:DoLaserTrace(entity,owner,pos,normal)
	local tracedata = {}
	tracedata.start = pos
	tracedata.endpos = pos + ( normal * 16000 )
	tracedata.mins =  Vector( -4, -4, -4 )
	tracedata.maxs =  Vector( 4, 4, 4 )
	
	local curpenetration=1
	
	if (entity:GetActionFloat2()/self.MaxCharge)>= 0.5 then
		tracedata.ignoreworld=true
		tracedata.filter = function(ent)
			if ent==owner then 
				return false
			end
			if IsValid(ent) and curpenetration < self.MaxPenetration then
				self:LaserTraceCallback(entity,owner,ent)
				curpenetration=curpenetration+1
				return false
			end
			return true
		end
	else
		tracedata.filter = owner
	end

	
	owner:LagCompensation(true)
	local tr = util.TraceHull( tracedata )
	owner:LagCompensation(false)
	return tr
end

function newsa:DrawWorldModel(entity,owner)
	local bone=owner:LookupBone("ValveBiped.Bip01_L_Clavicle")
	if not bone then return end
	local matrix = owner:GetBoneMatrix(bone)
	if not matrix then return end
	local pos = matrix:GetTranslation()
	if not pos then return end
	local ang = matrix:GetAngles()
	if not ang then return end
	if not entity.mm then return end
	
	if not owner.LaserAtch then
		owner.LaserAtch = {}
	end
	
	multimodel.SetOutputTarget(owner.LaserAtch)
	multimodel.Draw(entity.mm,owner,{origin=pos,angles=ang})
	multimodel.SetOutputTarget(nil)
	self:DrawEffects(entity,owner)
end

newsa.offpos=Vector(2,8,-8)
newsa.offang=Angle(0,70,100)


function newsa:PreDrawViewModel(entity,owner,weapon,viewmodel)
	if not entity.mm then return end
	local usevmforposition=false
	local pos=usevmforposition and viewmodel:GetPos() or owner:EyePos()
	local ang=usevmforposition and viewmodel:GetAngles() or owner:EyeAngles()
	
	if not owner.LaserAtch then
		owner.LaserAtch = {}
	end
	
	pos,ang=LocalToWorld(self.offpos,self.offang,pos,ang)
	multimodel.SetOutputTarget(owner.LaserAtch)
	multimodel.Draw(entity.mm,owner,{origin=pos,angles=ang})
	multimodel.SetOutputTarget(nil)
	self:DrawEffects(entity,owner)
end


if CLIENT then
	newsa.MuzzleParticle=CreateMaterial("sa_muzzlecore",
				"UnlitGeneric",{
					['$basetexture' ] = "sprites/physcannon_bluecore1b",//"effects/fluttercore"
					[ '$additive' ] = "1",
					[ '$vertexcolor' ] = "1",
					[ '$vertexalpha' ] = "1",
				}
	)
	newsa.Color=Color(100,160,255,255)
end
function newsa:DrawEffects(entity,owner)
	if entity:GetActionBool1() and owner.LaserAtch and owner.LaserAtch.laser_muzzle then
		render.SetMaterial(self.MuzzleParticle)
		local sizelerp=Lerp(entity:GetActionFloat2()/self.MaxCharge,0,4)
		local pos=owner.LaserAtch.laser_muzzle.pos
		render.DrawSprite(pos,2+sizelerp,2+sizelerp,self.Color)
	end
end
