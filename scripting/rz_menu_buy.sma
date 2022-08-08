#include <AmxModX>
#include <AmxMisc>
#include <ReZP>
#include <ReApi_V>

public stock const PluginName[] = "[ReZP] Menu: Buy";
public stock const PluginVersion[] = "1.0 beta";
public stock const PluginAuthor[] = "ImmortalAmxx";
public stock const PluginURL[] = "https://github.com/ImmortalAmxx/ReZP-BuyMenu";
public stock const PluginDescription[] = "Buy menu for ReZP by fl0wer.";

//public stock const PluginFilePath[] = "rezombieplague"; // Путь к файлу. Если ну нежно - закомментируйте строку -> // перед строчкой.
public stock const PluginFileName[] = "rz_buymenu.ini"; // Название .ini файла.

enum _:ArrDataMenu {
	MENU_NAME[64],
	MENU_CMD[32],
	MENU_ACCESS[10]
};

enum _:ArrDataItem {
	ITEM_NAME[32],
	ITEM_MENU_NAME[64],
	ITEM_COST[7],
	ITEM_ROUNDNUM[2],
	ITEM_LIMIT[2],
	ITEM_LIMITTYPE[2],
	ITEM_ACCESS[3]
};

new Array:g_aBuyData, Array:g_aMenuData, Array:g_aMenuID, Array:g_aMenuAccess, g_szConfigsDir[256], g_pPlayerLimit[33][100], g_iLimit[100];

public plugin_init() {
	register_plugin(
		.plugin_name = PluginName,
		.version = PluginVersion,
		.author = PluginAuthor
	);

	RegisterHookChain(RG_RoundEnd, "@RG_RoundEnd_Post", .post = true);

	UTIL_RegisterClCmd(.szCmd = "buymenu", .szFunc = "@ClientCommand_BuyMenu");
	register_dictionary(.filename = "rezombieplague/ru/buymenu.txt");

	@ArrayFunc();
}

@RG_RoundEnd_Post() {
	arrayset(g_pPlayerLimit[0][0], 0, sizeof(g_pPlayerLimit) * sizeof(g_pPlayerLimit[]));
	arrayset(g_iLimit[0], 0, sizeof(g_iLimit) * sizeof(g_iLimit[]));
}

@ArrayFunc() {
	g_aMenuData = ArrayCreate(ArrDataMenu);
	g_aBuyData = ArrayCreate(ArrDataItem);
	g_aMenuID = ArrayCreate(10);
	g_aMenuAccess = ArrayCreate(32);

	get_configsdir(g_szConfigsDir, charsmax(g_szConfigsDir));

	@CreateFile();
	@ReadFile();
}

@ClientCommand_BuyMenu(pPlayer) {
	new iMenu, aDataMenu[ArrDataMenu];

	iMenu = menu_create(fmt("%l", "BUYMENU_TITLE"), "@Menu_Handler");

	for(new iCase; iCase < ArraySize(g_aMenuData); iCase++) {
		ArrayGetArray(g_aMenuData, iCase, aDataMenu);
		menu_additem(iMenu, aDataMenu[MENU_NAME], fmt("%i", iCase));
	}

	UTIL_RegisterMenu(pPlayer, iMenu);
}

@Menu_Handler(pPlayer, iMenu, iItem) {
	if(iItem == MENU_EXIT) {
		menu_destroy(iMenu);
		return PLUGIN_HANDLED;
	}

	new aDataMenu[ArrDataMenu];
	ArrayGetArray(g_aMenuData, iItem, aDataMenu);

	client_cmd(pPlayer, aDataMenu[MENU_CMD]);

	return PLUGIN_HANDLED;
}

@ClientCommand_ShowMenuPre(pPlayer) {
	new szArgvCmd[256];
	read_argv(read_argc() - 1, szArgvCmd, charsmax(szArgvCmd));
	remove_quotes(szArgvCmd);

	replace_all(szArgvCmd, charsmax(szArgvCmd), "/", "");

	new iMenuNum, aDataMenu[ArrDataMenu];

	for(iMenuNum = 0; iMenuNum < ArraySize(g_aMenuData); iMenuNum++) {
		ArrayGetArray(g_aMenuData, iMenuNum, aDataMenu);
		if(equal(szArgvCmd, aDataMenu[MENU_CMD])) {
			new szClass[32];
			ArrayGetString(g_aMenuAccess, iMenuNum, szClass, charsmax(szClass)); 

			new iClass = rz_player_get(pPlayer, RZ_PLAYER_CLASS, szClass);

			if(iClass)
				@ShowMenu(pPlayer, iMenuNum);
		}
	}
}

