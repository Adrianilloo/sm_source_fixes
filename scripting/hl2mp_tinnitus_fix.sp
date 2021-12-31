#include "base"
#include <sdkhooks>
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

public void OnPluginStart()
{
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
		SDKHook(client, SDKHook_OnTakeDamage, OnClientTakeDamage);
	}
}

Action OnClientTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damageType)
{
	// Prevent explosion ringing noise, which could also stay in an infinite loop
	damageType &= ~DMG_BLAST;
	return Plugin_Changed;
}
