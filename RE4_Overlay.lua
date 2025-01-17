

-- chainsaw.DynamicsSystem
-- chainsaw.DropItemManager
-- chainsaw.CharacterManager

-- chainsaw.EnemyAttackPermitManager
-- checkAttackPermit(chainsaw.CharacterContext, chainsaw.CharacterContext)  chainsaw.EnemyAttackPermitManager.AttackPermitResult

-- chainsaw.EnemyDropPartsManager

-- chainsaw.ExecutionPermitter


-- chainsaw.GameRankSystem
-- chainsaw.GameSituationManager
-- chainsaw.GameStatsManager

-- chainsaw.MaterialGroupManager
-- chainsaw.MaterialZoneManager

-- chainsaw.EnemyManager
-- chainsaw.PlayerManager
-- chainsaw.HitPoint
-- chainsaw.CharacterBackup

-- chainsaw.MovieManager
-- chainsaw.SoundDetectionManager

local re = re
local sdk = sdk
local d2d = d2d
local imgui = imgui
local log = log
local json = json
local draw = draw

log.info("[RE4 Overlay] Loaded");

local CN_FONT_NAME = 'NotoSansSC-Bold.otf'
local CN_FONT_SIZE = 18
local CJK_GLYPH_RANGES = {
    0x0020, 0x00FF, -- Basic Latin + Latin Supplement
    0x2000, 0x206F, -- General Punctuation
    0x3000, 0x30FF, -- CJK Symbols and Punctuations, Hiragana, Katakana
    0x31F0, 0x31FF, -- Katakana Phonetic Extensions
    0xFF00, 0xFFEF, -- Half-width characters
    0x4e00, 0x9FAF, -- CJK Ideograms
    0,
}

local fontCN = imgui.load_font(CN_FONT_NAME, CN_FONT_SIZE, CJK_GLYPH_RANGES)


local SceneManager = sdk.get_native_singleton("via.SceneManager")
local function GetSceneManager()
    if SceneManager == nil then SceneManager = sdk.get_native_singleton("via.SceneManager") end
	return SceneManager
end

local SaveDataManager = sdk.get_managed_singleton("share.SaveDataManager")
local function GetSaveDataManager()
    if SaveDataManager == nil then SaveDataManager = sdk.get_managed_singleton("share.SaveDataManager") end
	return SaveDataManager
end

local TimerManager = sdk.get_managed_singleton("chainsaw.TimerManager")
local function GetTimerManager()
    if TimerManager == nil then TimerManager = sdk.get_managed_singleton("chainsaw.TimerManager") end
	return TimerManager
end

local CharmManager = sdk.get_managed_singleton("chainsaw.CharmManager")
local function GetCharmManager()
    if CharmManager == nil then CharmManager = sdk.get_managed_singleton("chainsaw.CharmManager") end
	return CharmManager
end

local GameStatsManager = sdk.get_managed_singleton("chainsaw.GameStatsManager")
local function GetGameStatsManager()
    if GameStatsManager == nil then GameStatsManager = sdk.get_managed_singleton("chainsaw.GameStatsManager") end
	return GameStatsManager
end

local GameClock = sdk.get_managed_singleton("share.GameClock")
local function GetGameClock()
    if GameClock == nil then GameClock = sdk.get_managed_singleton("share.GameClock") end
	return GameClock
end

local MapManager = sdk.get_managed_singleton("chainsaw.MapManager")
local function GetMapManager()
    if MapManager == nil then MapManager = sdk.get_managed_singleton("chainsaw.MapManager") end
	return MapManager
end

local InventoryManager = sdk.get_managed_singleton("chainsaw.InventoryManager")
local function GetInventoryManager()
    if InventoryManager == nil then InventoryManager = sdk.get_managed_singleton("chainsaw.InventoryManager") end
	return InventoryManager
end

local DropItemManager = sdk.get_managed_singleton("chainsaw.DropItemManager")
local function GetDropItemManager()
    if DropItemManager == nil then DropItemManager = sdk.get_managed_singleton("chainsaw.DropItemManager") end
	return DropItemManager
end

local GameRankSystem = sdk.get_managed_singleton("chainsaw.GameRankSystem")
local function GetGameRankSystem()
    if GameRankSystem == nil then GameRankSystem = sdk.get_managed_singleton("chainsaw.GameRankSystem") end
	return GameRankSystem
end

local EnemyAttackPermitManager = sdk.get_managed_singleton("chainsaw.EnemyAttackPermitManager")
local function GetEnemyAttackPermitManager()
    if EnemyAttackPermitManager == nil then EnemyAttackPermitManager = sdk.get_managed_singleton("chainsaw.EnemyAttackPermitManager") end
	return EnemyAttackPermitManager
end

local CharacterManager = sdk.get_managed_singleton("chainsaw.CharacterManager")
local function GetCharacterManager()
    if CharacterManager == nil then CharacterManager = sdk.get_managed_singleton("chainsaw.CharacterManager") end
	return CharacterManager
end

local function getMasterPlayer()
    local mgr = GetCharacterManager()
    if mgr == nil then return nil end
    return mgr:call("getPlayerContextRef")
end

-- return cha:call("get_DollNpcContextList()")
local function GetEnemyList()
    local cha = GetCharacterManager()
    if cha == nil then return nil end
    return cha:call("get_EnemyContextList")
end

local EnemyManager = CharacterManager:call("get_EnemyManager")
local function GetEnemyManager()
    if EnemyManager == nil then EnemyManager = CharacterManager:call("get_EnemyManager") end
	return EnemyManager
end

local PlayerManager = CharacterManager:call("get_PlayerManager")
local function GetPlayerManager()
    if PlayerManager == nil then PlayerManager = CharacterManager:call("get_PlayerManager") end
	return PlayerManager
end

-- ==== Config ====

local Languages = {"EN", "CN"}

local Config = json.load_file("RE4_Overlay/RE4_Overlay.json") or {}
if Config.Enabled == nil then
    Config.Enabled = true
end
if Config.FontSize == nil then
    Config.FontSize = 24
end
if Config.Language == nil then
    Config.Language = "EN"
end

if Config.StatsUI == nil then
    Config.StatsUI = {
        PosX = 1400,
        PosY = 200,
        RowHeight = 25,
        Width = 400,
        DrawPlayerHPBar = false,
    }
end
if Config.StatsUI.Enabled == nil then
    Config.StatsUI.Enabled = true
end
if Config.StatsUI.RowsCount == nil then
    Config.StatsUI.RowsCount = 25
end

if Config.EnemyUI == nil then
    Config.EnemyUI = {
        PosX = 0,
        PosY = 200,
        RowHeight = 25,
        Width = 400,
        DrawEnemyHPBar = true,
        DrawPartHPBar = true,
        FilterMaxHPEnemy = true,
        FilterMaxHPPart = true,
        FilterUnbreakablePart = true,
    }
end
if Config.EnemyUI.Enabled == nil then
    Config.EnemyUI.Enabled = true
end
if Config.EnemyUI.DisplayPartHP == nil then
    Config.EnemyUI.DisplayPartHP = true
end
if Config.EnemyUI.FilterNoInSightEnemy == nil then
    Config.EnemyUI.FilterNoInSightEnemy = false
end
if Config.EnemyUI.RowsCount == nil then
    Config.EnemyUI.RowsCount = 40
end

if Config.FloatingUI == nil then
    Config.FloatingUI = {
        Enabled = true,

        FilterMaxHPEnemy = false,
        FilterBlockedEnemy = true,
        MaxDistance = 15,
        IgnoreDistanceIfDamaged = true,
        IgnoreDistanceIfDamagedScale = 0.8,

        DisplayNumber = false,

        WorldPosOffsetX = 0,
        WorldPosOffsetY = 1.75,
        WorldPosOffsetZ = 0,

        ScreenPosOffsetX = -125,
        ScreenPosOffsetY = 0,

        Height = 14,
        Width = 200,
        MinScale = 0.3,
        ScaleHeightByDistance = true,
        ScaleWidthByDistance = false,
    }
end

if Config.FloatingUI.FontSize == nil then
    Config.FloatingUI.FontSize = 18
end

if Config.DisplayConfig == nil then
    Config.DisplayConfig = {}
end

local DisplayConfigOrder = {
    "IGT",
    "Game Rank (DA)",
    "Action Point",
    "Item Point",
    "Backup Action Point",
    "Backup Item Point",
    "Fix Item Point",
    "Retry Count",
    "Kill Count",

    "Player Damage Rate",

    "Enemy DA Title",
    "Enemy Damage Rate",
    "Enemy Wince Rate",
    "Enemy Break Rate",
    "Enemy Stopping Rate",

    "Knife Reduce Rate",
    "Player HP Value",
    "Player Hate Rate",
    "Player Distance",
    ----
    "Duffel Check",
    "Display Position",
    "Display Rotation",
    ----
    ----
    "Enemy UI Title",
    "Enemy Name",
    "Enemy HP Value",
    "Enemy Game Rank Add",
    "Enemy Part HP Value",

    ----
    "Charm Manager Title",
    "Charm Manager Random Table Seed",
    "Charm Manager Random Table Counter"
}

if Config.CheatConfig == nil then
    Config.CheatConfig = {
        LockHitPoint = false,
    }
end
if Config.CheatConfig.NoHitMode == nil then
    Config.CheatConfig.NoHitMode = false
end
if Config.CheatConfig.UnlimitItemAndDurability == nil then
    Config.CheatConfig.UnlimitItemAndDurability = false
end
if Config.CheatConfig.SkipCG == nil then
    Config.CheatConfig.SkipCG = false
end
if Config.CheatConfig.SkipRadio == nil then
    Config.CheatConfig.SkipRadio = false
end
if Config.CheatConfig.DisableEnemyAttackCheck == nil then
    Config.CheatConfig.DisableEnemyAttackCheck = false
end
if Config.CheatConfig.PredictCharm == nil then
    Config.CheatConfig.PredictCharm = false
end
if Config.CheatConfig.AlsoForTeammate == nil then
    Config.CheatConfig.AlsoForTeammate = true
end

if Config.DebugMode == nil then
	Config.DebugMode = false
end

if Config.TesterMode == nil then
	Config.TesterMode = false
end

if Config.DangerMode == nil then
	Config.DangerMode = false
end

if Config.TesterMode then
    if Config.FixPlayer == nil then
        Config.FixPlayer = false
    end

    if Config.FixDelLago == nil then
        Config.FixDelLago = false
    end
end

-- ==== Utils ====

local function FindIndex(table, value)
	for i = 1, #table do
		if table[i] == value then
			return i;
		end
	end

	return nil;
end

local function GetEnumMap(enumTypeName)
	local t = sdk.find_type_definition(enumTypeName)
	if not t then return {} end

	local fields = t:get_fields()
	local enum = {}

	for i, field in ipairs(fields) do
		if field:is_static() then
			local name = field:get_name()
			local raw_value = field:get_data(nil)
			enum[raw_value] = name
		end
	end

	return enum
end

local KindMap = GetEnumMap("chainsaw.CharacterKindID")
local BodyPartsMap = GetEnumMap("chainsaw.character.BodyParts")
local BodyPartsSideMap = GetEnumMap("chainsaw.character.BodyPartsSide")
local ItemIDMap = GetEnumMap("chainsaw.ItemID")

