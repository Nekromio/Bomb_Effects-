#pragma semicolon 1
#pragma newdecls required

#include <sdktools_functions>
#include <sdktools_entinput>
#include <sdktools_tempents>
#include <sdktools_tempents_stocks>
#include <sdktools_stringtables>
#include <sdktools_sound>
#include <sdktools_variant_t>
#include <sdkhooks>

ConVar
	cvSound;

Handle
	hTimerRing,
	hTimerCircle,
	hTimerEffect;

int
	iBeamSprite,
	iHaloSprite,
	iBombTime,
	iEntRef[4],
	iLgtning,
	iSteam1,
	Engine_Version,
	game[4] = {0,1,2,3};		//0-UNDEFINED|1-css34|2-css|3-csgo

char
	sSound[512];

int GetCSGame()
{
	if (GetFeatureStatus(FeatureType_Native, "GetEngineVersion") == FeatureStatus_Available) 
	{
		switch (GetEngineVersion())
		{
			case Engine_SourceSDK2006: return game[1];
			case Engine_CSS: return game[2];
			case Engine_CSGO: return game[3];
		}
	}
	return game[0];
}

public Plugin myinfo = 
{
	name = "[Any] Bomb Effects+",
	author = "Nek.'a 2x2 | ggwp.site",
	description = "Эффект установленной бомбы и звуки",
	version = "1.4.3",
	url = "https://ggwp.site/"
}

public APLRes AskPluginLoad2()
{
	Engine_Version = GetCSGame();
	if(!Engine_Version)
		SetFailState("Game is not supported!");
	return APLRes_Success;
}

public void OnPluginStart()
{	
	if(Engine_Version < 3)
		cvSound = CreateConVar("sm_bombeffect_sound", "bomb/bombpl.wav", "Путь к звуку");
	
	HookEvent("bomb_planted", Event_BombPlanted);
	HookEvent("round_end", Event_RoundEnd);
}

