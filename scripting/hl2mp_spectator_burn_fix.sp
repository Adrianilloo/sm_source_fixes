#include <smlib>

#pragma semicolon 1
#pragma newdecls  required

public Plugin myinfo =
{
	name = "Spectator Burn Fix",
	author = "AdRiAnIlloO",
	description = "Finishes players ignition as soon as they join spectate, to prevent burning active players",
	version = "1.0"
}

public void OnPluginStart()
{
	HookEvent("player_team", OnPlayerChangeTeam);
}

void OnPlayerChangeTeam(Event event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(event.GetInt("userid"));

	if (client > 0 && event.GetInt("team") == TEAM_SPECTATOR)
	{
		char class[MAX_NAME_LENGTH];
		int entity = GetEntPropEnt(client, Prop_Data, "m_hEffectEntity");

		if (entity > INVALID_ENT_REFERENCE && GetEntityNetClass(entity, class, sizeof(class))
			&& StrEqual(class, "CEntityFlame"))
		{
			RemoveEntity(entity);
		}
	}
}
