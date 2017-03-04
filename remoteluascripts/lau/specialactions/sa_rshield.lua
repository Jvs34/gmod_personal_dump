

newsa=nil
newsa=SA:New("Energy shield","sa_rshield","An energy shield, when those faggots keep pissing you off")
if CLIENT then
	multimodel.Register("sa_rshield", {
		{
			transform = {Vector(3,-4.5,0),Angle(0,0,0),Vector(1,1,1)},
			children = {
				{
					model = "models/props_lab/reciever01b.mdl",
					transform = {Vector(0, 0, 0), Angle(0,-90,90), Vector(0.25,0.4,1)},
				},
				{
					model = "models/Items/car_battery01.mdl",
					transform = {Vector(-5, 0, 0), Angle(0,90,90), Vector(1,1,1)/3},
				},
				{
					model = "models/props_lab/powerbox02d.mdl",
					transform = {Vector(3, 0, 0), Angle(0,0,0), Vector(1.2,0.65,1.3)/3},
				},
				{
					model = "models/props_lab/powerbox03a.mdl",
					transform = {Vector(0,0,-4), Angle(90,90,0), Vector(0.3,0.7,0.5)},
				},
				--
			},
		},
	})
	
	local EFFECT={}
	EFFECT.Mat=Material("effects/combinemuzzle2_nocull")
	EFFECT.FadeTime=0.3
	EFFECT.Color=Color(255,255,255,255)
    function EFFECT:Init( data )
        self.Player = data:GetEntity()
		self:SetPos(self.Player:GetPos())
		self:SetAngles(self.Player:GetAngles())
		self:SetParent(self.Player)
		
		
		self.HitPos=data:GetOrigin()
		local ppos,a=LocalToWorld(self.Player:OBBCenter(),angle_zero,self.Player:GetPos(),angle_zero)
		
		
		self.HitNormal=(ppos-self.HitPos):GetNormal()
		
		
		self.DieTime=CurTime()+self.FadeTime
		self.StartTime=CurTime()
	end
    function EFFECT:Think()
		return (self.DieTime > CurTime() and IsValid(self.Player))
	end
    function EFFECT:Render() 
		if not IsValid(self.Player) or not self.Player:Alive() then return end
		local size=Lerp(math.TimeFraction(self.StartTime,self.DieTime, CurTime() ),32,64)
		local alpha=Lerp(math.TimeFraction(self.StartTime,self.DieTime, CurTime() ),255,0)
		self.Color.a=alpha
		
		local p,a=LocalToWorld(self.Player:OBBCenter(),angle_zero,self.Player:GetPos(),angle_zero)
		
		local hitpos,_a=LocalToWorld(self.HitNormal*-37,angle_zero,p,a)
		
		
		render.SetMaterial(self.Mat)
		render.DrawQuadEasy( hitpos, self.HitNormal, size,size, self.Color, 0 )
	end
	effects.Register(EFFECT,"sashieldhit",true)

end


newsa.CooldownBeforeRecharge=4
newsa.MaxShield=400
newsa.ChargeRate=100
function newsa:Initialize(entity,owner)
	if CLIENT then
		entity.mm=multimodel.CreateInstance("sa_rshield")
	end
	entity.suitsound=CreateSound(entity,"SuitRecharge.ChargingLoop")
	
	--the shield will be recharged by its 5% every half second
	--ActionFloat1 is the shield's current cooldown
	--NextAction is the shield's current next recharge
	--CooldownBeforeRecharge is the cooldown that will be added whenever the user gets hit
	--ActionInt2 is the current shield value
	--ActionInt3 is the max shield capacity
	
end


function newsa:Deinitialize(entity,owner)
	if entity.suitsound then
		entity.suitsound:Stop()
	end
end


function newsa:Think(entity,owner)
	--entity:SetActionBool1(owner:KeyDown(entity:GetKey()))
	if SERVER then
		if entity:GetActionInt2() > 1 then
			owner:SetBloodColor(-1)
		else
			owner:SetBloodColor(BLOOD_COLOR_RED)
		end
	end
	
	if entity:GetActionInt2() < entity:GetActionInt3() and entity:GetActionFloat1() < CurTime() then
		if entity.suitsound then
			local extrapitch=Lerp(entity:GetActionInt2()/entity:GetActionInt3(),0,40)
			entity.suitsound:PlayEx(0.6,60+extrapitch)
		end
	else
		if entity.suitsound then
			entity.suitsound:Stop()
		end
	end
	
	--the shield will be recharged by its 5% every half second
	--ActionFloat1 is the shield's current cooldown
	--NextAction is the shield's current next recharge
	--CooldownBeforeRecharge is the cooldown that will be added whenever the user gets hit
	--ActionInt2 is the current shield value
	--ActionInt3 is the max shield capacity
	
	if entity:GetActionInt2() < entity:GetActionInt3() and entity:GetActionFloat1()<CurTime() then
		local current=entity:GetActionInt2()
		local add=(entity:GetActionInt3()/self.ChargeRate)*((entity:GetActionInt3()/self.ChargeRate)*0.1)
		local finaladd=math.Clamp(current+add,0,entity:GetActionInt3())
		entity:SetActionInt2(math.Round(finaladd))
		
		if entity:GetActionInt2() == entity:GetActionInt3() then
			owner:EmitSound("AlyxEMP.Charge",30)
		end
	end
	
	--[[
	if entity:GetActionInt2() < entity:GetActionInt3() then
		
		
		if entity:GetActionFloat1() < CurTime() and entity:GetNextAction() < CurTime() then
			
			
			--cooldown's done, let's recharge it
			local amount=(entity:GetActionInt3()*10)/100
			if amount + entity:GetActionInt2() >= entity:GetActionInt3() then
				if SERVER then
					entity:SetActionInt2(entity:GetActionInt3())
				end
				owner:EmitSound("AlyxEMP.Charge",30)
			else
				if SERVER then
					entity:SetActionInt2(entity:GetActionInt2()+amount)
				end
			end
			if SERVER then
				entity:SetNextAction(CurTime() + 1)
			end
		end
	end
	]]
