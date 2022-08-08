/**
    История изменений:
        0.1 (15.10.2021) by b0t.
            - Первый релиз;
*/

#if !defined _reapi_included
    #include <reapi>
#endif

#if !defined _xs_included
    #include <xs>
#endif

#if !defined _fakemeta_included
    #include <fakemeta>
#endif

#if defined _reapi_v_included
    #endinput
#endif
#define _reapi_v_included

enum _:PERCENT_DATA {
    _IS_,                   //Какое число соответствует N процентов от исходного
    _GET_,                  //Сколько процентов составляет N-е число от исходного
    _ADD_,                  //Добавить N процентов к числу
    _SUB_                   //Вычесть N процентов от числа
};

/**
    * Узнать есть ли у игрока 'бессмертие'.
    *
    *   @param pPlayer      Игрок.
    *
    *   @return             bool
*/
stock bool:rg_get_user_godmode(const pPlayer) {
    return bool:(Float:get_entvar(pPlayer,var_takedamage) == DAMAGE_NO);
}

/**
    * Выдать/Забрать у игрока 'бессмертие'.
    *
    *   @param pPlayer      Игрок.
    *   @param bType        Включить/отключить
    *
    *   @return             -
*/
stock rg_set_user_godmode(const pPlayer,const bool:bType = false) {
    set_entvar(pPlayer,var_takedamage,bType ? DAMAGE_NO : DAMAGE_YES);
}

/**
    * Узнать есть ли у игрока 'ноклип'.
    *
    *   @param pPlayer      Игрок.
    *
    *   @return             bool
*/
stock bool:rg_get_user_noclip(const pPlayer) {
    return bool:(get_entvar(pPlayer,var_movetype) == MOVETYPE_NOCLIP);
}

/**
    * Выдать/Забрать у игрока 'ноклип'.
    *
    *   @param pPlayer      Игрок.
    *   @param bType        Включить/отключить
    *
    *   @return             -
*/
stock rg_set_user_noclip(const pPlayer,const bool:bType = false) {
    set_entvar(pPlayer,var_movetype,bType ? MOVETYPE_NOCLIP : MOVETYPE_WALK);
}

/**
    * Сделает объект видимым/невидимым.
    *
    *   @param iEnt         Объект
    *   @param bHide        Выключить/включить
    *
    *   @return             -
*/
stock rg_set_entity_invisibility(const iEnt, bool:bHide = true) {
    new iFlags = get_entvar(iEnt,var_effects);
    set_entvar(iEnt,var_effects,bHide ? (iFlags |= EF_NODRAW) : (iFlags &= ~EF_NODRAW))
}

/**
    * Узнать видно ли объект.
    *
    *   @param iEnt      Объект
    *
    *   @return             true -- если не видно
*/
stock bool:rg_get_user_invisibility(const iEnt) {
    return bool:(get_entvar(iEnt, var_effects) & EF_NODRAW)
}

/**
    * Какую скорость имеет игрок.
    *
    *   @param pPlayer      Игрок.
    *
    *   @return             float
*/
stock Float:rg_get_user_maxspeed(const pPlayer) {
    return Float:get_entvar(pPlayer,var_maxspeed);
}

/**
    * Устанавливает игроку скорость.
    *
    *   @param pPlayer      Игрок.
    *   @param fSpeed       Скорость(float)
    *
    *   @return             -
*/
stock rg_set_user_maxspeed(const pPlayer, Float:fSpeed = -1.0) {
    if(speed != -1)
        set_entvar(pPlayer,var_maxspeed,speed);
    else
        rg_reset_maxspeed(pPlayer);
}

/**
    * Устанавливает игроку гравитацию.
    *
    *   @param pPlayer      Игрок.
    *   @param fGravity       Скорость(float)
    *
    *   @return             -
*/
stock rg_set_user_gravity(const pPlayer,Float:fGravity = 1.0) {
    set_entvar(pPlayer,var_gravity,gravity);
}

/**
    * Какую гравитацию имеет игрок.
    *
    *   @param pPlayer      Игрок.
    *
    *   @return             float
*/
stock Float:rg_get_user_gravity(const pPlayer) {
    return Float:get_entvar(pPlayer,var_gravity);
}

/**
    * Вернёт true если у игрока есть прибор ночного виденья.
    *
    *   @param pPlayer      Игрок.
    *
    *   @return             bool
*/
stock rg_get_user_nvg(const pPlayer) {
    return get_member(pPlayer,m_bHasNightVision);
}

/**
    * Выдёт игроку прибор ночного виденья.
    *
    *   @param pPlayer      Игрок.
    *   @param bNvg         false/true
    *
    *   @return             -
*/
stock rg_set_user_nvg(const pPlayer,bool:bNvg = true) {
    set_member(pPlayer,m_bHasNightVision,bNvg);
}

/**
    * Устанавливает эффекты объекту
    *   @NOTE: Необходимые константы можно найти в 'amxconst.inc'
    *
    *   @param iEnt     Объект
    *   @param iFx      Эффекты
    *   @param fColor   Цвет = Float:{R,G,B}
    *   @param iRender  Режим рендеринга. Одна из констант kRender*
    *   @param iAmount  Объём (0-255)
    *
    *   @return             -
*/
stock rg_set_entity_rendering(const iEnt,
                                const iFx = kRenderFxNone,
                                const Float:fColor[] = {255.0,255.0,255.0},
                                const iRender = kRenderNormal,
                                const iAmount = 16) {
    set_entvar(iEnt,var_renderfx,iFx);
    set_entvar(iEnt,var_rendercolor,fColor);
    set_entvar(iEnt,var_rendermode,iRender);
    set_entvar(iEnt,var_renderamt,float(iAmount));
}

