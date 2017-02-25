if (SERVER) then
    SWEP.AutoSwitchTo        = true
    SWEP.AutoSwitchFrom        = true
end


if ( CLIENT ) then
    SWEP.DrawAmmo            = true
    SWEP.PrintName            = "Can Nade"
    SWEP.Author                = "Jvs"
    SWEP.DrawCrosshair        = true
    SWEP.ViewModelFOV        = 54
    SWEP.RenderGroup = RENDERGROUP_BOTH
    SWEP.CSM=nil;

    function SWEP:DrawHUD()
    end
    
    function SWEP:ViewModelDrawn()
        self:DrawClientSideWeapon();
    end
    
    function SWEP:CreateCSM()
        if self.WeaponModel.Useless then return end
        if !self.CSM || !IsValid(self.CSM)then
            self.CSM = ClientsideModel( self.WeaponModel.Model, RENDER_GROUP_OPAQUE_ENTITY )
            self.CSM:SetNoDraw( true )
        end
    
    end
    
    function SWEP:CalculateOffset(pos,ang,off)
        local selfangle=ang// or Angle()
        local selfpos=pos// or Vector()
        local offset = selfangle:Right() * off.x + selfangle:Forward() * off.y + selfangle:Up() * off.z;
        local pos=selfpos + offset
        return pos
    end
    
    function SWEP:DrawWorldModel()
        if self.DontDrawCSM then return end
        if !IsValid(self:GetOwner()) then
            self:DrawModel();
        return 
        end
        if ( !self.m_hHands ) then
            self.m_hHands = self:GetOwner():LookupAttachment( "anim_attachment_RH" );
        end

        local hand = self:GetOwner():GetAttachment( self.m_hHands );
        if !hand then return end
        local offset = hand.Ang:Right() * self.HoldPos.x + hand.Ang:Forward() * self.HoldPos.y + hand.Ang:Up() * self.HoldPos.z;

        hand.Ang:RotateAroundAxis( hand.Ang:Right(),    self.HoldAng.x );
        hand.Ang:RotateAroundAxis( hand.Ang:Forward(),    self.HoldAng.y );
        hand.Ang:RotateAroundAxis( hand.Ang:Up(),        self.HoldAng.z );

        self.CSM:SetRenderOrigin( hand.Pos + offset )
        self.CSM:SetRenderAngles( hand.Ang )
        
        self.CSM:DrawModel();
    end
    
    
    function SWEP:DrawWorldModelTranslucent()
        self:DrawWorldModel()
    end
    
    function SWEP:DrawClientSideWeapon()
        if !self.CSM || !IsValid(self.CSM) || self.DontDrawCSM then return end
        local vm = self.Owner:GetViewModel()
        local matrix = vm:GetBoneMatrix(vm:LookupBone(self.WeaponModel.Bone))
        local pos = matrix:GetTranslation()
        local ang = matrix:GetAngle()
        self.CSM:SetRenderOrigin(self:CalculateOffset(pos,ang,self.WeaponModel.OffsetVector))
        ang:RotateAroundAxis(ang:Forward(),self.WeaponModel.OffsetAngle.y)
        ang:RotateAroundAxis(ang:Up(),self.WeaponModel.OffsetAngle.p)
        ang:RotateAroundAxis(ang:Right(),self.WeaponModel.OffsetAngle.r)
        self.CSM:SetRenderAngles(ang)
        if !self.WeaponModel.Useless then
            self.CSM:DrawModel();
        end
    end
    
    //effect created by Sakarias88
    local EFFECT={}
    
    function EFFECT:Init( data )
        self.Position = data:GetOrigin()    
        self.Speed = data:GetStart()
        self.Size = data:GetScale();
        local emitter = ParticleEmitter( self.Position )
            //for i=1, 100*self.Size do    
            for i=1, 200 do    
                local particle = emitter:Add( "effects/smoke", self.Position )
                    particle:SetVelocity( Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(-100,100))+(self.Speed*self.Size*4) )
                    particle:SetDieTime(1)
                    particle:SetStartAlpha(200)
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(math.random(self.Size,10+self.Size))
                    particle:SetEndSize( 0 )
                    particle:SetRoll( math.Rand( -10,10  ) )
                    particle:SetRollDelta(math.Rand( -0.2, 0.2 ))
                    particle:SetColor( 90, 60, 20)            
                    particle:SetGravity( Vector( 0, 0, -15*i ) )
                    particle:SetCollide( true )
                    particle:SetBounce( 0.2 )
            end            
        emitter:Finish()
    end
    function EFFECT:Think( )return false end
    function EFFECT:Render() end
    effects.Register(EFFECT,"SodaCan_Explode")
