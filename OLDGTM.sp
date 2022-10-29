#include <sourcemod>
#include <cstrike>
#include <sdkhooks>
#include <sdktools>

#pragma semicolon 1
#pragma newdecls required

float ga_iLastPos[MAXPLAYERS + 1][3];

// Entity index, entity reference
int ga_iLastGun[MAXPLAYERS + 1][2];

public Plugin myinfo = 
{
	name = "GunThrowMeasure",
	author = "technyk",
	description = "A plugin made to measure the distance of gun throws",
	version = "1.0",
	url = "https://github.com/technyk"
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, int err_max)
{
	EngineVersion g_engineversion = GetEngineVersion();
	if (g_engineversion != Engine_CSGO)
	{
		SetFailState("This plugin was made for use with Counter-Strike: Global Offensive only.");
	}
}

public void OnPluginStart()
{
	HookEvent("player_death", Event_PlayerDeath, EventHookMode_Pre);
}

public void OnClientPutInServer(int client){
	
	SDKHook(client, SDKHook_WeaponDrop, OnWeaponDrop);
	
}

Action OnWeaponDrop(int client, int weapon){
	
	if(weapon != -1){
		float position[3];
		GetEntPropVector(client, Prop_Data, "m_vecAbsOrigin", position);
		
		ga_iLastGun[client][0] = weapon;
		ga_iLastGun[client][1] = EntIndexToEntRef(weapon);
		
		
		ga_iLastPos[client][0] = position[0];
		ga_iLastPos[client][1] = position[1];
		ga_iLastPos[client][2] = position[2];
		
		return Plugin_Continue;
	}
	
	return Plugin_Continue;
	
}

public void OnGameFrame(){
	
	for(int i = 1; i < sizeof(ga_iLastGun); i++) {
		
		if(ga_iLastGun[i][0] != -1 && ga_iLastGun[i][0] != 0){
			
			if(EntRefToEntIndex(ga_iLastGun[i][1]) != INVALID_ENT_REFERENCE && IsClientInGame(i)){
			
				int flags = GetEntProp(ga_iLastGun[i][0], Prop_Data, "m_iEFlags");
				int m_iState = GetEntProp(ga_iLastGun[i][0], Prop_Send, "m_iState");
				
				if(flags & (1<<22)){
					
					if(m_iState == 0){
						
						float plrPos[3];
						plrPos = ga_iLastPos[i];
						
						float gunPos[3];
						GetEntPropVector(ga_iLastGun[i][0], Prop_Data, "m_vecAbsOrigin", gunPos);
						
						float distance = GetVectorDistance(plrPos, gunPos);
						
						char plrName[64];
						GetClientName(i, plrName, sizeof(plrName));
						
						PrintToChatAll(" \x04%s \x01hodil zbraň do dálky \x04%f \x01jednotek", plrName, distance);
						
						ga_iLastGun[i][0] = 0;
						ga_iLastGun[i][1] = 0;
						ga_iLastPos[i][0] = 0.0;
						ga_iLastPos[i][1] = 0.0;
						ga_iLastPos[i][2] = 0.0;
						
					}
					
				}
			
			}else{
	
				ga_iLastGun[i][0] = 0;
				ga_iLastGun[i][1] = 0;
				ga_iLastPos[i][0] = 0.0;
				ga_iLastPos[i][1] = 0.0;
				ga_iLastPos[i][2] = 0.0;

			}
		
		}
		
	}
	
}


public Action Event_PlayerDeath(Event event, const char[] name, bool dontBroadcast){
	
	event.SetBool("headshot", true);
	return Plugin_Continue;
	
}
