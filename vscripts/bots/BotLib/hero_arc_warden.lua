local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

local RI = require(GetScriptDirectory()..'/FunLib/util_role_item')

local sUtility = {}
local sUtilityItem = RI.GetBestUtilityItem(sUtility)

local HeroBuild = {
    ['pos_1'] = {
        [1] = {
            ['talent'] = {
                [1] = {
					['t25'] = {10, 0},
					['t20'] = {10, 0},
					['t15'] = {10, 0},
					['t10'] = {10, 0},
				},
            },
            ['ability'] = {
				[1] = {3,1,3,1,3,6,3,1,1,2,6,2,2,2,6},
            },
            ['buy_list'] = {
				"item_tango",
				"item_double_branches",
				"item_faerie_fire",
				"item_slippers",
				"item_circlet",
	
				"item_wraith_band",
				"item_boots",
				"item_magic_wand",
				"item_hand_of_midas",
				"item_maelstrom",
				"item_gungir",--
				"item_travel_boots",
				"item_manta",--
				"item_sheepstick",--
				"item_bloodthorn",--
				"item_skadi",--
				"item_travel_boots_2",--
				"item_moon_shard",
				"item_aghanims_shard",
				"item_ultimate_scepter_2",
			},
            ['sell_list'] = {
				"item_wraith_band",
				"item_magic_wand",
				"item_hand_of_midas",
			},
        },
    },
    ['pos_2'] = {
        [1] = {
            ['talent'] = {
				[1] = {
					['t25'] = {10, 0},
					['t20'] = {0, 10},
					['t15'] = {0, 10},
					['t10'] = {0, 10},
				},
            },
            ['ability'] = {
				[1] = {3,1,1,3,1,6,1,3,3,2,6,2,2,2,6},
            },
            ['buy_list'] = {
				"item_tango",
				"item_double_branches",
				"item_circlet",
				"item_faerie_fire",
	
				"item_bottle",
				"item_magic_wand",
				"item_spirit_vessel",
				"item_boots",
				"item_hand_of_midas",
				"item_gungir",--
				"item_travel_boots",
				"item_blink",
				"item_octarine_core",--
				"item_ultimate_scepter",
				"item_orchid",
				"item_sheepstick",--
				"item_overwhelming_blink",--
				"item_bloodthorn",--
				"item_travel_boots_2",--
				"item_ultimate_scepter_2",
				"item_moon_shard",
				"item_aghanims_shard",
			},
            ['sell_list'] = {
				"item_circlet",
				"item_bottle",
				"item_magic_wand",
				"item_spirit_vessel",
				"item_hand_of_midas",
			},
        },
		[2] = {
            ['talent'] = {
				[1] = {
					['t25'] = {10, 0},
					['t20'] = {0, 10},
					['t15'] = {0, 10},
					['t10'] = {0, 10},
				},
            },
            ['ability'] = {
				[1] = {3,1,1,3,1,6,1,3,3,2,6,2,2,2,6},
            },
            ['buy_list'] = {
				"item_tango",
				"item_double_branches",
				"item_faerie_fire",
	
				"item_bottle",
				"item_spirit_vessel",
				"item_magic_wand",
				"item_boots",
				"item_hand_of_midas",
				"item_gungir",--
				"item_travel_boots",
				"item_orchid",
				"item_manta",--
				"item_greater_crit",--
				"item_skadi",--
				"item_bloodthorn",--
				"item_travel_boots_2",--
				"item_moon_shard",
				"item_aghanims_shard",
				"item_ultimate_scepter_2",
			},
            ['sell_list'] = {
				"item_bottle",
				"item_spirit_vessel",
				"item_magic_wand",
				"item_hand_of_midas",
			},
        },
    },
    ['pos_3'] = {
        [1] = {
            ['talent'] = {
                [1] = {},
            },
            ['ability'] = {
                [1] = {},
            },
            ['buy_list'] = {},
            ['sell_list'] = {},
        },
    },
    ['pos_4'] = {
        [1] = {
            ['talent'] = {
                [1] = {},
            },
            ['ability'] = {
                [1] = {},
            },
            ['buy_list'] = {},
            ['sell_list'] = {},
        },
    },
    ['pos_5'] = {
        [1] = {
            ['talent'] = {
                [1] = {},
            },
            ['ability'] = {
                [1] = {},
            },
            ['buy_list'] = {},
            ['sell_list'] = {},
        },
    },
}

local sSelectedBuild = HeroBuild[sRole][RandomInt(1, #HeroBuild[sRole])]

local nTalentBuildList = J.Skill.GetTalentBuild(J.Skill.GetRandomBuild(sSelectedBuild.talent))
local nAbilityBuildList = J.Skill.GetRandomBuild(sSelectedBuild.ability)

X['sBuyList'] = sSelectedBuild.buy_list
X['sSellList'] = sSelectedBuild.sell_list


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_ranged_carry' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
	Minion.MinionThink(hMinionUnit)
end

return X