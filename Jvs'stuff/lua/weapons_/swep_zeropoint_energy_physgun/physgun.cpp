//========= Copyright © 1996-2005, Valve Corporation, All rights reserved. ============//
//
// Purpose: 
//
// $NoKeywords: $
//=============================================================================//


ConVar phys_gunmass("phys_gunmass", "200");
ConVar phys_gunvel("phys_gunvel", "400");
ConVar phys_gunforce("phys_gunforce", "5e5" );
ConVar phys_guntorque("phys_guntorque", "100" );

static int g_physgunBeam;
#define PHYSGUN_BEAM_SPRITE		"sprites/physbeam.vmt"


class CWeaponGravityGun;

class CGravControllerPoint : public IMotionEvent
{
	DECLARE_SIMPLE_DATADESC();

public:
	CGravControllerPoint( void );
	~CGravControllerPoint( void );
	void AttachEntity( CBaseEntity *pEntity, IPhysicsObject *pPhys, const Vector &position );
	void DetachEntity( void );
	void SetMaxVelocity( float maxVel )
	{
		m_maxVel = maxVel;
	}
	void SetTargetPosition( const Vector &target )
	{
		m_targetPosition = target;
		if ( m_attachedEntity == NULL )
		{
			m_worldPosition = target;
		}
		m_timeToArrive = gpGlobals->frametime;
	}

	void SetAutoAlign( const Vector &localDir, const Vector &localPos, const Vector &worldAlignDir, const Vector &worldAlignPos )
	{
		m_align = true;
		m_localAlignNormal = -localDir;
		m_localAlignPosition = localPos;
		m_targetAlignNormal = worldAlignDir;
		m_targetAlignPosition = worldAlignPos;
	}

	void ClearAutoAlign()
	{
		m_align = false;
	}

	IMotionEvent::simresult_e Simulate( IPhysicsMotionController *pController, IPhysicsObject *pObject, float deltaTime, Vector &linear, AngularImpulse &angular );
	Vector			m_localPosition;
	Vector			m_targetPosition;
	Vector			m_worldPosition;
	Vector			m_localAlignNormal;
	Vector			m_localAlignPosition;
	Vector			m_targetAlignNormal;
	Vector			m_targetAlignPosition;
	bool			m_align;
	float			m_saveDamping;
	float			m_maxVel;
	float			m_maxAcceleration;
	Vector			m_maxAngularAcceleration;
	EHANDLE			m_attachedEntity;
	QAngle			m_targetRotation;
	float			m_timeToArrive;

	IPhysicsMotionController *m_controller;
};


BEGIN_SIMPLE_DATADESC( CGravControllerPoint )

	DEFINE_FIELD( m_localPosition,		FIELD_VECTOR ),
	DEFINE_FIELD( m_targetPosition,		FIELD_POSITION_VECTOR ),
	DEFINE_FIELD( m_worldPosition,		FIELD_POSITION_VECTOR ),
	DEFINE_FIELD( m_localAlignNormal,		FIELD_VECTOR ),
	DEFINE_FIELD( m_localAlignPosition,	FIELD_VECTOR ),
	DEFINE_FIELD( m_targetAlignNormal,	FIELD_VECTOR ),
	DEFINE_FIELD( m_targetAlignPosition,	FIELD_POSITION_VECTOR ),
	DEFINE_FIELD( m_align,				FIELD_BOOLEAN ),
	DEFINE_FIELD( m_saveDamping,			FIELD_FLOAT ),
	DEFINE_FIELD( m_maxVel,				FIELD_FLOAT ),
	DEFINE_FIELD( m_maxAcceleration,		FIELD_FLOAT ),
	DEFINE_FIELD( m_maxAngularAcceleration,	FIELD_VECTOR ),
	DEFINE_FIELD( m_attachedEntity,		FIELD_EHANDLE ),
	DEFINE_FIELD( m_targetRotation,		FIELD_VECTOR ),
	DEFINE_FIELD( m_timeToArrive,			FIELD_FLOAT ),

	// Physptrs can't be saved in embedded classes... this is to silence classcheck
	// DEFINE_PHYSPTR( m_controller ),

END_DATADESC()


CGravControllerPoint::CGravControllerPoint( void )
{
	m_attachedEntity = NULL;
}

