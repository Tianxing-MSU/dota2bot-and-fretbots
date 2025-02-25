local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local TU = dofile( GetScriptDirectory()..'/FunLib/techies_utility' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetRoleItemsBuyList( bot )

if GetBot():GetUnitName() == 'npc_dota_hero_techies'
then

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
                [1] = {},
            },
            ['ability'] = {
                [1] = {},
            },
            ['buy_list'] = {},
            ['sell_list'] = {},
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
                    ['t20'] = {10, 0},
                    ['t15'] = {0, 10},
                    ['t10'] = {0, 10},
                },
                [2] = {
                    ['t25'] = {0, 10},
                    ['t20'] = {10, 0},
                    ['t15'] = {0, 10},
                    ['t10'] = {0, 10},
                },
            },
            ['ability'] = {
                [1] = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},
            },
            ['buy_list'] = {
                "item_double_tango",
                "item_double_branches",
                "item_blood_grenade",
                "item_circlet",
            
                "item_boots",
                "item_magic_wand",
                "item_tranquil_boots",
                "item_glimmer_cape",--
                "item_boots_of_bearing",--
                "item_solar_crest",--
                "item_lotus_orb",--
                "item_shivas_guard",--
                "item_sheepstick",--
                "item_aghanims_shard",
                "item_moon_shard",
                "item_ultimate_scepter_2",
            },
            ['sell_list'] = {
                "item_circlet", "item_solar_crest",
                "item_magic_wand", "item_lotus_orb",
            },
        },
    },
    ['pos_5'] = {
        [1] = {
            ['talent'] = {
                [1] = {
                    ['t25'] = {10, 0},
                    ['t20'] = {10, 0},
                    ['t15'] = {0, 10},
                    ['t10'] = {0, 10},
                },
                [2] = {
                    ['t25'] = {0, 10},
                    ['t20'] = {10, 0},
                    ['t15'] = {0, 10},
                    ['t10'] = {0, 10},
                },
            },
            ['ability'] = {
                [1] = {1,3,1,2,1,6,1,3,3,3,6,2,2,2,6},
            },
            ['buy_list'] = {
                "item_double_tango",
                "item_double_branches",
                "item_blood_grenade",
                "item_circlet",
            
                "item_boots",
                "item_magic_wand",
                "item_arcane_boots",
                "item_glimmer_cape",--
                "item_guardian_greaves",--
                "item_solar_crest",--
                "item_lotus_orb",--
                "item_shivas_guard",--
                "item_sheepstick",--
                "item_aghanims_shard",
                "item_moon_shard",
                "item_ultimate_scepter_2",
            },
            ['sell_list'] = {
                "item_circlet", "item_solar_crest",
                "item_magic_wand", "item_lotus_orb",
            },
        },
    },
}

