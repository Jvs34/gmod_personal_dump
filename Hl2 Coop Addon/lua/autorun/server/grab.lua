AddCSLuaFile('grab.lua')

local pullRange		= 64
local holdRange		= 64
local throwStrength	= 15
local pullStrength	= 70
local maxmass=70
function agagaDrop( pl )
	if(pl.GrabbedEnt)then
		pl.GrabbedEnt:SetCollisionGroup( pl.GrabbedCollision );
		pl.GrabbedPhys:EnableGravity(true)
		pl.GrabbedPhys:SetVelocity(pl.GrabbedPhys:GetVelocity()*throwStrength-pl:GetVelocity()*(throwStrength-1))
		if(pl:KeyDown( IN_ATTACK )) then
			pl.GrabbedPhys:SetVelocity( pl:GetAimVector()*throwStrength*40 + pl:GetVelocity() )
		end
			if(pl.GrabbedEnt:GetClass()=="npc_grenade_frag")then
				pl.GrabbedEnt:Fire("settimer","2");
				pl.GrabbedEnt:SetOwner(pl);
			end
		pl.GrabbedEnt=nil
	end
end
local function agagaThink()
	for _, pl in pairs(player.GetAll()) do
		if(pl:Alive())then
			if(pl.GrabChange&&!pl:KeyDown( IN_USE )) then
				pl.GrabChange=false
			end
			if(pl.GrabbedEnt)then
				if(pl:GetActiveWeapon()!=NULL)then
				pl:GetActiveWeapon():SetNextPrimaryFire(CurTime()+0.5)
				pl:GetActiveWeapon():SetNextSecondaryFire(CurTime()+0.5)
				pl:DrawViewModel(false)
				pl:DrawWorldModel(false)
				end
				ent=pl.GrabbedEnt
				if(ent:IsValid())then
					phys= pl.GrabbedPhys
					if(ent:GetMoveType() == MOVETYPE_VPHYSICS)then
						if(((pl:KeyDown( IN_USE )||pl:KeyDown( IN_ATTACK )||pl:KeyDown( IN_ATTACK2 )||pl:KeyDown( IN_ALT1 )||pl:KeyDown( IN_ALT2 )) && !pl.GrabChange)||pl:InVehicle( )) then
							agagaDrop( pl )
							pl.GrabChange=true
						else
							local tracedata = {}
							tracedata.start = pl:EyePos( )
							tracedata.endpos = pl:EyePos( )+(pl:GetAimVector()*(holdRange+pl.GrabbedEnt:BoundingRadius( )))
							tracedata.filter = {pl,pl.GrabbedEnt}
							local trace = util.TraceLine(tracedata)
							dist=trace.HitPos:Distance(pl:EyePos( ))
							dist=dist-pl.GrabbedEnt:BoundingRadius( )
							if(dist>holdRange)then	dist=holdRange	end
							pos=pl:EyePos()+pl:GetAimVector()*dist-phys:GetMassCenter()
							vel=pl:GetVelocity()+(pl:EyePos()+pl:GetAimVector()*dist-phys:GetPos()-phys:GetMassCenter())*4
							ang=pl:GetAimVector():Angle()
							ang.x=0
							phys:SetPos(pos)
							phys:SetVelocity(vel)
							phys:SetAngle(ang)
						end
					else
						pl.GrabbedEnt=nil
					end
				else
					pl.GrabbedEnt=nil
				end
			//otherwise...
			elseif(!pl.GrabbedEnt) then
				if(pl:GetActiveWeapon()!=NULL && !pl:InVehicle() && pl:GetActiveWeapon():GetClass()!="gmod_camera")then
				pl:DrawViewModel(true)
				pl:DrawWorldModel(true)
				end 
				//find the closest, most in front object
				ent=nil
				bestcost=0
				for k, v in pairs( ents.FindInSphere( pl:GetPos(), pullRange ) ) do
					if(!(v==pl)) then
						if(v:IsValid() && IsValid(v:GetPhysicsObject()) && v:GetMoveType() == MOVETYPE_VPHYSICS && !v:IsNPC() && !v:IsVehicle()) then
							dotmin=0.9
							looking=pl:GetAimVector()
							looking.z=0
							looking=looking:Normalize()
							direction=((v:GetPos()+v:GetPhysicsObject():GetMassCenter())-pl:EyePos())
							direction.z=0
							direction=direction:Normalize()
							dot=looking:DotProduct(direction)
							if(dot>=dotmin)then
								dot=(2-dot)*4
								dist=(v:GetPos()+v:GetPhysicsObject():GetMassCenter()):Distance(pl:EyePos( ))
								cost=dist*dot
								if(!ent) then
									ent=v
									bestcost=cost
								elseif(cost<bestcost) then
									ent=v
									bestcost=cost
								end 
							end
						end
					end
				end
				//found something suitable.
				if(ent) then
					local v = {}
					v.start = pl:GetShootPos()
					v.endpos = v.start + pl:GetAimVector() * pullRange
					v.filter = pl
					v = util.TraceLine(v)
					if(v.Entity==ent)then
						phys= ent:GetPhysicsObjectNum(v.PhysicsBone)
					else
						phys= ent:GetPhysicsObject()
					end
					if(pl:KeyDown( IN_USE ) && !pl.GrabChange) then
						if(phys) then
						if(phys:GetMass()<maxmass)then
							if((phys:GetPos()+phys:GetMassCenter()):Distance(pl:EyePos( )) <= holdRange && !ent:IsNPC() && !ent:IsVehicle()) then
								pl.GrabbedEnt=ent
								pl.GrabbedCollision= ent:GetCollisionGroup();
								pl.GrabbedPhys=phys
								ent:SetCollisionGroup( COLLISION_GROUP_WEAPON )
								phys:EnableGravity(false)
								ent:SetPhysicsAttacker(	pl );
								pl.GrabChange=true
								if(pl.GrabbedEnt:GetClass()=="npc_grenade_frag")then
									pl.GrabbedEnt:Fire("settimer","3");
								end
							elseif(v.HitPos:Distance(pl:EyePos( )) <= pullRange ) then
								pulldir=((pl:EyePos( )+pl:GetAimVector():Normalize()*64)-(phys:GetPos()+phys:GetMassCenter())):Normalize()
								phys:ApplyForceCenter ((pulldir * pullStrength) * phys:GetMass())
							end
						end
						end
					end
				end
			end
		end
	end
end

hook.Add("Think","agagaThink",agagaThink)