SWEP.AutoSwitchTo        = true
SWEP.AutoSwitchFrom        = true
    

if ( CLIENT ) then
    SWEP.DrawAmmo            = false
    SWEP.PrintName            = "PuntCannon"
    SWEP.Author                = "Jvs"
    SWEP.DrawCrosshair        = true
    SWEP.ViewModelFOV        = 54
    local PHYSCANNON_BEAM_SPRITE
    local PHYSCANNON_CENTER_GLOW
    local MEGACANNON_BEAM_SPRITE
    local MEGACANNON_CENTER_GLOW
    local MEGACANNON_UPGRADE_MUZZLE
    SWEP.Contact        = "jvs_34@yahoo.it"
    //Credits to Andrew Mc Watters for his drawweaponselection from his swep_bases
    // Override this in your SWEP to set the icon in the weapon selection
    SWEP.WepSelectFont            = "TitleFont2"
    SWEP.WepSelectLetter        = "m"

    /*---------------------------------------------------------
        Checks the objects before any action is taken
        This is to make sure that the entities haven't been removed
    ---------------------------------------------------------*/
    function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

        // Set us up the texture
        surface.SetDrawColor( color_transparent )
        if(self.dt.SuperCharged)then
        surface.SetTextColor( 0, 12, 255, alpha )
        else
        surface.SetTextColor( 255, 220, 0, alpha )
        end
        surface.SetFont( self.WepSelectFont )
        local w, h = surface.GetTextSize( self.WepSelectLetter )

        // Draw that mother
        surface.SetTextPos( x + ( wide / 2 ) - ( w / 2 ),
                            y + ( tall / 2 ) - ( h / 2 ) )
        surface.DrawText( self.WepSelectLetter )

        
    end
    
    PHYSCANNON_BEAM_SPRITE=CreateMaterial("sprites/orangelightnew",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/orangelight1",
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
    PHYSCANNON_CENTER_GLOW =CreateMaterial("sprites/orangecorenew",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/orangecore1",
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
    
    MEGACANNON_BEAM_SPRITE =CreateMaterial("sprites/physcannon_bluelightnew",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/lgtning",//"sprites/physcannon_bluelight1b",
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
    
    MEGACANNON_CENTER_GLOW =CreateMaterial("sprites/physcannon_bluecorenew",
            "UnlitGeneric",{
                ['$basetexture' ] = "sprites/physcannon_bluecore1b",//"effects/fluttercore"
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
            }
    )
    
    MEGACANNON_UPGRADE_MUZZLE=CreateMaterial("effects/strider_muzzlenew",
            "UnlitGeneric",{
                ['$basetexture' ] = "effects/strider_muzzle",
                [ '$additive' ] = "1",
                [ '$vertexcolor' ] = "1",
                [ '$vertexalpha' ] = "1",
        }
    )        
    //effect register
    local EFFECT={}
    EFFECT.Mat = PHYSCANNON_BEAM_SPRITE
    EFFECT.MegaMat=MEGACANNON_BEAM_SPRITE
    EFFECT.DieT=0.1
    /*---------------------------------------------------------
       Init( data table )
    ---------------------------------------------------------*/
    function EFFECT:Init( data )
        self.IsSuperPuntEffect=(data:GetScale()==1) and true or false;
        self.EndPos     = data:GetOrigin()
        self.Ent =    data:GetEntity();
        if(!IsValid(self.Ent))then return end
        self.Entity:SetRenderBoundsWS( self.Ent:GetAttachment( 1).Pos, self.EndPos )
        self.DieTime = CurTime() + self.DieT
        local effectdata = EffectData()
            effectdata:SetOrigin( self.EndPos )
            effectdata:SetMagnitude( 5 )
            effectdata:SetScale( 1 )
            effectdata:SetRadius( 5 )
        util.Effect( "Sparks", effectdata )
            
        local emitter = ParticleEmitter(self.EndPos )
        local particle = emitter:Add( (self.IsSuperPuntEffect==true) and "effects/blueflare1.vtf" or "effects/yellowflare.vtf",self.EndPos)
        particle:SetVelocity(Vector(0,0,0))
        particle:SetLifeTime(0)
        particle:SetDieTime(self.DieT)
        particle:SetStartAlpha(255)
        particle:SetEndAlpha(255)
        particle:SetStartSize(math.random( 24, 32 ))
        particle:SetEndSize(0)
        particle:SetRoll( math.random( 0, 360 ))
        particle:SetRollDelta( 0.0 )
        particle:SetColor( 255, 255, 255 )
        particle:VelocityDecay( false )        
        emitter:Finish()    
        self.Size=16
        if(self.Ent:IsWeapon())then self.Size=8 end
        local dlight = DynamicLight( self:EntIndex() )
        if ( dlight ) then
            if(self.IsSuperPuntEffect==true)then
            dlight.r =    127
            dlight.g = 153
            dlight.b = 221
            else
            dlight.r =    201
            dlight.g = 193
            dlight.b = 80
            end
            
            dlight.Pos =  self.EndPos
            dlight.Brightness = 4
            dlight.Size =200
            dlight.Decay = 200
            dlight.DieTime = CurTime() + self.DieT
        end
            
    end

    /*---------------------------------------------------------
       THINK
    ---------------------------------------------------------*/
    function EFFECT:Think( )

        if ( CurTime() > self.DieTime && IsValid(self.Ent) ) then


        
            return false
        end
        
        return true

    end

    /*---------------------------------------------------------
       Draw the effect
    ---------------------------------------------------------*/
    function EFFECT:Render( )
        if(!IsValid(self.Ent))then return end
        render.SetMaterial( (self.IsSuperPuntEffect==true) and self.MegaMat or self.Mat )
        if !self.Ent:GetAttachment( 1) then return end
        render.DrawBeam( self.Ent:GetAttachment( 1).Pos,self.EndPos,self.Size,1,0,Color( 255, 255, 255, 255 ) )
                         
    end
    effects.Register(EFFECT,"PuntCannonEffect")
        
    
    SWEP.RenderGroup         = RENDERGROUP_TRANSLUCENT
    function SWEP:ViewModelDrawn()
        self:DrawCannon(true)
    end
    
    function SWEP:DrawWorldModelTranslucent()
        self.Weapon:DrawModel()
        self:DrawCannon(false)
    end

    function SWEP:DrawWorldModel()
        //self.Weapon:DrawModel()
        //self:DrawCannon(false)
    end

    function SWEP:DrawCannon(vmwmbool)    
        //vmwmbool is the boolean that controls how we are calling these functions
        local ent=(vmwmbool) and self:GetOwner():GetViewModel() or self.Weapon

        local attachment=ent:GetAttachment( 1)
        local StartPos = attachment.Pos
        local size=(12*self.dt.Charge)/200;
        local sizenocharge=12;
        local beamsize=8;
        local distance=36
        if(vmwmbool)then
            StartPos=attachment.Ang:Forward()*32 + StartPos
            //size=20
            size=(24*self.dt.Charge)/200;
            sizenocharge=24;
            beamsize=16;
        end

        render.SetMaterial((self.dt.SuperCharged) and MEGACANNON_CENTER_GLOW or PHYSCANNON_CENTER_GLOW)
        render.DrawSprite(StartPos,size,size,Color(255,255,255,55+self.dt.Charge));
        render.SetMaterial((self.dt.SuperCharged) and MEGACANNON_BEAM_SPRITE or PHYSCANNON_BEAM_SPRITE)
            local rand=math.random(3,7)
            if(vmwmbool)then
                render.DrawBeam( ent:GetAttachment( 4).Pos+ent:GetAttachment( 1).Ang:Forward()*distance,StartPos,beamsize/4,rand,1,Color( 255, 255, 255, self.dt.Charge ) )
                render.DrawBeam( ent:GetAttachment( 7).Pos+ent:GetAttachment( 1).Ang:Forward()*distance,StartPos,beamsize/4,rand,1,Color( 255, 255, 255, self.dt.Charge ) )
                
                render.SetMaterial((self.dt.SuperCharged) and MEGACANNON_CENTER_GLOW or PHYSCANNON_CENTER_GLOW)
                render.DrawSprite(ent:GetAttachment( 4).Pos+ent:GetAttachment( 1).Ang:Forward()*distance,2,2,Color(255,255,255,55));
                render.DrawSprite(ent:GetAttachment( 7).Pos+ent:GetAttachment( 1).Ang:Forward()*distance,2,2,Color(255,255,255,55));
                
            else
                render.DrawBeam( ent:GetAttachment( 3).Pos,ent:GetAttachment( 1).Pos,beamsize/4,rand,0,Color( 255, 255, 255, self.dt.Charge ) )
                render.DrawBeam( ent:GetAttachment( 5).Pos,ent:GetAttachment( 1).Pos,beamsize/4,rand,0,Color( 255, 255, 255, self.dt.Charge ) )
                render.DrawBeam( ent:GetAttachment( 7).Pos,ent:GetAttachment( 1).Pos,beamsize/4,rand,0,Color( 255, 255, 255, self.dt.Charge ) )
                
                render.SetMaterial((self.dt.SuperCharged) and MEGACANNON_CENTER_GLOW or PHYSCANNON_CENTER_GLOW)
                render.DrawSprite(ent:GetAttachment( 3).Pos,1,1,Color(255,255,255,55));
                render.DrawSprite(ent:GetAttachment( 5).Pos,1,1,Color(255,255,255,55));
                render.DrawSprite(ent:GetAttachment( 7).Pos,1,1,Color(255,255,255,55));
            end
            render.SetMaterial((self.dt.SuperCharged) and MEGACANNON_BEAM_SPRITE or PHYSCANNON_BEAM_SPRITE)
            if self.ZapDuration > CurTime() then
                
                local rmprong=self.RandomProng;
                if(vmwmbool)then
                    if rmprong>1 then self.RandomProng=math.random(0,1); end
                    rmprong=self.RandomProng;
                    if rmprong==0 then
                    render.DrawBeam( ent:GetAttachment( 4).Pos+ent:GetAttachment( 1).Ang:Forward()*36,StartPos,beamsize/4,rand,1,Color( 255, 255, 255, 255 ) )
                    else
                    render.DrawBeam( ent:GetAttachment( 7).Pos+ent:GetAttachment( 1).Ang:Forward()*36,StartPos,beamsize/4,rand,1,Color( 255, 255, 255, 255 ) )
                    end
                else
                    if rmprong==0 then
                    render.DrawBeam( ent:GetAttachment( 3).Pos,ent:GetAttachment( 1).Pos,beamsize/4,rand,0,Color( 255, 255, 255,255) )
                    elseif rmprong==1 then
                    render.DrawBeam( ent:GetAttachment( 5).Pos,ent:GetAttachment( 1).Pos,beamsize/4,rand,0,Color( 255, 255, 255,255) )
                    else
                    render.DrawBeam( ent:GetAttachment( 7).Pos,ent:GetAttachment( 1).Pos,beamsize/4,rand,0,Color( 255, 255, 255,255) )
                    end
                end
            
            end
        local dlight = DynamicLight( self:EntIndex() )
        if ( dlight && (self.dt.Charge > 0 || self.dt.UpgradingEffect)) then
            if(self.dt.SuperCharged==true)then
            dlight.r =    127
            dlight.g = 153
            dlight.b = 221
            else
            dlight.r =    201
            dlight.g = 193
            dlight.b = 80
            end
            dlight.Pos = vmwmbool and self:GetOwner():EyePos() or StartPos
            if self.dt.UpgradingEffect then
            dlight.Size =200
            dlight.Decay = 200
            dlight.Brightness = 5
            else
            dlight.Brightness = self.dt.Charge/50
            dlight.Size =self.dt.Charge
            dlight.Decay = self.dt.Charge
            end
            dlight.DieTime = CurTime() + 0.1
        end
        if self.dt.UpgradingEffect then
            //this is the upgrading muzzle
                for i=0,4 do
                    render.SetMaterial(MEGACANNON_UPGRADE_MUZZLE);
                    local m_uchStartSize    = math.random( 1, 2 ) * (i+1);
                    render.DrawSprite(StartPos,sizenocharge+m_uchStartSize,sizenocharge+m_uchStartSize,Color(255,255,255,255));
                end
                //this is the upgrading particles
                local sParticle;
                local offset;
                self.PartEmitter=ParticleEmitter( StartPos )
                for i=0,4 do
                        
                        offset = StartPos + Vector(math.random(-32,32),math.random(-32,32),math.random(-32,32))
                        sParticle=self.PartEmitter:Add( "effects/strider_muzzle", offset )
                        sParticle:SetVelocity(StartPos-offset)
                        sParticle:SetDieTime(0.5)
                        sParticle:SetLifeTime(0);
                        sParticle:SetRoll(math.random( 0, 360 ))
                        sParticle:SetRollDelta(0);
                        sParticle:SetColor(255,255,255)
                        sParticle:SetStartAlpha(255);
                        sParticle:SetEndAlpha(0)
                        sParticle:SetStartSize(math.random(1,2))
                        sParticle:SetEndSize(0)
                end
                self.PartEmitter:Finish()
        end
        
        if self.dt.Charge >=200 then
                for i=0,4 do
                    render.SetMaterial(MEGACANNON_UPGRADE_MUZZLE);
                    local m_uchStartSize    = math.random( 0,1 ) * (i+1);
                    local sizenocharge=sizenocharge-2;
                    render.DrawSprite(StartPos,sizenocharge+m_uchStartSize,sizenocharge+m_uchStartSize,Color(255,255,255,255));
                end
                if self.dt.SuperCharged then
                    local sParticle;
                    local offset;
                    self.PartEmitter=ParticleEmitter( StartPos )
                    for i=0,4 do
                            offset = StartPos + Vector(math.random(-32,32),math.random(-32,32),math.random(-32,32))
                            sParticle=self.PartEmitter:Add( "effects/strider_muzzle", offset )
                            sParticle:SetVelocity(StartPos-offset)
                            sParticle:SetDieTime(0.5)
                            sParticle:SetLifeTime(0);
                            sParticle:SetRoll(math.random( 0, 360 ))
                            sParticle:SetRollDelta(0);
                            sParticle:SetColor(255,255,255)
                            sParticle:SetStartAlpha(255);
                            sParticle:SetEndAlpha(0)
                            sParticle:SetStartSize(math.random(1,2))
                            sParticle:SetEndSize(0)
                    end
                    self.PartEmitter:Finish()
                end
                /*
                local sParticle;
                local offset;
                self.PartEmitter=ParticleEmitter( StartPos )
                for i=0,4 do
                        offset = StartPos + Vector(math.random(-16,16),math.random(-16,16),math.random(-16,16))
                        sParticle=self.PartEmitter:Add( self.dt.SuperCharged and "effects/strider_muzzle" or "sprites/orangecore1", StartPos )
                        sParticle:SetVelocity(StartPos-offset)
                        sParticle:SetDieTime(0.5)
                        sParticle:SetLifeTime(0);
                        sParticle:SetRoll(math.random( 0, 360 ))
                        sParticle:SetRollDelta(0);
                        sParticle:SetColor(255,255,255)
                        sParticle:SetStartAlpha(255);
                        sParticle:SetEndAlpha(0)
                        sParticle:SetStartSize(0)
                        sParticle:SetEndSize(math.random(1,2))
                end
                self.PartEmitter:Finish()
                */
        end
    end
    
    local function ChangeIcon(um)
        local ent=um:ReadEntity()
        if(!IsValid(ent))then return end
        if ent:GetDTBool("SuperCharged") then
        killicon.AddFont( ent:GetClass(), "HL2MPTypeDeath",",", Color( 0, 12, 255, 255 ) )
        else
        killicon.AddFont( ent:GetClass(), "HL2MPTypeDeath",",", Color( 255, 80, 0, 255 ) )
        end
    end
    usermessage.Hook("cl_dr", ChangeIcon)
    
    local function Notifyzap(um)
        local ent=um:ReadEntity()
        local pron=um:ReadShort();
        if(!IsValid(ent))then return end
        ent.ZapDuration=CurTime()+0.3
        ent.RandomProng=pron;
    end
    usermessage.Hook("notifyzap", Notifyzap)

    
    
end

SWEP.Category                = "Jvs"
SWEP.Slot                    = 0
SWEP.SlotPos                = 5
SWEP.Weight                    = 5
SWEP.Spawnable                 = true
SWEP.AdminSpawnable          = true

SWEP.ViewModel            = "models/weapons/v_puntcannon.mdl"    //just use self:SetSkin(var)
SWEP.WorldModel            = "models/weapons/w_physics.mdl"    //"     "     "     "

SWEP.Primary.ClipSize        = -1
SWEP.Primary.DefaultClip    = -1    
SWEP.Primary.Ammo             = "none"
SWEP.Primary.Automatic        = true


SWEP.Secondary.ClipSize        = -1
SWEP.Secondary.DefaultClip    = -1
SWEP.Secondary.Ammo         = false
SWEP.Secondary.Automatic     = false

SWEP.TraceLength    = 250.0

//THESE ARE HERE ONLY IN THE CASE THE USER MESSES WITH THE CONVARS
SWEP.Damage    =5
SWEP.MegaDamage=75

SWEP.ChargeTime=2
SWEP.CanMegaCannonCharge=true    //if false,the megapuntcannon cannot charge,even because it will oneshot almost every npc

local Damage=CreateConVar("puntcannon_damage", "5", FCVAR_ARCHIVE)
local MegaDamage=CreateConVar("puntcannon_megadamage", "75", FCVAR_ARCHIVE)
//local StartUpgraded=CreateConVar("puntcannon_startupgraded", "1", FCVAR_ARCHIVE)//commented,right now if the user goes in the water with
                                                                                  //the puntcannon charging it will get electrocutted

function SWEP:Initialize()
    if(CLIENT)then
    killicon.AddFont( self:GetClass(), "HL2MPTypeDeath",",", Color( 255, 80, 0, 255 ) )
    language.Add(self:GetClass(),"PuntCannon")
    self.PartEmitter=ParticleEmitter( Vector(0,0,0) )
    end
    self:InstallDataTable();
    self:DTVar( "Int", 0, "Charge" );
    self:DTVar( "Bool", 0, "SuperCharged" );
    self:DTVar( "Bool", 1, "UpgradingEffect" );    //what the hell,why do i need to assign an another id? should not dtvar do that?
    self.CanAttackTime=CurTime()*2;
    self.Charge=false;
    self.NextCharge=CurTime();
    self:SetWeaponHoldType("physgun")
    
    self.RandomProng=0;
    self.NextIdleZap=CurTime();
    self.ZapDuration=CurTime();
    
    self.dt.SuperCharged=false;
    self.dt.UpgradingEffect=false;
    if SERVER then
    self.ChargeSound = CreateSound( self, "Weapon_PhysCannon.HoldSound" )
        //what,is the CreateEntityRagdoll faster than the lua variable assignment?
        hook.Add("CreateEntityRagdoll","PuntcannonTesla",function(entity,ragdoll)
            local e=ragdoll;
            if(entity.HitByMegaPuntCannon)then
                local pos=e:GetPos();
                timer.Create("Zapping"..e:EntIndex(),0.1,10,function()
                    local fx = EffectData()
                    fx:SetStart(pos);
                    fx:SetOrigin(pos);
                    fx:SetScale(10);
                    fx:SetMagnitude(10);
                    fx:SetEntity(e);
                    util.Effect("TeslaHitBoxes",fx);
                end);
            end
        end)
        
    end
end

function SWEP:Precache()
    
end


function SWEP:Holster( wep )
if SERVER then    self.ChargeSound:Stop();end
    self.NextCharge=CurTime();
    self.dt.Charge=0;
    if(self.Charge)then self.Weapon:EmitSound((self.dt.SuperCharged) and "Weapon_MegaPhysCannon.DryFire" or "Weapon_PhysCannon.DryFire")end
    self.Charge=false;
        
    return true;
end

function SWEP:OnDrop(vec)
if SERVER then    self.ChargeSound:Stop();end
    self.NextCharge=CurTime();
    self.dt.Charge=0;
    if(self.Charge)then self.Weapon:EmitSound((self.dt.SuperCharged) and "Weapon_MegaPhysCannon.DryFire" or "Weapon_PhysCannon.DryFire")end
    self.Charge=false;
    if(self.dt.SuperCharged)then
    self:SetPoseParameter("active",1)
    end
end

function SWEP:OnRemove()
    if(SERVER)then
        self.ChargeSound:Stop()
    end
end

function SWEP:StupidSPFix(FunctName)
if SERVER && SinglePlayer() then
self:CallOnClient(FunctName,"")
end
end



        

function SWEP:Deploy()
    if(self.dt.SuperCharged)then
    self:Upgrade(true);
    self:SetPoseParameter("active",1)
    else
        if(IsValid(self.Owner) && IsValid(self.Owner:GetViewModel()))then
        self.Owner:GetViewModel():SetSkin(0)
        end
        self:SetSkin(0)
    end
    self:ChangeIcon()
    

    
        self.m_WeaponDeploySpeed=1
        self.Weapon:SendWeaponAnim(ACT_VM_DRAW)
        self.CanAttackTime=self.Weapon:SequenceDuration()+CurTime()
    return true
end

local function VectorMA2(start,scale,direction)
    local dest=Vector();
    dest.x = start.x + scale * direction.x;
    dest.y = start.y + scale * direction.y;
    dest.z = start.z + scale * direction.z;
    return dest;
end


//credits to _Kilburn for his Can-non swep buildbonepositions code
local function BuildBPositions(self)
    local Weap=self.Weap
    if !IsValid(Weap) then return end
    if LocalPlayer():GetActiveWeapon()!=Weap then return end
    
    local b = self:LookupBone("square")
    if !b then return end
    local m = self:GetBoneMatrix(b)
    if !m then return end
    local val=Lerp(Weap.dt.Charge/200,40,-35);
    local a=Angle(val,0,40)
    m:Rotate(a)
    self:SetBoneMatrix(b, m)
end

function SWEP:Think()
    if CLIENT && IsValid(self.Owner:GetViewModel()) && self.Owner:GetViewModel().BuildBonePositions!=BuildBPositions then
        self.Owner:GetViewModel().Weap=self;
        self.Owner:GetViewModel().BuildBonePositions=BuildBPositions
    end
    
    if(IsValid(self.Owner) && IsValid(self.Owner:GetViewModel()))then
        local value=self.dt.SuperCharged and    1 or self.dt.Charge/200;
        self.Owner:GetViewModel():SetPoseParameter("prong_open",value)
        self:SetPoseParameter("active",value)
    end
    
        //random zaps are only clientside
        /*
        self.NextIdleZap=CurTime();
        self.ZapDuration=CurTime();
        */
    if self.CanAttackTime<CurTime() && self.NextIdleZap < CurTime() && self.dt.SuperCharged && self.dt.Charge==0 && self.Owner:WaterLevel() == 0 then
            self.ZapDuration=CurTime()+0.2
            self.RandomProng=math.random(0,2);
            self.Weapon:EmitSound("Weapon_MegaPhysCannon.ChargeZap")
                if SERVER then
                    umsg.Start("notifyzap")
                    umsg.Entity(self)
                    umsg.Short(self.RandomProng)
                    umsg.End()
                end
            self.NextIdleZap=CurTime()+math.random(.5,3)
    end
    
    
    if(self.CanAttackTime<CurTime() && self.dt.UpgradingEffect)then
        self.dt.UpgradingEffect=false;
    end
    
        if self.Charge && self.NextCharge < CurTime() then
            if(self.dt.Charge<200)then
                self.dt.Charge=self.dt.Charge+1
                if(self.dt.Charge>=200)then self.Weapon:EmitSound((self.dt.SuperCharged) and "Weapon_MegaPhysCannon.Pickup" or "Weapon_PhysCannon.Pickup");end
            end
            if SERVER then self.ChargeSound:ChangePitch(100+self.dt.Charge/1.7);end
            self.NextCharge=CurTime()+self.ChargeTime/200;
            
            if self.Owner:WaterLevel()>=3 then
                if SERVER then    self.ChargeSound:Stop();end
                self.NextCharge=CurTime();
                self.dt.Charge=0;
                self:DryFire();
                self.Charge=false;
                if(self.dt.SuperCharged)then
                    self:Downgrade();
                    self:Shock(30);
                else
                    self:Shock(5);
                end
            end
        end
end

function SWEP:Shock(dm)
    if SERVER then
		local info=DamageInfo();
        info:SetAttacker( self );
        info:SetInflictor( self );
        info:SetDamage(dm);
        info:SetDamageType( DMG_SHOCK );
        info:SetDamageForce( Vector(0,0,0));    // Scale?
        info:SetDamagePosition( self:GetPos() );
        self.Owner:TakeDamageInfo(info)
    end
        local fx = EffectData()
        fx:SetStart(self:GetPos());
        fx:SetOrigin(self:GetPos());
        fx:SetScale(30);
        fx:SetMagnitude(30);
        fx:SetEntity(self.Owner);
        util.Effect("TeslaHitBoxes",fx);
            
    self.Weapon:EmitSound("LoudSpark")
end

function SWEP:Repulse(force)
    if SERVER then    self.ChargeSound:Stop();end
    //self.Owner:SetAnimation(PLAYER_ATTACK1)
    local pOwner=self.Owner;
    
    local forward=pOwner:GetAimVector( );

    // NOTE: Notice we're *not* using the mega tracelength here
    // when you have the mega cannon. Punting has shorter range.
    local start, end1;
    start = pOwner:EyePos();
    local flPuntDistance = self.TraceLength;
    end1=VectorMA2( start, flPuntDistance, forward);
    //end1=forward*flPuntDistance+start
    local tracedata={};
    tracedata.start = start
    tracedata.endpos = end1
    tracedata.filter = self.Owner
    tracedata.mins = Vector(8,8,8)*-1
    tracedata.maxs = Vector(8,8,8)
     
    local tr = util.TraceHull( tracedata )
    
    local bValid = true;
    local pEntity = tr.Entity;
    if ( tr.fraction == 1 || (!IsValid(tr.Entity)||!tr.Entity))then
        bValid = false;
    elseif ( (pEntity:GetMoveType() != MOVETYPE_VPHYSICS))then
        bValid = false;
    end

    // If the entity we've hit is invalid, try a traceline instead
    if ( !bValid )then
        tracedata = {}
        tracedata.start = start
        tracedata.endpos =end1
        tracedata.filter = self.Owner
        tr = util.TraceLine(tracedata)
        if ( tr.fraction == 1 || !tr.Entity)then
            // Play dry-fire sequence
            self:DryFire();
            return;
        end

        pEntity = tr.Entity;
    end
    //check if the entity is not valid or if the GravGunPunt hook disallows us from hitting that entity (prop protection)
    if(!IsValid(pEntity) || !hook.Call("GravGunPunt",GAMEMODE,self.Owner,pEntity))then
        if(self.Charge)then
            if(tr.Hit && !tr.HitSky && !IsValid(pEntity))then
                if tr.HitWorld then
                    local Pos1 = tr.HitPos + tr.HitNormal
                    local Pos2 = tr.HitPos - tr.HitNormal
                    util.Decal("RedGlowFade",Pos1,Pos2)
                end
                self:PuntEffect(tr.HitPos);
            else
            self:DryFire();
            return;
            end
        else
            self:DryFire();
        end
    else
        pOwner:LagCompensation( true );
        if ( pEntity:GetMoveType() != MOVETYPE_VPHYSICS )then
                // Don't let the player zap any NPC's except regular antlions and headcrabs.
            self:PuntNonVPhysics( pEntity, forward, tr );
        else
            self:PuntVPhysics( pEntity, forward, tr );
        end
    end
    
    if SERVER && self.Charge && self.Owner:GetMoveType()==MOVETYPE_WALK then
        local f2=pOwner:GetAimVector( )*-1;
        force=force*3
        local f1=f2*force
        self.Owner:SetVelocity(f1)
        
    end
    
end

function SWEP:PrimaryAttack()
	self:StupidSPFix("PrimaryAttack")
    if self.CanAttackTime > CurTime() then return end
    self.CanAttackTime=CurTime()+0.5
    if !self.Charge then
        self:Repulse(0);
    else
        self:Repulse(self.dt.Charge)
        self.dt.Charge=0;
        self.Charge=false;
        self.NextCharge=CurTime();
    end
    
end

function SWEP:DryFire()
    self.Owner:DoAttackEvent()
    self.Weapon:EmitSound((self.dt.SuperCharged)and "Weapon_MegaPhysCannon.DryFire" or"Weapon_PhysCannon.DryFire")
    self.Weapon:SendWeaponAnim(ACT_VM_PRIMARYATTACK)
end

function SWEP:PuntNonVPhysics(pEntity, vecForward,tr)
    local pOwner = self.Owner;
    if SERVER then
        local info=DamageInfo();
        local force=1500+(self.dt.Charge*3)
        
        info:SetAttacker( self.Owner );
        info:SetInflictor( self );
        local dmgtodo=self.dt.SuperCharged and MegaDamage:GetInt() or Damage:GetInt()
        if type(dmgtodo) != "number" then
            ErrorNoHalt("PUNTCANNON CONVAR ERROR,DAMAGE IS NOT NUMBER,USING STANDARD DAMAGE")
            dmgtodo=self.dt.SuperCharged and self.MegaDamage or self.Damage;
        end
        info:SetDamage( dmgtodo +self.dt.Charge/3);
        info:SetDamageType( DMG_CRUSH );
        info:SetDamageForce( vecForward*force*300);    // Scale?
        info:SetDamagePosition( tr.HitPos );
        pEntity:DispatchTraceAttack( info, tr.StartPos, tr.HitPos );
        pEntity.HitByMegaPuntCannon=self.dt.SuperCharged;
        if pEntity:IsPlayer() then
        force=400+(self.dt.Charge*3)
        pEntity:SetVelocity(vecForward * force + Vector(0,0,2) * 150)
        
        end
        if(self.dt.SuperCharged)then
                //stolen from the stargate mod,credits to avon
                local e=pEntity
                local pos=e:GetPos();
                timer.Create("Zapping"..e:EntIndex(),0.1,10,function()
                    local fx = EffectData()
                    fx:SetStart(pos);
                    fx:SetOrigin(pos);
                    fx:SetScale(10);
                    fx:SetMagnitude(10);
                    fx:SetEntity(e);
                    util.Effect("TeslaHitBoxes",fx);
                end);
        end
        end        
    pOwner:LagCompensation( false);
    self:PuntEffect(tr.HitPos);
end


function SWEP:PuntVPhysics(pEntity, vecForward,tr)
    if SERVER then
        local pOwner = self.Owner;
        local info=DamageInfo();

        local forward = vecForward;

        info:SetAttacker( self.Owner );
        info:SetInflictor( self );
        local dmgtodo=self.dt.SuperCharged and MegaDamage:GetInt() or Damage:GetInt()
        if type(dmgtodo) != "number" then
            ErrorNoHalt("PUNTCANNON CONVAR ERROR,DAMAGE IS NOT NUMBER,USING STANDARD DAMAGE")
            dmgtodo=self.dt.SuperCharged and self.MegaDamage or self.Damage;
        end
        info:SetDamage( dmgtodo +self.dt.Charge/3);
        info:SetDamageType( DMG_CRUSH );
        pEntity:DispatchTraceAttack( info, tr.StartPos, tr.HitPos );
        pOwner:LagCompensation( false);
        self:PuntEffect(tr.HitPos);
        pEntity:SetPhysicsAttacker(self.Owner);
        local pList={};
        local listCount = pEntity:GetPhysicsObjectCount( )-1;
        
    
        pEntity:PhysWake();
        if ( !listCount || listCount<0 )then
            self:DryFire();
            return;
        end

        for i = 0,listCount do
            pList[i]=pEntity:GetPhysicsObjectNum( i)
        end

        
        if( forward.z < 0 )then
            //reflect, but flatten the trajectory out a bit so it's easier to hit standing targets
            forward.z = forward.z*-0.65;
        end
                
        // NOTE: Do this first to enable motion (if disabled) - so forces will work
        // Tell the object it's been punted
        
            // limit mass to avoid punting REALLY huge things
            local totalMass = 0;
            for i = 0,listCount do
            totalMass = pList[i]:GetMass()+totalMass;
            
            end
            local maxMass = 250;
            if ( pEntity:IsVehicle() )then
                maxMass =maxMass* 2.5;    // 625 for vehicles
            end
            
            local mass = math.min(totalMass, maxMass); // max 250kg of additional force
            // Put some spin on the object
            for i = 0,listCount do
                local hitObjectFactor = 0.5;
                local otherObjectFactor = 1 - hitObjectFactor;
                  // Must be light enough
                local ratio = pList[i]:GetMass() / totalMass;
                if ( pList[i] == pEntity:GetPhysicsObject( ))then
                    ratio = ratio+hitObjectFactor;
                    ratio = math.min(ratio,1);
                else
                    ratio = ratio*otherObjectFactor;
                end
                local fff=self.dt.SuperCharged and 30000 or 15000
                fff=fff+self.dt.Charge*100
                  pList[i]:ApplyForceCenter( forward * fff * ratio );
                  pList[i]:ApplyForceOffset( forward * mass * 600 * ratio, tr.HitPos );
            end
            if(self.dt.SuperCharged && string.find(pEntity:GetClass(),"ragdoll"))then
                pEntity:Fire("StartRagdollBoogie");
                //stolen from the stargate mod,credits to avon
                    local e=pEntity
                    local pos=e:GetPos();
                    timer.Create("Zapping"..e:EntIndex(),0.1,50,function()
                        local fx = EffectData()
                        fx:SetStart(pos);
                        fx:SetOrigin(pos);
                        fx:SetScale(10);
                        fx:SetMagnitude(10);
                        fx:SetEntity(e);
                        util.Effect("TeslaHitBoxes",fx);
                    end);
            end

    end
    
    
    
    
end

function SWEP:PuntEffect(endpos)
    local pPlayer=self.Owner;
    local effectdata = EffectData()
    local view;
    if CLIENT then view=GetViewEntity() else view=pPlayer:GetViewEntity() end
        local effectdata = EffectData()
        if ( view:IsPlayer()) then
            if(CLIENT && LocalPlayer()==self:GetOwner())then
            effectdata:SetEntity(self:GetOwner():GetViewModel())
            else
            effectdata:SetEntity(self)
            end
            if(SinglePlayer())then effectdata:SetEntity(self:GetOwner():GetViewModel()) else effectdata:SetEntity(self) end
        else
            effectdata:SetEntity(self)
        end
        effectdata:SetOrigin( endpos )
        effectdata:SetScale((self.dt.SuperCharged)and 1 or 0)
    util.Effect( "PuntCannonEffect", effectdata )
    self.Weapon:EmitSound((self.dt.SuperCharged) and "Weapon_MegaPhysCannon.Launch" or "Weapon_PhysCannon.Launch")
    pPlayer:ViewPunch( Angle( -6,math.Rand( -2,2 ), 0) );
    self.Owner:DoAttackEvent()
    self.Weapon:SendWeaponAnim(ACT_VM_SECONDARYATTACK)
end

function SWEP:SecondaryAttack()
self:StupidSPFix("PrimaryAttack")
if self.dt.SuperCharged && self.CanMegaCannonCharge==false then return end
if self.CanAttackTime > CurTime()  then return end
    if self.Charge then
        if self.dt.Charge<200 || self.dt.SuperCharged then return end
        self:Upgrade();

        self.Weapon:SendWeaponAnim(ACT_VM_IDLE)
        return
    end
    
    if self.Owner:WaterLevel()>=3 then
        self:DryFire();
        self.Owner:SetAnimation(PLAYER_ATTACK1)

        if(self.dt.SuperCharged)then
            self:Downgrade();
            self:Shock(30);
        else
            self:Shock(5)
        end
    
        self.CanAttackTime=CurTime()+0.5
        return;
    end
    self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
    if SERVER then    self.ChargeSound:Play();end
    self.Charge=true
    self.CanAttackTime=CurTime()+0.5
    self.NextCharge=CurTime();
end

function SWEP:ChangeIcon()
    if CLIENT then return end
    umsg.Start("cl_dr", self.Owner)
    umsg.Entity(self)
    umsg.End()

end

function SWEP:Downgrade()
    self.dt.SuperCharged=false;
    self:SetSkin(0);
    if(IsValid(self.Owner) && IsValid(self.Owner:GetViewModel()))then
    self.Owner:GetViewModel():SetSkin(0)
    end
    self:ChangeIcon();
    self.Weapon:EmitSound("Weapon_Physgun.Off")
    if SERVER then
    self.ChargeSound:Stop()
    self.ChargeSound = CreateSound( self, "Weapon_PhysCannon.HoldSound" )
    self:CreateEffect();
    end
end

function SWEP:Upgrade(bol)
    self.dt.SuperCharged=true;
    self:SetSkin(1);
    //self.TraceLength=self.MegaTraceLength;
    if(IsValid(self.Owner) && IsValid(self.Owner:GetViewModel()))then
    self.Owner:GetViewModel():SetSkin(1)
    end
    if !bol then
    self.Weapon:EmitSound("Weapon_MegaPhysCannon.Charge")
    end
    self:ChangeIcon();
    if SERVER then
    self.ChargeSound:Stop()
    self.ChargeSound = CreateSound( self, "Weapon_MegaPhysCannon.HoldSound" )
    self:CreateEffect();
    end
    if !bol then
        self.Charge=false;
        self.NextCharge=CurTime()+2.5
        self.dt.Charge=0;
        self.CanAttackTime=CurTime()+2.5
        self.dt.UpgradingEffect=true
    end
end

function SWEP:CreateEffect()
end

function SWEP:Reload()
    //thank god i didn't want to add any feature to the reload
end