CGravControllerPoint::~CGravControllerPoint( void )
{
	DetachEntity();
}


void CGravControllerPoint::AttachEntity( CBaseEntity *pEntity, IPhysicsObject *pPhys, const Vector &position )
{
	m_attachedEntity = pEntity;
	pPhys->WorldToLocal( &m_localPosition, position );
	m_worldPosition = position;
	pPhys->GetDamping( NULL, &m_saveDamping );
	float damping = 2;
	pPhys->SetDamping( NULL, &damping );
	m_controller = physenv->CreateMotionController( this );
	m_controller->AttachObject( pPhys, true );
	m_controller->SetPriority( IPhysicsMotionController::HIGH_PRIORITY );
	SetTargetPosition( position );
	m_maxAcceleration = phys_gunforce.GetFloat() * pPhys->GetInvMass();
	m_targetRotation = pEntity->GetAbsAngles();
	float torque = phys_guntorque.GetFloat();
	m_maxAngularAcceleration = torque * pPhys->GetInvInertia();
}

void CGravControllerPoint::DetachEntity( void )
{
	CBaseEntity *pEntity = m_attachedEntity;
	if ( pEntity )
	{
		IPhysicsObject *pPhys = pEntity->VPhysicsGetObject();
		if ( pPhys )
		{
			// on the odd chance that it's gone to sleep while under anti-gravity
			pPhys->Wake();
			pPhys->SetDamping( NULL, &m_saveDamping );
		}
	}
	m_attachedEntity = NULL;
	physenv->DestroyMotionController( m_controller );
	m_controller = NULL;

	// UNDONE: Does this help the networking?
	m_targetPosition = vec3_origin;
	m_worldPosition = vec3_origin;
}


IMotionEvent::simresult_e CGravControllerPoint::Simulate( IPhysicsMotionController *pController, IPhysicsObject *pObject, float deltaTime, Vector &linear, AngularImpulse &angular )
{
	//Jvs:thank god we have the shadow parameter controller
}



m_active
m_useDown;
m_hObject;
m_distance;
m_movementLength;
m_lastYaw;
m_soundState;
m_originalObjectPosition;
m_gravCallback;

};

IMPLEMENT_SERVERCLASS_ST( CWeaponGravityGun, DT_WeaponGravityGun )
	SendPropVector( SENDINFO_NAME(m_gravCallback.m_targetPosition, m_targetPosition), -1, SPROP_COORD ),
	SendPropVector( SENDINFO_NAME(m_gravCallback.m_worldPosition, m_worldPosition), -1, SPROP_COORD ),
	SendPropInt( SENDINFO(m_active), 1, SPROP_UNSIGNED ),
	SendPropModelIndex( SENDINFO(m_viewModelIndex) ),
END_SEND_TABLE()

LINK_ENTITY_TO_CLASS( weapon_physgun, CWeaponGravityGun );


enum physgun_soundstate { SS_SCANNING, SS_LOCKEDON };
enum physgun_soundIndex { SI_LOCKEDON = 0, SI_SCANNING = 1, SI_LIGHTOBJECT = 2, SI_HEAVYOBJECT = 3, SI_ON, SI_OFF };


//=========================================================
//=========================================================

CWeaponGravityGun::CWeaponGravityGun()
{
	m_active = false;
	m_bFiresUnderwater = true;

}

//=========================================================
//=========================================================

//=========================================================
//=========================================================
void CWeaponGravityGun::Precache( void )
{
	BaseClass::Precache();

	g_physgunBeam = PrecacheModel(PHYSGUN_BEAM_SPRITE);

	PrecacheScriptSound( "Weapon_Physgun.Scanning" );
	PrecacheScriptSound( "Weapon_Physgun.LockedOn" );
	PrecacheScriptSound( "Weapon_Physgun.Scanning" );
	PrecacheScriptSound( "Weapon_Physgun.LightObject" );
	PrecacheScriptSound( "Weapon_Physgun.HeavyObject" );
}

void CWeaponGravityGun::EffectCreate( void )
{
	EffectUpdate();
	m_active = true;
}