end

SWEP.CurrentAnim=nil;

SWEP.ACT_VM_DEPLOY={
    [1]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.7
    },
    [2]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.3,
        CallBack="ANIMATION_FINISHED"
    },
}

SWEP.ACT_VM_SHAKE_SHAKE_SHAKE={
    [1]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(7.8299999237061,-10.430000305176,33.909999847412),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.1,
    },
    [2]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(-18.260000228882,7.8299999237061,-36.520000457764),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.1,
        CallBack="CAN_SHAKE"
    },
    FrameLoop=1,
}

SWEP.ACT_VM_THROW_CAN={
    [1]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.1,
    },
    [2]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,-54.779998779297,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.1,
    },
    [3]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,26.090000152588,-36.520000457764),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(20.870000839233,-73.040000915527,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,-20.870000839233),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.1,
        DontDrawCSM=true,
        CallBack="CAN_THROW"
    },
    [4]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,0,0),
        Duration=0.7,
    },
    [5]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.0,
        CallBack="ANIMATION_FINISHED"
    },
}

SWEP.ACT_VM_IDLE={
    [1]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.5,
    },
    [2]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(11.430000305176,-38.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.5,
    },
    [3]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(9.430000305176,-40.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.5,
    },
    FrameLoop=1
}
SWEP.ACT_VM_DRINK={
    [1]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Finger1']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Finger0']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Hand']=Angle(0,0,0),
        Duration=0.3
    },
    [2]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Forearm']=Angle(-13.039999961853,0,20.870000839233),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,23.479999542236),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,-10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,-75.650001525879,0),
        ['ValveBiped.Bip01_L_Finger1']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Finger0']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Hand']=Angle(0,0,0),
        Duration=0.3,
        
    },
    [3]={
        ['ValveBiped.Bip01_L_Forearm']=Angle(-0,0,18.260000228882),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,23.479999542236),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(-2.6099998950958,-80.870002746582,0),
        ['ValveBiped.Bip01_L_Hand']=Angle(0,0,41.740001678467),
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,-10.430000305176,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_Finger1']=Angle(0,-20.870000839233,0),
        ['ValveBiped.Bip01_L_Finger0']=Angle(0,13.039999961853,0),
        Duration=0.2,
        CallBack="CAN_POP"
    },
    [4]={
        ['ValveBiped.Bip01_L_Forearm']=Angle(-0,0,18.260000228882),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-33.909999847412,23.479999542236),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(-13.039999961853,-86.089996337891,7.8299999237061),
        ['ValveBiped.Bip01_L_Hand']=Angle(0,0,41.740001678467),
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,-10.430000305176,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_Finger1']=Angle(0,-20.870000839233,0),
        ['ValveBiped.Bip01_L_Finger0']=Angle(0,15.64999961853,0),
        Duration=0.4
    },
    [5]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Finger1']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Finger0']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Hand']=Angle(0,0,0),
        Duration=0.5
    },
    [6]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,-56.25,3.210000038147),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(35.360000610352,-48.209999084473,3.210000038147),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Finger1']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Finger0']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Hand']=Angle(0,0,0),
        Duration=0.6,
        CallBack="CAN_DRINK"
    },
    [7]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,-56.25,3.210000038147),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(35.360000610352,-48.209999084473,3.210000038147),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Finger1']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Finger0']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_Hand']=Angle(0,0,0),
        Duration=0.2,
    },
    [8]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(0,0,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,0,0),
        Duration=0.7,
        CallBack="CAN_CHANGESKIN"
    },
    [9]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.0,
        CallBack="CAN_BURP"
    },
    [10]={
        ['ValveBiped.Bip01_L_Clavicle']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Forearm']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_UpperArm']=Angle(10.430000305176,-39.130001068115,31.299999237061),
        ['ValveBiped.Bip01_R_Hand']=Angle(0,0,0),
        ['ValveBiped.Bip01_R_Finger0']=Angle(-20.870000839233,10.430000305176,0),
        ['ValveBiped.Bip01_L_UpperArm']=Angle(0,0,0),
        Duration=0.0,
        CallBack="ANIMATION_FINISHED"
    },

}
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
e.Pressure=0;
e.Detonated=false;
function e:Initialize()
    if(SERVER)then
    self:SetModel( "models/props_junk/PopCan01a.mdl" )
    self:SetMoveType( MOVETYPE_VPHYSICS );
    self:PhysicsInit( SOLID_VPHYSICS );
    self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG );
    self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG );
    self:GetPhysicsObject():SetMaterial("popcan")
    self:PhysWake()
    self.GrenadeTimer=CurTime()+10;
    end
    self:InstallDataTable();
