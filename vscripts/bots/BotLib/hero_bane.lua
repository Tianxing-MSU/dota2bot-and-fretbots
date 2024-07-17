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
                [1] = {},
            },
            ['ability'] = {
                [1] = {},
            },
            ['buy_list'] = {},
            ['sell_list'] = {},
        },
    },
    ['pos_2'] = {
        [1] = {
            ['talent'] = {
                [1] = {
					['t25'] = {10, 0},
					['t20'] = {10, 0},
					['t15'] = {0, 10},
					['t10'] = {0, 10},
				},
            },
            ['ability'] = {
				[1] = {1,2,2,1,2,6,2,1,1,3,6,3,3,3,6},
            },
            ['buy_list'] = {
				"item_tango",
				"item_double_branches",
				"item_double_circlet",
				"item_enchanted_mango",
			
				"item_bottle",
				"item_magic_wand",
				"item_arcane_boots",
				"item_urn_of_shadows",
				"item_phylactery",
				"item_hand_of_midas",
				"item_spirit_vessel",
				"item_aghanims_shard",
				"item_ultimate_scepter",
				"item_kaya_and_sange",--
				"item_angels_demise",--
				"item_black_king_bar",--
				"item_hurricane_pike",--
				"item_travel_boots",
				"item_octarine_core",--
				"item_travel_boots_2",--
				"item_ultimate_scepter_2",
				"item_moon_shard",
			},
            ['sell_list'] = {
				"item_circlet",
				"item_bottle",
				"item_magic_wand",
				"item_hand_of_midas",
				"item_spirit_vessel",
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
				[1] = {
					['t25'] = {10, 0},
					['t20'] = {0, 10},
					['t15'] = {10, 0},
					['t10'] = {10, 0},
				}
            },
            ['ability'] = {
				[1] = {2,3,2,3,2,6,2,3,3,1,1,6,1,1,6},
            },
            ['buy_list'] = {
				"item_double_tango",
				"item_double_branches",
				"item_blood_grenade",
			
				"item_circlet",
				"item_boots",
				"item_magic_wand",
				"item_tranquil_boots",
				"item_aether_lens",--
				"item_solar_crest",--
				"item_glimmer_cape",--
				"item_aghanims_shard",
				"item_boots_of_bearing",--
				"item_ultimate_scepter",
				"item_aeon_disk",--
				"item_refresher",--
				"item_ultimate_scepter_2",
				"item_moon_shard",
			},
            ['sell_list'] = {
				"item_circlet",
				"item_magic_wand",
			},
        },
    },
    ['pos_5'] = {
        [1] = {
            ['talent'] = {
				[1] = {
					['t25'] = {10, 0},
					['t20'] = {0, 10},
					['t15'] = {10, 0},
					['t10'] = {10, 0},
				}
            },
            ['ability'] = {
				[1] = {2,3,2,3,2,6,2,3,3,1,1,6,1,1,6},
            },
            ['buy_list'] = {
				"item_double_tango",
				"item_double_branches",
				"item_blood_grenade",
			
				"item_circlet",
				"item_boots",
				"item_magic_wand",
				"item_arcane_boots",
				"item_aether_lens",--
				"item_glimmer_cape",--
				"item_aghanims_shard",
				"item_force_staff",--
				"item_guardian_greaves",--
				"item_ultimate_scepter",
				"item_aeon_disk",--
				"item_refresher",--
				"item_ultimate_scepter_2",
				"item_moon_shard",
			},
            ['sell_list'] = {
				"item_circlet",
				"item_magic_wand",
			},
        },
    },
}

local sSelectedBuild = HeroBuild[sRole][RandomInt(1, #HeroBuild[sRole])]

local nTalentBuildList = J.Skill.GetTalentBuild(J.Skill.GetRandomBuild(sSelectedBuild.talent))
local nAbilityBuildList = J.Skill.GetRandomBuild(sSelectedBuild.ability)

X['sBuyList'] = sSelectedBuild.buy_list
X['sSellList'] = sSelectedBuild.sell_list


if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_priest' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = true

function X.MinionThink( hMinionUnit )

	if Minion.IsValidUnit( hMinionUnit )
	then
		Minion.IllusionThink( hMinionUnit )
	end

end

return X