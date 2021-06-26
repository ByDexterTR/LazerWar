#include <sourcemod>
#include <sdktools>
#include <sdkhooks>
#include <clientprefs>
#include <cstrike>
#include <emitsoundany>
#include <warden>

public Plugin myinfo = 
{
	name = "Lazer Savaşları", 
	author = "quantum, ByDexter", 
	description = "Lazer Savaşları jailbreak plugini", 
	version = "1.1", 
	url = "https://steamcommunity.com/id/quascave"
};

#pragma semicolon 1
#pragma newdecls required

int takimNumarasi[MAXPLAYERS] =  { -1, ... };
int oyuncuTakimDurumu[MAXPLAYERS] =  { -1, ... };
int g_iBeam = -1;
bool SiyahTakim[MAXPLAYERS] =  { false, ... };
bool BeyazTakim[MAXPLAYERS] =  { false, ... };

int SilahDurumu;
int TakimDurumu;
bool MuzikDurumu;
bool SinirsizMermi;
bool Sekmeme;
bool EkranEfekt;

bool Lazer_Savaslari_Aktif = false;
bool TakimYapildi = false;
bool M4A1;
bool USP;
bool MP5SD;

Handle h_timer = INVALID_HANDLE;
Handle g_Model;

ConVar g_Flag = null;
char YetkiBayragi[4];

public void OnMapStart()
{
	char mapismi[128];
	GetCurrentMap(mapismi, sizeof(mapismi));
	if (StrContains(mapismi, "jb_", false) == -1 && StrContains(mapismi, "jail_", false) == -1 && StrContains(mapismi, "ba_jail", false) == -1)
	{
		SetFailState("[LazerWar] Bu eklenti sadece jailbreak haritalarinda calisir.");
	}
	PrintToServer("!-------Lazer Savaslari eklentisi basari ile calistirildi-------!");
	
	AddFileToDownloadsTable("sound/misc/LaserWarsSounds/Countdown/3.mp3");
	PrecacheSoundAny("misc/LaserWarsSounds/Countdown/3.mp3", false);
	AddFileToDownloadsTable("sound/misc/LaserWarsSounds/Countdown/2.mp3");
	PrecacheSoundAny("misc/LaserWarsSounds/Countdown/2.mp3", false);
	AddFileToDownloadsTable("sound/misc/LaserWarsSounds/Countdown/1.mp3");
	PrecacheSoundAny("misc/LaserWarsSounds/Countdown/1.mp3", false);
	AddFileToDownloadsTable("sound/misc/LaserWarsSounds/Ambiance/starwars.mp3");
	PrecacheSoundAny("misc/LaserWarsSounds/Ambiance/starwars.mp3", false);
	AddFileToDownloadsTable("sound/misc/LaserWarsSounds/End/end.mp3");
	PrecacheSoundAny("misc/LaserWarsSounds/End/end.mp3", false);
	AddFileToDownloadsTable("sound/misc/LaserWarsSounds/Start/start.mp3");
	PrecacheSoundAny("misc/LaserWarsSounds/Start/start.mp3", false);
	
	g_iBeam = PrecacheModel("materials/sprites/laserbeam.vmt", true);
	
	AddFileToDownloadsTable("sound/misc/LaserWarsSounds/Weapon/1.mp3");
	PrecacheSound("misc/LaserWarsSounds/Weapon/1.mp3", false);
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_cape_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_glove_c.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_glove_c.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_glove_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_helmet_c.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_helmet_c.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_helmet_env.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_helmet_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_innercape_c.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_innercape_inv.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_innercape_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/black.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_body_c.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_body_c.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_body_evn.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_body2_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_cape_c.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_cape_c.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/vader/t_hero_jedi_darthvader_cape_inv.vmt");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/vader/vader.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/vader/vader.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/vader/vader.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/vader/vader.vvd");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/vader/vader_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/vader/vader_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/vader/vader_arms.vvd");
	PrecacheModel("models/player/custom_player/kuristaja/vader/vader_arms.mdl", false);
	PrecacheModel("models/player/custom_player/kuristaja/vader/vader.mdl", false);
	AddFileToDownloadsTable("materials/models/player/kuristaja/stormtrooper/stormtrooper_body.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/stormtrooper/stormtrooper_body_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/stormtrooper/stormtrooper_body2.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/stormtrooper/stormtrooper_hands.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/stormtrooper/stormtrooper_hands.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/stormtrooper/stormtrooper_hands_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/stormtrooper/stormtrooper_hands2.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/stormtrooper/stormtrooper_helmet.vmt");
	AddFileToDownloadsTable("materials/models/player/kuristaja/stormtrooper/stormtrooper_helmet.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/stormtrooper/stormtrooper_helmet_normal.vtf");
	AddFileToDownloadsTable("materials/models/player/kuristaja/stormtrooper/stormtrooper_body.vmt");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/stormtrooper/stormtrooper.vvd");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/stormtrooper/stormtrooper.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/stormtrooper/stormtrooper.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/stormtrooper/stormtrooper.phy");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/stormtrooper/stormtrooper_arms.dx90.vtx");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/stormtrooper/stormtrooper_arms.mdl");
	AddFileToDownloadsTable("models/player/custom_player/kuristaja/stormtrooper/stormtrooper_arms.vvd");
	PrecacheModel("models/player/custom_player/kuristaja/stormtrooper/stormtrooper_arms.mdl", false);
	PrecacheModel("models/player/custom_player/kuristaja/stormtrooper/stormtrooper.mdl", false);
}

