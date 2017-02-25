//A stupid hook to give the admin super powers.
//By Jvs
function Smode(player, command, arguments)
	local Num = tonumber(arguments[1])
	if ( !arguments[1]) then return end
	if(Num>0 && Num<6)then
			if (!player:IsAdmin()) then return end
			player.SUPERMODE=Num;
	else
			if (!player:IsAdmin()) then return end
			player.SUPERMODE=0;//Disable the admin super powers
	end
end
concommand.Add( "admin_supermode",Smode )

local function PlayerDeathFFF(ply) 
	if ply:IsAdmin() then 


	end
end
hook.Add("PlayerDeath", "PlayerDeathFFF", PlayerDeathFFF);


function DischargeF(Ownah)
		if(Ownah.SoundPlayed==true)then
			Ownah.SoundPlayed=false;
		end
		Ownah:SetRunSpeed(500);
		Ownah:SetMaterial("")
		DestroyTrailF(Ownah)
		Ownah.Var=false;
		
end

function DestroyTrailF(Ownah)
	if SERVER then
	if(Ownah.Trail && IsValid(Ownah.Trail))then Ownah.Trail:Remove(); end
	end
end

function CreateTrailF(pl)
	if SERVER then
	if(pl:GetActiveWeapon()!= NULL)then
	pl.Trail = util.SpriteTrail( pl:GetActiveWeapon(),0,Color( 215, 244, 23, 244 ),true,32.0,8,0.5,1,"sprites/combineball_trail_black_1.vmt")
	else
	pl.Trail = util.SpriteTrail( pl,0,Color( 215, 244, 23, 244 ),true,32.0,8,0.5,1,"sprites/combineball_trail_black_1.vmt")
	end
	end
end

local function SupModFix()
	if CLIENT then return end

	for _, pl in pairs(player.GetAll()) do
	
	
		if(pl:KeyDown(IN_SPEED) && pl:IsAdmin() && pl:Alive() && pl.SUPERMODE)then
			pl.Var=true;
			if(pl.Var==true)then
				if !pl.SoundPlayed then pl.SoundPlayed=false end
				if(pl.SoundPlayed==false)then
					pl.SoundPlayed=true;
				end
				if(!IsValid(pl.Trail))then CreateTrailF(pl) end
				pl:SetRunSpeed(500*5);
				pl:SetMaterial("Models/effects/comball_sphere")
			end
		else
			if(pl.Var==true)then
			pl.Var=false;
			DischargeF(pl)
			end
		end
		/*
		if(pl:Alive() && pl:GetActiveWeapon() != NULL)then
			if(pl.SUPERMODE==1)then
				pl:SetMaterial("Models/props_combine/stasisshield_sheet")
			elseif(pl.SUPERMODE==2)then
				pl:SetMaterial("Models/props_combine/tprings_globe")
			elseif(pl.SUPERMODE==3)then
				pl:SetMaterial("Models/props_lab/Tank_Glass001")
			elseif(pl.SUPERMODE==4)then
				pl:SetMaterial("Models/effects/splodearc_sheet")
			elseif(pl.SUPERMODE==5)then
				pl:SetMaterial("Models/effects/comball_sphere")
			else
				pl:SetMaterial("")
			end
		end
		*/
	end
end

hook.Add("Think","SupModFix",SupModFix)

function SonicSprint2(ent1,ent2)
		if(ent1:IsPlayer() && ent1:IsAdmin() && ent1:KeyDown(IN_SPEED) && ent1:Alive() && ent1.SUPERMODE && ent1 != GetWorldEntity())then
			local dmg=DamageInfo();
			dmg:SetAttacker(ent1)
			dmg:SetInflictor(ent1)
			dmg:SetDamage(100);//a combine ball does heavy damage,tought you are not a combine ball,whatever...
			dmg:SetDamageType(DMG_DISSOLVE)
			dmg:SetDamageForce(ent1:GetAimVector()*900000)
			dmg:SetDamagePosition(ent2:GetPos())
			if SERVER && ent1:GetMoveType()==MOVETYPE_WALK && ent1:GetPos():Distance( ent2:GetPos() )<=200 && ent1:IsAdmin() && ent1:KeyDown(IN_SPEED) then 
			ent2:TakeDamageInfo(dmg)
			end
		end
