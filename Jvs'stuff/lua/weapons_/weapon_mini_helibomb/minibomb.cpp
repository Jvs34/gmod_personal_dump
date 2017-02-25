

#define BOMB_LIFETIME	2.5f	// Don't access this directly. Call GetBombLifetime();
#define BOMB_RAMP_SOUND_TIME 1.0f

#define GRENADE_HELICOPTER_MODEL "models/combine_helicopter/helicopter_bomb01.mdl"



	DEFINE_FIELD( m_bActivated,			FIELD_BOOLEAN ),
	DEFINE_FIELD( m_bExplodeOnContact,	FIELD_BOOLEAN ),
	DEFINE_SOUNDPATCH( m_pWarnSound ),

	DEFINE_FIELD( m_hWarningSprite,		FIELD_EHANDLE ),
	DEFINE_FIELD( m_bBlinkerAtTop,		FIELD_BOOLEAN ),

	DEFINE_THINKFUNC( ExplodeThink ),
	DEFINE_THINKFUNC( AnimateThink ),
	DEFINE_THINKFUNC( RampSoundThink ),
	DEFINE_THINKFUNC( WarningBlinkerThink ),
	DEFINE_ENTITYFUNC( ExplodeConcussion ),

END_DATADESC()

#define SF_HELICOPTER_GRENADE_DUD	(1<<16)	// Will not become active on impact, only when launched via physcannon

//------------------------------------------------------------------------------
// Precache
//------------------------------------------------------------------------------
void CGrenadeHelicopter::Precache( void )
{
	BaseClass::Precache( );
	PrecacheModel( GRENADE_HELICOPTER_MODEL );

	PrecacheScriptSound( "ReallyLoudSpark" );
	PrecacheScriptSound( "NPC_AttackHelicopterGrenade.Ping" );
	PrecacheScriptSound( "NPC_AttackHelicopterGrenade.PingCaptured" );
	PrecacheScriptSound( "NPC_AttackHelicopterGrenade.HardImpact" );
}


//------------------------------------------------------------------------------
// Spawn
//------------------------------------------------------------------------------
void CGrenadeHelicopter::Spawn( void )
{
	Precache();

	// point sized, solid, bouncing
	SetCollisionGroup( COLLISION_GROUP_PROJECTILE );
	SetModel( GRENADE_HELICOPTER_MODEL );
	// use a lower gravity for grenades to make them easier to see
	
	m_bActivated = false;
	m_pWarnSound = NULL;
	m_bExplodeOnContact = false;

	m_flDamage = 50;

	g_pNotify->AddEntity( this, this );

}

void CGrenadeHelicopter::BecomeActive()
{

	m_bActivated = true;

	
	SetThink( &CGrenadeHelicopter::ExplodeThink );
	
	SetNextThink( gpGlobals->curtime + GetBombLifetime() );

		SetContextThink( &CGrenadeHelicopter::RampSoundThink, gpGlobals->curtime + GetBombLifetime() - BOMB_RAMP_SOUND_TIME, s_pRampSoundContext );

		CSoundEnvelopeController &controller = CSoundEnvelopeController::GetController();
		CReliableBroadcastRecipientFilter filter;
		m_pWarnSound = controller.SoundCreate( filter, entindex(), "NPC_AttackHelicopterGrenade.Ping" );
		controller.Play( m_pWarnSound, 1.0, PITCH_NORM );
	
	SetContextThink( &CGrenadeHelicopter::WarningBlinkerThink, gpGlobals->curtime + (GetBombLifetime() - 2.0f), s_pWarningBlinkerContext );

}


//------------------------------------------------------------------------------
// Pow!
//------------------------------------------------------------------------------
void CGrenadeHelicopter::RampSoundThink( )
{
	if ( m_pWarnSound )
	{
		CSoundEnvelopeController &controller = CSoundEnvelopeController::GetController();
		controller.SoundChangePitch( m_pWarnSound, 140, BOMB_RAMP_SOUND_TIME );
	}
}






//------------------------------------------------------------------------------
// If we hit something, start the timer
//------------------------------------------------------------------------------
void CGrenadeHelicopter::VPhysicsCollision( int index, gamevcollisionevent_t *pEvent )
{
	BaseClass::VPhysicsCollision( index, pEvent );
	BecomeActive();

	if ( m_bExplodeOnContact )
	{
		Vector vecVelocity;
		GetVelocity( &vecVelocity, NULL );
		DoExplosion( GetAbsOrigin(), vecVelocity );
	}
}


//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
float CGrenadeHelicopter::GetBombLifetime()
{
	return BOMB_LIFETIME;
}




//------------------------------------------------------------------------------
// Pow!
//------------------------------------------------------------------------------
void CGrenadeHelicopter::DoExplosion( const Vector &vecOrigin, const Vector &vecVelocity )
{

	if ( GetShakeAmplitude() )
	{
		UTIL_ScreenShake( GetAbsOrigin(), GetShakeAmplitude(), 150.0, 1.0, 250, SHAKE_START );
	}

	CEffectData data;

	// If we're under water do a water explosion
	if ( GetWaterLevel() != 0 && (GetWaterType() & CONTENTS_WATER) )
	{
		data.m_vOrigin = WorldSpaceCenter();
		data.m_flMagnitude = 128;
		data.m_flScale = 128;
		DispatchEffect( "WaterSurfaceExplosion", data );
	}
	else
	{
		// Otherwise do a normal explosion
		data.m_vOrigin = GetAbsOrigin();
		DispatchEffect( "HelicopterMegaBomb", data );
	}

	UTIL_Remove( this );
}


//------------------------------------------------------------------------------
// I think I Pow!
//------------------------------------------------------------------------------
void CGrenadeHelicopter::ExplodeThink(void)
{

	Vector vecVelocity;
	GetVelocity( &vecVelocity, NULL );
	DoExplosion( GetAbsOrigin(), vecVelocity );


}