#define LoopClients(%1) for (int %1 = 1; %1 <= MaxClients; %1++) if (IsClientInGame(%1))

public void OnPluginStart()
{
	RegConsoleCmd("sm_laserwar", Lazer_Savaslari);
	RegConsoleCmd("sm_lws", Lazer_Savaslari);
	RegConsoleCmd("sm_lw", Lazer_Savaslari);
	RegConsoleCmd("sm_laserdur", Lazer_Savaslari_Durdur);
	
	g_Model = RegClientCookie("LWS_Model", "Oyuncuların modellerinin saklandığı cookie", CookieAccess_Protected);
	
	HookEvent("round_start", El_Basi_Sonu);
	HookEvent("round_end", El_Basi_Sonu);
	HookEvent("player_death", Oyuncu_Oldugunde);
	HookEvent("bullet_impact", Event_OnBulletImpact);
	
	AddNormalSoundHook(Hook_NormalSound);
	
	g_Flag = CreateConVar("lw_flag", "b", "Erişim bayrağı (Lazer War)");
	g_Flag.GetString(YetkiBayragi, sizeof(YetkiBayragi));
	g_Flag.AddChangeHook(ConVarChanged);
	
	AddTempEntHook("Shotgun Shot", Hook_BlockTE);
	AddTempEntHook("Blood Sprite", Hook_BlockTE);
	
	LoopClients(i)
	{
		OnClientPostAdminCheck(i);
	}
}

public void OnPluginEnd()
{
	Lazer_Savaslari_Durdur(0, 0);
}

public void OnClientPostAdminCheck(int client)
{
	SDKHook(client, SDKHook_OnTakeDamage, OnTakeDamage);
}

public void ConVarChanged(ConVar convar, const char[] oldValue, const char[] newValue)
{
	if (convar == g_Flag)
	{
		g_Flag.GetString(YetkiBayragi, sizeof(YetkiBayragi));
	}
}

public void OnClientCookiesCached(int client)
{
	SetClientCookie(client, g_Model, "");
}

public Action Lazer_Savaslari(int client, int args)
{
	Lazer_SavaslariFirstMenu(client);
}

public Action Lazer_SavaslariFirstMenu(int client)
{
	if (warden_iswarden(client) || CheckAdminFlag(client, YetkiBayragi))
	{
		Handle menuhandle = CreateMenu(Lazer_Savaslari_Silah, MENU_ACTIONS_DEFAULT);
		SetMenuTitle(menuhandle, " Lazer Savaşları\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬");
		char secenek[128];
		
		if (!Lazer_Savaslari_Aktif)
		{
			AddMenuItem(menuhandle, "Baslat", "! Oyunu Başlat !\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\n ");
		}
		else
		{
			AddMenuItem(menuhandle, "Durdur", "! Oyunu Durdur !\n▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬▬\n ");
		}
		
		if (SilahDurumu == 0)
		{
			Format(secenek, sizeof(secenek), "Silah: M4A1-S");
			M4A1 = true;
			USP = false;
			MP5SD = false;
		}
		else if (SilahDurumu == 1)
		{
			Format(secenek, sizeof(secenek), "Silah: USP-S");
			M4A1 = false;
			USP = true;
			MP5SD = false;
		}
		else if (SilahDurumu == 2)
		{
			Format(secenek, sizeof(secenek), "Silah: MP5-SD");
			M4A1 = false;
			USP = false;
			MP5SD = true;
		}
		AddMenuItem(menuhandle, "sec1", secenek, ITEMDRAW_DEFAULT);
		
		if (TakimDurumu == 0)
		{
			Format(secenek, sizeof(secenek), "Takım Durumu: Takımlı");
		}
		else if (TakimDurumu == 1)
		{
			Format(secenek, sizeof(secenek), "Takım Durumu: Herkes Tek");
		}
		
		AddMenuItem(menuhandle, "sec2", secenek, ITEMDRAW_DEFAULT);
		
		if (MuzikDurumu)
		{
			Format(secenek, sizeof(secenek), "Müzik Durumu: Aktif");
		}
		else
		{
			Format(secenek, sizeof(secenek), "Müzik Durumu: Deaktif");
		}
		
		AddMenuItem(menuhandle, "sec3", secenek, ITEMDRAW_DEFAULT);
		
		if (SinirsizMermi)
		{
			Format(secenek, sizeof(secenek), "Sınırsız Mermi: Aktif");
		}
		else
		{
			Format(secenek, sizeof(secenek), "Sınırsız Mermi: Deaktif");
		}
		
		AddMenuItem(menuhandle, "sec4", secenek, ITEMDRAW_DEFAULT);
		
		if (Sekmeme)
		{
			Format(secenek, sizeof(secenek), "Mermi Sekmeme: Aktif");
		}
		else
		{
			Format(secenek, sizeof(secenek), "Mermi Sekmeme: Deaktif");
		}
		
		AddMenuItem(menuhandle, "sec5", secenek, ITEMDRAW_DEFAULT);
		
		if (EkranEfekt)
		{
			Format(secenek, sizeof(secenek), "Ekran Efekt: Aktif");
		}
		else
		{
			Format(secenek, sizeof(secenek), "Ekran Efekt: Deaktif");
		}
		
		AddMenuItem(menuhandle, "sec6", secenek, ITEMDRAW_DEFAULT);
		
		SetMenuPagination(menuhandle, 0);
		SetMenuExitBackButton(menuhandle, false);
		SetMenuExitButton(menuhandle, true);
		DisplayMenu(menuhandle, client, MENU_TIME_FOREVER);
	}
	else
	{
		PrintToChat(client, "[SM] \x01Lazer Savaşını sadece \x0CKomutçular \x01başlatabilir!");
	}
	return Plugin_Continue;
}