public void OnMapStart()
{
	if(Engine_Version < 3)
	{
		iBeamSprite = PrecacheModel("sprites/laser.vmt");
		iHaloSprite = PrecacheModel("sprites/halo01.vmt");
		
		char sBuffer[512];
		cvSound.GetString(sBuffer, sizeof(sBuffer));
		
		if(sBuffer[0])
		{
			sSound = sBuffer;
			PrecacheSound(sBuffer, true);
			Format(sBuffer, sizeof(sBuffer), "sound/%s", sBuffer);
			AddFileToDownloadsTable(sBuffer);
		}
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

void Event_BombPlanted(Handle event, const char[] name, bool dontBroadcast)
{
	if(Engine_Version <3 && sSound[0])
		EmitSoundToAll(sSound);

	bool bRndOne = view_as<bool>(GetRandomInt(0, 1));
	
	switch(bRndOne)
	{
		case false:
		{
			int index = FindEntityByClassname(MaxClients + 1, "planted_c4");
			if(index == -1)
				return;
			
			float pos[3];
			iEntRef[0] = EntIndexToEntRef(index);
			hTimerEffect = CreateTimer(1.0, Timer_Effect, iEntRef[0], TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
			GetEntPropVector(index, Prop_Data, "m_vecOrigin", pos, 0);
			pos[2] += 20.0;
			TeleportEntity(index, pos, NULL_VECTOR, NULL_VECTOR);
			FunctionCircle(pos);
		}
	
		case true:
		{
			bool bRndTo = view_as<bool>(GetRandomInt(0, 1));
			float pos_[3], startPos[3], direction[3];
			int color[4] = {255, 0, 0, 0};
			startPos[0] = pos_[0] + GetRandomInt(-500, 500);
			startPos[1] = pos_[1] + GetRandomInt(-500, 500);
			startPos[2] = pos_[2] + 800;
			int index  = FindEntityByClassname(-1, "planted_c4");
			if(index == -1)
				return;

			iEntRef[1] = CreateEntityByName("point_tesla", -1);

			if(iEntRef[1] == -1)
				return;

			float lastPos[3];
			GetEntPropVector(index, Prop_Send, "m_vecOrigin", lastPos, 0);
			DispatchKeyValueVector(iEntRef[1], "Origin", lastPos);
			DispatchKeyValue(iEntRef[1], "m_flRadius", "50.0");
			DispatchKeyValue(iEntRef[1], "m_SoundName", "DoSpark");
			DispatchKeyValue(iEntRef[1], "beamcount_min", "42");
			DispatchKeyValue(iEntRef[1], "beamcount_max", "62");
			DispatchKeyValue(iEntRef[1], "texture", "sprites/physbeam.vmt");
			DispatchKeyValue(iEntRef[1], "m_Color", "255 255 255");
			DispatchKeyValue(iEntRef[1], "thick_min", "10.0");
			DispatchKeyValue(iEntRef[1], "thick_max", "11.0");
			DispatchKeyValue(iEntRef[1], "lifetime_min", "0.3");
			DispatchKeyValue(iEntRef[1], "lifetime_max", "0.3");
			DispatchKeyValue(iEntRef[1], "interval_min", "0.1");
			DispatchKeyValue(iEntRef[1], "interval_max", "0.2");
			DispatchSpawn(iEntRef[1]);
			ActivateEntity(iEntRef[1]);
			AcceptEntityInput(iEntRef[1], "DoSpark", -1, -1, 0);
			AcceptEntityInput(iEntRef[1], "TurnOn", -1, -1, 0);
			SetVariantString("OnUser1 !self:kill::5.0:1");
			AcceptEntityInput(iEntRef[1], "AddOutput", -1, -1, 0);
			AcceptEntityInput(iEntRef[1], "FireUser1", -1, -1, 0);

			iEntRef[1] = EntIndexToEntRef(iEntRef[1]);

			iEntRef[2] = CreateEntityByName("env_sprite", -1);
			if (iEntRef[2] != -1)
			{
				if(!bRndTo)
					DispatchKeyValue(iEntRef[2], "model", "ggwp/bomb_effect/effect3.vmt");
				else
					DispatchKeyValue(iEntRef[2], "model", "ggwp/bomb_effect/effect9.vmt");

				DispatchKeyValue(iEntRef[2], "rendermode", "1");
				DispatchKeyValue(iEntRef[2], "spawnflags", "1");
				DispatchKeyValue(iEntRef[2], "rendercolor", "0 0 0");
				DispatchKeyValue(iEntRef[2], "renderfx", "0");
				DispatchKeyValue(iEntRef[2], "renderamt", "255");
				DispatchKeyValue(iEntRef[2], "scale", "0.7");
				DispatchKeyValue(iEntRef[2], "GlowProxySize", "1");
				DispatchSpawn(iEntRef[2]);
				lastPos[2] += 85.0;
				TeleportEntity(iEntRef[2], lastPos, NULL_VECTOR, NULL_VECTOR);
				AcceptEntityInput(iEntRef[2], "ShowSprite", -1, -1, 0);

				iEntRef[2] = EntIndexToEntRef(iEntRef[2]);

				iEntRef[3] = CreateEntityByName("env_spark", -1);

				if(iEntRef[3] != -1)
				{
					GetEntPropVector(index, Prop_Send, "m_vecOrigin", lastPos, 0);
					DispatchKeyValueVector(iEntRef[3], "Origin", lastPos);
					DispatchKeyValue(iEntRef[3], "spawnflags", "896");
					DispatchKeyValue(iEntRef[3], "angles", "-90 0 0");
					DispatchKeyValue(iEntRef[3], "magnitude", "8");
					DispatchKeyValue(iEntRef[3], "traillength", "5");
					DispatchKeyValue(iEntRef[3], "m_SoundName", "DoSpark");
					DispatchSpawn(iEntRef[3]);
					ActivateEntity(iEntRef[3]);
					AcceptEntityInput(iEntRef[3], "DoSpark", -1, -1, 0);
					AcceptEntityInput(iEntRef[3], "Enable", -1, -1, 0);
					AcceptEntityInput(iEntRef[3], "StartSpark", -1, -1, 0);
					EmitAmbientSound("sound/ambient/machines/zap1.wav", lastPos, 0, 75, 0, 1.0, 100, 0.0);

					iEntRef[3] = EntIndexToEntRef(iEntRef[3]);
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

void FunctionCircle(float pos[3])
{
	int color[4];
	color[0] = GetRandomInt(0, 255);
	color[1] = GetRandomInt(0, 255);
	color[2] = GetRandomInt(0, 255);
	color[3] = 255;
	
	float dir[3];
	for(int i; i < 3; i++)
	{
		switch(i)
		{
			case 0: pos[2] += 10.0;
			case 1: pos[2] -= 10.0;
			case 2: pos[2] -= 10.0;
		}
		TE_SetupBeamRingPoint(pos, 50.0, 60.0, iHaloSprite, iBeamSprite, 0, 15, 1.0, 7.0, 2.0, color, 10, 0);
		TE_SendToAll();

		TE_SetupSparks(pos, dir, 5000, 1000);
		TE_SendToAll();
	}
	
	if(!hTimerRing)
		hTimerRing = CreateTimer(1.5, Timer_Ring, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
	if(!hTimerCircle)
		hTimerCircle = CreateTimer(0.1, Timer_Circle, _, TIMER_REPEAT|TIMER_FLAG_NO_MAPCHANGE);
}

Action Timer_Ring(Handle timer)
{
	if(iBombTime < 30)
	{
		iBombTime += 1;
		float pos[3];
		if(IsValidEntity(iEntRef[0]))
			GetEntPropVector(iEntRef[0], Prop_Data, "m_vecOrigin", pos, 0);
		FunctionCircle(pos);
	}
	else
	{
		iBombTime = 0;
	}

	return Plugin_Continue;
}

Action Timer_Circle(Handle timer)
{
	float pos[3];
	if(IsValidEntity(iEntRef[0]))
	{
		GetEntPropVector(iEntRef[0], Prop_Data, "m_angRotation", pos, 0);
		pos[1] += 10.0;
		TeleportEntity(iEntRef[0], NULL_VECTOR, pos, NULL_VECTOR);
	}
	hTimerRing = null;
	return Plugin_Continue;
}

Action Timer_Effect(Handle timer, int iRef)
{
	bool bRndOneT = view_as<bool>(GetRandomInt(0, 1));
	int iEnt = EntRefToEntIndex(iRef);
	float pos[3]; int color[4];
	if(!IsValidEntity(iEnt))
		return Plugin_Stop;
	
	if(!bRndOneT)
	{
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", pos);
		color[0] = GetRandomInt(0, 255);
		color[1] = GetRandomInt(0, 255);
		color[2] = GetRandomInt(0, 255);
		color[3] = 255;
		pos[2] += 10.0;
		TE_SetupBeamRingPoint(pos, 50.0, 60.0, iHaloSprite, iBeamSprite, 0, 15, 5.0, 7.0, 9.0, color, 10, 9);
		TE_SendToAll();
		TE_SetupBeamRingPoint(pos, 10.0, 390.0, iHaloSprite, iBeamSprite, 0, 0, 9.0, 10.0, 10.0, color, 25, 0);
		TE_SendToAll();
		TE_SetupSparks(pos, view_as<float>({0.0, 0.0, 0.0}), 5000, 1000);
		TE_SendToAll();	
	}
	else
	{
		GetEntPropVector(iEnt, Prop_Send, "m_vecOrigin", pos);
		color[0] = 0;
		color[1] = 51;
		color[2] = 0;
		color[3] = 255;
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

void Event_RoundEnd(Event event, char[] name, bool dontBroadcast)
{
	int index;
	for(int i = 0; i < 4; i++) if(iEntRef[i])
	{
		index = EntRefToEntIndex(iEntRef[i]);
		if(index == INVALID_ENT_REFERENCE || !IsValidEntity(index))
			continue;
		AcceptEntityInput(index, "Kill");
	}

	if(hTimerRing)
		delete hTimerRing;
	if(hTimerCircle)
		delete hTimerCircle;
}