ItemIDMap[0x6B93100] = "Handgun Ammo"
ItemIDMap[0x6B93D80] = "Shotgun Shells"
ItemIDMap[0x6B94A00] = "Submachine Gun Ammo"
ItemIDMap[0x6D19B00] = "Green Herb"
ItemIDMap[0x6D19BA0] = "Unknown"
ItemIDMap[0x6D1A140] = "Red Herb"
ItemIDMap[0x6D1A1E0] = "Unknown"
ItemIDMap[0x6D1A780] = "Yellow Herb"
ItemIDMap[0x6D1ADC0] = "Mixed Herb (G+G)"
ItemIDMap[0x6D1B400] = "Mixed Herb (G+G+G)"
ItemIDMap[0x6D1BA40] = "Mixed Herb (G+R)"
ItemIDMap[0x6D1C080] = "Mixed Herb (G+Y)"
ItemIDMap[0x6D1C6C0] = "Mixed Herb (R+Y)"
ItemIDMap[0x6D1CD00] = "Mixed Herb (G+R+Y)"
ItemIDMap[0x6D1D340] = "Mixed Herb (G+G+Y)"
ItemIDMap[0x6D1D980] = "First Aid Spray"
ItemIDMap[0x7026F00] = "Gunpowder"
ItemIDMap[0x7027540] = "Resources (L)"
ItemIDMap[0x7027B80] = "Attachable Mines"
ItemIDMap[0x70281C0] = "Broken Knife"
ItemIDMap[0x7028800] = "Resources (S)"
ItemIDMap[0x71C17C0] = "Hunter's Lodge Key"
ItemIDMap[0x7641700] = "Pesetas"
ItemIDMap[0x7668800] = "Case Upgrade (7x10)"
ItemIDMap[0x7668E40] = "Case Upgrade (7x12)"
ItemIDMap[0x7669480] = "Case Upgrade (8x12)"
ItemIDMap[0x7669AC0] = "Case Upgrade (8x13)"
ItemIDMap[0x766A100] = "Case Upgrade (9x13)"
ItemIDMap[0x766C680] = "Attaché Case: Silver"
ItemIDMap[0x768FF40] = "Recipe: Handgun Ammo"
ItemIDMap[0x7690580] = "Recipe: Shotgun Shells"
ItemIDMap[0x7690BC0] = "Recipe: Submachine Gun Ammo"
ItemIDMap[0x7691200] = "Recipe: Rifle Ammo"
ItemIDMap[0x7691840] = "Recipe: Magnum Ammo"
ItemIDMap[0x7691E80] = "Recipe: Bolts"
ItemIDMap[0x76924C0] = "Recipe: Bolts"
ItemIDMap[0x7692B00] = "#Rejected#"
ItemIDMap[0x7693140] = "Recipe: Attachable Mines"
ItemIDMap[0x7693780] = "Recipe: Heavy Grenade"
ItemIDMap[0x7693DC0] = "Recipe: Flash Grenade"
ItemIDMap[0x7697C40] = "Recipe: Mixed Herb (G+G)"
ItemIDMap[0x7698280] = "Recipe: Mixed Herb (G+R)"
ItemIDMap[0x76988C0] = "Recipe: Mixed Herb (G+Y)"
ItemIDMap[0x7698F00] = "Recipe: Mixed Herb (R+Y)"
ItemIDMap[0x7699540] = "Recipe: Mixed Herb (G+G+G)"
ItemIDMap[0x7699B80] = "Recipe: Mixed Herb (G+G+Y)"
ItemIDMap[0x769A1C0] = "Recipe: Mixed Herb (G+G+Y)"
ItemIDMap[0x769A800] = "Recipe: Mixed Herb (G+R+Y)"
ItemIDMap[0x769AE40] = "Recipe: Mixed Herb (G+R+Y)"
ItemIDMap[0x769B480] = "Recipe: Mixed Herb (G+R+Y)"
ItemIDMap[0x1061A800] = "SG-09 R"
ItemIDMap[0x10641900] = "W-870"
ItemIDMap[0x10668A00] = "TMP"
ItemIDMap[0x107A1200] = "Combat Knife"
ItemIDMap[0x107A1E80] = "Kitchen Knife"
ItemIDMap[0x1083D600] = "Hand Grenade"
ItemIDMap[0x1083E280] = "Flash Grenade"
ItemIDMap[0x1083E8C0] = "Chicken Egg"
ItemIDMap[0x1083EF00] = "Brown Chicken Egg"

ItemIDMap[127200000] = { CN = "荷塞先生", EN = "Don Jose",}
ItemIDMap[127201600] = { CN = "迭戈先生", EN = "Don Diego",}
ItemIDMap[127203200] = { CN = "埃斯特万先生", EN = "Don Esteban",}
ItemIDMap[127204800] = { CN = "曼努埃尔先生", EN = "Don Manuel",}
ItemIDMap[127206400] = { CN = "伊莎贝尔女士", EN = "Isabel",}
ItemIDMap[127208000] = { CN = "玛丽亚女士", EN = "Maria",}
ItemIDMap[127209600] = { CN = "萨尔瓦多医生", EN = "Dr. Salvador",}
ItemIDMap[127211200] = { CN = "贝拉姐妹", EN = "Bella Sisters",}
ItemIDMap[127212800] = { CN = "佩德罗先生", EN = "Don Pedro",}
ItemIDMap[127214400] = { CN = "邪教徒·巨镰", EN = "Zealot w/ scythe",}
ItemIDMap[127216000] = { CN = "邪教徒·盾牌", EN = "Zealot w/ shield",}
ItemIDMap[127217600] = { CN = "邪教徒·十字弩", EN = "Zealot w/ bowgun",}
ItemIDMap[127219200] = { CN = "邪教徒·引导者", EN = "Leader zealot",}
ItemIDMap[127220800] = { CN = "士兵·炸药", EN = "Soldier w/ dynamite",}
ItemIDMap[127222400] = { CN = "士兵·电棍", EN = "Soldier w/ stun-rod",}
ItemIDMap[127224000] = { CN = "士兵·铁锤", EN = "Soldier w/ hammer",}
ItemIDMap[127225600] = { CN = "J.J.", EN = "J.J.",}
ItemIDMap[127227200] = { CN = "里昂·手枪", EN = "Leon w/ handgun",}
ItemIDMap[127228800] = { CN = "里昂·霰弹枪", EN = "Leon w/ shotgun",}
ItemIDMap[127230400] = { CN = "里昂·RPG", EN = "Leon w/ rocket launcher",}
ItemIDMap[127232000] = { CN = "商人", EN = "Merchant",}
ItemIDMap[127233600] = { CN = "阿什莉·格拉汉姆", EN = "Ashley Graham",}
ItemIDMap[127235200] = { CN = "路易斯·塞拉", EN = "Luis Sera",}
ItemIDMap[127236800] = { CN = "艾达·王", EN = "Ada Wong",}
ItemIDMap[127238400] = { CN = "鸡", EN = "Chicken",}
ItemIDMap[127240000] = { CN = "黑鲈鱼", EN = "Black Bass",}
ItemIDMap[127241600] = { CN = "独角仙", EN = "Rhinoceros Beetle",}
ItemIDMap[127243200] = { CN = "光明教徽", EN = "Iluminados Emblem",}
ItemIDMap[127244800] = { CN = "打击者", EN = "Striker",}
ItemIDMap[127246400] = { CN = "可爱熊", EN = "Cute Bear",}

ItemIDMap[119275200] = { CN = "钥匙串（华丽钥匙）", EN = "Bunch of Keys (Ashley)", }
ItemIDMap[119238400] = { CN = "路易斯的钥匙", EN = "", }
ItemIDMap[119276800] = { CN = "立方雕", EN = "", }

local function GetItemName(id)
    if id == nil then return "" end
    local name = ItemIDMap[id]
    if Config.Language == "CN" and name.CN ~= nil and name.CN ~= "" then
        return name.CN
    end
    if Config.Language == "EN" and name.EN ~= nil and name.EN ~= "" then
        return name.EN
    end
    return name
end

local DropTypeMap = GetEnumMap("chainsaw.RandomDrop.DropType")

local function SetInvincible(playerBaseContext)
    -- TODO: Should check id?
    if playerBaseContext == nil then return end

    local hp = playerBaseContext:call("get_HitPoint")
    if Config.CheatConfig.LockHitPoint then
        hp:call("recovery", 99999)
    end

    if Config.CheatConfig.NoHitMode then
        hp:call("set_Invincible", true)
    end

    -- invisible attempt, but failed
    -- playerBaseContext:call("updateSafeRoomInfo", true) -- not working
    -- playerBaseContext:set_field("<State>k__BackingField", 2305843009213693952) -- in safe room
    -- playerBaseContext:set_field("<StateOld>k__BackingField", 2305843009213693952) -- in safe room
end

-- ==== Hooks ====
local RETVAL_TRUE = sdk.to_ptr(1)
local RETVAL_FALSE = sdk.to_ptr(0)

local TypedefPlayerBaseContext = sdk.find_type_definition("chainsaw.HitPoint")
local TypedefInventoryManager = sdk.find_type_definition("chainsaw.InventoryManager")
local TypedefItemUseManager = sdk.find_type_definition("chainsaw.ItemUseManager")
local TypedefInventoryControllerBase = sdk.find_type_definition("chainsaw.InventoryControllerBase")
local TypedefItem = sdk.find_type_definition("chainsaw.Item")
local TypedefWeaponItem = sdk.find_type_definition("chainsaw.WeaponItem")
local TypedefEnemyAttackPermitManager = sdk.find_type_definition("chainsaw.EnemyAttackPermitManager")

local lastTableNo
local lastLotterySeed
local lastLotteryCount
local lastCharmItemIDs
local lastGotChartmID
local lastRankPointKillCount
if Config.TesterMode then
    sdk.hook(sdk.find_type_definition("chainsaw.CharmManager"):get_method("drawingCharmGacha(System.Int32)"),
    function (args)
        lastTableNo = sdk.to_int64(args[3])
    end, function(ret)
        return ret
    end)

    sdk.hook(sdk.find_type_definition("chainsaw.CharmManager"):get_method("getCharmGachaItemId(chainsaw.CharmManager.LotteryTableData, System.Collections.Generic.List`1<chainsaw.ItemID>)"),
    function (args)
        local lotteryTable = sdk.to_managed_object(args[3])
        lastLotterySeed = lotteryTable:get_field("_Seed")
        lastLotteryCount = lotteryTable:get_field("_CurrnetCount")
        lastCharmItemIDs = sdk.to_managed_object(args[4])
    end, function(ret)
        lastGotChartmID = sdk.to_int64(ret)
        return ret
    end)

    sdk.hook(sdk.find_type_definition("chainsaw.GameRankSystem"):get_method("set_RankPointKillCount(System.Int32)"),
    function (args)
        lastRankPointKillCount = sdk.to_int64(args[3])
    end, function(ret)
        return ret
    end)
end

local disableCam
local cameraController
if Config.TesterMode then
    sdk.hook(sdk.find_type_definition("chainsaw.VehicleCameraController"):get_method("updateCameraPosition()"),
    function (args)
        cameraController = sdk.to_managed_object(args[2])
        if disableCam then
            return sdk.PreHookResult.SKIP_ORIGINAL
        end
    end, function(ret)
        return ret
    end)
end

-- sdk.hook(sdk.find_type_definition("chainsaw.Ch1f1z0HeadUpdater"):get_method("update()"),
-- function (args)
--     local this = sdk.to_managed_object(args[2])
--     if this:call("get_CharacterKindID") == "ch1_f1z0" then
--         return sdk.PreHookResult.SKIP_ORIGINAL
--     end
-- end, function(ret)
--     return ret
-- end)

-- sdk.hook(sdk.find_type_definition("chainsaw.Ch1f1z0BodyUpdater"):get_method("update()"),
-- function (args)
--     local this = sdk.to_managed_object(args[2])
--     if this:call("get_CharacterKindID") == "ch1_f1z0" then
--         return sdk.PreHookResult.SKIP_ORIGINAL
--     end
-- end, function(ret)
--     return ret
-- end)

-- sdk.hook(sdk.find_type_definition("chainsaw.TimelineEventActorEnemyCh1f1z0"):get_method("update()"),
-- function (args)
--     return sdk.PreHookResult.SKIP_ORIGINAL
-- end, function(ret)
--     return ret
-- end)

-- local disableWaterObstacle
-- sdk.hook(sdk.find_type_definition("chainsaw.WaterObstacleController"):get_method("onUpdate()"),
-- function (args)
--     if disableWaterObstacle then
--         return sdk.PreHookResult.SKIP_ORIGINAL
--     end
-- end, function(ret)
--     return ret
-- end)

local lastSaveArg
sdk.hook(sdk.find_type_definition("share.SaveDataManager"):get_method("requestStartSaveGameDataFlow(System.Int32, share.GameSaveRequestArgs)"),
function (args)
    lastSaveArg = sdk.to_managed_object(args[4])
end, function(ret)
    return ret
end)

local lastSavePoint

if Config.TesterMode then
    sdk.hook(sdk.find_type_definition("chainsaw.GmSavePoint"):get_method("openSaveLoad"),
    function (args)
        lastSavePoint = sdk.to_managed_object(args[2])
    end, function(ret)
        return ret
    end)
end