local sSelectedBuild = HeroBuild[sRole][RandomInt(1, #HeroBuild[sRole])]

local nTalentBuildList = J.Skill.GetTalentBuild(J.Skill.GetRandomBuild(sSelectedBuild.talent))
local nAbilityBuildList = J.Skill.GetRandomBuild(sSelectedBuild.ability)

X['sBuyList'] = sSelectedBuild.buy_list
X['sSellList'] = sSelectedBuild.sell_list

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_antimage' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

end

local StickyBomb        = bot:GetAbilityByName('techies_sticky_bomb')
local ReactiveTazer     = bot:GetAbilityByName('techies_reactive_tazer')
local ReactiveTazerStop = bot:GetAbilityByName('techies_reactive_tazer_stop')
local BlastOff          = bot:GetAbilityByName('techies_suicide')
local MineFieldSign     = bot:GetAbilityByName('techies_minefield_sign')
local ProximityMines    = bot:GetAbilityByName('techies_land_mines')

local StickyBombDesire, StickyBombLocation
local ReactiveTazerDesire
-- local ReactiveTazerStopDesire
local BlastOffDesire, BlastOffLocation
local MineFieldSignDesire, MineFieldSignLocation
local ProximityMinesDesire, ProximityMinesLocation

local MineCooldownTime = 0

local ComboDesire, ComboLocation

local botTarget

function X.SkillsComplement()
	if J.CanNotUseAbility(bot) then return end

    StickyBomb        = bot:GetAbilityByName('techies_sticky_bomb')
    ReactiveTazer     = bot:GetAbilityByName('techies_reactive_tazer')
    ReactiveTazerStop = bot:GetAbilityByName('techies_reactive_tazer_stop')
    BlastOff          = bot:GetAbilityByName('techies_suicide')
    MineFieldSign     = bot:GetAbilityByName('techies_minefield_sign')
    ProximityMines    = bot:GetAbilityByName('techies_land_mines')

    botTarget = J.GetProperTarget(bot)

    ComboDesire, ComboLocation, Flag = X.ConsiderCombo()
    if ComboDesire > 0
    then
        bot:Action_ClearActions(false)
        local nCastPoint = BlastOff:GetCastPoint()
        local nLeapDuration = BlastOff:GetSpecialValueInt('stun_radius')

        if Flag == 1
        then
            if J.CheckBitfieldFlag(ReactiveTazer:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
            then
                bot:ActionQueue_UseAbilityOnEntity(ReactiveTazer, bot)
            else
                bot:ActionQueue_UseAbility(ReactiveTazer)
            end

            bot:ActionQueue_Delay(0.6)
            bot:ActionQueue_UseAbilityOnLocation(BlastOff, ComboLocation)
            bot:ActionQueue_Delay(nCastPoint + nLeapDuration)
            if not ReactiveTazerStop:IsHidden()
            then
                bot:ActionQueue_UseAbility(ReactiveTazerStop)
            end
        end

        return
    end

    StickyBombDesire, StickyBombLocation = X.ConsiderStickyBomb()
    if StickyBombDesire > 0
    then
        bot:Action_UseAbilityOnLocation(StickyBomb, StickyBombLocation)
        return
    end

    ReactiveTazerDesire = X.ConsiderReactiveTazer()
    if ReactiveTazerDesire > 0
    then
        if J.CheckBitfieldFlag(ReactiveTazer:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
        then
            bot:Action_UseAbilityOnEntity(ReactiveTazer, bot)
        else
            bot:Action_UseAbility(ReactiveTazer)
        end

        return
    end

    BlastOffDesire, BlastOffLocation = X.ConsiderBlastOff()
    if BlastOffDesire > 0
    then
        bot:Action_UseAbilityOnLocation(BlastOff, BlastOffLocation)
        return
    end

    ProximityMinesDesire, ProximityMinesLocation = X.ConsiderProximityMines()
    if ProximityMinesDesire > 0
    then
        bot:Action_UseAbilityOnLocation(ProximityMines, ProximityMinesLocation)
        MineCooldownTime = DotaTime()
        return
    end

    MineFieldSignDesire, MineFieldSignLocation = X.ConsiderMineFieldSign()
    if MineFieldSignDesire > 0
    then
        bot:Action_UseAbilityOnLocation(MineFieldSign, MineFieldSignLocation)
        return
    end
end

function X.ConsiderStickyBomb()
    if not J.CanCastAbility(StickyBomb)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nCastRange = J.GetProperCastRange(false, bot, StickyBomb:GetCastRange())
    local nDamage = StickyBomb:GetSpecialValueInt('damage')
    local nSpeed = StickyBomb:GetSpecialValueInt('speed')
    local nAcceleration = StickyBomb:GetSpecialValueInt('acceleration')
    local nAbilityLevel = StickyBomb:GetLevel()

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local eta = J.GetETAWithAcceleration(GetUnitToUnitDistance(bot, enemyHero), nSpeed, nAcceleration)
            if J.IsChasingTarget(bot, enemyHero)
            then
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(eta)
            else
                return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
            end
        end
    end

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        for _, enemyHero in pairs(nAllyInRangeEnemy)
        do
            if  J.IsValidHero(allyHero)
            and J.IsRetreating(allyHero)
            and allyHero:WasRecentlyDamagedByAnyHero(1.5)
            and not allyHero:IsIllusion()
            then
                if  J.IsValidHero(enemyHero)
                and J.CanCastOnNonMagicImmune(enemyHero)
                and J.IsInRange(bot, enemyHero, nCastRange)
                and J.IsChasingTarget(enemyHero, allyHero)
                and not J.IsDisabled(enemyHero)
                and not J.IsTaunted(enemyHero)
                and not J.IsSuspiciousIllusion(enemyHero)
                and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
                then
                    local eta = J.GetETAWithAcceleration(GetUnitToUnitDistance(bot, enemyHero), nSpeed, nAcceleration)
                    if J.IsChasingTarget(enemyHero, allyHero)
                    then
                        return BOT_ACTION_DESIRE_HIGH, enemyHero:GetExtrapolatedLocation(eta)
                    else
                        return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                    end
                end
            end
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                local eta = J.GetETAWithAcceleration(GetUnitToUnitDistance(bot, botTarget), nSpeed, nAcceleration)
                if J.IsChasingTarget(bot, botTarget)
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(eta)
                else
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                end
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    return BOT_ACTION_DESIRE_HIGH, (bot:GetLocation() + enemyHero:GetLocation()) / 2
                end
            end
        end
	end

    if  (J.IsPushing(bot) or J.IsDefending(bot))
    and nAbilityLevel >= 3
    and not J.IsThereCoreNearby(1000)
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(1600, true)

        if  nEnemyLaneCreeps ~= nil and #nEnemyLaneCreeps >= 4
        and J.GetMP(bot) > 0.5
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nEnemyLaneCreeps)
        end
	end

    if J.IsLaning(bot)
	then
        local creepList = {}
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                local nTowers = enemyHero:GetNearbyTowers(600, true)
                if  nTowers ~= nil and #nTowers >= 1
                and J.IsValidBuilding(nTowers[1])
                and nTowers[1]:GetAttackTarget() == enemyHero
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end
        end

		for _, creep in pairs(nEnemyLaneCreeps)
		do
            if  J.IsValid(creep)
            and creep:GetHealth() <= nDamage
            then
                table.insert(creepList, creep)
            end
		end

        if  #creepList >= 2
        and J.GetMP(bot) > 0.35
        and J.CanBeAttacked(creepList[1])
        and not J.IsThereCoreNearby(1200)
        then
            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(creepList)
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    local creepList = {}
    local nCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)
    for _, creep in pairs(nCreeps)
    do
        if  J.IsValid(creep)
        and creep:GetHealth() <= nDamage
        then
            table.insert(creepList, creep)
        end
    end

    if  #creepList >= 3
    and J.CanBeAttacked(creepList[1])
    and not J.IsThereCoreNearby(1200)
    then
        return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(creepList)
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderReactiveTazer()
    if not J.CanCastAbility(ReactiveTazer)
    then
        return BOT_ACTION_DESIRE_NONE
    end

    local nRadius = ReactiveTazer:GetSpecialValueInt('stun_radius')

    if  J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and not J.IsSuspiciousIllusion(botTarget)
        and not J.IsDisabled(botTarget)
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                return BOT_ACTION_DESIRE_HIGH
            end
		end
	end

    if  J.IsRetreating(bot)
    and bot:GetActiveModeDesire() > BOT_ACTION_DESIRE_HIGH
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(1.5))
                then
                    return BOT_ACTION_DESIRE_HIGH
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderBlastOff()
    if not J.CanCastAbility(BlastOff)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, BlastOff:GetCastRange())
	local nCastPoint = BlastOff:GetCastPoint()
    local nRadius = BlastOff:GetSpecialValueInt('radius')
    local nLeapDuration = BlastOff:GetSpecialValueFloat('duration')

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and J.CanCastOnNonMagicImmune(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
        and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
        and not enemyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
        and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
        and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
        then
            local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                if enemyHero:IsChanneling()
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end
        end
    end

	if  J.IsInTeamFight(bot, 1200)
	then
		local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0 )
        local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius * 0.8)

		if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
        and not J.IsLocationInChrono(J.GetCenterOfUnits(nInRangeEnemy))
        then
			return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
		end
	end

	if  J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                local flag = false
                local eta = nCastPoint + nLeapDuration
                local nEnemyTowers = botTarget:GetNearbyTowers(700, false)

                if J.IsChasingTarget(bot, botTarget)
                then
                    if J.IsInLaningPhase()
                    then
                        if nEnemyHeroes ~= nil and #nEnemyTowers >= 1
                        then
                            flag = true
                        end
                    end

                    if not flag
                    then
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(eta)
                    end
                else
                    if J.IsInLaningPhase()
                    then
                        if nEnemyHeroes ~= nil and #nEnemyTowers >= 1
                        then
                            flag = true
                        end
                    end

                    if not flag
                    then
                        nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius)
                        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                        else
                            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                        end
                    end
                end
            end
		end
	end

    if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(2))
                then
                    if  J.GetHP(bot) < 0.5
                    and J.CanCastOnNonMagicImmune(enemyHero)
                    and bot:GetHealth() < J.GetTotalEstimatedDamageToTarget(nInRangeEnemy, bot, 5.5)
                    then
                        return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                    else
                        return BOT_ACTION_DESIRE_HIGH, J.Site.GetXUnitsTowardsLocation(bot, J.GetTeamFountain(), nCastRange)
                    end
                end
            end
        end
	end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderMineFieldSign()
    if ProximityMines ~= nil and not ProximityMines:IsTrained()
    or not J.CanCastAbility(MineFieldSign)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

    local nRadius = MineFieldSign:GetSpecialValueInt('aura_radius')
    local nSpots = TU.GetAvailableSpot()
    MineLocation, MineLocationDistance = TU.GetClosestSpot(bot, nSpots)

    if  MineLocation ~= nil
    and GetUnitToLocationDistance(bot, MineLocation) <= bot:GetCurrentVisionRange()
    and not IsEnemyCloserToWardLocation(MineLocation, MineLocationDistance)
    then
        -- Try 50 times
        for i = 0, 50
        do
            local loc = J.GetRandomLocationWithinDist(MineLocation, 0, nRadius * 3 + 100)
            if IsLocationPassable(loc)
            then
                local nMineList = J.GetTechiesMinesInLoc(loc, nRadius)
                if #nMineList >= 3
                then
                    return BOT_ACTION_DESIRE_HIGH, loc
                end
            end

            i = i + 1
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderProximityMines()
    if not J.CanCastAbility(ProximityMines)
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, ProximityMines:GetCastRange())
    local nDamage = ProximityMines:GetSpecialValueInt('damage')
    local nRadius = 350

	if J.IsGoingOnSomeone(bot)
	then
		if  J.IsValidTarget(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 1200)
        and J.IsAttacking(bot)
        and not J.IsChasingTarget(bot, botTarget)
        and not J.IsSuspiciousIllusion(botTarget)
        and not botTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not botTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not botTarget:HasModifier('modifier_oracle_false_promise_timer')
        and not botTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
            local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
            and #nInRangeAlly >= #nInRangeEnemy
            then
                nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius)
                if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                then
                    if not TU.IsOtherMinesClose(J.GetCenterOfUnits(nInRangeEnemy))
                    then
                        return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy)
                    end
                else
                    if not TU.IsOtherMinesClose(botTarget:GetLocation())
                    then
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
                    end
                end
            end
		end
	end

	if J.IsRetreating(bot)
	then
        local nInRangeEnemy = bot:GetNearbyHeroes(1000, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and J.CanCastOnNonMagicImmune(enemyHero)
            and J.IsChasingTarget(enemyHero, bot)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not J.IsDisabled(enemyHero)
            then
                local nInRangeAlly = enemyHero:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and ((#nTargetInRangeAlly > #nInRangeAlly)
                    or bot:WasRecentlyDamagedByAnyHero(1))
                and J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_MAGICAL)
                then
                    local loc = (bot:GetLocation() + enemyHero:GetLocation()) / 2
                    if GetUnitToLocationDistance(bot, loc) <= nCastRange
                    then
                        return BOT_ACTION_DESIRE_HIGH, loc
                    else
                        return BOT_ACTION_DESIRE_HIGH, bot:GetLocation()
                    end
                end
            end
        end
	end

	if J.IsPushing(bot)
	then
		local nEnemyTowers = bot:GetNearbyTowers(1200, true)
		if  nEnemyTowers ~= nil and #nEnemyTowers >= 1
        and J.IsValidBuilding(nEnemyTowers[1])
        and J.CanBeAttacked(nEnemyTowers[1])
        then
            local nInRangeAlly = J.GetAlliesNearLoc(nEnemyTowers[1]:GetLocation(), bot:GetAttackRange())
            local nInRangeEnemy = J.GetEnemiesNearLoc(nEnemyTowers[1]:GetLocation(), 1600)

            if  nInRangeAlly ~= nil and #nInRangeAlly >= 1
            and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
            then
                return BOT_ACTION_DESIRE_HIGH, nEnemyTowers[1]:GetLocation() + RandomVector(500)
            end
		end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and not TU.IsOtherMinesClose(botTarget:GetLocation())
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nCastRange)
        and J.IsAttacking(bot)
        and not TU.IsOtherMinesClose(botTarget:GetLocation())
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    -- General Mines
    local nManaCost = ReactiveTazer:GetManaCost() + BlastOff:GetManaCost()

    if  IsSuitableToPlaceMine()
    and DotaTime() > MineCooldownTime + 1.2
    and J.GetManaAfter(nManaCost) * bot:GetMana() > ProximityMines:GetManaCost() * 2
    then
		local nSpots = TU.GetAvailableSpot()
		MineLocation, MineLocationDistance = TU.GetClosestSpot(bot, nSpots)

		if  MineLocation ~= nil
        and GetUnitToLocationDistance(bot, MineLocation) <= 4000
		and not IsEnemyCloserToWardLocation(MineLocation, MineLocationDistance)
		then
            -- Try 100 times
            for i = 0, 100
            do
                local loc = J.GetRandomLocationWithinDist(MineLocation, 0, nRadius * 3 + 100)
                if  IsLocationPassable(loc)
                and not TU.IsOtherMinesClose(loc)
                then
                    local nMineList = J.GetTechiesMinesInLoc(loc, nRadius * 3 + 100) --☠️, fine..
                    if #nMineList < 3
                    then
                        return BOT_ACTION_DESIRE_HIGH, loc
                    end
                end

                i = i + 1
            end
		end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