end
hook.Add("ShouldCollide","SonicSprint2",SonicSprint2)

function SonicSprintDMG2(victim, attacker)
	if(victim:IsPlayer() && victim:IsAdmin() && victim:KeyDown(IN_SPEED) && victim:Alive() && victim.SUPERMODE)then
		return false;
	end
end
 
hook.Add( "PlayerShouldTakeDamage", "SonicSprintDMG2", SonicSprintDMG2)


function SmodeKill(player, command, arguments)
	if (!player:IsAdmin()) then return end
	local pos=player:GetEyeTrace().HitPos
	if !(player:GetEyeTrace().Entity && IsValid(player:GetEyeTrace().Entity))then return end
	local ent=player:GetEyeTrace().Entity;
	local Num=player.SUPERMODE;
			local DMG=DamageInfo();
			DMG:SetDamage(50);
			DMG:SetDamageForce(player:GetAimVector())
				DMG:SetDamageType(DMG_BLAST);//The Super admin mode will do the rest
			DMG:SetAttacker(player);
			if!(player:GetActiveWeapon()==NULL)then
				DMG:SetInflictor(player:GetActiveWeapon());
			else
			DMG:SetInflictor(player);
			end
			ent:TakeDamageInfo(DMG);
end
concommand.Add( "admin_kill",SmodeKill )


//Every mode has it's powers.
//The dissolve dmg plays the combball proximity sound,and when you die by that,your body will dissolve
//The blast dmg just creates an explosion,and makes the receiver half deaf.
//The burn dmg just ignite the target for how much the damage is,EG:grav gun punt=1 dmg,1 second burn.
//The shock damage just creates (automatically) sparks on the target,the target will play the rollermine shock
//The sonic damage does not do anything but on the player (internal bleeding detected),the target will play the sniper sound.
local function AdminSmodeDmg( ent, inflictor, attacker, amount, dmginfo )

	local InflictClass 	= inflictor:GetClass()
	local AttackClass = attacker:GetClass();

	if (!inflictor:IsValid()) then return end
	if (!attacker:IsValid()) then return end
	if( (attacker:IsPlayer() && attacker:IsAdmin() )|| (inflictor:IsPlayer() && inflictor:IsAdmin()))then
		if(attacker.SUPERMODE==1 || inflictor.SUPERMODE==1 )then
			local heal=math.Round(dmginfo:GetDamage()/5)
			local current=attacker:Health();
			local max=attacker:GetMaxHealth();
							if current <= (max - heal) then
									attacker:SetHealth( current + heal )
							else
									attacker:SetHealth( max )
							end
			dmginfo:SetDamageType(DMG_DISSOLVE);
			ent:EmitSound("NPC_CombineBall.WhizFlyby")
		elseif(attacker.SUPERMODE==2 || inflictor.SUPERMODE==2 )then
		dmginfo:SetDamageType(DMG_BLAST);
				local expl = ents.Create("env_explosion")
				dmginfo:ScaleDamage(1.5);
				expl:SetKeyValue("spawnflags",128)
				expl:SetPos(ent:GetPos())
				expl:Spawn()
				expl:Fire("explode","",0)
		elseif(attacker.SUPERMODE==3 || inflictor.SUPERMODE==3 )then
		dmginfo:SetDamageType(DMG_BURN);
		ent:Extinguish()
		ent:Ignite( dmginfo:GetDamage(), 0 )
		elseif(attacker.SUPERMODE==4 || inflictor.SUPERMODE==4 )then
		dmginfo:SetDamageType(DMG_SHOCK);
		if(attacker:WaterLevel()>0)then
			dmginfo:ScaleDamage(3);
		end
		ent:EmitSound("NPC_RollerMine.Shock");
		elseif(attacker.SUPERMODE==5 || inflictor.SUPERMODE==5 )then
		dmginfo:SetDamageType(DMG_SONIC);
		dmginfo:SetDamageForce(dmginfo:GetDamageForce()*9999999);
		ent:EmitSound("npc/sniper/sniper1.wav");
		end
	
	end
	
end

hook.Add( "EntityTakeDamage", "AdminSmodeDmg", AdminSmodeDmg )