-- sdk.hook(sdk.find_type_definition("chainsaw.EnemyBehaviorTreeCondition_Base"):get_method("evaluate(via.behaviortree.ConditionArg)"),
-- function (args)
-- end, function(ret)
--     -- FIXME: this will affect Player and causes CTD
--     -- return RETVAL_FALSE
--     return ret
-- end)

-- sdk.hook(sdk.find_type_definition("chainsaw.PlayerBaseContext"):get_method("updateSafeRoomInfo(System.Boolean)"),
-- function (args)
-- end, function(ret)
--     -- return RETVAL_FALSE
--     return ret
-- end)

-- DropItemInfo

-- DropItemRandomTable

-- sdk.hook(sdk.find_type_definition("chainsaw.EnemyBehaviorTreeCondition_CheckFindState"):get_method("get_FindState()"),
-- function (args)
-- end, function(ret)
--     -- return RETVAL_FALSE
--     -- sdk.call_native_func(ret, sdk.find_type_definition("System.Collections.Generic.HashSet`1<System.UInt32>"), "Clear")
--     return 0
-- end)
-- sdk.hook(sdk.find_type_definition("chainsaw.EnemyBaseContext"):get_method("get_Actions()"),
-- function (args)
-- end, function(ret)
--     -- return RETVAL_FALSE
--     -- sdk.call_native_func(ret, sdk.find_type_definition("System.Collections.Generic.HashSet`1<System.UInt32>"), "Clear")
--     return ret
-- end)

local function skipMovie(movie)
    if not Config.DangerMode then return end

    if movie then
        local time = sdk.call_native_func(movie, sdk.find_type_definition("via.movie.Movie"), "get_DurationTime")
        sdk.call_native_func(movie, sdk.find_type_definition("via.movie.Movie"), "seek", time)
        -- movie:seek(movie:get_DurationTime())
    end
end

-- via.timeline.GameObjectClipPlayer
-- chainsaw.TimelineEventManager
-- MovieManager skipMovie
-- chainsaw.TimelineEventPlayer play

-- Skip Cutscene Real time render CG
local currentEventIDNum = 0
local currentEventID = 0
local currentTimelineEventWork
sdk.hook(sdk.find_type_definition("chainsaw.TimelineEventWork"):get_method("play"),
function (args)
    -- if not Config.CheatConfig.SkipCG then return end
    currentTimelineEventWork = sdk.to_managed_object(args[2])
    if currentTimelineEventWork ~= nil then
        currentEventIDNum = currentTimelineEventWork:get_field("_EventIDNum")
        currentEventID = currentTimelineEventWork:get_field("_EventID")
    else
        currentEventIDNum = -1
        currentEventID = -1
    end
    -- return sdk.PreHookResult.SKIP_ORIGINAL
end, function(ret)
    if not Config.CheatConfig.SkipCG then return end
    currentTimelineEventWork:call("skip")
    return ret
end)

-- Skip Radio Message
-- local thisRadioMsgManager
-- local radioMsgEvent
-- sdk.hook(sdk.find_type_definition("chainsaw.RadioMsgManager"):get_method("trgRadioMsgEvent(chainsaw.RadioMsgEvent)"),
-- function (args)
--     if not Config.CheatConfig.SkipRadio then return end
--     thisRadioMsgManager = sdk.to_managed_object(args[2])
--     radioMsgEvent = sdk.to_int64(args[3])
--     -- return sdk.PreHookResult.SKIP_ORIGINAL
-- end, function(ret)
--     if not Config.CheatConfig.SkipRadio then return end
--     -- thisRadioMsgManager:call("skipRadio")
--     -- thisRadioMsgManager:call("endRadio")
--     return ret
-- end)

-- sdk.hook(sdk.find_type_definition("chainsaw.RadioMovieWork"):get_method("requestLoadMovie(chainsaw.RadioMsgMovieID)"),
-- function (args)
--     if not Config.CheatConfig.SkipRadio then return end
--     return sdk.PreHookResult.SKIP_ORIGINAL
-- end, function(ret)
--     if not Config.CheatConfig.SkipRadio then return end
--     return ret
-- end)

-- Skip Radio Message
local currentMovieLoader
local currentMovieID
local currentMovieCallback
sdk.hook(sdk.find_type_definition("chainsaw.GuiMovieLoaderBase"):get_method("setupMovie(System.Int32, System.Action`1<System.Boolean>)"),
function (args)
    if not Config.CheatConfig.SkipRadio then return end
    currentMovieLoader = sdk.to_managed_object(args[2])
    currentMovieID = sdk.to_int64(args[3]) & 0xFFFFFFFF
    -- currentMovieID = sdk.to_int64(args[3])
    currentMovieCallback = sdk.to_managed_object(args[4])
    return sdk.PreHookResult.SKIP_ORIGINAL
end, function(ret)
    if not Config.CheatConfig.SkipRadio then return end
    currentMovieLoader:call("stopMovie", currentMovieID)
    return ret
end)

-- via.movie.MovieManager
-- Fast forward movies to the end to mute audio
local currentMovie
if Config.TesterMode then
    sdk.hook(sdk.find_type_definition("via.movie.Movie"):get_method("play"),
    function (args)
        currentMovie = (args[2])
        skipMovie(currentMovie)
    end, function(ret)
        skipMovie(currentMovie)
        return ret
    end)
end

-- local DisableAttack = true
sdk.hook(TypedefEnemyAttackPermitManager:get_method("checkAttackPermit(chainsaw.CharacterContext, chainsaw.CharacterContext)"),
function (args)
    -- if Config.CheatConfig.UnlimitItemAndDurability then
    --     return sdk.PreHookResult.SKIP_ORIGINAL
    -- end
end, function (retval)
    if not Config.CheatConfig.DisableEnemyAttackCheck then
        return retval
    end
    -- FIXME: this only affect melee enemy? strange
    sdk.to_managed_object(retval):call("set_Has", false)
	return retval
end)

local countTable = {}

local keyItemInventory
local lastHoverKeyItemID
local lastHoverKeyItemGuid
local lastHoverKeyItem
if Config.TesterMode then
    sdk.hook(sdk.find_type_definition("chainsaw.gui.keyitem.KeyItemInventory"):get_method("getItemId(System.Guid)"),
    function (args)
        keyItemInventory = sdk.to_managed_object(args[2])
        lastHoverKeyItemGuid = sdk.to_int64(args[3])
    end, function (retval)
        if retval == nil then
        else
            lastHoverKeyItemID = sdk.to_int64(retval)
            if keyItemInventory ~= nil and lastHoverKeyItemGuid ~= nil then
                lastHoverKeyItem = keyItemInventory:call("getInventoryItem(System.Guid)", lastHoverKeyItemGuid)
            end
        end
        return retval
    end)
end

local lastHoverItemID
sdk.hook(sdk.find_type_definition("chainsaw.gui.inventory.CsInventory"):get_method("getItem(chainsaw.InventorySlotType, chainsaw.CsSlotIndex)"),
function (args)
end, function (retval)
    if retval == nil or sdk.to_managed_object(retval) == nil then
    else
        lastHoverItemID = sdk.to_managed_object(retval):call("get_ItemId")
    end
	return retval
end)

local lastUseItemID
sdk.hook(TypedefItem:get_method("reduceCount(System.Int32)"),
function (args)
    local finalCount = sdk.to_int64(args[3]) & 0xFFFFFFFF
    local this = sdk.to_managed_object(args[2])
    local currentCount = this:get_field("_CurrentItemCount")

    if this:call("get_ItemType") == 0 then
        -- key item
        return
    end

    lastUseItemID = this:get_field("_ItemId")
    if Config.TesterMode then
        table.insert(countTable, tostring(currentCount) .. " -> " .. tostring(finalCount) .. "/ItemID: " .. tostring(this:get_field("_ItemId")))
    end
    if Config.CheatConfig.UnlimitItemAndDurability and (finalCount == 0 or finalCount < currentCount) then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end, function (retval)
	return retval
end)
sdk.hook(TypedefItem:get_method("reduceDurability(System.Int32)"),
function (args)
    if Config.CheatConfig.UnlimitItemAndDurability then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end, function (retval)
	return retval
end)

local lastShootAmmoItemID
sdk.hook(TypedefWeaponItem:get_method("reduceAmmoCount(System.Int32)"),
function (args)
    local this = sdk.to_managed_object(args[2])
    lastShootAmmoItemID = this:call("get_CurrentAmmo()")
    if Config.CheatConfig.UnlimitItemAndDurability then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end, function (retval)
	return retval
end)
sdk.hook(TypedefWeaponItem:get_method("reduceTacticalAmmo(System.Int32)"),
function (args)
    if Config.CheatConfig.UnlimitItemAndDurability then
        return sdk.PreHookResult.SKIP_ORIGINAL
    end
end, function (retval)
	return retval
end)

-- These hooks doesn't work

-- sdk.hook(PlayerBaseContext:get_method("get_Invincible"),
-- function (args)

-- end, function (retval)
--     if invincibleMode then
--         return RETVAL_TRUE
--     end
-- 	return retval
-- end)

-- sdk.hook(PlayerBaseContext:get_method("get_NoDamage"),
-- function (args)

-- end, function (retval)
--     if invincibleMode then
--         return RETVAL_TRUE
--     end
-- 	return retval
-- end)

-- sdk.hook(PlayerBaseContext:get_method("get_NoDeath"),
-- function (args)

-- end, function (retval)
--     if invincibleMode then
--         return RETVAL_TRUE
--     end
-- 	return retval
-- end)

-- sdk.hook(PlayerBaseContext:get_method("get_Immortal"),
-- function (args)

-- end, function (retval)
--     if invincibleMode then
--         return RETVAL_TRUE
--     end
-- 	return retval
-- end)

-- ==== UI ====

local UI = {
    Font = nil,
    Row = 0,
    RowHeight = 25,
    PosX = 1400,
    PosY = 200,
    Width = 400,
}

function UI:new(o, posX, posY, rowHeight, width, font)
    o = o or {}
    setmetatable(o, self)
    self.__index = self

    self.Font = font
    self.Row = 0
    self.RowHeight = rowHeight
    self.PosX = posX
    self.PosY = posY
    self.Width = width
    return o
end

function UI:GetCurrentRowPosY()
    return self.PosY + self.Row * self.RowHeight + 10
end

function UI:NewRow(str, id)
    if id ~= nil and id ~= "" then
        if Config.DisplayConfig ~= nil then
            if Config.DisplayConfig[id] == nil then
                Config.DisplayConfig[id] = true
            elseif Config.DisplayConfig[id] == false then
                return
            end
        end
    end

    d2d.text(self.Font, str, self.PosX + 10, self:GetCurrentRowPosY(), 0xFFFFFFFF)
    self.Row = self.Row + 1
end

function UI:DrawBackground(rows)
    d2d.fill_rect(self.PosX, self.PosY, self.Width, rows * self.RowHeight, 0x69000000)
end

local function FloatColumn(val)
	if val ~= nil then -- and val ~= 0 then
		return string.format("%.2f", val)
	end
	return ""
end

-- ==== Draw UI ====

-- drawHPBar, width, leftOffset are optional
local function DrawHP(ui, name, hp, drawHPBar, width, leftOffset, id)
    local current = hp:call("get_CurrentHitPoint")
    local max = hp:call("get_DefaultHitPoint")
    if current == nil or current == 0 then return end
    if max == nil or max == 0 then return end

    ui:NewRow(name .. tostring(current) .. "/" .. tostring(max), id)

    if drawHPBar then
        if leftOffset == nil then leftOffset = 0 end

        d2d.fill_rect(ui.PosX + 10 + leftOffset, ui:GetCurrentRowPosY() + 4, width - 20 - leftOffset, ui.RowHeight - 8, 0xFFCCCCCC)
        d2d.fill_rect(ui.PosX + 10 + leftOffset, ui:GetCurrentRowPosY() + 4, current/max*(width-20-leftOffset), ui.RowHeight - 8, 0xFF5c9e76)
        ui:NewRow("")
    end
end

local fontTable = {}
local function initFont(size)
    if size == nil then size = Config.FontSize end
    if fontTable[size] == nil then
        fontTable[size] = d2d.Font.new("Tahoma", size, true)
    end
    return fontTable[size]
end

local TypeDefSceneManager = sdk.find_type_definition("via.SceneManager")