@ShowMenu(pPlayer, iKey) {
	new aDataMenu[ArrDataMenu], aDataItem[ArrDataItem], iMenu;

	ArrayGetArray(g_aMenuData, iKey, aDataMenu);

	iMenu = menu_create(aDataMenu[MENU_NAME], "@MenuHandler_Item");

	for(new iCase; iCase < ArraySize(g_aBuyData); iCase ++) {
		ArrayGetArray(g_aBuyData, iCase, aDataItem);
		if(ArrayGetCell(g_aMenuID, iCase) != iKey)
			continue;

		menu_additem(iMenu, 
			fmt("%s \r[\y%i Аммо\r]", aDataItem[ITEM_MENU_NAME], str_to_num(aDataItem[ITEM_COST])), 
			fmt("%i", iCase), read_flags(aDataItem[ITEM_ACCESS])
		);
	}

	UTIL_RegisterMenu(pPlayer, iMenu);
}

@MenuHandler_Item(pPlayer, iMenu, iItem) {
	if(iItem == MENU_EXIT) {
		menu_destroy(iMenu);
		return PLUGIN_HANDLED;
	}

	new szData[64];
	menu_item_getinfo(iMenu, iItem, .info = szData, .infolen = charsmax(szData));

	new iKey = str_to_num(szData);

	new aDataItem[ArrDataItem];
	ArrayGetArray(g_aBuyData, iKey, aDataItem);

	new iRoundNum = get_member_game(m_iTotalRoundsPlayed) + 1;

	if(aDataItem[ITEM_ROUNDNUM] != EOS) {
		if(iRoundNum < str_to_num(aDataItem[ITEM_ROUNDNUM])) {
			client_print_color(pPlayer, print_team_default, "%l %l", "BUYMENU_TAG", "BUYMENU_NO_ROUND", str_to_num(aDataItem[ITEM_ROUNDNUM]));
			return PLUGIN_HANDLED;
		}
	}

	if(aDataItem[ITEM_LIMITTYPE] != EOS) {
		switch(str_to_num(aDataItem[ITEM_LIMITTYPE])) {
			case 1:	{
				if(g_pPlayerLimit[pPlayer][iKey] >= str_to_num(aDataItem[ITEM_LIMIT])) {
					client_print_color(pPlayer, print_team_default, "%l %l", "BUYMENU_TAG", "BUYMENU_LIMIT", str_to_num(aDataItem[ITEM_LIMIT]));
					return PLUGIN_HANDLED;
				}
				else g_pPlayerLimit[pPlayer][iKey] ++;
			}
			case 2: {
				if(g_iLimit[iKey] >= str_to_num(aDataItem[ITEM_LIMIT])) {
					client_print_color(pPlayer, print_team_default, "%l %l", "BUYMENU_TAG", "BUYMENU_LIMIT", str_to_num(aDataItem[ITEM_LIMIT]));
					return PLUGIN_HANDLED;
				}
				else g_iLimit[iKey] ++;			
			}
		}
	}

	if(aDataItem[ITEM_COST] != EOS) {
		new iCost = str_to_num(aDataItem[ITEM_COST]);
		new iMoney = get_member(pPlayer, m_iAccount);

		if(iMoney < iCost) {
			client_print_color(pPlayer, print_team_default, "%l Аммо", "BUYMENU_TAG", "BUYMENU_NO_MONEY");
			return PLUGIN_HANDLED;
		}
		else rg_add_account(pPlayer, -iCost);
	}

	new iItem = rz_items_find(aDataItem[ITEM_NAME]);
	rz_items_player_give(pPlayer, iItem);

	return PLUGIN_HANDLED;
}

