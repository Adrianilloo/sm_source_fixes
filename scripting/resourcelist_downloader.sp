#include <smlib/files>

#pragma semicolon 1
#pragma newdecls  required

public Plugin myinfo =
{
	name = "Resource List Downloader",
	author = "AdRiAnIlloO",
	description = "Provides an enhanced map resource lists (.res) downloader with full search paths support",
	version = "1.0"
}

public void OnMapStart()
{
	char path[PLATFORM_MAX_PATH];
	GetCurrentMap(path, sizeof(path));
	Format(path, sizeof(path), "maps/%s.res", path);
	KeyValues resources = new KeyValues("Resources");

	if (resources.ImportFromFile(path) && resources.GotoFirstSubKey(false))
	{
		do
		{
			resources.GetSectionName(path, sizeof(path));
			File_AddToDownloadsTable(path, false);
		}
		while(resources.GotoNextKey(false));
	}

	delete resources;
}