local function DisplayEnemyContext(EnemyUI, enemyName, enemyCtx, masterPlayer)
    if Config.DebugMode then
        EnemyUI:NewRow(enemyName .. ": ")
    end
    if enemyCtx == nil then
        if Config.DebugMode then
            EnemyUI:NewRow(" is nil")
        end
        return
    end

    local kindID = enemyCtx:call("get_KindID")
    local kind = KindMap[kindID]
    local lively = enemyCtx:call("get_IsLively")
    local combatReady = enemyCtx:call("get_IsCombatReady")
    if Config.DebugMode then
        -- kind
        EnemyUI:NewRow(" KindID: ".. tostring(kindID) .. "/" .. tostring(kind))
        EnemyUI:NewRow(" Lively: ".. tostring(lively))
        EnemyUI:NewRow(" IsCombatReady: ".. tostring(combatReady))
    end

    -- if not allowEnemyUI then
    --     return
    -- end

    local hp = enemyCtx:call("get_HitPoint")
    if hp == nil then
        if Config.DebugMode then
            EnemyUI:NewRow(" HP is nil")
        end
        return
    end

    local currentHP = hp:call("get_CurrentHitPoint")
    local maxHP = hp:call("get_DefaultHitPoint")
    if currentHP == nil or maxHP == nil then
        if Config.DebugMode then
            EnemyUI:NewRow(" HP is nil")
        end
        return
    end

    local allowEnemy = currentHP > 0
    if not allowEnemy then
        return
    end

    -- Floating UI
    if Config.FloatingUI.Enabled and masterPlayer ~= nil then
        local allowFloating = true

        local playerPos = masterPlayer:call("get_Position")
        local worldPos = enemyCtx:call("get_Position")
        if playerPos ~= nil and worldPos ~= nil then
            local delta = playerPos - worldPos
            local distance = math.sqrt(delta.x * delta.x + delta.y * delta.y)

            if Config.FloatingUI.FilterMaxHPEnemy and currentHP >= maxHP then
                allowFloating = false
            end

            if distance > Config.FloatingUI.MaxDistance then
                if Config.FloatingUI.IgnoreDistanceIfDamaged and currentHP < maxHP then
                    allowFloating = true
                else
                    allowFloating = false
                end
            end

            if Config.FloatingUI.FilterBlockedEnemy then
                allowFloating = allowFloating and enemyCtx:call("get_HasRayToPlayer")
            end

            if Config.DebugMode then
                EnemyUI:NewRow(" Distance: ".. FloatColumn(distance))
            end

            -- allowFloating = true
            if allowFloating then
                local height = Config.FloatingUI.Height
                local width = Config.FloatingUI.Width

                local scale = (Config.FloatingUI.MaxDistance - distance) / Config.FloatingUI.MaxDistance
                if distance > Config.FloatingUI.MaxDistance then
                    scale = Config.FloatingUI.IgnoreDistanceIfDamagedScale
                end
                if scale < Config.FloatingUI.MinScale then
                    scale = Config.FloatingUI.MinScale
                end
                if Config.FloatingUI.ScaleHeightByDistance then
                    height = height * scale
                end
                if Config.FloatingUI.ScaleWidthByDistance then
                    width = width * scale
                end

                if Config.DebugMode then
                    EnemyUI:NewRow(" Bar Scale: ".. FloatColumn(scale))
                end

                worldPos.x = worldPos.x + Config.FloatingUI.WorldPosOffsetX
                worldPos.y = worldPos.y + Config.FloatingUI.WorldPosOffsetY
                worldPos.z = worldPos.z + Config.FloatingUI.WorldPosOffsetZ
                local screenPos = draw.world_to_screen(worldPos)

                if screenPos ~= nil then
                    local floatingX = screenPos.x + Config.FloatingUI.ScreenPosOffsetX
                    local floatingY = screenPos.y + Config.FloatingUI.ScreenPosOffsetY
                    if Config.FloatingUI.DisplayNumber then
                        local hpMsg = "HP: " .. tostring(currentHP) .. "/" .. tostring(maxHP)
                        if Config.TesterMode then
                            hpMsg = hpMsg .. " / " .. tostring(enemyCtx:call("get_ItemDropCount"))
                        end
                        d2d.text(initFont(Config.FloatingUI.FontSize), hpMsg, floatingX, floatingY - 24, 0xFFFFFFFF)
                    end
                    d2d.fill_rect(floatingX - 1, floatingY - 1, width + 2, height + 2, 0xFF000000)
                    d2d.fill_rect(floatingX, floatingY, width, height, 0xFFCCCCCC)
                    d2d.fill_rect(floatingX, floatingY, currentHP / maxHP * width, height, 0xFF5c9e76)
                end
            end

        end
    end

    local allowEnemyUI = true
    allowEnemyUI = allowEnemy and (lively and combatReady)
    -- allow = allow and (lively)
    if kind == "ch1_f1z0" then
        -- Del Lago has special value
        allowEnemyUI = true
    end

    -- Enemy UI Panel
    if Config.EnemyUI.FilterMaxHPEnemy then
        allowEnemy = allowEnemy and currentHP < maxHP
    end
    if Config.EnemyUI.Enabled and allowEnemy then
        EnemyUI:NewRow(enemyName, "Enemy Name")

        -- hp
        DrawHP(EnemyUI, " HP: ", hp, Config.EnemyUI.DrawEnemyHPBar, Config.EnemyUI.Width, 0, "Enemy HP Value")
        -- EnemyUI:NewRow(" HP: "
        --     .. tostring(currentHP) .. "/"
        --     .. tostring(maxHP)
        -- )

        -- add rank
        local addRank = enemyCtx:call("get_GameRankAdd")
        if addRank ~= nil and addRank ~= 0 then
            EnemyUI:NewRow(" GameRankAdd: " .. tostring(addRank), "Enemy Game Rank Add")
        end

        -- parts
        local partsDict = enemyCtx:call("get_BreakPartsHitPointDict") -- Dict<<BodyParts, BodyPartsSide>, HitPoint>
        if partsDict ~= nil then
            local parts = partsDict:get_field('_entries')

            if parts ~= nil then
                local array = {}
                for i=0, parts:call('get_Count')-1 do
                    table.insert(array, parts:call('get_Item',i))
                end
                local j = 0
                for _, k in pairs(array) do
                    if k ~= nil then
                        local key = k:get_field('key')
                        if key ~= nil then
                            local bodyParts = key:get_field("Item1")
                            local bodyPartsSide = key:get_field("Item2")
                            local partHP = k:get_field('value')
                            if bodyParts ~= nil and bodyPartsSide ~= nil and partHP ~= nil then
                                local partCurrentHP = partHP:call("get_CurrentHitPoint")
                                local partMaxHP = partHP:call("get_DefaultHitPoint")
                                if partCurrentHP ~= nil and partMaxHP ~= nil then
                                    local allow = true
                                    if Config.EnemyUI.FilterMaxHPPart then
                                        allow = allow and partCurrentHP < partMaxHP
                                    end
                                    if Config.EnemyUI.FilterUnbreakablePart then
                                        allow = allow and partMaxHP < maxHP
                                    end
                                    if allow then
                                        if Config.EnemyUI.DisplayPartHP then
                                            DrawHP(EnemyUI, "  " .. tostring(BodyPartsMap[bodyParts]) .. "("  .. tostring(BodyPartsSideMap[bodyPartsSide]) .. "): ", partHP, Config.EnemyUI.DrawPartHPBar, Config.EnemyUI.Width, 20, "Enemy Part HP Value")
                                        end
                                    end
                                end
                            end
                        end
                    end
                    j = j + 1
                end
            end
        end

        -- weakpoint

        -- WeakPointData? WeakPointUnit?

        -- if kind == "ch1_d6z0" then
        --     -- chainsaw.Ch1d6z0Context
        --     EnemyUI:NewRow(" WeakPointType: " .. tostring(enemyCtx:call("get_WeakPointType")))
        -- end
    end
end

local TypedefTransform = sdk.typeof("via.Transform")
local TypedefCharacterController = sdk.typeof("via.physics.CharacterController")
local function GetDelLagoTransform()
    local sceneMgr = GetSceneManager()
    if sceneMgr ~= nil then
        local scene = sdk.call_native_func(sceneMgr, TypeDefSceneManager, "get_CurrentScene")
        if scene ~= nil then
            local fishBody = scene:call("findGameObject(System.String)", "ch1f1z0_body")
            if fishBody ~= nil then
                local transform = fishBody:call("getComponent(System.Type)", TypedefTransform)
                if transform ~= nil then
                   return transform
                end
            end
        end
    end
    return transform
end
local function GetPlayerTransform()
    local sceneMgr = GetSceneManager()
    if sceneMgr ~= nil then
        local scene = sdk.call_native_func(sceneMgr, TypeDefSceneManager, "get_CurrentScene")
        if scene ~= nil then
            local playerBody = scene:call("findGameObject(System.String)", "ch0a0z0_body")
            if playerBody ~= nil then
                local transform = playerBody:call("getComponent(System.Type)", TypedefTransform)
                if transform ~= nil then
                   return transform
                end
            end
        end
    end
    return transform
end

local transIsNil = false
local controllerIsNil = false
local function SetDelLagoPos(pos)
    local sceneMgr = GetSceneManager()
    if sceneMgr ~= nil then
        local scene = sdk.call_native_func(sceneMgr, TypeDefSceneManager, "get_CurrentScene")
        if scene ~= nil then
            local fishBody = scene:call("findGameObject(System.String)", "ch1f1z0_body")
            if fishBody ~= nil then
                local transform = fishBody:call("getComponent(System.Type)", TypedefTransform)
                if transform == nil then
                    transIsNil = true
                    return nil
                end
                local controller = fishBody:call("getComponent(System.Type)", TypedefCharacterController)
                if controller == nil then
                    controllerIsNil = true
                    return nil
                end

                transIsNil = false
                controllerIsNil = false
                controller:call("warp")
                transform:call("set_Position",pos)
                controller:call("warp")
            end
        end
    end
    return transform
end
local function SetPlayerPos(pos)
    local sceneMgr = GetSceneManager()
    if sceneMgr ~= nil then
        local scene = sdk.call_native_func(sceneMgr, TypeDefSceneManager, "get_CurrentScene")
        if scene ~= nil then
            local fishBody = scene:call("findGameObject(System.String)", "ch0a0z0_body")
            if fishBody ~= nil then
                local transform = fishBody:call("getComponent(System.Type)", TypedefTransform)
                if transform == nil then
                    transIsNil = true
                    return nil
                end
                local controller = fishBody:call("getComponent(System.Type)", TypedefCharacterController)
                if controller == nil then
                    controllerIsNil = true
                    return nil
                end

                transIsNil = false
                controllerIsNil = false
                controller:call("warp")
                transform:call("set_Position",pos)
                controller:call("warp")
            end
        end
    end
    return transform
end

local function convertTime(timeInt64)
    if timeInt64 == nil then return "nil" end

    local timeStr = tostring(timeInt64)
    local len = #tostring(timeStr)
    if len <= 1 then
        return 0
    else
        local ms = tonumber(timeStr:sub(len - 5, len - 3))
        local igtSecond = tonumber(timeStr:sub(1, len - 6))
        return os.date("!%H:%M:%S", igtSecond) .. "." .. tostring(ms)
    end
end

local function DisplayItem(ui, item)
    if item ~= nil then
        local def = item:call("get__ItemDefine")
        if def ~= nil then
            ui:NewRow("Def._ItemSize: " .. tostring(def:get_field("_ItemSize")))
            ui:NewRow("Def._StackMax: " .. tostring(def:get_field("_StackMax")))
            ui:NewRow("Def._DefaultDurabilityMax: " .. tostring(def:get_field("_DefaultDurabilityMax")))
            ui:NewRow("Def._UseResults: " .. tostring(def:get_field("_UseResults"):call("get_Count")))
            local equipReq = def:get_field("_EquipRequirement")
            if equipReq ~= nil then
                ui:NewRow("Def.ER._EquipableTarget: " .. tostring(equipReq:get_field("_EquipableTarget")))
            end
            local addReq = def:get_field("_AdditionalRequirement")
            if addReq ~= nil then
                ui:NewRow("Def.AR._DedicatedTarget: " .. tostring(addReq:get_field("_DedicatedTarget")))
            end
        end
        ui:NewRow("_ID: " .. tostring(item:get_field("_ID"):call("ToString()")))
        ui:NewRow("_ItemId: " .. tostring(item:get_field("_ItemId")))
        ui:NewRow("_CurrentCondition: " .. tostring(item:get_field("_CurrentCondition")))
        ui:NewRow("_CurrentDurability: " .. tostring(item:get_field("_CurrentDurability")))
        ui:NewRow("_CurrentItemCount: " .. tostring(item:get_field("_CurrentItemCount")))
        ui:NewRow("get_IsValid: " .. tostring(item:call("get_IsValid")))
    end