end

function e:Draw()
    self:DrawModel();
end

function e:Think()
    if CLIENT then return end
    if self.GrenadeTimer < CurTime() && !self.Detonated then
        self:Detonate();
    end
end

function e:SetPressure(val)
    self.Pressure=val;
end

function e:OnTakeDamage(dmgfo)
    if !self.Detonated then
        self:Detonate();
    end
end

function e:Detonate(data)
    if self.Detonated then return end
    self.Detonated=true;
    self:EmitSound("Weapon_AR2.NPC_Double")
    self:EmitSound("ambient/water/water_splash1.wav")
    local dmg=Lerp(self.Pressure/100,10,200)
    local shake=Lerp(self.Pressure/100,1,25)
    util.BlastDamage( self,self:GetOwner(),self:GetPos(),150,dmg );
    util.ScreenShake( self:GetPos(), shake, 150.0, 1.0, 350 );
    local speed = self:GetPhysicsObject():GetVelocity()
    local effectdata = EffectData()
    effectdata:SetScale(self.Pressure/10)
    effectdata:SetOrigin( self:GetPos()+(self:GetUp())*7 )
    if data then
    effectdata:SetStart(data.HitNormal*-1 )
    else
    effectdata:SetStart(speed:GetNormal() )
    end
    util.Effect( "SodaCan_Explode", effectdata )
    if data then
        local Pos1 = data.HitPos + data.HitNormal
        local Pos2 = data.HitPos - data.HitNormal
        util.Decal("beersplash",Pos1,Pos2)
    end    
    self:Remove();
end

function e:PhysicsCollide( data, physobj )
    //we gotta explode when the speed data.OurOldVelocity:Length()
    // the speed required for a can to explode is >900 when the pressure is low,and 200 when the pressure is almost 100
    local speedrequired=Lerp(self.Pressure/100,1000,200)
    if data.OurOldVelocity:Length()>speedrequired && !self.Detonated then
        self:Detonate(data)
    end
end
scripted_ents.Register(e,"can_nade",true)

SWEP.AnimationFrame=1;
SWEP.AnimTime=CurTime();

local function GetNextFrame(self)
    /*what i need to do here is:
    increase animationframe
    check if animationframe is > #CurrentAnim then
        check if the currentanim got a FrameLoop
            set the animationframe to that frameloop
        otherwise set the animationframe to the end of the animation
    
    */
    local nextframe=self.Weap.AnimationFrame
    if nextframe+1> #self.Weap.CurrentAnim then
        if self.Weap.CurrentAnim.FrameLoop then
            nextframe=self.Weap.CurrentAnim.FrameLoop
        end
    else
        nextframe=nextframe+1;
    end
    
    return nextframe;
end

local function AdvanceFrame(self)
    if CurTime()<self.Weap.AnimTime then return end
    self.Weap.AnimationFrame=GetNextFrame(self);
    local callback=self.Weap.CurrentAnim[self.Weap.AnimationFrame].CallBack
    if callback then
        self.Weap:HandleCustomAnimationEvent(callback)
    end
    self.Weap.AnimTime=CurTime()+self.Weap.CurrentAnim[self.Weap.AnimationFrame].Duration;