void CWeaponGravityGun::EffectUpdate( void )
{
	Vector start, angles, forward, right;
	trace_t tr;

	CBasePlayer *pOwner = ToBasePlayer( GetOwner() );
	if ( !pOwner )
		return;

	m_viewModelIndex = pOwner->entindex();
	// Make sure I've got a view model
	CBaseViewModel *vm = pOwner->GetViewModel();
	if ( vm )
	{
		m_viewModelIndex = vm->entindex();
	}

	pOwner->EyeVectors( &forward, &right, NULL );

	start = pOwner->Weapon_ShootPosition();
	Vector end = start + forward * 4096;

	UTIL_TraceLine( start, end, MASK_SHOT, pOwner, COLLISION_GROUP_NONE, &tr );
	end = tr.endpos;
	float distance = tr.fraction * 4096;
	if ( tr.fraction != 1 )
	{
		// too close to the player, drop the object
		if ( distance < 36 )
		{
			DetachObject();
			return;
		}
	}

	if ( m_hObject == NULL && tr.DidHitNonWorldEntity() )
	{
		CBaseEntity *pEntity = tr.m_pEnt;
		// inform the object what was hit
		ClearMultiDamage();
		pEntity->DispatchTraceAttack( CTakeDamageInfo( pOwner, pOwner, 0, DMG_PHYSGUN ), forward, &tr );
		ApplyMultiDamage();
		AttachObject( pEntity, start, tr.endpos, distance );
		m_lastYaw = pOwner->EyeAngles().y;
	}

	// Add the incremental player yaw to the target transform
	matrix3x4_t curMatrix, incMatrix, nextMatrix;
	AngleMatrix( m_gravCallback.m_targetRotation, curMatrix );
	AngleMatrix( QAngle(0,pOwner->EyeAngles().y - m_lastYaw,0), incMatrix );
	ConcatTransforms( incMatrix, curMatrix, nextMatrix );
	MatrixAngles( nextMatrix, m_gravCallback.m_targetRotation );
	m_lastYaw = pOwner->EyeAngles().y;

	CBaseEntity *pObject = m_hObject;
	if ( pObject )
	{
		if ( m_useDown )
		{
			if ( pOwner->m_afButtonPressed & IN_USE )
			{
				m_useDown = false;
			}
		}
		else 
		{
			if ( pOwner->m_afButtonPressed & IN_USE )
			{
				m_useDown = true;
			}
		}

		if ( m_useDown )
		{
			pOwner->SetPhysicsFlag( PFLAG_DIROVERRIDE, true );
			if ( pOwner->m_nButtons & IN_FORWARD )
			{
				m_distance = UTIL_Approach( 1024, m_distance, gpGlobals->frametime * 100 );
			}
			if ( pOwner->m_nButtons & IN_BACK )
			{
				m_distance = UTIL_Approach( 40, m_distance, gpGlobals->frametime * 100 );
			}
		}

		if ( pOwner->m_nButtons & IN_WEAPON1 )
		{
			m_distance = UTIL_Approach( 1024, m_distance, m_distance * 0.1 );
		}
		if ( pOwner->m_nButtons & IN_WEAPON2 )
		{
			m_distance = UTIL_Approach( 40, m_distance, m_distance * 0.1 );
		}

		// Send the object a physics damage message (0 damage). Some objects interpret this 
		// as something else being in control of their physics temporarily.
		pObject->TakeDamage( CTakeDamageInfo( this, pOwner, 0, DMG_PHYSGUN ) );

		Vector newPosition = start + forward * m_distance;
		// 24 is a little larger than 16 * sqrt(2) (extent of player bbox)
		// HACKHACK: We do this so we can "ignore" the player and the object we're manipulating
		// If we had a filter for tracelines, we could simply filter both ents and start from "start"
		Vector awayfromPlayer = start + forward * 24;

		UTIL_TraceLine( start, awayfromPlayer, MASK_SOLID, pOwner, COLLISION_GROUP_NONE, &tr );
		if ( tr.fraction == 1 )
		{
			UTIL_TraceLine( awayfromPlayer, newPosition, MASK_SOLID, pObject, COLLISION_GROUP_NONE, &tr );
			Vector dir = tr.endpos - newPosition;
			float distance = VectorNormalize(dir);
			float maxDist = m_gravCallback.m_maxVel * gpGlobals->frametime;
			if ( distance >  maxDist )
			{
				newPosition += dir * maxDist;
		}
		else
		{
			newPosition = tr.endpos;
		}
		}
		else
		{
			newPosition = tr.endpos;
		}

			
		m_gravCallback.SetTargetPosition( newPosition );
		Vector dir = (newPosition - pObject->GetLocalOrigin());
		m_movementLength = dir.Length();
	}
	else
	{
		m_gravCallback.SetTargetPosition( end );
	}
}