end

local lastAddItem
local lastNewGameTime = 0
d2d.register(function()
	initFont()
end,
	function()
        if not Config.Enabled then return end

        local StatsUI = UI:new(nil, Config.StatsUI.PosX, Config.StatsUI.PosY, Config.StatsUI.RowHeight, Config.StatsUI.Width, initFont())
        if Config.StatsUI.Enabled then
            StatsUI:DrawBackground(Config.StatsUI.RowsCount or 25)
        end

        if Config.TesterMode then
            for i = 1, #countTable, 1 do
                StatsUI:NewRow("Count: " .. tostring(countTable[i]))
            end
        end

        if Config.TesterMode and lastSaveArg ~= nil then
            StatsUI:NewRow("lastSaveArg" .. tostring(lastSaveArg))
        end

        if Config.CheatConfig.PredictCharm then
            local charm = GetCharmManager()
            if charm ~= nil then
                local lotteryTables = charm:get_field("_LotteryTable")
                if lotteryTables ~= nil then
                    StatsUI:NewRow("--- Charm Manager ---", "Charm Manager Title")

                    local len = lotteryTables:call("get_Count")
                    for i = 0, len - 1, 1 do
                        local table = lotteryTables:call("get_Item", i)
                        StatsUI:NewRow("Gold Token " .. tostring(i) .. " : ")
                        StatsUI:NewRow(" Seed: " .. tostring(table:get_field("_Seed")), "Charm Manager Random Table Seed")
                        StatsUI:NewRow(" CurrentCount: " .. tostring(table:get_field("_CurrnetCount")), "Charm Manager Random Table Counter")

                        local lastCount = charm:get_field("_LotteryTable"):call("get_Item", i):get_field("_CurrnetCount")
                        local gacha = charm:call("drawingCharmGacha", i)
                        charm:get_field("_LotteryTable"):call("get_Item", i):set_field("_CurrnetCount", lastCount)
                        StatsUI:NewRow("Next Gacha: " .. tostring(gacha) .. ": " .. tostring(GetItemName(gacha)))
                        if i ~= len - 1 then
                            StatsUI:NewRow("")
                        end
                    end
                    StatsUI:NewRow("------------------", "Charm Manager Title")
                    StatsUI:NewRow("")
                else
                    StatsUI:NewRow("CharmManager: LotteryTable is nil")
                end
            else
                StatsUI:NewRow("CharmManager is nil")
            end
        end

        if Config.TesterMode then
            StatsUI:NewRow("lastTableNo: " .. tostring(lastTableNo))
            StatsUI:NewRow("LotterySeed: " .. tostring(lastLotterySeed))
            StatsUI:NewRow("LotteryCount: " .. tostring(lastLotteryCount))

            -- if lastCharmItemIDs ~= nil then
            -- -- FIXME: This is unstable, why?
            --     StatsUI:NewRow("Lottery Item IDs: ")
            --     local len = lastCharmItemIDs:call("get_Count")
            --     for i = 0, len - 1, 1 do
            --         local itemID = lastCharmItemIDs:call("get_Item", i)
            --         StatsUI:NewRow(tostring(itemID) .. ": " .. tostring(ItemIDMap[itemID]))
            --     end
            -- end
            StatsUI:NewRow("Last Gacha Item ID: " .. tostring(lastGotChartmID) .. ": " .. tostring(GetItemName(lastGotChartmID)))

            StatsUI:NewRow("radioMsgEvent: " .. tostring(radioMsgEvent))
            StatsUI:NewRow("currentMovieID: " .. tostring(currentMovieID))
            StatsUI:NewRow("currentMovieCallback: " .. tostring(currentMovieCallback))
        end

        local clock = GetGameClock()
        if clock ~= nil then
            if Config.TesterMode then
                StatsUI:NewRow("get_SystemElapsedTime: " .. convertTime(clock:call("get_SystemElapsedTime()")))
                StatsUI:NewRow("get_GameElapsedTime: " .. convertTime(clock:call("get_GameElapsedTime()")))
                StatsUI:NewRow("get_DemoSpendingTime: " .. convertTime(clock:call("get_DemoSpendingTime()")))
                StatsUI:NewRow("get_InventorySpendingTime: " .. convertTime(clock:call("get_InventorySpendingTime()")))
                StatsUI:NewRow("get_PauseSpendingTime: " .. convertTime(clock:call("get_PauseSpendingTime()")))
                StatsUI:NewRow("get_ActualRecordTime: " .. convertTime(clock:call("get_ActualRecordTime()")))
                StatsUI:NewRow("get_ActualPlayingTime: " .. convertTime(clock:call("get_ActualPlayingTime()")))
                StatsUI:NewRow("get_InSceneTime: " .. convertTime(clock:call("get_InSceneTime()")))
                StatsUI:NewRow("IGT?: " .. convertTime(clock:call("get_GameElapsedTime()") - clock:call("get_PauseSpendingTime")- clock:call("get_DemoSpendingTime")))
                -- StatsUI:NewRow("get_IsNotClearGameElapsedTime: " .. convertTime(clock:call("get_IsNotClearGameElapsedTime()")))
            end

            local mapMgr = GetMapManager()
            if mapMgr ~= nil then
                local sceneID = tostring(mapMgr:call("get_CurrMapSceneID()"))
                if currentEventIDNum == 10157 then -- New Game intro
                    lastNewGameTime = clock:call("get_ActualRecordTime()")
                -- else
                --     lastMainMenuTime = 0
                end
                if Config.TesterMode then
                    StatsUI:NewRow("currentEventIDNum: " .. tostring(currentEventIDNum))
                    StatsUI:NewRow("currentEventID: " .. tostring(currentEventID))
                    StatsUI:NewRow("SceneID: " .. sceneID)
                    -- StatsUI:NewRow("FloorID: " .. mapMgr:call("get_CurrMapFloorID()"))
                    -- StatsUI:NewRow("PlayerFloorID: " .. mapMgr:call("get_CurrMapPlayerFloorID()"))
                    -- StatsUI:NewRow("PartnerFloorID: " .. mapMgr:call("get_CurrMapPartnerFloorID"))
                    StatsUI:NewRow("lastNewGameTime: " .. convertTime(lastNewGameTime))
                end
                if sceneID == "0" then
                    currentEventIDNum = 0
                    currentEventID = 0
                    lastNewGameTime = 0
                end
            end

            if Config.StatsUI.Enabled then
                StatsUI:NewRow("IGT: " .. convertTime(clock:call("get_ActualRecordTime()") - lastNewGameTime), "IGT")
            end
        end

        local stats = GetGameStatsManager()
        if Config.StatsUI.Enabled and stats ~= nil then
            if Config.TesterMode then
                local igtStr = tostring(stats:call("getCalculatingRecordTime()"))
                local len = #tostring(igtStr)
                if len <= 1 then
                    StatsUI:NewRow("IGT: 0", "IGT")
                else
                    local ms = tonumber(igtStr:sub(len - 5, len - 3))
                    local igtSecond = tonumber(igtStr:sub(1, len - 6))
                    -- StatsUI:NewRow("IGT: " .. tostring(igtStr))
                    StatsUI:NewRow("IGT: " .. os.date("!%H:%M:%S", igtSecond) .. "." .. tostring(ms), "IGT")
                end
                if Config.TesterMode then
                    local timer = GetTimerManager()
                    if timer ~= nil then
                        StatsUI:NewRow("isOpenTimerStopGui: " .. tostring(timer:call("isOpenTimerStopGui()")))
                        StatsUI:NewRow("_IsTypeWriterPause: " .. tostring(timer:get_field("_IsTypeWriterPause")))
                        StatsUI:NewRow("CurrentSecond: " .. tostring(timer:call("get_CurrentSecond()")))
                        StatsUI:NewRow("OldActualPlayingTime: " .. tostring(timer:get_field("_OldActualPlayingTime")))
                    end
                end
                -- StatsUI:NewRow("IGT: " .. tostring(stats:call("get_PlaythroughStatsInfo()"):call("outputUIFormat()")))
                -- StatsUI:NewRow("IGT: " .. tostring(stats:call("get_CurrentCampaignStats()"))) -- nil??
                -- StatsUI:NewRow("IGT: " .. tostring(stats:call("get_CurrentCampaignStats()"):call("get_Playthrough()"):call("outputUIFormat()")))
            end
        end

        local gameRank = GetGameRankSystem()
        -- local gameRank
        if Config.StatsUI.Enabled and gameRank ~= nil then
            StatsUI:NewRow("GameRank: " .. tostring(gameRank:get_field("_GameRank")), "Game Rank (DA)")
            StatsUI:NewRow("ActionPoint: " .. FloatColumn(gameRank:get_field("_ActionPoint")), "Action Point")
            StatsUI:NewRow("ItemPoint: " .. FloatColumn(gameRank:get_field("_ItemPoint")), "Item Point")
            StatsUI:NewRow("BackupActionPoint: " .. FloatColumn(gameRank:get_field("BackupActionPoint")), "Backup Action Point")
            StatsUI:NewRow("BackupItemPoint: " .. FloatColumn(gameRank:get_field("BackupItemPoint")), "Backup Item Point")
            StatsUI:NewRow("FixItemPoint: " .. FloatColumn(gameRank:get_field("FixItemPoint")), "Fix Item Point")
            StatsUI:NewRow("RetryCount: " .. tostring(gameRank:call("get_RankPointPlRetryCount")), "Retry Count")

            if stats ~= nil then
                StatsUI:NewRow("KillCount: " .. tostring(stats:call("getKillCount")), "Kill Count")
            end
            if Config.TesterMode then
                StatsUI:NewRow("lastRankPointKillCount: " .. tostring(lastRankPointKillCount))
            end

            StatsUI:NewRow("")
            StatsUI:NewRow("PlayerDamageRate: " .. FloatColumn(gameRank:call("getRankPlayerDamageRate", nil)), "Player Damage Rate")
            StatsUI:NewRow("-- Enemy --", "Enemy DA Title")
            StatsUI:NewRow("DamageRate: " .. FloatColumn(gameRank:call("getRankEnemyDamageRate")), "Enemy Damage Rate")
            StatsUI:NewRow("WinceRate: " .. FloatColumn(gameRank:call("getRankEnemyWinceRate")), "Enemy Wince Rate")
            StatsUI:NewRow("BreakRate: " .. FloatColumn(gameRank:call("getRankEnemyBreakRate")), "Enemy Break Rate")
            StatsUI:NewRow("StoppingRate: " .. FloatColumn(gameRank:call("getRankEnemyStoppingRate")), "Enemy Stopping Rate")

            if Config.DisplayConfig["Knife Reduce Rate"] then
                StatsUI:NewRow("")
            end
            StatsUI:NewRow("KnifeReduceRate: " .. FloatColumn(gameRank:call("getKnifeReduceRate")), "Knife Reduce Rate")
            StatsUI:NewRow("")
        end

        -- local attackPermit = GetEnemyAttackPermitManager()
        -- if attackPermit ~= nil then
        --     StatsUI:NewRow("NowGameRank: " .. tostring(attackPermit:get_field("NowGameRank")))
        -- end

        local character = GetCharacterManager()
        if character ~= nil then
            local players = character:call("get_PlayerAndPartnerContextList") -- List<chainsaw.CharacterContext>
            if players ~= nil then
                local playerLen = players:call("get_Count")
                for i = 0, playerLen - 1, 1 do
                    local playerCtx = players:call("get_Item", i)

                    if Config.StatsUI.Enabled and playerCtx ~= nil then
                        local hp = playerCtx:call("get_HitPoint")
                        DrawHP(StatsUI, "Player " .. tostring(i) .. " HP: ", hp, Config.StatsUI.DrawPlayerHPBar, Config.StatsUI.Width, 0, "Player HP Value")
                        if Config.DebugMode then
                            StatsUI:NewRow("    Invincible: " .. tostring(hp:call("get_Invincible")))
                            StatsUI:NewRow("    NoDamage: " .. tostring(hp:call("get_NoDamage")))
                            StatsUI:NewRow("    NoDeath: " .. tostring(hp:call("get_NoDeath")))
                            StatsUI:NewRow("    Immortal: " .. tostring(hp:call("get_Immortal")))
                        end
                    end

                    if Config.CheatConfig.AlsoForTeammate then
                        SetInvincible(playerCtx)
                    end
                    -- StatsUI:NewRow("Player " .. tostring(i) .. " HP: " ..
                    --     tostring(hp:call("get_CurrentHitPoint")) .. "/" ..
                    --     tostring(hp:call("get_DefaultHitPoint"))
                    -- )
                end
            end
        end

        local masterPlayer = getMasterPlayer()
        if masterPlayer ~= nil then
            if Config.TesterMode then
                DrawHP(StatsUI, "MasterPlayer HP: ", masterPlayer:call("get_HitPoint"), Config.StatsUI.DrawPlayerHPBar, Config.StatsUI.Width, 0, "Player HP Value")
            end
            SetInvincible(masterPlayer)
        end
        if Config.StatsUI.Enabled and masterPlayer ~= nil then
            StatsUI:NewRow("HateRate: " .. FloatColumn(masterPlayer:call("get_HateRate")), "Player Hate Rate")
        end

        local player = GetPlayerManager()
        if Config.StatsUI.Enabled and player ~= nil then
            -- StatsUI:NewRow("1P HP: " .. FloatColumn(player:call("get_WwisePlayerHPRatio_1P")))
            -- StatsUI:NewRow("2P HP: " .. FloatColumn(player:call("get_WwisePlayerHPRatio_2P")))
            StatsUI:NewRow("Player Distance: " .. FloatColumn(player:call("get_WwisePlayerDistance")), "Player Distance")
        end
        
        local sceneMgr = GetSceneManager()
        if sceneMgr and Config.StatsUI.Enabled then
            local scene = sdk.call_native_func(sceneMgr, TypeDefSceneManager, "get_CurrentScene")
            if scene and Config.DisplayConfig["Duffel Check"] then
                local playerBody = scene:call("findGameObject(System.String)", "ch0a0z0_body")
                if playerBody == nil then playerBody = scene:call("findGameObject(System.String)", "ch6i0z0_body") end
                if playerBody == nil then playerBody = scene:call("findGameObject(System.String)", "ch6i1z0_body") end
                if playerBody == nil then playerBody = scene:call("findGameObject(System.String)", "ch6i2z0_body") end
                if playerBody == nil then playerBody = scene:call("findGameObject(System.String)", "ch6i3z0_body") end

                if playerBody then
                    local playerBody_Transform = playerBody:call("getComponent(System.Type)", sdk.typeof("via.Transform"))
                    if playerBody_Transform then    
                        transforms = {
                         pos = playerBody_Transform:call("get_Position"),
                         rot = playerBody_Transform:call("get_Rotation"),
                         }

                        local duffelYPos = tonumber(transforms.pos.y)
                        if duffelYPos < 0 and duffelYPos > -0.5 then
                            duffelNumber = nil
                        elseif duffelYPos <= -0.5 and duffelYPos >= -1 then
                            duffelNumber = duffelYPos
                        end
                        if duffelNumber ~= nil then
                            StatsUI:NewRow("Duffel Bag: ON (" .. tostring(duffelNumber) .. ")")
                        else
                            StatsUI:NewRow("Duffel Bag: OFF")
                        end
                        if scene and Config.DisplayConfig["Display Position"] then
                            StatsUI:NewRow(string.format("POS: X: %f|Y: %f|Z: %f",transforms.pos.x,transforms.pos.y,transforms.pos.z))
                        end
                        if scene and Config.DisplayConfig["Display Rotation"] then
                            StatsUI:NewRow(string.format("ROT: X: %f|Y: %f|Z: %f|W: %f",transforms.rot.x,transforms.rot.y,transforms.rot.z,transforms.rot.w))
                        end
                    end
                else duffelNumber = nil
            end
            StatsUI:NewRow("")
        end
    end

        if Config.TesterMode then
            -- if lastHoverKeyItemID ~= nil then
                StatsUI:NewRow("lastHoverKeyItemID: " .. GetItemName(lastHoverKeyItemID) .. "/" .. tostring(lastHoverKeyItemID))
                StatsUI:NewRow("lastHoverKeyItemGuid: " .. tostring(lastHoverKeyItemGuid))
                StatsUI:NewRow("lastHoverKeyItem: " .. tostring(lastHoverKeyItem))
                if lastHoverKeyItem ~= nil then
                    local item = lastHoverKeyItem:get_field("<Item>k__BackingField")
                    DisplayItem(StatsUI, item)
                end
            -- end
            -- if lastHoverItemID ~= nil then
                StatsUI:NewRow("lastHoverItemID: " .. GetItemName(lastHoverItemID) .. "/" .. tostring(lastHoverItemID))
            -- end
            -- if lastUseItemID ~= nil then
                StatsUI:NewRow("LastUseItemID: " .. GetItemName(lastUseItemID) .. "/" .. tostring(lastUseItemID))
            -- end
            -- if lastShootAmmoItemID ~= nil then
                StatsUI:NewRow("LastShootAmmoItemID: " .. GetItemName(lastShootAmmoItemID) .. "/" .. tostring(lastShootAmmoItemID))
            -- end

            local drop = GetDropItemManager()
            if drop ~= nil then
                StatsUI:NewRow("-- Drop Manager --")
                local DistRandomItem = drop:get_field("DistRandomItem") -- float
                StatsUI:NewRow("DistRandomItem: " .. FloatColumn(DistRandomItem))

                local stacks = drop:get_field("_RandomDropStack") -- List<RandomDropStack>
                StatsUI:NewRow("== _RandomDropStack (" .. tostring(stacks:call("get_Count")) .. ") ==")
                local stackLen = stacks:call("get_Count")
                for i = 0, stackLen - 1, 1 do
                    local stack = stacks:call("get_Item", i)
                    StatsUI:NewRow("DropType: " .. DropTypeMap[stack:get_field("DropType")])
                    -- StatsUI:NewRow(ItemIDMap[stack:get_field("ID")] .. ": " .. tostring(stack:get_field("Rate")))
                end

                local collectedDropItem = drop:call("collectDropItem()") -- DropItemContext[]
                StatsUI:NewRow("== collectedDropItem (" .. tostring(collectedDropItem:call("get_Count")) .. ") ==")
                -- local collectedDropItemLen = collectedDropItem:call("get_Count")
                -- for i = 0, collectedDropItemLen - 1, 1 do
                --     local dropItemCtx = collectedDropItem:call("get_Item", i)
                --     StatsUI:NewRow(ItemIDMap[dropItemCtx:call("getItemID")])
                -- end


                local dropItemDict = drop:get_field("_DropItem") -- Dict<int, DropItem>
                StatsUI:NewRow("== _DropItem (" .. tostring(dropItemDict:call("get_Count")) .. ") ==")
                local dropItemEntries = dropItemDict:get_field('_entries')
                for _, k in pairs(dropItemEntries) do
                    local id = k:get_field('key')
                    local dropItem = k:get_field('value')
                    if dropItem ~= nil then
                        StatsUI:NewRow( tostring(id) .. ": " .. GetItemName(dropItem:call("getItemID")) .. " / " .. tostring(dropItem:call("getCount")))
                    end
                end


                local LostItem = drop:get_field("_LostItem") -- Dict<int, DropItem>
                local LostItemCount = drop:get_field("_LostItemCount") -- Dict<int, int>

                local limitCount = drop:get_field("_LimitCount") -- List<List<int>>
                StatsUI:NewRow("== LimitCount (" .. tostring(limitCount:call("get_Count")) .. ") ==")
                local limitCountLen = limitCount:call("get_Count")
                for i = 0, limitCountLen - 1, 1 do
                    local limits = limitCount:call("get_Item", i)

                    local limitsStr = ""
                    local limitsLen = limits:call("get_Count")
                    for j = 0, limitsLen - 1, 1 do
                        local limit = limits:call("get_Item", j)
                        limitsStr = limitsStr .. tostring(limit) .. ","
                    end
                    StatsUI:NewRow("_LimitCount: " .. (limitsStr))
                end


                local _LoadCount = drop:get_field("_LoadCount") -- int
                StatsUI:NewRow("_LoadCount: " .. FloatColumn(_LoadCount))

                StatsUI:NewRow("")
                local randomTable = drop:get_field("_DropTable") -- RandomDrop
                StatsUI:NewRow("== Drop Table ==")
                local _PointRate = randomTable:get_field("_PointRate") -- PointRate[]
                local _CustomTypeData = randomTable:get_field("_CustomTypeData") -- CustomTypeData[]
                local _HitPointRate = randomTable:get_field("_HitPointRate") -- int
                local _DroppedCountRange = randomTable:get_field("_DroppedCountRange") -- float

                StatsUI:NewRow("_HitPointRate: " .. FloatColumn(_HitPointRate))
                StatsUI:NewRow("_DroppedCountRange: " .. FloatColumn(_DroppedCountRange))

                StatsUI:NewRow("== _PointRate (" .. tostring(_PointRate:call("get_Count")) .. ") ==")
                local pointRateLen = _PointRate:call("get_Count")
                for i = 0, pointRateLen - 1, 1 do
                    local PointRate = _PointRate:call("get_Item", i)
                    StatsUI:NewRow(GetItemName(PointRate:get_field("ID")) .. ": " .. tostring(PointRate:get_field("Rate")))
                end

                local customTypeDataLen = _CustomTypeData:call("get_Count")
                for i = 0, customTypeDataLen - 1, 1 do
                    local customTypeData = _CustomTypeData:call("get_Item", i)
                    local idsStr = ""
                    local IDs = customTypeData:get_field("IDs")
                    local idsLen = IDs:call("get_Count")
                    for j = 0, idsLen - 1, 1 do
                        local id = IDs:call("get_Item", j)
                        idsStr = idsStr .. tostring(GetItemName(id)) .. ", "
                    end

                    StatsUI:NewRow(tostring(i) .. ": " .. tostring(idsStr))
                end

            end
        end

        local EnemyUI = UI:new(nil, Config.EnemyUI.PosX, Config.EnemyUI.PosY, Config.EnemyUI.RowHeight, Config.EnemyUI.Width, initFont())

        -- -- local list = enemy:call("get_LinkEnemyList") -- List<chainsaw.EnemeyHeadUpdater>
        -- local combatEnemyDB = enemy:call("get_CombatEnemyDB") -- Dict<chainsaw.CharacterKindID, Hashset<UInt32>> -- guid? pointer?
        -- local combatEnemy = enemy:get_field("_CombatEnemyCollection") -- Hashset<UInt32> -- GUID? pointer?

        if Config.EnemyUI.Enabled then
            EnemyUI:DrawBackground(Config.EnemyUI.RowsCount or 40)
            EnemyUI:NewRow("-- Enemy UI --", "Enemy UI Title")
        end

        if Config.TesterMode then
            DisplayItem(EnemyUI, lastAddItem)
        end
        -- if Config.SearchDelLago then
            -- local sceneMgr = GetSceneManager()
            -- if sceneMgr ~= nil then
            --     local scene = sdk.call_native_func(sceneMgr, TypeDefSceneManager, "get_CurrentScene")
            --     if scene ~= nil then
            --         -- StatsUI:NewRow("SceneName: " .. tostring(scene:call("get_Name")))
            --         -- 湖主：1f1z0 不在 enemy list 里
            --         local fishBody = scene:call("findGameObject(System.String)", "ch1f1z0_body")
            --         if fishBody ~= nil then
            --             -- local updater = fishBody:call("getComponent(System.Type)", sdk.typeof("chainsaw.Ch1f1z0BodyUpdater"))
            --             -- if updater ~= nil then
            --             --     local context = updater:call("get_Context")
            --             --     if context ~= nil then
            --             --         DisplayEnemyContext(EnemyUI, "Del Lago", context, masterPlayer)
            --             --         -- local hp = context:call("get_HitPoint")
            --             --         -- DrawHP(EnemyUI, "Del Lago HP: ", hp, Config.EnemyUI.DrawEnemyHPBar, Config.EnemyUI.Width, 0)
            --             --     else
            --             --         -- EnemyUI:NewRow("ctx is nil")
            --             --     end
            --             -- else
            --             --     -- EnemyUI:NewRow("updater is nil ")
            --             -- end
            --             local comps = fishBody:call("get_Components")
            --             StatsUI:NewRow("Fish: " .. tostring(comps:call("get_Count")))
            --             local len = comps:call("get_Count")
            --             for i = 0, len - 1, 1 do
            --                 local comp = comps:call("get_Item", i)
            --                 StatsUI:NewRow("Fish: " .. tostring(comp:call("ToString")))
            --             end
            --         end
            --     end
            -- end
        -- end
        -- if Config.SearchDelLago then
            -- local sceneMgr = GetSceneManager()
            -- if sceneMgr ~= nil then
            --     local scene = sdk.call_native_func(sceneMgr, TypeDefSceneManager, "get_CurrentScene")
            --     if scene ~= nil then
            --         local playerBody = scene:call("findGameObject(System.String)", "ch0a0z0_body")
            --         if playerBody ~= nil then
            --             -- local updater = fishBody:call("getComponent(System.Type)", sdk.typeof("chainsaw.Ch1f1z0BodyUpdater"))
            --             -- if updater ~= nil then
            --             --     local context = updater:call("get_Context")
            --             --     if context ~= nil then
            --             --         DisplayEnemyContext(EnemyUI, "Del Lago", context, masterPlayer)
            --             --         -- local hp = context:call("get_HitPoint")
            --             --         -- DrawHP(EnemyUI, "Del Lago HP: ", hp, Config.EnemyUI.DrawEnemyHPBar, Config.EnemyUI.Width, 0)
            --             --     else
            --             --         -- EnemyUI:NewRow("ctx is nil")
            --             --     end
            --             -- else
            --             --     -- EnemyUI:NewRow("updater is nil ")
            --             -- end
            --             local comps = playerBody:call("get_Components")
            --             StatsUI:NewRow("Player: " .. tostring(comps:call("get_Count")))
            --             local len = comps:call("get_Count")
            --             for i = 0, len - 1, 1 do
            --                 local comp = comps:call("get_Item", i)
            --                 StatsUI:NewRow("Player: " .. tostring(comp:call("ToString")))
            --             end
            --         end
            --     end
            -- end
        -- end

        local enemy = GetEnemyManager()
        if enemy ~= nil then
            local enemies
            if Config.EnemyUI.FilterNoInSightEnemy then
                enemies = enemy:call("get_CameraInsideEnemyContextRefs") -- chainsaw.EnemyBaseContext[]
            else
                enemies = GetEnemyList()
            end

            if enemies ~= nil then
                local enemyLen = enemies:call("get_Count")

                if Config.EnemyUI.Enabled and Config.DebugMode then
                    EnemyUI:NewRow("EnemyCount: " .. tostring(enemyLen))
                end

                for i = 0, enemyLen - 1, 1 do
                    local enemyCtx = enemies:call("get_Item", i)
                    if enemyCtx ~= nil then
                        DisplayEnemyContext(EnemyUI, "Enemy: " .. tostring(i), enemyCtx, masterPlayer)
                    end
                end
            end
            -- chainsaw.EnemyBaseContext: GameRankAdd
            -- chainsaw.CharacterContext: KindID, SpawnerID (type is ContextID?), IsRespawn, BreakPartsHitPointList, _HitPointVital
            -- chainsaw.character.chxxxxx.WeakPointBackup
            -- chainsaw.chxxxxxWeakPoint.Info
            -- chainsaw.chxxxxxWeakPoint.DamageSetting
        end
	end
)

