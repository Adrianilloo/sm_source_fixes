#include "base"
#include <smlib>

#pragma semicolon 1
#pragma newdecls  required

public Plugin myinfo =
{
	name = "TestActivator Fix",
	author = "AdRiAnIlloO",
	description = "Fixes server crash when TestActivator input is called with an invalid activator",
	version = "1.1"
}

#define OFFSET_NAME "AcceptInput"

DynamicHook gAcceptInputHook;

public void OnPluginStart()
{
	GameData data = new GameData("dhooks.testactivator_fix"); // Cache function definition first (required)
	char path[PLATFORM_MAX_PATH];
	int baseLen = BuildPath(Path_SM, path, sizeof(path), "gamedata/"),
		sdkToolsLen = baseLen + strcopy(path[baseLen], sizeof(path) - baseLen, "sdktools.games/"),
		len = sdkToolsLen + strcopy(path[sdkToolsLen], sizeof(path) - sdkToolsLen, "custom/");
	DirectoryListing overrides = OpenDirectory(path);

	// Load offset from custom gamedata overrides first, if any
	if (overrides != null)
	{
		for (FileType type; gAcceptInputHook == null && overrides.GetNext(path[len], sizeof(path) - len, type);)
		{
			if (type == FileType_File)
			{
				File_GetFileName(path[len], path[len], sizeof(path) - len);
				gAcceptInputHook = LoadDHooksOffset(path[baseLen], OFFSET_NAME, false);
			}
		}

		delete overrides;
	}

	if (gAcceptInputHook == null)
	{
		len = sdkToolsLen + strcopy(path[sdkToolsLen], sizeof(path) - sdkToolsLen, "game.");
		GetGameFolderName(path[len], sizeof(path) - len);
		gAcceptInputHook = LoadDHooksOffset(path[baseLen], OFFSET_NAME);
	}

	delete data;

	if (StartHandleLateLoad())
	{
		for (int i = GetMaxEntities(); i < 4096; ++i)
		{
			if (IsValidEntity(i))
			{
				OnEntityCreated(i);
			}
		}
	}
}

public void OnEntityCreated(int entity)
{
	if (!IsValidEdict(entity)) // Optimize out - Filters are logical entities
	{
		char classname[MAX_NAME_LENGTH];
		GetEntityClassname(entity, classname, sizeof(classname));

		if (String_StartsWith(classname, "filter_"))
		{
			gAcceptInputHook.HookEntity(Hook_Pre, entity, OnFilterAcceptInput);
		}
	}
}

MRESReturn OnFilterAcceptInput(DHookReturn hReturn, DHookParam params)
{
	if (params.IsNull(2)) // Invalid activator?
	{
		char input[MAX_NAME_LENGTH];
		params.GetString(1, input, sizeof(input));

		if (StrEqual(input, "TestActivator", false))
		{
			hReturn.Value = false;
			return MRES_Supercede;
		}
	}

	return MRES_Ignored;
}