end



local function BuildBPositions(self)
    local Weap=self.Weap
    if !Weap.CurrentAnim then return end
    if !IsValid(LocalPlayer():GetActiveWeapon()) || LocalPlayer():GetActiveWeapon()!=self.Weap then return end
    for i,v in pairs(Weap.CurrentAnim[Weap.AnimationFrame])do
        
        //the for cycle here will see:
        //i,the bonename,or whatever is in the [frame] primary table,something like "ValveBiped.Bip01_Shit_like_that"
        //v,the content inside the [i],so Angle(p,y,r)
        
        if type(v)=="Angle" then
            if self==LocalPlayer() && string.find(string.lower(i),"r_upper") then continue end
            local b = self:LookupBone(i)
            if b then
            local m = self:GetBoneMatrix(b)
                if m then
                    
                    //allright,so we need to interpolate to the next frame,so we can just use less frames and less choppy animations
                    
                    local ang=Angle(v.p,v.y,v.r);//fuuuu-,basically,this was the bug i was looking for,it was returning the original vector,not a copy of it
                                                 //and it was screwing up the animation
                    //we need to get the rotation shit of the next frame of the same viewmodel bone

                    local nextframe=GetNextFrame(self);
                    local nextframeangle=Weap.CurrentAnim[nextframe][i] or Angle(0,0,0)

                    //the angle table values are: p,y,r

                    //if nextframeangle then
                        local frac=math.TimeFraction(Weap.AnimTime-Weap.CurrentAnim[Weap.AnimationFrame].Duration,Weap.AnimTime, CurTime() )
                        ang.p=Lerp(frac,v.p,nextframeangle.p)
                        ang.y=Lerp(frac,v.y,nextframeangle.y)
                        ang.r=Lerp(frac,v.r,nextframeangle.r)
                    //end
                    
                    m:Rotate(ang)
                    self:SetBoneMatrix(b,m)
                end
            end
        end
        
    end
    Weap.DontDrawCSM=(Weap.CurrentAnim[Weap.AnimationFrame].DontDrawCSM) and true or false
    //AdvanceFrame(self);
end

    

SWEP.Category                = "Half Life 2" 
SWEP.Slot                    = 4
SWEP.SlotPos                = 5
SWEP.Weight                    = 5
SWEP.Spawnable                 = true
SWEP.AdminSpawnable          = true
 
SWEP.ViewModel            = "models/weapons/v_animhands.mdl"
SWEP.WorldModel            ="models/props_junk/PopCan01a.mdl"
SWEP.DontDrawCSM=false;
SWEP.WeaponModel={
    Model="models/props_junk/PopCan01a.mdl",
    Bone="ValveBiped.Bip01_R_Hand",
    OffsetVector=Vector(2,4,0),
    OffsetAngle=Angle(90,180,00),
    Skin=0,
}


SWEP.HoldPos=Vector(0,0,0)
SWEP.HoldAng=Vector(0,0,0)

SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1    
SWEP.Primary.Ammo             = false
SWEP.Primary.Automatic        = true


SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Ammo         = false
SWEP.Secondary.Automatic     = false

function SWEP:Initialize()
self:SetWeaponHoldType("slam")
self:InstallDataTable();
    if IsValid(self.Owner) then
        self:SendWeaponAH(self.ACT_VM_DEPLOY)
        self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
        self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
    end
self:DTVar( "Int", 0, "Pressure" );
self.dt.Pressure=0;
self.Skin=0;
self.DirtyTime=0
if CLIENT then
    self:CreateCSM();
    self:ChangeKillicon();

end

end 

function SWEP:ChangeKillicon()
    local col=Color( 0, 12, 255, 255 )
    if self.WeaponModel.Skin==0 then
        col=Color( 0, 12, 255, 255 )
    elseif self.WeaponModel.Skin==1 then
        col=Color( 255, 0, 12, 255 )
    else
        col=Color( 255, 80, 0, 255 )
    end
    killicon.AddFont( self:GetClass(), "HL2MPTypeDeath","4", col )
    killicon.AddFont( "can_nade", "HL2MPTypeDeath","4", col )