public int Lazer_Savaslari_Silah(Handle menuhandle, MenuAction action, int client, int position)
{
	if (action == MenuAction_Select)
	{
		char Item[32];
		GetMenuItem(menuhandle, position, Item, sizeof(Item));
		if (warden_iswarden(client) || CheckAdminFlag(client, YetkiBayragi))
		{
			if (StrEqual(Item, "Baslat", true))
			{
				if (GetTeamClientCount(CS_TEAM_T) == 1)
				{
					PrintCenterText(client, "[SM] \x0E%N \x01yaşayan sadece 1 oyuncu var.", client);
				}
				for (int i = 1; i < MaxClients; i++)
				{
					if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T)
					{
						SetEntProp(i, Prop_Data, "m_ArmorValue", 0, 4);
						SetEntProp(i, Prop_Send, "m_bHasHelmet", 0);
						ModelKaydet(i);
					}
				}
				if (TakimDurumu == 0)
				{
					TakimYapildi = true;
					int yasayanTSayisi;
					for (int i = 1; i <= MaxClients; i++)
					{
						oyuncuTakimDurumu[i] = 0;
						if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
						{
							yasayanTSayisi++;
						}
					}
					if (yasayanTSayisi % 2 == 1)
					{
						PrintToChat(client, "[SM] \x01Bu komutu kullanabilmek için yaşayan \x0ET Takımı Sayısı \x01çift sayıda olmalıdır.");
					}
					if (yasayanTSayisi % 2 == 0 && yasayanTSayisi != 0)
					{
						int j;
						for (int i = 1; i <= MaxClients; i++)
						{
							if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i) && GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
							{
								takimNumarasi[i] = j % 2 + 1;
								oyuncuTakimDurumu[i] = j % 2 + 1;
								j++;
							}
						}
						for (int i = 1; i <= MaxClients; i++)
						{
							if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
							{
								if (GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
								{
									if (takimNumarasi[i] == 1)
									{
										BeyazTakim[i] = false;
										SiyahTakim[i] = true;
										PrintCenterText(i, "Takımınız: !! Karanlık Takım !!");
										Ekran_Renk_Olustur(i, { 0, 0, 0, 160 } );
									}
									if (takimNumarasi[i] == 2)
									{
										BeyazTakim[i] = true;
										SiyahTakim[i] = false;
										PrintCenterText(i, "Takımınız: !! Beyaz Takım !!");
										Ekran_Renk_Olustur(i, { 255, 255, 255, 160 } );
									}
								}
							}
						}
						for (int i = 1; i <= MaxClients; i++)
						{
							if (IsClientConnected(i) && IsClientInGame(i) && !IsFakeClient(i))
							{
								if (GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
								{
									if (takimNumarasi[i] == 1)
									{
										SetEntityModel(i, "models/player/custom_player/kuristaja/vader/vader.mdl");
										//SetEntPropString(i, Prop_Send, "m_szArmsModel", "models/player/custom_player/kuristaja/vader/vader_arms.mdl");
										Handle hHudText = CreateHudSynchronizer();
										SetHudTextParams(-1.0, -0.3, 3.0, 255, 0, 0, 0, 0, 6.0, 0.1, 0.2);
										ShowSyncHudText(i, hHudText, "KARANLIK TARAFTASIN!");
										delete hHudText;
										PrintToChat(i, "[SM] \x01Takımınız: ! KARANLIK TARAF !");
									}
									if (takimNumarasi[i] == 2)
									{
										SetEntityModel(i, "models/player/custom_player/kuristaja/stormtrooper/stormtrooper.mdl");
										//SetEntPropString(i, Prop_Send, "m_szArmsModel", "models/player/custom_player/kuristaja/stormtrooper/stormtrooper_arms.mdl");
										Handle hHudText = CreateHudSynchronizer();
										SetHudTextParams(-1.0, -0.3, 3.0, 0, 0, 255, 0, 0, 6.0, 0.1, 0.2);
										ShowSyncHudText(i, hHudText, "BEYAZ TARAFTASIN!");
										delete hHudText;
										PrintToChat(i, "[SM] \x01Takımınız: ! BEYAZ TARAF !");
									}
								}
							}
						}
						h_timer = CreateTimer(1.0, GeriSayim3, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
						Lazer_Savaslari_Aktif = true;
					}
				}
				else if (TakimDurumu == 1)
				{
					Takim_Kapat();
					Lazer_Savaslari_Aktif = true;
					h_timer = CreateTimer(1.0, GeriSayim3, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
					for (int i = 1; i <= MaxClients; i++)
					{
						if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T)
						{
							SetEntityModel(i, "models/player/custom_player/kuristaja/stormtrooper/stormtrooper.mdl");
							//SetEntPropString(i, Prop_Send, "m_szArmsModel", "models/player/custom_player/kuristaja/stormtrooper/stormtrooper_arms.mdl", 0);
							Handle hHudText = CreateHudSynchronizer();
							SetHudTextParams(-1.0, -0.3, 3.0, 0, 0, 255, 0, 0, 6.0, 0.1, 0.2);
							ShowSyncHudText(i, hHudText, "HERKES TEK !");
							delete hHudText;
							Ekran_Renk_Olustur(i, { 255, 255, 255, 160 } );
							PrintToChat(i, "[SM] \x01Herkes Tek !");
						}
					}
				}
			}
			else if (StrEqual(Item, "Durdur", true))
			{
				PrintToChatAll("[SM] \x01Lazer Savaşları \x0E%N \x01tarafından durduruldu!", client);
				Takim_Kapat();
				SetCvar("sv_infinite_ammo", 0);
				SetCvar("mp_teammates_are_enemies", 0);
				SetCvar("mp_friendlyfire", 0);
				SekmemeAyarla(false);
				StopSoundAny(-2, 0, "misc/LaserWarsSounds/Ambiance/starwars.mp3");
				EmitSoundToAllAny("misc/LaserWarsSounds/End/end.mp3", -2, 0, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				Lazer_Savaslari_Aktif = false;
				M4A1 = false;
				USP = false;
				MP5SD = false;
				for (int i = 1; i < MaxClients; i++)
				{
					if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T)
					{
						ModelVer(i);
						Silahlari_Sil(i);
						GivePlayerItem(i, "weapon_knife");
						if (EkranEfekt)
						{
							SetEntProp(i, Prop_Send, "m_bNightVisionOn", 0);
						}
					}
				}
				if (h_timer != INVALID_HANDLE)
				{
					h_timer = INVALID_HANDLE;
				}
			}
			else if (StrEqual(Item, "sec1", true))
			{
				if (SilahDurumu == 0)
				{
					SilahDurumu = 1;
				}
				else if (SilahDurumu == 1)
				{
					SilahDurumu = 2;
				}
				else
				{
					SilahDurumu = 0;
				}
				Lazer_SavaslariFirstMenu(client);
			}
			else if (StrEqual(Item, "sec2", true))
			{
				if (TakimDurumu == 0)
				{
					TakimDurumu = 1;
				}
				else
				{
					TakimDurumu = 0;
				}
				Lazer_SavaslariFirstMenu(client);
			}
			else if (StrEqual(Item, "sec3", true))
			{
				if (MuzikDurumu)
				{
					MuzikDurumu = false;
				}
				else
				{
					MuzikDurumu = true;
				}
				Lazer_SavaslariFirstMenu(client);
			}
			else if (StrEqual(Item, "sec4", true))
			{
				if (SinirsizMermi)
				{
					SinirsizMermi = false;
				}
				else
				{
					SinirsizMermi = true;
				}
				Lazer_SavaslariFirstMenu(client);
			}
			else if (StrEqual(Item, "sec5", true))
			{
				if (Sekmeme)
				{
					Sekmeme = false;
				}
				else
				{
					Sekmeme = true;
				}
				Lazer_SavaslariFirstMenu(client);
			}
			else if (StrEqual(Item, "sec6", true))
			{
				if (EkranEfekt)
				{
					EkranEfekt = false;
				}
				else
				{
					EkranEfekt = true;
				}
				Lazer_SavaslariFirstMenu(client);
			}
		}
		else
		{
			ReplyToCommand(client, "[SM] \x0ELazer Savaşını \x01Sadece \x0CKomutçular \x01Yapabilir!");
		}
	}
	else if (action == MenuAction_End)
	{
		delete menuhandle;
	}
}

public Action GeriSayim3(Handle Timer, any data)
{
	int client = GetClientOfUserId(data);
	h_timer = CreateTimer(1.0, GeriSayim2, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	EmitSoundToAllAny("misc/LaserWarsSounds/Countdown/3.mp3", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			PrintHintText(i, "Lazer Savaşlarının Başlamasına Son 3 Saniye");
		}
	}
	return Plugin_Continue;
}

public Action GeriSayim2(Handle Timer, any data)
{
	int client = GetClientOfUserId(data);
	h_timer = CreateTimer(1.0, GeriSayim1, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	EmitSoundToAllAny("misc/LaserWarsSounds/Countdown/2.mp3", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			PrintHintText(i, "Lazer Savaşlarının Başlamasına Son 2 Saniye");
		}
	}
	return Plugin_Continue;
}

public Action GeriSayim1(Handle Timer, any data)
{
	int client = GetClientOfUserId(data);
	h_timer = CreateTimer(1.0, Baslat, GetClientUserId(client), TIMER_FLAG_NO_MAPCHANGE);
	EmitSoundToAllAny("misc/LaserWarsSounds/Countdown/1.mp3", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i))
		{
			PrintHintText(i, "Lazer Savaşlarının Başlamasına Son 1 Saniye");
		}
	}
	return Plugin_Continue;
}