end


function newsa:OnOwnerTakesDamage(entity,owner,dmginfo)
	if dmginfo:IsFallDamage() then return end --fuck fall damage
	if dmginfo:IsDamageType(DMG_SHOCK) then return end	--let the shock damage trough
	

	entity:SetActionFloat1(CurTime() + self.CooldownBeforeRecharge)	
	if entity:GetActionInt2() > 0 then
		local effectdata = EffectData()
		effectdata:SetEntity(owner)
		effectdata:SetOrigin( dmginfo:GetDamagePosition() )
		util.Effect( "sashieldhit", effectdata )	--sashieldexplode	--sashieldhit
	else
		--let the damage pass trough
		return
	end

	if dmginfo:GetDamage() >= entity:GetActionInt2() then
		local dmg=dmginfo:GetDamage()
		dmginfo:SetDamage(dmg-entity:GetActionInt2())
		entity:SetActionInt2(0)
	else
		local dmg=dmginfo:GetDamage()
		dmginfo:SetDamage(0)
		entity:SetActionInt2(entity:GetActionInt2()-dmg)
	end
	
	if entity:GetActionInt2() > 0 then
		owner:EmitSound("NPC_CombineBall.Impact")
	else
		owner:EmitSound("NPC_CombineBall.Explosion")
	end
end

function newsa:ResetVars(entity,owner)
	entity:SetActionFloat1(CurTime())
	entity:SetNextAction(CurTime())
	entity:SetActionBool1(false)
	
	entity:SetActionInt2(self.MaxShield)
	entity:SetActionInt3(self.MaxShield)
	
	if entity.suitsound then
		entity.suitsound:Stop()
	end
end

function newsa:GetShieldPercent(entity,owner)
	return entity:GetActionInt2()/entity:GetActionInt3()
end


if CLIENT then
	newsa.Mat=Material("models/props_combine/stasisshield_sheet")
	newsa.NewMat= CreateMaterial("NewShieldEffect"..CurTime(),
		"Refract",{
			[ '$model' ] = "1",
			[ '$nocull' ] = "1",
			
			[ '$translucent' ] = "1",
			[ '$refractamount' ] = "0.2",
			[ '$refracttint' ] = "[0.7 1 1]",
			
			[ '$dudvmap' ] = "dev/water_dudv",
			[ '$normalmap' ] = "dev/water_normal",
			
			[ '$surfaceprop' ] = "water",
			[ '$bumpframe' ] = "0",
			[ 'Proxies']={
			}
			
		}
	)
	
	--[[
	PlayerColor
		{
			resultVar	$color2
			default		0.1 0.1 0.1
		}
	]]
end

function newsa:DrawShield(entity,owner,isvm)
	if entity:GetActionInt2() > 0 then
		owner:RemoveAllDecals()
		local p,a=LocalToWorld(owner:OBBCenter(),angle_zero,owner:GetPos(),angle_zero)
		render.UpdateRefractTexture()
		
		local refractlerp=Lerp(self:GetShieldPercent(entity,owner),0,0.3)
		
		
		
		local plycolor=owner:GetPlayerColor()*refractlerp +Vector(0.7,0.7,0.7)
		
		if isvm then
			refractlerp=0.05
		end
		
		self.NewMat:SetFloat("$refractamount",refractlerp)
		self.NewMat:SetVector("$refracttint",plycolor)
		render.SetMaterial( self.NewMat )
		render.DrawSphere( p, 40, 20, 20, self.ShieldColor )
		self.NewMat:SetFloat("$refractamount",	0.2)
		self.NewMat:SetVector("$refracttint",Vector(0.7,1,1))
	end
end

function newsa:PostDrawViewModel(entity,owner,weapon,viewmodel)
	--self:DrawShield(entity,owner,true)
end

function newsa:DrawWorldModel(entity,owner)
	self:DrawShield(entity,owner)
	
	local bone=owner:LookupBone("ValveBiped.Bip01_Spine2")
	if not bone then return end
	local matrix = owner:GetBoneMatrix(bone)
	if not matrix then return end
	local pos = matrix:GetTranslation()
	if not pos then return end
	local ang = matrix:GetAngles()
	if not ang then return end
	if not entity.mm then return end
	multimodel.Draw(entity.mm,owner,{origin=pos,angles=ang})
end

function newsa:HUDDraw(entity,owner)
	local fuel=(self:GetShieldPercent(entity,owner))*100--math.Round
	local x=ScrW()/2
	local y=ScrH()-(ScrH()/10)
	local maxw=ScrW()/4
	local maxh=ScrH()/25
	surface.SetDrawColor( 0,0,255,255 )
	surface.DrawRect( x-(maxw/2), y, maxw, maxh )
	
	surface.SetDrawColor( 0,250,255,255 )
	surface.DrawRect( x-(maxw/2), y, (maxw *fuel)/100, maxh )
end
