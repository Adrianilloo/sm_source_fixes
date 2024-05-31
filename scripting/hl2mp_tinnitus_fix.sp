#include "base"
#include <smlib/clients>

#pragma semicolon 1
#pragma newdecls  required

public Plugin myinfo =
{
	name = "HL2MP Tinnitus Fix",
	author = "AdRiAnIlloO",
	description = "Blocks Half-Life 2: Deathmatch explosions ringing noise",
	version = "1.0"
}

DynamicHook gExplosionDamageHook;

public void OnPluginStart()
{
	gExplosionDamageHook = LoadDHooksOffset("dhooks.hl2mp_tinnitus_fix", "OnDamagedByExplosion");

	if (StartHandleLateLoad())
	{
		LOOP_CLIENTS(i, CLIENTFILTER_NOBOTS)
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(int client)
{
	if (!IsFakeClient(client))
	{
		gExplosionDamageHook.HookEntity(Hook_Pre, client, OnClientDamagedByExplosion);
	}
}

MRESReturn OnClientDamagedByExplosion(DHookParam params)
{
	return MRES_Supercede; // Prevent ear ringing sound, which may play infinitely (engine DSP bug)
}