void CWeaponGravityGun::SoundCreate( void )
{
	m_soundState = SS_SCANNING;
	SoundStart();
}


void CWeaponGravityGun::SoundDestroy( void )
{
	SoundStop();
}


void CWeaponGravityGun::SoundStop( void )
{
	switch( m_soundState )
	{
	case SS_SCANNING:
		GetOwner()->StopSound( "Weapon_Physgun.Scanning" );
		break;
	case SS_LOCKEDON:
		GetOwner()->StopSound( "Weapon_Physgun.Scanning" );
		GetOwner()->StopSound( "Weapon_Physgun.LockedOn" );
		GetOwner()->StopSound( "Weapon_Physgun.LightObject" );
		GetOwner()->StopSound( "Weapon_Physgun.HeavyObject" );
		break;
	}
}



//-----------------------------------------------------------------------------
// Purpose: returns the linear fraction of value between low & high (0.0 - 1.0) * scale
//			e.g. UTIL_LineFraction( 1.5, 1, 2, 1 ); will return 0.5 since 1.5 is
//			halfway between 1 and 2
// Input  : value - a value between low & high (clamped)
//			low - the value that maps to zero
//			high - the value that maps to "scale"
//			scale - the output scale
// Output : parametric fraction between low & high
//-----------------------------------------------------------------------------
static float UTIL_LineFraction( float value, float low, float high, float scale )
{
	if ( value < low )
		value = low;
	if ( value > high )
		value = high;

	float delta = high - low;
	if ( delta == 0 )
		return 0;
	
	return scale * (value-low) / delta;
}

void CWeaponGravityGun::SoundStart( void )
{
	CPASAttenuationFilter filter( GetOwner() );
	filter.MakeReliable();

	switch( m_soundState )
	{
	case SS_SCANNING:
		{
			EmitSound( filter, GetOwner()->entindex(), "Weapon_Physgun.Scanning" );
		}
		break;
	case SS_LOCKEDON:
		{
			// BUGBUG - If you start a sound with a pitch of 100, the pitch shift doesn't work!
			
			EmitSound( filter, GetOwner()->entindex(), "Weapon_Physgun.LockedOn" );
			EmitSound( filter, GetOwner()->entindex(), "Weapon_Physgun.Scanning" );
			EmitSound( filter, GetOwner()->entindex(), "Weapon_Physgun.LightObject" );
			EmitSound( filter, GetOwner()->entindex(), "Weapon_Physgun.HeavyObject" );
		}
		break;
	}
													//   volume, att, flags, pitch
}

void CWeaponGravityGun::SoundUpdate( void )
{
	int newState;
	
	if ( m_hObject )
		newState = SS_LOCKEDON;
	else
		newState = SS_SCANNING;

	if ( newState != m_soundState )
	{
		SoundStop();
		m_soundState = newState;
		SoundStart();
	}

	switch( m_soundState )
	{
	case SS_SCANNING:
		break;
	case SS_LOCKEDON:
		{
			CPASAttenuationFilter filter( GetOwner() );
			filter.MakeReliable();

			float height = m_hObject->GetAbsOrigin().z - m_originalObjectPosition.z;

			// go from pitch 90 to 150 over a height of 500
			int pitch = 90 + (int)UTIL_LineFraction( height, 0, 500, 60 );

			CSoundParameters params;
			if ( GetParametersForSound( "Weapon_Physgun.LockedOn", params, NULL ) )
			{
				EmitSound_t ep( params );
				ep.m_nFlags = SND_CHANGE_VOL | SND_CHANGE_PITCH;
				ep.m_nPitch = pitch;

				EmitSound( filter, GetOwner()->entindex(), ep );
			}

			// attenutate the movement sounds over 200 units of movement
			float distance = UTIL_LineFraction( m_movementLength, 0, 200, 1.0 );

			// blend the "mass" sounds between 50 and 500 kg
			IPhysicsObject *pPhys = m_hObject->VPhysicsGetObject();
			
			float fade = UTIL_LineFraction( pPhys->GetMass(), 50, 500, 1.0 );

			if ( GetParametersForSound( "Weapon_Physgun.LightObject", params, NULL ) )
			{
				EmitSound_t ep( params );
				ep.m_nFlags = SND_CHANGE_VOL;
				ep.m_flVolume = fade * distance;

				EmitSound( filter, GetOwner()->entindex(), ep );
			}

			if ( GetParametersForSound( "Weapon_Physgun.HeavyObject", params, NULL ) )
			{
				EmitSound_t ep( params );
				ep.m_nFlags = SND_CHANGE_VOL;
				ep.m_flVolume = (1.0 - fade) * distance;

				EmitSound( filter, GetOwner()->entindex(), ep );
			}
		}
		break;
	}
}




