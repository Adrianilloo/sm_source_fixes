#include <base>
#include <smlib/clients>

#pragma semicolon 1
#pragma newdecls  required

public Plugin myinfo =
{
	name = "HL2MP Scores Fix",
	author = "AdRiAnIlloO",
	description = "Fixes Half-Life 2: Deathmatch team change scoring issues",
	version = "1.1"
}

enum struct STeamChangeInfo {
	int mOldClientScore;
	int mOldClientDeaths;
	int mOldTeam;
	int mOldTeamScore; // Old team's previous score
	int mNewTeamScore; // New team's previous score
}

bool gIsActive;
DynamicHook gChangeTeamHook, gJoinTeamHook;
ArrayList gTeamChangeInfo;

public void OnPluginStart()
{
	GameData data = new GameData("dhooks.hl2mp_scores_fix");
	gChangeTeamHook = LoadDHooksOffsetEx(data, "ChangeTeam");
	gJoinTeamHook = LoadDHooksOffsetEx(data, "HandleCommand_JoinTeam");
	delete data;
	gTeamChangeInfo = new ArrayList(sizeof(STeamChangeInfo));
}

public void OnMapStart()
{
	gIsActive = FindConVar("mp_teamplay").BoolValue;

	if (StartHandleLateLoad() && gIsActive)
	{
		LOOP_CLIENTS(i, CLIENTFILTER_ALL)
		{
			OnClientPutInServer(i);
		}
	}
}

public void OnClientPutInServer(int client)
{
	if (gIsActive)
	{
		gJoinTeamHook.HookEntity(Hook_Pre, client, OnClientJoinTeamPre);
		gChangeTeamHook.HookEntity(Hook_Pre, client, OnClientChangeTeamPre);
		gChangeTeamHook.HookEntity(Hook_Post, client, OnClientChangeTeamPost);
	}
}

MRESReturn OnClientJoinTeamPre(int client, DHookReturn hReturn, DHookParam params)
{
	gTeamChangeInfo.Clear(); // Just in case (this hook shouldn't be inside a ChangeTeam call)
	CacheClientScoreData(client, params);
	return MRES_Handled;
}

MRESReturn OnClientChangeTeamPre(int client, DHookParam params)
{
	if (gTeamChangeInfo.Length < 1) // As this hook might be inside a JoinTeam call, optimize that out
	{
		CacheClientScoreData(client, params);
	}

	return MRES_Handled;
}

void CacheClientScoreData(int client, DHookParam params)
{
	int oldTeam = GetClientTeam(client), newTeam = params.Get(1);

	if (newTeam != oldTeam)
	{
		// Cache all score data that may change at hook end, avoiding all logic around game assumptions
		STeamChangeInfo info;
		info.mOldClientScore = Client_GetScore(client);
		info.mOldClientDeaths = GetClientDeaths(client);
		info.mOldTeam = oldTeam;
		info.mOldTeamScore = GetTeamScore(info.mOldTeam);
		info.mNewTeamScore = GetTeamScore(newTeam);
		gTeamChangeInfo.PushArray(info);
	}
}

MRESReturn OnClientChangeTeamPost(int client, DHookParam params)
{
	if (gTeamChangeInfo.Length > 0)
	{
		STeamChangeInfo info;
		gTeamChangeInfo.GetArray(0, info);
		gTeamChangeInfo.Clear();
		Client_SetScore(client, info.mOldClientScore);
		Client_SetDeaths(client, info.mOldClientDeaths);
		SetTeamScore(info.mOldTeam, info.mOldTeamScore - info.mOldClientScore);
		SetTeamScore(params.Get(1), info.mNewTeamScore + info.mOldClientScore);
	}

	return MRES_Handled;
}