@CreateFile() {
	new szData[256];

	formatex(szData, charsmax(szData), "%s", g_szConfigsDir);

	if(!dir_exists(szData))
		mkdir(szData);
 
	#if defined PluginFilePath
		formatex(szData, charsmax(szData), "%s/%s/%s", szData, PluginFilePath, PluginFileName);
	#else
		formatex(szData, charsmax(szData), "%s/%s", szData, PluginFileName);
	#endif

	if(!file_exists(szData))
		write_file(szData,
		";  /*-----[Пример записи в файл]-----*/^n\
		;^n\
		;   Регистрируем меню:^n\
		;	  (Название меню #команда)^n\
		;	   #кому доступно# -- zombie, human, sniper, assassin, nemesis^n\
		;   Ниже, под регистрацией, уже добавляем айтем^n\
		;   ^"Название самого предмета^" ^"Название пункта^" ^"Цена^" ^"С какого раунда?^" ^"Тип лимита^" ^"Кол-во для лимита^" ^"Флаг доступа^"^n\
		;^n\
		;	Название самого предмета -- берется из rz_item_create(^"itemname^")^n\
		;   Название пункта -- Название пункта в меню.^n\
		;   Цена -- Цена за покупку/продажу/возрождение.^n\
		;   С какого раунда доступно? -- Номер раунда, с которого можно взять шмотку (Если не нужно - оставляем пустоту).^n\
		;   Тип лимита -- Тип лимита (Если не нужно - оставляем пустоту, 1 - для каждого игрока отдельно, 2 - глобальный).^n\
		;   Кол-во для лимита -- Максимумальное кол-во покупок при лимите.^n\
		;	Флаг доступа -- флаг, для которого доступна шмотка (Если для всех - оставляем пустоту.)^n\
		;^n\
		;   /*-----[Настройки]-----*/^n\
		(\r[\yBuyMenu\r] \wСняражение (Люди) #addon_buy_human)^n\
		#human#^n\
		^"human_armor^" ^"Броня (+50)^" ^"15^" ^"1^" ^"1^" ^"1^" ^"^"^n\
		^"human_firegrenade^" ^"Граната Огонь^" ^"6^" ^"1^" ^"1^" ^"1^" ^"^"^n\
		^"human_frostgrenade^" ^"Граната Заморозка^" ^"6^" ^"1^" ^"1^" ^"1^" ^"^"^n\
		^"human_flaregrenade^" ^"Светловая граната^" ^"6^" ^"1^" ^"1^" ^"1^" ^"^"^n\
		^n\
		(\r[\yBuyMenu\r] \wСняражение (Зомби) #addon_buy_zm)^n\
		#zombie#^n\
		^"human_antidote^" ^"Антидот^" ^"15^" ^"1^" ^"2^" ^"1^" ^"^"^n\
		^"zombie_madness^" ^"Бешенство^" ^"15^" ^"1^" ^"1^" ^"1^" ^"^"^n\
		^"zombie_infectionbomb^" ^"Инфекционная граната^" ^"20^" ^"1^" ^"1^" ^"1^" ^"^"^n\
		"
	);
}

@ReadFile() {
	new szData[256], szFile[256], f, aDataItem[ArrDataItem], aDataMenu[ArrDataMenu], iMenuID;

	#if defined PluginFilePath
		formatex(szFile, charsmax(szFile), "%s/%s/%s", g_szConfigsDir, PluginFilePath, PluginFileName);
	#else
		formatex(szFile, charsmax(szFile), "%s/%s", g_szConfigsDir, PluginFileName);
	#endif

	f = fopen(szFile, "r");

	while(!feof(f)) {
		fgets(f, szData, charsmax(szData));
		trim(szData);

		if(szData[0] == EOS || szData[0] == ';' || szData[0] == '/' && szData[1] == '/')
			continue;

		if(szData[0] == '(') {
			replace_all(szData, charsmax(szData), "(", "");
			replace_all(szData, charsmax(szData), ")", "");

			strtok(szData, aDataMenu[MENU_NAME], charsmax(aDataMenu), aDataMenu[MENU_CMD], charsmax(aDataMenu), '#');

			ArrayPushArray(g_aMenuData, aDataMenu);

			if(ArraySize(g_aMenuData) > 1) iMenuID++;

			continue;
		}

		if(szData[0] == '#') {
			replace_all(szData, charsmax(szData), "#", "");

			new szAccess[10];
			parse(szData, szAccess, charsmax(szAccess));

			ArrayPushString(g_aMenuAccess, szAccess);

			continue;
		}

		if(szData[0] == '"') {
			parse(szData,
				aDataItem[ITEM_NAME], charsmax(aDataItem),
				aDataItem[ITEM_MENU_NAME], charsmax(aDataItem),
				aDataItem[ITEM_COST], charsmax(aDataItem),
				aDataItem[ITEM_ROUNDNUM], charsmax(aDataItem),
				aDataItem[ITEM_LIMITTYPE], charsmax(aDataItem),
				aDataItem[ITEM_LIMIT], charsmax(aDataItem),
				aDataItem[ITEM_ACCESS], charsmax(aDataItem)
			);

			ArrayPushArray(g_aBuyData, aDataItem);
			ArrayPushCell(g_aMenuID, iMenuID);

			continue;
		}
		else
			continue;
	}


	for(new iCmd; iCmd < ArraySize(g_aMenuData); iCmd++) {
		ArrayGetArray(g_aMenuData, iCmd, aDataMenu);
		UTIL_RegisterClCmd(.szCmd = aDataMenu[MENU_CMD], .szFunc = "@ClientCommand_ShowMenuPre");
	}

	fclose(f);
}