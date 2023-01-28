#pragma semicolon 1
#pragma newdecls required

#include <sdktools>
#include <sdkhooks>

#define MAX_FILE_LEN 128

Handle
	hSound,
	hTimerRing,
	hTimerCircle,
	hTimerEffect;

int
	iBeamSprite,
	iHaloSprite,
	iIndex,
	iBombTime,
	iBall,
	iBall_2,
	iBall_3,
	iLgtning,
	iSteam1,
	iEffect,
	Engine_Version;

char
	sSound[MAX_FILE_LEN];

#define GAME_UNDEFINED 0
#define GAME_CSS_34 1
#define GAME_CSS 2
#define GAME_CSGO 3

int GetCSGame()
{
	if (GetFeatureStatus(FeatureType_Native, "GetEngineVersion") == FeatureStatus_Available) 
	{ 
		switch (GetEngineVersion()) 
		{ 
			case Engine_SourceSDK2006: return GAME_CSS_34; 
			case Engine_CSS: return GAME_CSS; 
			case Engine_CSGO: return GAME_CSGO; 
		} 
	}
	return GAME_UNDEFINED;
}

public Plugin myinfo = 
{
	name = "[Any] Bomb Effects+",
	author = "Nek.'a 2x2 | ggwp.site",
	description = "Эффект установленной бомбы и звуки",
	version = "1.3.5.8",
	url = "https://ggwp.site/"
}

public APLRes AskPluginLoad2()
{
	Engine_Version = GetCSGame();
	if(Engine_Version == GAME_UNDEFINED)
		SetFailState("Game is not supported!");
}

public void OnPluginStart()
{	
	if(Engine_Version != GAME_CSGO)
		hSound = CreateConVar("sm_bombeffect_sound", "bomb/bombpl.wav", "Путь к звуку");
	
	HookEvent("bomb_planted", Event_BombPlanted);
	HookEvent("round_end", Event_End);
	HookEvent("round_start", Event_End);
}

public void OnMapStart()
{
	if(Engine_Version != GAME_CSGO)
	{
		iBeamSprite = PrecacheModel("sprites/laser.vmt");
		iHaloSprite = PrecacheModel("sprites/halo01.vmt");
		GetConVarString(hSound, sSound, MAX_FILE_LEN);
		char buffer[MAX_FILE_LEN];
		if(sSound[0])
			PrecacheSound(sSound, true);
		Format(buffer, sizeof(buffer), "sound/%s", sSound);
		AddFileToDownloadsTable(buffer);
	}
	else
	{
		iBeamSprite = PrecacheModel("sprites/laserbeam.vmt");
		iHaloSprite = PrecacheModel("sprites/halo.vmt");
	}
	
	AddFileToDownloadsTable("materials/ggwp/bomb_effect/effect3.vmt");
	AddFileToDownloadsTable("materials/ggwp/bomb_effect/effect3.vtf");
	AddFileToDownloadsTable("materials/ggwp/bomb_effect/effect9.vmt");
	AddFileToDownloadsTable("materials/ggwp/bomb_effect/effect9.vtf");
	PrecacheModel("ggwp/bomb_effect/effect3.vmt", true);
	PrecacheModel("ggwp/bomb_effect/effect9.vmt", true);
	PrecacheSound("ambient/machines/zap1.wav", true);
	iSteam1 = PrecacheModel("sprites/steam1.vmt", false);
	iLgtning = PrecacheModel("sprites/lgtning.vmt", false);
}