end

function SWEP:Deploy()
self:SendWeaponAH(self.ACT_VM_DEPLOY)
self:StupidSPFix("Deploy")
self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
return true;
end

function SWEP:StupidSPFix(FunctName)
    if SERVER && SinglePlayer() then
    self:CallOnClient(FunctName,"")
    end
end

function SWEP:ChangeCanSkin(skin)
    if SERVER then
        local randomskin=math.random(0,2)
        umsg.Start("cn_cskin", self.Owner)
        umsg.Entity(self)
        umsg.Short(randomskin)
        umsg.End()
        self.Skin=randomskin
    else
        self:ChangeKillicon()
        self.WeaponModel.Skin=skin;//for future uses
        if self.CSM && IsValid(self.CSM) then
            self.CSM:SetSkin(skin)    //for the viewmodel
        end
        self:SetSkin(skin)        //for the worldmodel
    end
end


if CLIENT then
    local function SkinChangeCanNade(umsg)
        local ent=umsg:ReadEntity()
        local sk=umsg:ReadShort();
        if(!IsValid(ent))then return end
        ent:ChangeCanSkin(sk);
    end
    usermessage.Hook("cn_cskin", SkinChangeCanNade)
end

function SWEP:ThrowCan()
    if CLIENT then return end

    //get the pressure from the self.dt.Pressure and then send it to the can
    //Code taken from amcwatters' swep_frag
    local    vecEye = self.Owner:EyePos();
    local    vForward, vRight;
    vForward = self.Owner:GetForward();
    vRight = self.Owner:GetRight();
    local vecSrc = vecEye + vForward * 18.0 + vRight * 8.0;
    vecSrc = self:CheckThrowPosition( self.Owner, vecEye, vecSrc );
    local vecThrow;
    vecThrow = self.Owner:GetVelocity();
    
    local throwspeeddamnit=Lerp(self.dt.Pressure/100,1000,2000)
	//1200
    vecThrow = vecThrow + vForward * throwspeeddamnit;
    local can = ents.Create("can_nade");
    if !can || !IsValid(can) then return end
    can:SetPos( vecSrc );
    can:SetAngles( Angle(0,0,0) );
    can:SetOwner( self.Owner );
    can:Spawn()
    can:Activate()
    can:SetPressure(self.dt.Pressure)
    can:SetSkin(self.Skin)
    can:GetPhysicsObject():SetVelocity( vecThrow );
    can:GetPhysicsObject():AddAngleVelocity( Angle(600,math.random(-1200,1200),0) );
    self:ChangeCanSkin()
    self.dt.Pressure=0;
end

function SWEP:Holster()
    local canholster=CurTime()>self:GetNextPrimaryFire();
    if canholster then
        if CLIENT && IsValid(self.Owner) && IsValid(self.Owner:GetViewModel())then
            self.Owner:GetViewModel().BuildBonePositions=nil;
        end
    end
    return canholster;
end

function SWEP:OnDrop()
    if CLIENT && IsValid(self.Owner) && IsValid(self.Owner:GetViewModel())then
        self.Owner:GetViewModel().BuildBonePositions=nil;
    end
end

function SWEP:OnRemove()
    if CLIENT && IsValid(self.Owner) && IsValid(self.Owner:GetViewModel())then
        self.Owner:GetViewModel().BuildBonePositions=nil;
    end
end


function SWEP:PrimaryAttack()
    self:StupidSPFix("PrimaryAttack")
    self:SendWeaponAH(self.ACT_VM_SHAKE_SHAKE_SHAKE)
    self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
    self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
end

function SWEP:SecondaryAttack()
    if self.dt.Pressure != 0 then return end
    
    self:StupidSPFix("SecondaryAttack")
    self:SendWeaponAH(self.ACT_VM_DRINK)
    self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
    self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
end