public Action Baslat(Handle Timer)
{
	EmitSoundToAllAny("misc/LaserWarsSounds/Start/start.mp3", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	SetCvar("mp_teammates_are_enemies", 1);
	SetCvar("mp_friendlyfire", 1);
	if (Sekmeme)
	{
		SekmemeAyarla(true);
	}
	if (SinirsizMermi)
	{
		SetCvar("sv_infinite_ammo", 1);
	}
	if (MuzikDurumu)
	{
		EmitSoundToAllAny("misc/LaserWarsSounds/Ambiance/starwars.mp3", -2, 0, 75, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
	}
	for (int i = 1; i <= MaxClients; i++)
	{
		if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
		{
			SetEntityHealth(i, 100);
			if (EkranEfekt)
			{
				SetEntProp(i, Prop_Send, "m_bNightVisionOn", 1);
			}
			Silahlari_Sil(i);
			PrintHintText(i, "Lazer Savaşları BAŞLADI!\n[---!Güç Sizinle Olsun!---]");
		}
	}
	h_timer = INVALID_HANDLE;
	return Plugin_Stop;
}


public Action OnTakeDamage(int victim, int &attacker, int &inflictor, float &damage, int &damagetype)
{
	if (Lazer_Savaslari_Aktif)
	{
		if (TakimYapildi)
		{
			int iAttacker;
			if (attacker > 64)
				iAttacker = GetClientOfUserId(attacker);
			else
				iAttacker = attacker;
			
			if (iAttacker > 0)
			{
				if (oyuncuTakimDurumu[victim] == oyuncuTakimDurumu[iAttacker])
				{
					damage = 0.0;
					return Plugin_Changed;
				}
				else
				{
					damage = 25.0;
					return Plugin_Changed;
				}
			}
		}
		else
		{
			damage = 25.0;
			return Plugin_Changed;
		}
	}
	return Plugin_Continue;
}

public Action Event_OnBulletImpact(Handle event, const char[] name, bool dontBroadcast)
{
	int client = GetClientOfUserId(GetEventInt(event, "userid"));
	if (GetClientTeam(client) == CS_TEAM_T && Lazer_Savaslari_Aktif)
	{
		if (TakimYapildi)
		{
			if (takimNumarasi[client] == 1)
			{
				float m_fOrigin[3];
				float m_fImpact[3];
				GetClientEyePosition(client, m_fOrigin);
				m_fImpact[0] = GetEventFloat(event, "x", 0.0);
				m_fImpact[1] = GetEventFloat(event, "y", 0.0);
				m_fImpact[2] = GetEventFloat(event, "z", 0.0);
				m_fOrigin[2] = m_fOrigin[2] - 20;
				int Renk[4];
				Renk[0] = 0;
				Renk[1] = 0;
				Renk[2] = 0;
				Renk[3] = 255;
				TE_SetupBeamPoints(m_fOrigin, m_fImpact, g_iBeam, 0, 0, 0, 0.1, 1.0, 1.0, 1, 0.0, Renk, 0);
				TE_SendToAll(0.1);
				float position[3] = 0.0;
				GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
				EmitSoundToAll("misc/LaserWarsSounds/Weapon/1.mp3", 0, 0, 75, 0, 1.0, 100, -1, position, NULL_VECTOR, true, 0.0);
			}
			else
			{
				if (takimNumarasi[client] == 2)
				{
					float m_fOrigin[3];
					float m_fImpact[3];
					GetClientEyePosition(client, m_fOrigin);
					m_fImpact[0] = GetEventFloat(event, "x", 0.0);
					m_fImpact[1] = GetEventFloat(event, "y", 0.0);
					m_fImpact[2] = GetEventFloat(event, "z", 0.0);
					m_fOrigin[2] = m_fOrigin[2] - 20;
					int Renk[4];
					Renk[0] = 255;
					Renk[1] = 255;
					Renk[2] = 255;
					Renk[3] = 255;
					TE_SetupBeamPoints(m_fOrigin, m_fImpact, g_iBeam, 0, 0, 0, 0.1, 1.0, 1.0, 1, 0.0, Renk, 0);
					TE_SendToAll(0.1);
					float position[3] = 0.0;
					GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
					EmitSoundToAll("misc/LaserWarsSounds/Weapon/1.mp3", 0, 0, 75, 0, 1.0, 100, -1, position, NULL_VECTOR, true, 0.0);
				}
			}
		}
		float m_fOrigin[3];
		float m_fImpact[3];
		GetClientEyePosition(client, m_fOrigin);
		m_fImpact[0] = GetEventFloat(event, "x", 0.0);
		m_fImpact[1] = GetEventFloat(event, "y", 0.0);
		m_fImpact[2] = GetEventFloat(event, "z", 0.0);
		m_fOrigin[2] = m_fOrigin[2] - 20;
		int Renk[4];
		Renk[0] = GetRandomInt(1, 255);
		Renk[1] = GetRandomInt(1, 255);
		Renk[2] = GetRandomInt(1, 255);
		Renk[3] = 255;
		TE_SetupBeamPoints(m_fOrigin, m_fImpact, g_iBeam, 0, 0, 0, 0.1, 1.0, 1.0, 1, 0.0, Renk, 0);
		TE_SendToAll(0.1);
		float position[3] = 0.0;
		GetEntPropVector(client, Prop_Send, "m_vecOrigin", position);
		EmitSoundToAll("misc/LaserWarsSounds/Weapon/1.mp3", 0, 0, 75, 0, 1.0, 100, -1, position, NULL_VECTOR, true, 0.0);
	}
	return Plugin_Continue;
}

public Action Hook_NormalSound(int clients[64], int & numClients, char sample[255], int & entity, int & channel, float & volume, int & level, int & pitch, int & flags)
{
	if (strncmp(sample, "weapons", 7, true) && strncmp(sample[0], "weapons", 7, true))
	{
		return Plugin_Continue;
	}
	return Plugin_Continue;
}

public Action El_Basi_Sonu(Event event, const char[] name, bool dontBroadcast)
{
	if (Lazer_Savaslari_Aktif)
	{
		Takim_Kapat();
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("mp_teammates_are_enemies", 0);
		SetCvar("mp_friendlyfire", 0);
		SekmemeAyarla(false);
		StopSoundAny(-2, 0, "misc/LaserWarsSounds/Ambiance/starwars.mp3");
		EmitSoundToAllAny("misc/LaserWarsSounds/End/end.mp3", -2, 0, 200, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		Lazer_Savaslari_Aktif = false;
		M4A1 = false;
		USP = false;
		MP5SD = false;
		for (int i = 1; i <= MaxClients; i++)
		{
			if (IsClientInGame(i))
			{
				SetEntProp(i, Prop_Send, "m_bNightVisionOn", 0);
			}
		}
		if (h_timer != INVALID_HANDLE)
		{
			delete h_timer;
		}
	}
}

public Action Oyuncu_Oldugunde(Handle event, const char[] name, bool dontBroadcast)
{
	if (Lazer_Savaslari_Aktif)
	{
		if (!TakimYapildi)
		{
			int T_Sayisi = 0;
			char Kazanan_Ismi[128];
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i) && GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
				{
					GetClientName(i, Kazanan_Ismi, 128);
					T_Sayisi++;
				}
			}
			if (T_Sayisi <= 1)
			{
				PrintToChatAll("[SM] \x04Lazer Savaşlarını \x01%s \x04Kazandı!", Kazanan_Ismi);
				SetCvar("sv_infinite_ammo", 0);
				SetCvar("mp_teammates_are_enemies", 0);
				SetCvar("mp_friendlyfire", 0);
				SekmemeAyarla(false);
				StopSoundAny(-2, 0, "misc/LaserWarsSounds/Ambiance/starwars.mp3");
				EmitSoundToAllAny("misc/LaserWarsSounds/End/end.mp3", -2, 0, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				Lazer_Savaslari_Aktif = false;
				M4A1 = false;
				USP = false;
				MP5SD = false;
				for (int j = 1; j < MaxClients; j++)
				{
					if (IsClientInGame(j) && GetClientTeam(j) == CS_TEAM_T)
					{
						ModelVer(j);
						Silahlari_Sil(j);
						GivePlayerItem(j, "weapon_knife");
						if (EkranEfekt)
						{
							SetEntProp(j, Prop_Send, "m_bNightVisionOn", 0);
						}
					}
				}
			}
		}
		else
		{
			int Siyah_Sayisi;
			int Beyaz_Sayisi;
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsValidClient(i))
				{
					if (GetClientTeam(i) == CS_TEAM_T && IsPlayerAlive(i))
					{
						if (takimNumarasi[i] == 1)
						{
							Siyah_Sayisi++;
						}
						if (takimNumarasi[i] == 2)
						{
							Beyaz_Sayisi++;
						}
					}
				}
			}
			if (Siyah_Sayisi <= 0)
			{
				PrintToChatAll("[SM] \x04Lazer Savaşlarını \x01Beyaz taraf \x04Kazandı!");
				SetCvar("sv_infinite_ammo", 0);
				SetCvar("mp_teammates_are_enemies", 0);
				SetCvar("mp_friendlyfire", 0);
				SekmemeAyarla(false);
				StopSoundAny(-2, 0, "misc/LaserWarsSounds/Ambiance/starwars.mp3");
				EmitSoundToAllAny("misc/LaserWarsSounds/End/end.mp3", -2, 0, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				Lazer_Savaslari_Aktif = false;
				M4A1 = false;
				USP = false;
				MP5SD = false;
				for (int j = 1; j < MaxClients; j++)
				{
					if (IsClientInGame(j) && GetClientTeam(j) == CS_TEAM_T)
					{
						ModelVer(j);
						Silahlari_Sil(j);
						GivePlayerItem(j, "weapon_knife");
						if (EkranEfekt)
						{
							SetEntProp(j, Prop_Send, "m_bNightVisionOn", 0);
						}
					}
				}
			}
			if (Beyaz_Sayisi <= 0)
			{
				PrintToChatAll("[SM] \x04Lazer Savaşlarını \x01Siyah taraf \x04Kazandı!");
				SetCvar("sv_infinite_ammo", 0);
				SetCvar("mp_teammates_are_enemies", 0);
				SetCvar("mp_friendlyfire", 0);
				SekmemeAyarla(false);
				StopSoundAny(-2, 0, "misc/LaserWarsSounds/Ambiance/starwars.mp3");
				EmitSoundToAllAny("misc/LaserWarsSounds/End/end.mp3", -2, 0, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
				Lazer_Savaslari_Aktif = false;
				M4A1 = false;
				USP = false;
				MP5SD = false;
				for (int j = 1; j < MaxClients; j++)
				{
					if (IsClientInGame(j) && GetClientTeam(j) == CS_TEAM_T)
					{
						ModelVer(j);
						Silahlari_Sil(j);
						GivePlayerItem(j, "weapon_knife");
						if (EkranEfekt)
						{
							SetEntProp(j, Prop_Send, "m_bNightVisionOn", 0);
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

void Takim_Kapat()
{
	TakimYapildi = false;
	for (int i = 1; i <= MaxClients; i++)
	{
		oyuncuTakimDurumu[i] = false;
		if (IsClientConnected(i) && IsClientInGame(i) && GetClientTeam(i) != CS_TEAM_NONE && GetClientTeam(i) != CS_TEAM_SPECTATOR && IsPlayerAlive(i))
		{
			SetEntityRenderColor(i, 255, 255, 255, 255);
		}
	}
}

void SekmemeAyarla(bool Durum)
{
	if (Durum)
	{
		SetCvar("weapon_accuracy_nospread", 1);
		SetCvarFloat("weapon_recoil_cooldown", 0.0);
		SetCvarFloat("weapon_recoil_decay1_exp", 9999.0);
		SetCvarFloat("weapon_recoil_decay2_exp", 9999.0);
		SetCvarFloat("weapon_recoil_decay2_lin", 9999.0);
		SetCvarFloat("weapon_recoil_scale", 0.0);
		SetCvar("weapon_recoil_suppression_shots", 500);
		SetCvarFloat("weapon_recoil_view_punch_extra", 0.0);
	}
	else
	{
		SetCvar("weapon_accuracy_nospread", 0);
		SetCvarFloat("weapon_recoil_cooldown", 0.55);
		SetCvarFloat("weapon_recoil_decay1_exp", 3.5);
		SetCvarFloat("weapon_recoil_decay2_exp", 8.0);
		SetCvarFloat("weapon_recoil_decay2_lin", 18.0);
		SetCvarFloat("weapon_recoil_scale", 2.0);
		SetCvar("weapon_recoil_suppression_shots", 4);
		SetCvarFloat("weapon_recoil_view_punch_extra", 0.055);
	}
}

public Action Hook_BlockTE(const char[] te_name, const int[] Players, int numClients, float delay)
{
	if (Lazer_Savaslari_Aktif)
	{
		return Plugin_Stop;
	}
	return Plugin_Continue;
}

void Silahlari_Sil(int client)
{
	int wepIdx;
	for (int i; i < 12; i++)
	{
		while ((wepIdx = GetPlayerWeaponSlot(client, i)) != -1)
		{
			RemovePlayerItem(client, wepIdx);
			RemoveEntity(wepIdx);
		}
	}
	if (M4A1)
	{
		GivePlayerItem(client, "weapon_m4a1_silencer");
	}
	else if (USP)
	{
		GivePlayerItem(client, "weapon_usp_silencer");
	}
	else if (MP5SD)
	{
		GivePlayerItem(client, "weapon_mp5sd");
	}
}

public Action Lazer_Savaslari_Durdur(int client, int args)
{
	if (warden_iswarden(client) || CheckAdminFlag(client, YetkiBayragi) || client == 0)
	{
		if (client != 0)
			PrintToChatAll("[SM] \x01Lazer Savaşları \x0E%N \x01tarafından durduruldu!", client);
		
		Takim_Kapat();
		SetCvar("sv_infinite_ammo", 0);
		SetCvar("mp_teammates_are_enemies", 0);
		SetCvar("mp_friendlyfire", 0);
		SekmemeAyarla(false);
		StopSoundAny(-2, 0, "misc/LaserWarsSounds/Ambiance/starwars.mp3");
		EmitSoundToAllAny("misc/LaserWarsSounds/End/end.mp3", -2, 0, 100, 0, 1.0, 100, -1, NULL_VECTOR, NULL_VECTOR, true, 0.0);
		Lazer_Savaslari_Aktif = false;
		M4A1 = false;
		USP = false;
		MP5SD = false;
		if (EkranEfekt)
		{
			for (int i = 1; i <= MaxClients; i++)
			{
				if (IsClientInGame(i) && GetClientTeam(i) == CS_TEAM_T)
				{
					SetEntProp(i, Prop_Send, "m_bNightVisionOn", 0);
				}
			}
		}
		if (h_timer != INVALID_HANDLE)
		{
			delete h_timer;
		}
		
	}
	else
	{
		ReplyToCommand(client, "[SM] \x0ELazer Savaşını \x01Sadece \x0Ckomutçular \x01durdurabilir!");
	}
	return Plugin_Continue;
}

bool IsValidClient(int client, bool nobots = true)
{
	if (client <= 0 || client > MaxClients || !IsClientConnected(client) || (nobots && IsFakeClient(client)))
	{
		return false;
	}
	return IsClientInGame(client);
}

void ModelKaydet(int client)
{
	char PlayerModel[PLATFORM_MAX_PATH];
	GetClientModel(client, PlayerModel, sizeof(PlayerModel));
	SetClientCookie(client, g_Model, PlayerModel);
}

void ModelVer(int client)
{
	char PlayerModel[PLATFORM_MAX_PATH];
	GetClientCookie(client, g_Model, PlayerModel, sizeof(PlayerModel));
	SetEntityModel(client, PlayerModel);
}

void SetCvar(char[] cvarName, int value)
{
	ConVar IntCvar = FindConVar(cvarName);
	if (IntCvar == null)return;
	int flags = IntCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	IntCvar.Flags = flags;
	IntCvar.IntValue = value;
	flags |= FCVAR_NOTIFY;
	IntCvar.Flags = flags;
}

void SetCvarFloat(char[] cvarName, float value)
{
	ConVar FloatCvar = FindConVar(cvarName);
	if (FloatCvar == null)return;
	int flags = FloatCvar.Flags;
	flags &= ~FCVAR_NOTIFY;
	FloatCvar.Flags = flags;
	FloatCvar.FloatValue = value;
	flags |= FCVAR_NOTIFY;
	FloatCvar.Flags = flags;
}

bool CheckAdminFlag(int client, const char[] flags) // Z harfi otomatik erişim verir
{
	int iCount = 0;
	char sflagNeed[22][8], sflagFormat[64];
	bool bEntitled = false;
	Format(sflagFormat, sizeof(sflagFormat), flags);
	ReplaceString(sflagFormat, sizeof(sflagFormat), " ", "");
	iCount = ExplodeString(sflagFormat, ",", sflagNeed, sizeof(sflagNeed), sizeof(sflagNeed[]));
	for (int i = 0; i < iCount; i++)
	{
		if ((GetUserFlagBits(client) & ReadFlagString(sflagNeed[i])) || (GetUserFlagBits(client) & ADMFLAG_ROOT))
		{
			bEntitled = true;
			break;
		}
	}
	return bEntitled;
}

void Ekran_Renk_Olustur(int client, int Color[4])
{
	int clients[1];
	clients[0] = client;
	Handle message = StartMessageEx(GetUserMessageId("Fade"), clients, 1, 0);
	Protobuf pb = UserMessageToProtobuf(message);
	pb.SetInt("duration", 200);
	pb.SetInt("hold_time", 40);
	pb.SetInt("flags", 17);
	pb.SetColor("clr", Color);
	EndMessage();
} 