/**
    * Прибавит игроку здоровье
    *
    *   @param pPlayer      Игрок
    *   @param fHp          Здоровье
    *   @param bIsMax       Использовать мнимальный/максимальные значения(false/true)
    *   @param fHpMin       Минимальное кол-во здоровья
    *   @param fHpMax       Максимальное кол-во здоровья
    *
    *   @return             -
*/
stock rg_set_user_health(const pPlayer,const Float:fHp,const bool:bIsMax = false,const Float:fHpMin = 1.0,const Float:fHpMax = 100.0) {
    if(bIsMax)
        set_entvar(pPlayer,var_health,floatclamp((get_entvar(pPlayer,var_health)+fHp),fHpMin,fHpMax));
    else
        set_entvar(pPlayer,var_health,fHp);
}

/**
    * Получить команду игрока
    *
    *   @param pPlayer      Игрок
    *
    *   @return             -
*/
stock TeamName:rg_get_user_team(const pPlayer) {
    return TeamName:get_member(pPlayer,m_iTeam);
}

/**
    * Заморозит/разморозит объект
    *
    *   @param iEnt     Объект
    *   @param bFreez   true -- заморозит
    *
    *   @return             -
*/
stock rg_set_entity_frozen(const iEnt,const bool:bFreez = false) {
    new iFlags = get_entvar(iEnt,var_flags);
    set_entvar(iEnt,var_flags,bFreez ? (iFlags |= FL_FROZEN) : (iFlags &~ FL_FROZEN));
}

/**
    * "Передаст" деньги одного игрока другому
    *
    *   @param pPlayer      Игрок со счёта которого будем списывать
    *   @param pSender      Игрок, на счёт которому будем зачислять
    *   @param iAmmount     Сумма
    *   @param bUpdateHud   Обновлять худ денег
    *
    *   @return             -
*/
stock UTIL_TransferMoney(const pPlayer,const pSender,const iAmmount,const bool:bUpdateHud = false) {
    rg_add_account(pPlayer,-iAmmount,AS_SET,bUpdateHud);
    rg_add_account(pSender,iAmmount,AS_SET,bUpdateHud);
}

/**
    * Удалит ключи цветов из строки
    *
    *   @param szMessage     Массив с сообщением
    *   @param iMaxLen       Максимальный размер массива
    *   @param bType         true -- Удалять цвета из меню | false -- из чата
    *
    *   @return             -
*/
stock UTIL_ReplaceSimvols(szMessage[],const iMaxLen,const bool:bType = false) {
    switch(bType) {
        case false: {
            replace_all(szMessage,iMaxLen,"\r","");
            replace_all(szMessage,iMaxLen,"\y","");
            replace_all(szMessage,iMaxLen,"\d","");
            replace_all(szMessage,iMaxLen,"\w","");
        }
        case true: {
            replace_all(szMessage,iMaxLen,"^4","");
            replace_all(szMessage,iMaxLen,"^2","");
            replace_all(szMessage,iMaxLen,"^1","");
        }
    }
}

/**
    * Зарегистрирует команду во всех чатах + консоль
    *
    *   @param szCmd     Команда
    *   @param szFunc    Функция обработчик
    *
    *   @return             -
*/
stock UTIL_RegisterClCmd(const szCmd[],const szFunc[]) {
    register_clcmd(fmt("%s",szCmd),szFunc);
    register_clcmd(fmt("say /%s",szCmd),szFunc);
    register_clcmd(fmt("say_team /%s",szCmd),szFunc);
}

/**
    * Отображает меню игроку
    *   @NOTE: Если игрока нет на сервере -- уничтожит меню для избежания утечек памяти
    *
    *   @param pPlayer               Игрок
    *   @param iMenu            Меню
    *   @param szNextName       Оформление кнопки "Далее"
    *   @param szBackName       Оформление кнопки "Назад"
    *   @param szExitName       Оформление кнопки "Выход"
    *   @param szNumberColor    Цвет номеров (1,2,3...)
    *   @param iPage            С какой страницы открыть меню
    *
    *   @return             -
*/
stock UTIL_RegisterMenu(const pPlayer,
                        const iMenu,
                        const szNextName[] = "Назад",
                        const szBackName[] = "Далее",
                        const szExitName[] = "Выход",
                        const szNumberColor[] = "\y",
                        const iPage = 0) {
    
    if(menu_items(iMenu) <= 0 || !is_user_connected(pPlayer))
        menu_destroy(iMenu);
    else {
        menu_setprop(iMenu,MPROP_NEXTNAME,szNextName);
        menu_setprop(iMenu,MPROP_BACKNAME,szBackName);
        menu_setprop(iMenu,MPROP_EXITNAME,szExitName);

        menu_setprop(iMenu,MPROP_NUMBER_COLOR,szNumberColor);

        menu_display(pPlayer,iMenu,iPage);
    }
}

/**
    * Воспроизведёт звук игроку/всем
    *
    *   @param pPlayer          Игрок
    *   @param szSound          Звук в формате (.wav/.mp3)
    *   @param bStopSound       Остановить предыдущие(костыль)
    *
    *   @return             -
*/
stock UTIL_PlaySound(const pPlayer = 0,const szSound[],const bool:bStopSound = false) {
    if (bStopSound)
        client_cmd(pPlayer, "mp3 stop;stopsound");
        
    if(containi(szSound,".mp3") != -1)
        client_cmd(pPlayer,"mp3 play ^"sound/%s^"", szSound);
    else
        client_cmd(pPlayer,"spk ^"%s^"", szSound);
}