public void Event_BombPlanted(Handle event, const char[] name, bool dontBroadcast)
{
	if(IsSoundPrecached(sSound))
		EmitSoundToAll(sSound);

	bool bRndOne = view_as<bool>(GetRandomInt(0, 1));
	float pos[3];
	if(!bRndOne)
	{
		iIndex = FindEntityByClassname(MaxClients + 1, "planted_c4");
		if(iIndex == -1)
		return;
		iEffect = EntIndexToEntRef(iIndex);
		hTimerEffect = CreateTimer(1.0, TimerEffect, iEffect, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
		GetEntPropVector(iIndex, Prop_Data, "m_vecOrigin", pos, 0);
		pos[2] += 20.0;
		TeleportEntity(iIndex, pos, NULL_VECTOR, NULL_VECTOR);
		FunctionCircle(pos);
	}
	
	if(bRndOne)
	{
		bool bRndTo = view_as<bool>(GetRandomInt(0, 1));
		float pos_[3], startPos[3], direction[3];
		int color[4] = {255, 0, 0, 0};
		startPos[0] = pos_[0] + GetRandomInt(-500, 500);
		startPos[1] = pos_[1] + GetRandomInt(-500, 500);
		startPos[2] = pos_[2] + 800;
		if ((iIndex = FindEntityByClassname(-1, "planted_c4")) != -1)
		{
			iBall = CreateEntityByName("point_tesla", -1);
			if (iBall != -1)
			{
				float lastPos[3];
				GetEntPropVector(iIndex, Prop_Send, "m_vecOrigin", lastPos, 0);
				DispatchKeyValueVector(iBall, "Origin", lastPos);
				DispatchKeyValue(iBall, "m_flRadius", "50.0");
				DispatchKeyValue(iBall, "m_SoundName", "DoSpark");
				DispatchKeyValue(iBall, "beamcount_min", "42");
				DispatchKeyValue(iBall, "beamcount_max", "62");
				DispatchKeyValue(iBall, "texture", "sprites/physbeam.vmt");
				DispatchKeyValue(iBall, "m_Color", "255 255 255");
				DispatchKeyValue(iBall, "thick_min", "10.0");
				DispatchKeyValue(iBall, "thick_max", "11.0");
				DispatchKeyValue(iBall, "lifetime_min", "0.3");
				DispatchKeyValue(iBall, "lifetime_max", "0.3");
				DispatchKeyValue(iBall, "interval_min", "0.1");
				DispatchKeyValue(iBall, "interval_max", "0.2");
				DispatchSpawn(iBall);
				ActivateEntity(iBall);
				AcceptEntityInput(iBall, "DoSpark", -1, -1, 0);
				AcceptEntityInput(iBall, "TurnOn", -1, -1, 0);
				SetVariantString("OnUser1 !self:kill::5.0:1");
				AcceptEntityInput(iBall, "AddOutput", -1, -1, 0);
				AcceptEntityInput(iBall, "FireUser1", -1, -1, 0);
				iBall_2 = CreateEntityByName("env_sprite", -1);
				if (iBall_2 != -1)
				{
					if(!bRndTo) DispatchKeyValue(iBall_2, "model", "ggwp/bomb_effect/effect3.vmt");
					if(bRndTo) DispatchKeyValue(iBall_2, "model", "ggwp/bomb_effect/effect9.vmt");
					DispatchKeyValue(iBall_2, "rendermode", "1");
					DispatchKeyValue(iBall_2, "spawnflags", "1");
					DispatchKeyValue(iBall_2, "rendercolor", "0 0 0");
					DispatchKeyValue(iBall_2, "renderfx", "0");
					DispatchKeyValue(iBall_2, "renderamt", "255");
					DispatchKeyValue(iBall_2, "scale", "0.7");
					DispatchKeyValue(iBall_2, "GlowProxySize", "1");
					DispatchSpawn(iBall_2);
					lastPos[2] += 85.0;
					TeleportEntity(iBall_2, lastPos, NULL_VECTOR, NULL_VECTOR);
					AcceptEntityInput(iBall_2, "ShowSprite", -1, -1, 0);
					iBall_3 = CreateEntityByName("env_spark", -1);
					if (iBall_3 != -1)
					{
						GetEntPropVector(iIndex, Prop_Send, "m_vecOrigin", lastPos, 0);
						DispatchKeyValueVector(iBall_3, "Origin", lastPos);
						DispatchKeyValue(iBall_3, "spawnflags", "896");
						DispatchKeyValue(iBall_3, "angles", "-90 0 0");
						DispatchKeyValue(iBall_3, "magnitude", "8");
						DispatchKeyValue(iBall_3, "traillength", "5");
						DispatchKeyValue(iBall_3, "m_SoundName", "DoSpark");
						DispatchSpawn(iBall_3);
						ActivateEntity(iBall_3);
						AcceptEntityInput(iBall_3, "DoSpark", -1, -1, 0);
						AcceptEntityInput(iBall_3, "Enable", -1, -1, 0);
						AcceptEntityInput(iBall_3, "StartSpark", -1, -1, 0);
						EmitAmbientSound("sound/ambient/machines/zap1.wav", lastPos, 0, 75, 0, 1.0, 100, 0.0);
					}
				}
				TE_SetupBeamPoints(startPos, lastPos, iLgtning, 0, 0, 0, 0.2, 20.0, 10.0, 0, 2.0, color, 3);
				TE_SendToAll();
				TE_SetupBeamPoints(startPos, lastPos, iLgtning, 0, 0, 0, 0.2, 10.0, 5.0, 0, 1.0, {255, 255, 255, 255}, 3);
				TE_SendToAll();
				TE_SetupSparks(lastPos, direction, 5000, 1000);
				TE_SendToAll();
				TE_SetupEnergySplash(lastPos, direction, false);
				TE_SendToAll();
				TE_SetupSmoke(lastPos, iSteam1, 5.0, 10);
				TE_SendToAll();
			}
		}
	}
}

void FunctionCircle(float pos[3])
{
	int color[4]; color[0] = GetRandomInt(0, 255); color[1] = GetRandomInt(0, 255); color[2] = GetRandomInt(0, 255); color[3] = 255;
	float dir[3] = 0.0;
	pos[2] += 10.0;
	TE_SetupBeamRingPoint(pos, 50.0, 60.0, iHaloSprite, iBeamSprite, 0, 15, 1.0, 7.0, 2.0, color, 10, 0);
	TE_SendToAll();
	TE_SetupSparks(pos, dir, 5000, 1000);
	TE_SendToAll();
	pos[2] = pos[2] - 10.0;
	TE_SetupBeamRingPoint(pos, 50.0, 60.0, iHaloSprite, iBeamSprite, 0, 15, 1.0, 7.0, 2.0, color, 10, 0);
	TE_SendToAll();
	TE_SetupSparks(pos, dir, 5000, 1000);
	TE_SendToAll();
	pos[2] = pos[2] - 10.0;
	TE_SetupBeamRingPoint(pos, 50.0, 60.0, iHaloSprite, iBeamSprite, 0, 15, 1.0, 7.0, 2.0, color, 10, 0);
	TE_SendToAll();
	TE_SetupSparks(pos, dir, 5000, 1000);
	TE_SendToAll();
	if(!hTimerRing) hTimerRing = CreateTimer(1.5, TimerRing, 0, 1);
	if(!hTimerCircle) hTimerCircle = CreateTimer(0.1, TimerCircle, 0, 1);
}

public Action TimerRing(Handle timer)
{
	if(iBombTime < 30)
	{
		iBombTime += 1;
		float pos[3];
		if(IsValidEntity(iIndex))
		GetEntPropVector(iIndex, Prop_Data, "m_vecOrigin", pos, 0);
		FunctionCircle(pos);
	}
	else
	{
		iBombTime = 0;
		//if(hTimerRing) KillTimer(hTimerRing, false);
	}
	return Plugin_Continue;
}

public Action TimerCircle(Handle timer)
{
	float pos[3];
	if(IsValidEntity(iIndex))
	{
		GetEntPropVector(iIndex, Prop_Data, "m_angRotation", pos, 0);
		pos[1] += 10.0;
		TeleportEntity(iIndex, NULL_VECTOR, pos, NULL_VECTOR);
	}
	return Plugin_Continue;
}

public Action TimerEffect(Handle timer, any iClient)
{
	bool bRndOneT = view_as<bool>(GetRandomInt(0, 1));
	int c4 = EntRefToEntIndex(iClient);
	float pos[3]; int color[4];
	if(c4 == -1 || !IsValidEntity(c4))
		return Plugin_Stop;
	
	if(!bRndOneT)
	{
		GetEntPropVector(c4, Prop_Send, "m_vecOrigin", pos);
		color[0] = GetRandomInt(0, 255); color[1] = GetRandomInt(0, 255); color[2] = GetRandomInt(0, 255); color[3] = 255;
		pos[2] += 10.0;
		TE_SetupBeamRingPoint(pos, 50.0, 60.0, iHaloSprite, iBeamSprite, 0, 15, 5.0, 7.0, 9.0, color, 10, 9);
		TE_SendToAll();
		TE_SetupBeamRingPoint(pos, 10.0, 390.0, iHaloSprite, iBeamSprite, 0, 0, 9.0, 10.0, 10.0, color, 25, 0);
		TE_SendToAll();
		TE_SetupSparks(pos, view_as<float>({0.0, 0.0, 0.0}), 5000, 1000);
		TE_SendToAll();	
	}
	
	if(bRndOneT)
	{
		GetEntPropVector(c4, Prop_Send, "m_vecOrigin", pos);
		color[0] = 0; color[1] = 51; color[2] = 0; color[3] = 255;
		pos[2] += 20.0;
		TE_SetupBeamRingPoint(pos, 50.0, 60.0, iHaloSprite, iBeamSprite, 0, 15, 5.0, 7.0, 9.0, color, 10, 9);
		TE_SendToAll();
		TE_SetupBeamRingPoint(pos, 10.0, 390.0, iHaloSprite, iBeamSprite, 0, 0, 9.0, 5.0, 15.0, color, 25, 0);
		TE_SendToAll();
		TE_SetupSparks(pos, view_as<float>({0.0, 0.0, 0.0}), 5000, 1000);
		TE_SendToAll();
	}
	
	static int counter;
	if(hTimerEffect != timer)
	{
		// Когда дескрипторы не совпадают, остановите этот конкретный таймер
		counter = 0;
		return Plugin_Stop;
	}
	counter++;
	if(counter >= 34)
	{
		counter = 0;
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

public Action Event_End(Handle event, char[] name, bool dontBroadcast)
{
	Kill_Entity(GetEventInt(event, "userid"));
}

stock void Kill_Entity(int client, const bool bTimer = false)
{
	if(iIndex && IsValidEntity(iIndex))
	{
		AcceptEntityInput(iIndex, "Kill");
		//PrintToChatAll("Сущность убита");
	}
	
	if(iBall && IsValidEntity(iBall))
	{
		//PrintToChatAll("Еффект %d iBall убит", iBall);
		AcceptEntityInput(iBall, "Kill");
	}
	if(iBall_2 && IsValidEntity(iBall_2))
	{
		//PrintToChatAll("Еффект %d iBall_2 убит", iBall_2);
		AcceptEntityInput(iBall_2, "Kill");
	}
	if(iBall_3 && IsValidEntity(iBall_3))
	{
		//PrintToChatAll("Еффект %d iBall_3 убит", iBall_3);
		AcceptEntityInput(iBall_3, "Kill");
	}
	
	if(bTimer) hTimerRing = null;
	else if(hTimerRing) delete hTimerRing;
	
	if(bTimer) hTimerCircle = null;
	else if(hTimerCircle) delete hTimerCircle;
	
	//if(bTimer) hTimerEffect = null;
	//else if(hTimerEffect) delete hTimerEffect;
}