//shared!
function SWEP:HandleCustomAnimationEvent(AnimationEvent)
    if AnimationEvent=="ANIMATION_FINISHED" then
        self:SendWeaponAH(self.ACT_VM_IDLE)
    elseif AnimationEvent== "CAN_THROW" then
        self:ThrowCan()
    elseif AnimationEvent=="CAN_POP" then
        if CLIENT then self:EmitSound("can/pop.mp3") end
    elseif AnimationEvent=="CAN_DRINK" then
        if CLIENT then self:EmitSound("can/drink_fast.wav") end
        self:HealByCan();
    elseif AnimationEvent=="CAN_BURP" then
        if CLIENT && math.random(0,2)==1 then    self:EmitSound("can/burp.wav") end
    elseif AnimationEvent=="CAN_CHANGESKIN" then
        if SERVER then self:ChangeCanSkin() end
    elseif AnimationEvent=="CAN_SHAKE" then
        if CLIENT then self:EmitSound("player/footsteps/slosh"..math.random(1,4)..".wav",30,100) end
        
        if self.dt.Pressure <100 && self.Owner:KeyDown(IN_ATTACK) then
            if SERVER then self.dt.Pressure=self.dt.Pressure+4; end
        end
        
        
        if (self.dt.Pressure>=10 && !self.Owner:KeyDown(IN_ATTACK)) || (self.dt.Pressure<104 && self.dt.Pressure>96) then
            self:SendWeaponAH(self.ACT_VM_THROW_CAN)
            self.Owner:DoAttackEvent();
            self:EmitSound("Weapon_Crowbar.Single")
            self:SetNextPrimaryFire(CurTime()+self:GetAHDuration())
            self:SetNextSecondaryFire(CurTime()+self:GetAHDuration())
        elseif self.dt.Pressure<10 && !self.Owner:KeyDown(IN_ATTACK) then
            if SERVER then self.dt.Pressure=0; end
            self:SendWeaponAH(self.ACT_VM_IDLE)
        end
        
    end
end


function SWEP:HealByCan()
    if CLIENT then return end
    local maxhealth=self.Owner:GetMaxHealth()
    local twentyfiveperc=(25*maxhealth)/100
    if(self.Owner:Health()+twentyfiveperc<maxhealth)then
        self.Owner:SetHealth(self.Owner:Health()+twentyfiveperc)
    else
        self.Owner:SetHealth(maxhealth)
    end
end

function SWEP:Think()
    self:SSAnimThink();    //this function will handle server side animation callbacks
    if CLIENT && IsValid(self.Owner:GetViewModel())then
        self.Owner:GetViewModel().Weap=self;
        self.Owner:GetViewModel().BuildBonePositions=BuildBPositions
        /*
        self.Owner.Weap=self;
        self.Owner.BuildBonePositions=BuildBPositions
        */
    end
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

function SWEP:SSAnimThink()
    if !self.CurrentAnim then return end
    
    if CurTime()<self.AnimTime then return end
    self.AnimationFrame=self:GetNextFrame();
    local callback=self.CurrentAnim[self.AnimationFrame].CallBack
    if callback then
        self:HandleCustomAnimationEvent(callback)
    end
    self.AnimTime=CurTime()+self.CurrentAnim[self.AnimationFrame].Duration;
end

function SWEP:GetNextFrame()
    local nextframe=self.AnimationFrame
    if nextframe+1> #self.CurrentAnim then
        if self.CurrentAnim.FrameLoop then
            nextframe=self.CurrentAnim.FrameLoop
        end
    else
        nextframe=nextframe+1;
    end
    
    return nextframe;
end


function SWEP:SendWeaponAH(ANIM)
    if !ANIM then return end
    //HAX,shouldn't the animation itself set the AnimTime on animation switching?
    self.AnimTime=CurTime()+ANIM[1].Duration;
    self.CurrentAnim=ANIM;
    self.AnimationFrame=1;

end

function SWEP:GetAHDuration()
    if !self.CurrentAnim then return end
    //this is fucking ugly,i hate to do this everytime a swep needs the duration,can't i just set a variable to something like... AnimDuration?
    local ahtime=0;
    for i,v in pairs(self.CurrentAnim)do
        if type(v)!="table" then continue; end
        ahtime=ahtime+v.Duration
    end
    return ahtime;
end

 
 