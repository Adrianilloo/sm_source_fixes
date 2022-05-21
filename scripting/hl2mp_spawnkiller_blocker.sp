#include "base"

#pragma semicolon 1
#pragma newdecls  required

public Plugin myinfo =
{
	name = "HL2MP Spawn Killer Blocker",
	author = "AdRiAnIlloO",
	description = "Prevents nearby players auto kill upon spawning in Half-Life 2: Deathmatch",
	version = "1.0"
}

DynamicHook gValidSpawnPointHook;

public void OnMapStart()
{
	delete gValidSpawnPointHook;
	gValidSpawnPointHook = LoadDHooksOffset("dhooks.hl2mp_spawnkiller_blocker", "IsSpawnPointValid");
	DHookGamerules(gValidSpawnPointHook, false, _, IsSpawnPointValid);
}

MRESReturn IsSpawnPointValid(DHookReturn hReturn, DHookParam params)
{
	DHookSetReturn(hReturn, true);
	return MRES_Supercede;
}