-- Helper Funcs
function IsSuitableToPlaceMine()
	local nEnemyHeroes = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE)

	local nMode = bot:GetActiveMode()
    local nTeamFightLocation = J.GetTeamFightLocation(bot)

	if (nMode == BOT_MODE_RETREAT
		and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_HIGH)
    or (nMode == BOT_MODE_RUNE and DotaTime() > 0)
    or nMode == BOT_MODE_DEFEND_ALLY
    or J.IsGoingOnSomeone(bot) and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
    or J.IsPushing(bot) and bot:GetActiveModeDesire() > BOT_MODE_DESIRE_MODERATE
	or J.IsDefending(bot)
    or J.IsDoingRoshan(bot)
    or J.IsDoingTormentor(bot)
    or nTeamFightLocation ~= nil
	or (nEnemyHeroes ~= nil and #nEnemyHeroes >= 1 and IsIBecameTheTarget(nEnemyHeroes))
	or bot:WasRecentlyDamagedByAnyHero(5.0)
	then
		return false
	end

	return true
end

function IsIBecameTheTarget(nUnits)
	for _, u in pairs(nUnits)
	do
		if  u ~= nil
		and u:IsAlive()
		and u:CanBeSeen()
        and u:GetAttackTarget() == bot
		then
			return true
		end
	end

	return false
end

function IsEnemyCloserToWardLocation(wardLoc, botDist)
	for _, id in pairs(GetTeamPlayers(GetOpposingTeam()))
	do
		local info = GetHeroLastSeenInfo(id)

		if info ~= nil
		then
			local dInfo = info[1]

			if  dInfo ~= nil
			and dInfo.time_since_seen < 5
			and J.GetDistance(dInfo.location, wardLoc) <  botDist
			then
				return true
			end
		end
	end

	return false
end

-- Combos
function X.ConsiderCombo()
    local ComboFlag = 0

    if CanDoCombo1()
    then
        ComboFlag = 1
    end

    if ComboFlag > 0
    then
        local nCastRange = J.GetProperCastRange(false, bot, BlastOff:GetCastRange())
        local nCastPoint = BlastOff:GetCastPoint()
        local nRadius = BlastOff:GetSpecialValueInt('radius')
        local nLeapDuration = BlastOff:GetSpecialValueFloat('duration')

        if J.IsInTeamFight(bot, 1200)
        then
            local nLocationAoE = bot:FindAoELocation(true, true, bot:GetLocation(), nCastRange, nRadius, 0, 0)
            local nInRangeEnemy = J.GetEnemiesNearLoc(nLocationAoE.targetloc, nRadius)

            if  nInRangeEnemy ~= nil and #nInRangeEnemy >= 2
            and (J.IsValidHero(nInRangeEnemy[1]) and not nInRangeEnemy[1]:IsMagicImmune()
                or J.IsValidHero(nInRangeEnemy[2]) and not nInRangeEnemy[2]:IsMagicImmune())
            and not J.IsLocationInChrono(J.GetCenterOfUnits(nInRangeEnemy))
            then
                return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy), ComboFlag
            end
        end

        if J.IsGoingOnSomeone(bot)
        then
            if  J.IsValidTarget(botTarget)
            and J.CanCastOnNonMagicImmune(botTarget)
            and J.IsInRange(bot, botTarget, nCastRange)
            and not J.IsSuspiciousIllusion(botTarget)
            and not botTarget:IsMagicImmune()
            and not botTarget:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not botTarget:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nInRangeAlly = botTarget:GetNearbyHeroes(1200, true, BOT_MODE_NONE)
                local nInRangeEnemy = botTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
                and #nInRangeAlly >= #nInRangeEnemy
                then
                    local eta = nCastPoint + nLeapDuration
                    if J.IsChasingTarget(bot, botTarget)
                    then
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetExtrapolatedLocation(eta), ComboFlag
                    else
                        nInRangeEnemy = J.GetEnemiesNearLoc(botTarget:GetLocation(), nRadius)
                        if nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
                        then
                            return BOT_ACTION_DESIRE_HIGH, J.GetCenterOfUnits(nInRangeEnemy), ComboFlag
                        else
                            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), ComboFlag
                        end
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0, 0
end

function CanDoCombo1()
    if  J.CanCastAbility(ReactiveTazer)
    and J.CanCastAbility(BlastOff)
    then
        local nManaCost = ReactiveTazer:GetManaCost()
                        + BlastOff:GetManaCost()

        if  bot:GetMana() >= nManaCost
        and J.GetHP(bot) > 0.35
        then
            return true
        end
    end

    return false
end

return X