local toAddKeyItemID = ""
local lastAddItemValid = nil
local lastAddItemResult = nil
local delLagoNoClipPos = Vector3f.new(0.0, 0.0, 0.0)
local playerNoClipPos = Vector3f.new(0.0, 0.0, 0.0)
-- === Menu ===
local clicks = 0
re.on_draw_ui(function()
	local configChanged = false
    if imgui.tree_node("RE4 Overlay") then
		local changed = false
		changed, Config.Enabled = imgui.checkbox("Enabled", Config.Enabled)
		configChanged = configChanged or changed

        imgui.text("Language: affect Charm prediction only")
		local langIdx = FindIndex(Languages, Config.Language)
		changed, langIdx = imgui.combo("Language", langIdx, Languages)
		configChanged = configChanged or changed
		Config.Language = Languages[langIdx]

        _, Config.FontSize = imgui.drag_int("Font Size", Config.FontSize, 1, 10, 30)
        if imgui.tree_node("Cheat Utils") then
            changed, Config.CheatConfig.AlsoForTeammate = imgui.checkbox("Full HP and Invincible also for teammate", Config.CheatConfig.AlsoForTeammate)
            if changed and Config.CheatConfig.AlsoForTeammate == false then
                local character = GetCharacterManager()
                if character ~= nil then
                    local players = character:call("get_PlayerAndPartnerContextList") -- List<chainsaw.CharacterContext>
                    if players ~= nil then
                        local playerLen = players:call("get_Count")
                        for i = 0, playerLen - 1, 1 do
                            local playerCtx = players:call("get_Item", i)

                            local hp = playerCtx:call("get_HitPoint")
                            hp:call("set_Invincible", false)
                        end
                    end
                end
            end

            changed, Config.CheatConfig.LockHitPoint = imgui.checkbox("Full HitPoint (recovery 99999 hp every frame)", Config.CheatConfig.LockHitPoint)
            configChanged = configChanged or changed
            changed, Config.CheatConfig.UnlimitItemAndDurability = imgui.checkbox("Infinite Item and Durability (No Consumption)", Config.CheatConfig.UnlimitItemAndDurability)
            configChanged = configChanged or changed

            local player = getMasterPlayer()
            if player ~= nil then

                imgui.text("Invincibility (WARNING: Make sure disable it before save. Or it may corrupt save or have unexpected bugs, I am not sure. )")
                changed, Config.CheatConfig.NoHitMode = imgui.checkbox("Invincibility", Config.CheatConfig.NoHitMode)
                configChanged = configChanged or changed

                if changed and Config.CheatConfig.NoHitMode == false then
                    local hp = player:call("get_HitPoint")
                    hp:call("set_Invincible", false)
                end
                -- changed, player["<HitPoint>k__BackingField"]["<Invincible>k__BackingField"] = imgui.checkbox("Invincibility", player["<HitPoint>k__BackingField"]["<Invincible>k__BackingField"])
                -- configChanged = configChanged or changed
            end

            imgui.text("Set PTAS")
			local _, ptasValue = imgui.input_text("Set PTAS", "");
            local ptas = tonumber(ptasValue)
            if ptas ~= nil then
				local inventory = GetInventoryManager()
                if inventory ~= nil then
                    inventory:call("setPTAS", ptas)
                end
			end

            local gameRank = GetGameRankSystem()

            imgui.text("Set ActionPoint (shoot, get damaged or any other action to take effect)")
			local _, actionPointValue = imgui.input_text("Set ActionPoint", "");
            local actionPoint = tonumber(actionPointValue)
            if actionPoint ~= nil then
                if actionPoint > 5000 then actionPoint = 5000 end
                if actionPoint < -5000 then actionPoint = -5000 end
                if gameRank ~= nil then
                    gameRank:set_field("_ActionPoint", actionPoint)
                end
			end

            imgui.text("Set ItemPoint (shoot, get damaged or any other action to take effect)")
			local _, itemPointValue = imgui.input_text("Set ItemPoint", "");
            local itemPoint = tonumber(itemPointValue)
            if itemPoint ~= nil then
                if itemPoint > 100000 then itemPoint = 100000 end
                if itemPoint < 0 then itemPoint = 0 end
                if gameRank ~= nil then
                    gameRank:set_field("_ItemPoint", itemPoint)
                end
			end

            changed, Config.CheatConfig.DisableEnemyAttackCheck = imgui.checkbox("Disable Enemy Attack Check (doesn't work for ranged enemy)", Config.CheatConfig.DisableEnemyAttackCheck)
            configChanged = configChanged or changed
            changed, Config.CheatConfig.SkipCG = imgui.checkbox("Skip CG", Config.CheatConfig.SkipCG)
            configChanged = configChanged or changed
            changed, Config.CheatConfig.SkipRadio = imgui.checkbox("Skip Radio", Config.CheatConfig.SkipRadio)
            configChanged = configChanged or changed
            changed, Config.CheatConfig.PredictCharm = imgui.checkbox("Predict Charm Gacha", Config.CheatConfig.PredictCharm)
            configChanged = configChanged or changed

            imgui.tree_pop()
        end

		if imgui.tree_node("Customize Stats UI") then
            changed, Config.StatsUI.Enabled = imgui.checkbox("Enabled", Config.StatsUI.Enabled)
            configChanged = configChanged or changed
            changed, Config.StatsUI.DrawPlayerHPBar = imgui.checkbox("Draw Player HP Bar", Config.StatsUI.DrawPlayerHPBar)
            configChanged = configChanged or changed

			_, Config.StatsUI.PosX = imgui.drag_int("PosX", Config.StatsUI.PosX, 20, 0, 4000)
			_, Config.StatsUI.PosY = imgui.drag_int("PosY", Config.StatsUI.PosY, 20, 0, 4000)
			_, Config.StatsUI.RowHeight = imgui.drag_int("RowHeight", Config.StatsUI.RowHeight, 1, 10, 100)
			_, Config.StatsUI.RowsCount = imgui.drag_int("RowsCount", Config.StatsUI.RowsCount, 1, 0, 100)
			_, Config.StatsUI.Width = imgui.drag_int("Width", Config.StatsUI.Width, 1, 10, 1000)

			imgui.tree_pop()
		end

		if imgui.tree_node("Customize Enemy UI") then
            changed, Config.EnemyUI.Enabled = imgui.checkbox("Enabled", Config.EnemyUI.Enabled)
            configChanged = configChanged or changed
            changed, Config.EnemyUI.DrawEnemyHPBar = imgui.checkbox("Draw Enemy HP Bar", Config.EnemyUI.DrawEnemyHPBar)
            configChanged = configChanged or changed
            changed, Config.EnemyUI.DisplayPartHP = imgui.checkbox("Dispaly Enemy Part HP Number", Config.EnemyUI.DisplayPartHP)
            configChanged = configChanged or changed
            changed, Config.EnemyUI.DrawPartHPBar = imgui.checkbox("Draw Enemy Part HP Bar", Config.EnemyUI.DrawPartHPBar)
            configChanged = configChanged or changed
            changed, Config.EnemyUI.FilterMaxHPEnemy = imgui.checkbox("Filter Max HP Enemy", Config.EnemyUI.FilterMaxHPEnemy)
            configChanged = configChanged or changed
            changed, Config.EnemyUI.FilterMaxHPPart = imgui.checkbox("Filter Max HP Part", Config.EnemyUI.FilterMaxHPPart)
            configChanged = configChanged or changed
            changed, Config.EnemyUI.FilterUnbreakablePart = imgui.checkbox("Filter Unbreakable Part", Config.EnemyUI.FilterUnbreakablePart)
            configChanged = configChanged or changed
            changed, Config.EnemyUI.FilterNoInSightEnemy = imgui.checkbox("Filter No In Sight Enemy (disable to show all enemy)", Config.EnemyUI.FilterNoInSightEnemy)
            configChanged = configChanged or changed

			_, Config.EnemyUI.PosX = imgui.drag_int("PosX", Config.EnemyUI.PosX, 20, 0, 4000)
			_, Config.EnemyUI.PosY = imgui.drag_int("PosY", Config.EnemyUI.PosY, 20, 0, 4000)
			_, Config.EnemyUI.RowHeight = imgui.drag_int("RowHeight", Config.EnemyUI.RowHeight, 1, 10, 100)
			_, Config.EnemyUI.RowsCount = imgui.drag_int("RowsCount", Config.EnemyUI.RowsCount, 1, 0, 100)
			_, Config.EnemyUI.Width = imgui.drag_int("Width", Config.EnemyUI.Width, 1, 10, 1000)

			imgui.tree_pop()
		end

		if imgui.tree_node("Customize Floating Enemy UI") then
            changed, Config.FloatingUI.Enabled = imgui.checkbox("Enabled", Config.FloatingUI.Enabled)
            configChanged = configChanged or changed

            changed, Config.FloatingUI.FilterMaxHPEnemy = imgui.checkbox("Filter Max HP Enemy", Config.FloatingUI.FilterMaxHPEnemy)
            configChanged = configChanged or changed
            changed, Config.FloatingUI.FilterBlockedEnemy = imgui.checkbox("Filter Blocked Enemy", Config.FloatingUI.FilterBlockedEnemy)
            configChanged = configChanged or changed

            changed, Config.FloatingUI.MaxDistance = imgui.drag_float("Max Display Distance", Config.FloatingUI.MaxDistance, 0.1, 0.1, 1000, "%.1f")
            configChanged = configChanged or changed
            changed, Config.FloatingUI.IgnoreDistanceIfDamaged = imgui.checkbox("Ignore Distance Limit If Damaged", Config.FloatingUI.IgnoreDistanceIfDamaged)
            configChanged = configChanged or changed

            changed, Config.FloatingUI.IgnoreDistanceIfDamagedScale = imgui.drag_float("Ignore Distance Limit If Damaged UI Scale", Config.FloatingUI.IgnoreDistanceIfDamagedScale, 0.01, 0.01, 10, "%.2f")
            configChanged = configChanged or changed

            imgui.text("")
            changed, Config.FloatingUI.DisplayNumber = imgui.checkbox("Display Detailed Number", Config.FloatingUI.DisplayNumber)
            configChanged = configChanged or changed
            _, Config.FloatingUI.FontSize = imgui.drag_int("Font Size", Config.FloatingUI.FontSize, 1, 10, 30)

            imgui.text("\nWorld pos offset in 3D game world")
			_, Config.FloatingUI.WorldPosOffsetX = imgui.drag_float("World Pos Offset X", Config.FloatingUI.WorldPosOffsetX, 0.01, -10, 10, "%.2f")
			_, Config.FloatingUI.WorldPosOffsetY = imgui.drag_float("World Pos Offset Y", Config.FloatingUI.WorldPosOffsetY, 0.01, -10, 10, "%.2f")
			_, Config.FloatingUI.WorldPosOffsetZ = imgui.drag_float("World Pos Offset Z", Config.FloatingUI.WorldPosOffsetZ, 0.01, -10, 10, "%.2f")

            imgui.text("\nPos offset in 2d screen")
			_, Config.FloatingUI.ScreenPosOffsetX = imgui.drag_int("Screen Pos Offset X", Config.FloatingUI.ScreenPosOffsetX, 1, -4000, 4000)
			_, Config.FloatingUI.ScreenPosOffsetY = imgui.drag_int("Screen Pos Offset Y", Config.FloatingUI.ScreenPosOffsetY, 1, -4000, 4000)

            imgui.text("\nFloating HP bar height and width")
			_, Config.FloatingUI.Height = imgui.drag_int("Height", Config.FloatingUI.Height, 1, 10, 100)
			_, Config.FloatingUI.Width = imgui.drag_int("Width", Config.FloatingUI.Width, 1, 10, 1000)
            changed, Config.FloatingUI.ScaleHeightByDistance = imgui.checkbox("Scale Height By Distance", Config.FloatingUI.ScaleHeightByDistance)
            configChanged = configChanged or changed
            changed, Config.FloatingUI.ScaleWidthByDistance = imgui.checkbox("Scale Width By Distance", Config.FloatingUI.ScaleWidthByDistance)
            configChanged = configChanged or changed
            _, Config.FloatingUI.MinScale = imgui.drag_float("Min Scale", Config.FloatingUI.MinScale, 0.01, 0.1, 10, "%.2f")

			imgui.tree_pop()
		end

        local saveMgr = GetSaveDataManager()
        if saveMgr ~= nil and imgui.tree_node("Save Management (!!!Danger!!! Backup your saves!!!)") then
            if Config.TesterMode then
                if imgui.button("Open SavePoint [TESTER MODE]") then
                    if lastSavePoint ~= nil then
                        lastSavePoint:call("openSaveLoad")
                    end
                end
            end
            imgui.text_colored("I don't guarantee this feature to be safe. Use it at your own risk.", 0xFF0000FF)
            if lastSaveArg ~= nil then
                imgui.text("-------------------------------------------------------------------")
                imgui.text("---------- Save management feature enabled --------")
                imgui.text("-------------------------------------------------------------------")
            else
                imgui.text("-------------------------------------------------------------------------------------------")
                imgui.text_colored("---------- You need to save at least once to enable this feature --------", 0xFF0000FF)
                imgui.text("-------------------------------------------------------------------------------------------")
            end


            imgui.push_font(fontCN)
            local allSlotIDs = saveMgr:call("getAllSaveSlotNo()")
            local slotsLen = allSlotIDs:call("get_Count")

            local saveDetailList = saveMgr:call("getSaveFileDetailList", 0, 21)
            local savesLen = saveDetailList:call("get_Count")
            -- imgui.text("== SaveSlots (" .. tostring(slotsLen) .. ") ==")
            -- for i = 0, slotsLen - 1, 1 do
            --     local slotID = allSlotIDs:call("get_Item", i)
            --     imgui.text("Slot " .. tostring(i) .. ": " .. tostring(slotID))
            -- end
            imgui.text("== SaveSlots (" .. tostring(savesLen) .. ") ==")
            for i = 0, savesLen - 1, 1 do
                imgui.text("----- Slot " .. tostring(i) .. " -----")

                local save = saveDetailList:call("get_Item", i):call("get_SaveFileDetail()")
                if save ~= nil then
                    imgui.text("DataCrashed?: " .. tostring(save:call("get_DataCrashed()")))
                    imgui.text(tostring(save:call("get_Slot")) .. ": " .. tostring(save:call("get_SubTitle()")) .. " | " .. tostring(save:call("get_Detail()")))

                    local timestampStr = tostring(save:call("get_LastUpdateTimeStamp"))
                    imgui.text("Last modified timestamp: " .. timestampStr)
                else
                    imgui.text("No save data")
                end
                -- local timestamp = tonumber(timestampStr:sub(1, #timestampStr - 9))
                -- imgui.text("Last modified date: " .. os.date("!%Y-%m-%d %H:%M:%S", 1679847024))
                -- imgui.text("Clicks " .. tostring(clicks))
                if imgui.button("Save at slot " .. tostring(i)) then
                    clicks = clicks + 1
                    if lastSaveArg ~= nil then
                        saveMgr:call("get_IsBusy()")
                        saveMgr:call("requestStartSaveGameDataFlow", i , lastSaveArg)
                    end
                end
            end

            imgui.pop_font()
            imgui.tree_pop()
        end

        if imgui.tree_node("Display Config") then
            for _, k in pairs(DisplayConfigOrder) do
            -- for k, v in pairs(Config.DisplayConfig) do
                changed, Config.DisplayConfig[k] = imgui.checkbox(k, Config.DisplayConfig[k])
                configChanged = configChanged or changed
            end
            imgui.tree_pop()
        end

		changed, Config.DebugMode = imgui.checkbox("DebugMode (prints more fields in the overlay)", Config.DebugMode)
		configChanged = configChanged or changed

		changed, Config.TesterMode = imgui.checkbox("TesterMode (logs many data in the overlay, expected to reset script frequently to clear them) require reset script to enable", Config.TesterMode)
		configChanged = configChanged or changed

		changed, Config.DangerMode = imgui.checkbox("DangerMode (dev only, untested, undocumented and unstable functionalities)", Config.DangerMode)
		configChanged = configChanged or changed

        if Config.TesterMode then
            if imgui.tree_node("Del Lago Test") then
                _, Config.FixDelLago = imgui.checkbox("FixDelLago", Config.FixDelLago)

                local delLagoTransform = GetDelLagoTransform()
                if delLagoTransform ~= nil then
                    delLagoNoClipPos = delLagoTransform:call("get_Position")
                end

                changed, delLagoNoClipPos = imgui.drag_float3("Del Lago No Clip Position", delLagoNoClipPos, 0.15 ,-100000000.0, 100000000.0)
                -- imgui.text("trans "..tostring(transIsNil) .. " | contr " .. tostring(controllerIsNil))

                _, Config.FixPlayer = imgui.checkbox("FixPlayer", Config.FixPlayer)
                local playerTransform = GetPlayerTransform()
                if playerTransform ~= nil then
                    if playerNoClipPos == nil or playerNoClipPos == Vector3f.new(0.0, 0.0, 0.0) then
                        playerNoClipPos = playerTransform:call("get_Position")
                    end
                end
                changed, playerNoClipPos = imgui.drag_float3("Player No Clip Position", playerNoClipPos, 0.15 ,-100000000.0, 100000000.0)

                _, disableCam = imgui.checkbox("disableCam", disableCam)
                -- _, disableWaterObstacle = imgui.checkbox("disableWaterObstacle", disableWaterObstacle)

                imgui.tree_pop()
            end
        end

        if Config.TesterMode then
            local player = getMasterPlayer()
            -- if player ~= nil and lastHoverKeyItem ~= nil then
            if player ~= nil then
                local headUpdater = player:call("get_HeadUpdater()")
                if headUpdater ~= nil then
                    local inventoryCtl =  headUpdater:call("get_KeyItemInventoryController()")
                    if inventoryCtl ~= nil then
                        local inventory = inventoryCtl:call("get__Inventory()")
                        if inventory ~= nil then
                            _, toAddKeyItemID = imgui.input_text("New Key Item ID", toAddKeyItemID);
                            if toAddKeyItemID ~= nil and toAddKeyItemID ~= "" then
                                if imgui.button("Add key item: " .. tostring(toAddKeyItemID)) then
                                    local item = sdk.create_instance("chainsaw.Item", false):add_ref()
                                    local itemDef = sdk.create_instance("chainsaw.ItemDefiniition", false):add_ref()
                                    itemDef:set_field("_ItemSize", 0)
                                    itemDef:set_field("_StackMax", 1)
                                    itemDef:set_field("_DefaultDurabilityMax", 1000)
                                    local useResults = sdk.create_managed_array(sdk.find_type_definition("chainsaw.ItemUseResult"), 0)
                                    local equipReq = sdk.create_instance("chainsaw.EquipRequirement", false):add_ref()
                                    local addReq = sdk.create_instance("chainsaw.AdditionalRequirement", false):add_ref()
                                    equipReq:set_field("_EquipableTarget", 4294967295)
                                    addReq:set_field("_DedicatedTarget", 4294967295)
                                    itemDef:set_field("_UseResults", useResults)
                                    itemDef:set_field("_EquipRequirement", equipReq)
                                    itemDef:set_field("_AdditionalRequirement", addReq)

                                    item:call("set__ItemDefine", itemDef)
                                    item:set_field("_ItemId", toAddKeyItemID)
                                    item:set_field("_CurrentItemCount", 1)

                                    local guid = sdk.create_instance("System.Guid", false)
                                    -- guid = guid:call("Parse", "1b2f1654-171e-4cf0-98d9-1f2592669a00")
                                    guid = guid:call("NewGuid")
                                    item:call("setId", guid)

                                    lastAddItem = item
                                    lastAddItemValid = item:call("get_IsValid")
                                    if lastAddItemValid then
                                        lastAddItemResult = (inventoryCtl:call("add", item))
                                    end
                                end
                            else
                                imgui.text("item is nil")
                            end
                        else
                            imgui.text("inventory is nil")
                        end
                    else
                        imgui.text("inventoryController is nil")
                    end
                else
                    imgui.text("headUpdater is nil")
                end
            else
                imgui.text("player is nil")
            end
            if lastAddItemResult ~= nil then
                -- imgui.text("LastAddResult: " .. tostring(lastAddItemResult:get_field("ID")) .. "/" .. tostring(lastAddItemResult:get_field("AddCount")))
                imgui.text("LastAddResult: " .. tostring(lastAddItemResult:get_field("AddCount")))
            else
                imgui.text("LastAddResult is nil") -- 119275200
            end

            if lastAddItemValid ~= nil then
                imgui.text("item valid: " .. tostring(lastAddItemValid))
            end
        end

        imgui.tree_pop()

        if configChanged then
            json.dump_file("RE4_Overlay/RE4_Overlay.json", Config)
        end
    end
end)

if Config.TesterMode then
    re.on_frame(function()
        if Config.TesterMode then
            if Config.FixDelLago then
                if delLagoNoClipPos ~= nil then
                    SetDelLagoPos(delLagoNoClipPos)
                end
            end
            if Config.FixPlayer then
                if playerNoClipPos ~= nil then
                    SetPlayerPos(playerNoClipPos)
                end
            end
        end
    end)
end

re.on_config_save(function()
	json.dump_file("RE4_Overlay/RE4_Overlay.json", Config)
end)