CBaseEntity *CWeaponGravityGun::GetBeamEntity()
{
	CBasePlayer *pOwner = ToBasePlayer( GetOwner() );
	if ( !pOwner )
		return NULL;

	// Make sure I've got a view model
	CBaseViewModel *vm = pOwner->GetViewModel();
	if ( vm )
		return vm;

	return pOwner;
}




void CWeaponGravityGun::EffectDestroy( void )
{
	m_active = false;
	SoundStop();

	DetachObject();
}

void CWeaponGravityGun::DetachObject( void )
{
	if ( m_hObject )
	{
		CBasePlayer *pOwner = ToBasePlayer( GetOwner() );
		Pickup_OnPhysGunDrop( m_hObject, pOwner, DROPPED_BY_CANNON );

		m_gravCallback.DetachEntity();
		m_hObject = NULL;
	}
}

void CWeaponGravityGun::AttachObject( CBaseEntity *pObject, const Vector& start, const Vector &end, float distance )
{
	m_hObject = pObject;
	m_useDown = false;
	IPhysicsObject *pPhysics = pObject ? (pObject->VPhysicsGetObject()) : NULL;
	if ( pPhysics && pObject->GetMoveType() == MOVETYPE_VPHYSICS )
	{
		m_distance = distance;

		m_gravCallback.AttachEntity( pObject, pPhysics, end );
		float mass = pPhysics->GetMass();
		Msg( "Object mass: %.2f lbs (%.2f kg)\n", kg2lbs(mass), mass );
		float vel = phys_gunvel.GetFloat();
		if ( mass > phys_gunmass.GetFloat() )
		{
			vel = (vel*phys_gunmass.GetFloat())/mass;
		}
		m_gravCallback.SetMaxVelocity( vel );
//		Msg( "Object mass: %.2f lbs (%.2f kg) %f %f %f\n", kg2lbs(mass), mass, pObject->GetAbsOrigin().x, pObject->GetAbsOrigin().y, pObject->GetAbsOrigin().z );
//		Msg( "ANG: %f %f %f\n", pObject->GetAbsAngles().x, pObject->GetAbsAngles().y, pObject->GetAbsAngles().z );

		m_originalObjectPosition = pObject->GetAbsOrigin();

		pPhysics->Wake();
		
		CBasePlayer *pOwner = ToBasePlayer( GetOwner() );
		if( pOwner )
		{
			Pickup_OnPhysGunPickup( pObject, pOwner );
		}
	}
	else
	{
		m_hObject = NULL;
	}
}

//=========================================================
//=========================================================
void CWeaponGravityGun::PrimaryAttack( void )
{
	if ( !m_active )
	{
		SendWeaponAnim( ACT_VM_PRIMARYATTACK );
		EffectCreate();
		SoundCreate();
	}
	else
	{
		EffectUpdate();
		SoundUpdate();
	}
}


void CWeaponGravityGun::WeaponIdle( void )
{
	if ( HasWeaponIdleTimeElapsed() )
	{
		SendWeaponAnim( ACT_VM_IDLE );
		if ( m_active )
		{
			CBaseEntity *pObject = m_hObject;
			EffectDestroy();
			SoundDestroy();
		}
	}
}

