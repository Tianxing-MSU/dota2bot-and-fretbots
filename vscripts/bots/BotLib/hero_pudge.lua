local X = {}
local bot = GetBot()

local J = require( GetScriptDirectory()..'/FunLib/jmz_func' )
local Minion = dofile( GetScriptDirectory()..'/FunLib/aba_minion' )
local sTalentList = J.Skill.GetTalentList( bot )
local sAbilityList = J.Skill.GetAbilityList( bot )
local sRole = J.Item.GetOutfitType( bot )

local tTalentTreeList = {
						{--pos2
                            ['t25'] = {10, 0},
                            ['t20'] = {0, 10},
                            ['t15'] = {10, 0},
                            ['t10'] = {0, 10},
                        },--pos3
                        {
                            ['t25'] = {0, 10},
                            ['t20'] = {0, 10},
                            ['t15'] = {0, 10},
                            ['t10'] = {10, 0},
                        }
}

local tAllAbilityBuildList = {
						{1,2,2,3,1,6,1,1,2,2,6,3,3,3,6},--pos2
                        {1,2,2,3,2,6,2,3,3,3,6,1,1,1,6},--pos3
}

local nAbilityBuildList
local nTalentBuildList

if sRole == "outfit_mid"
then
    nAbilityBuildList   = tAllAbilityBuildList[1]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[1])
elseif sRole == "outfit_tank"
then
    nAbilityBuildList   = tAllAbilityBuildList[2]
    nTalentBuildList    = J.Skill.GetTalentBuild(tTalentTreeList[2])
end

local sUtility = {"item_pipe", "item_lotus_orb", "item_crimson_guard"}
local nUtility = sUtility[RandomInt(1, #sUtility)]

local sRoleItemsBuyList = {}

sRoleItemsBuyList['outfit_carry'] = sRoleItemsBuyList['outfit_carry']

sRoleItemsBuyList['outfit_mid'] = {
    "item_tango",
    "item_double_branches",

    "item_bracer",
    "item_bottle",
    "item_boots",
    "item_magic_wand",
    "item_eternal_shroud",--
    "item_blink",
    "item_ultimate_scepter",
    "item_travel_boots",
    "item_bloodstone",--
    "item_black_king_bar",--
    "item_kaya_and_sange",--
    "item_ultimate_scepter_2",
    "item_overwhelming_blink",--
    "item_travel_boots_2",--
    "item_aghanims_shard",
    "item_moon_shard",
}

sRoleItemsBuyList['outfit_tank'] = {
    "item_tango",
    "item_double_branches",
    "item_magic_stick",
    "item_ring_of_protection",

    "item_helm_of_iron_will",
    "item_boots",
    "item_magic_wand",
    "item_phase_boots",
    "item_veil_of_discord",
    "item_eternal_shroud",--
    "item_ultimate_scepter",
    "item_blink",
    "item_shivas_guard",--
    nUtility,--
    "item_black_king_bar",--
    "item_travel_boots",
    "item_overwhelming_blink",--
    "item_ultimate_scepter_2",
    "item_travel_boots_2",--
    "item_aghanims_shard",
    "item_moon_shard",
}

sRoleItemsBuyList['outfit_priest'] = sRoleItemsBuyList['outfit_priest']

sRoleItemsBuyList['outfit_mage'] = sRoleItemsBuyList['outfit_mage']

X['sBuyList'] = sRoleItemsBuyList[sRole]

Pos2SellList = {
    "item_bracer",
    "item_bottle",
    "item_magic_wand",
}

Pos3SellList = {
	"item_ring_of_protection",
    "item_magic_wand",
}

X['sSellList'] = {}

if sRole == "outfit_mid"
then
    X['sSellList'] = Pos2SellList
elseif sRole == "outfit_tank"
then
    X['sSellList'] = Pos3SellList
end

if J.Role.IsPvNMode() or J.Role.IsAllShadow() then X['sBuyList'], X['sSellList'] = { 'PvN_mid' }, {} end

nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] = J.SetUserHeroInit( nAbilityBuildList, nTalentBuildList, X['sBuyList'], X['sSellList'] )

X['sSkillList'] = J.Skill.GetSkillList( sAbilityList, nAbilityBuildList, sTalentList, nTalentBuildList )

X['bDeafaultAbility'] = false
X['bDeafaultItem'] = false

function X.MinionThink(hMinionUnit)
    Minion.MinionThink(hMinionUnit)
end

local MeatHook  = bot:GetAbilityByName('pudge_meat_hook')
local Rot       = bot:GetAbilityByName('pudge_rot')
local FleshHeap = bot:GetAbilityByName('pudge_flesh_heap')
-- local Eject     = bot:GetAbilityByName('')
local Dismember = bot:GetAbilityByName('pudge_dismember')

local MeatHookDesire, MeatHookLocation
local RotDesire
local FleshHeapDesire
-- local EjectDesire
local DismemberDesire, DismemberTarget

function X.SkillsComplement()
    if J.CanNotUseAbility(bot) then return end

    MeatHookDesire, MeatHookLocation = X.ConsiderMeatHook()
    if MeatHookDesire > 0
    then
        bot:Action_UseAbilityOnLocation(MeatHook, MeatHookLocation)
        return
    end

    RotDesire = X.ConsiderRot()
    if RotDesire > 0
    then
        bot:Action_UseAbility(Rot)
        return
    end

    FleshHeapDesire = X.ConsiderFleshHeap()
    if FleshHeapDesire > 0
    then
        bot:Action_UseAbility(FleshHeap)
        return
    end

    DismemberDesire, DismemberTarget = X.ConsiderDismember()
    if DismemberDesire > 0
    then
        if  Rot:IsTrained()
        and Rot:GetToggleState() == false
        then
            bot:Action_UseAbility(Rot)
        end

        if  FleshHeap:IsTrained()
        and FleshHeap:IsFullyCastable()
        then
            bot:Action_UseAbility(FleshHeap)
        end

        bot:Action_UseAbilityOnEntity(Dismember, DismemberTarget)
        return
    end

    -- EjectDesire = X.ConsiderEject()
    -- if EjectDesire > 0
    -- then
    --     bot:Action_UseAbility(Eject)
    --     return
    -- end
end

function X.ConsiderMeatHook()
    if not MeatHook:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, 0
    end

	local nCastRange = J.GetProperCastRange(false, bot, MeatHook:GetCastRange())
    local nCastPoint = MeatHook:GetCastPoint()
	local nRadius = MeatHook:GetSpecialValueInt('hook_width')
	local nSpeed = MeatHook:GetSpecialValueInt('hook_speed')
	local nDamage = MeatHook:GetSpecialValueInt('damage')
    local botTarget = J.GetProperTarget(bot)

    local nEnemyHeroes = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
    for _, enemyHero in pairs(nEnemyHeroes)
    do
        if  J.IsValidHero(enemyHero)
        and not J.IsSuspiciousIllusion(enemyHero)
        then
            if enemyHero:IsChanneling() or J.IsCastingUltimateAbility(enemyHero)
            then
                if  not J.IsHeroBetweenMeAndTarget(bot, enemyHero, enemyHero:GetLocation(), nRadius)
                and not J.IsCreepBetweenMeAndTarget(bot, enemyHero, enemyHero:GetLocation(), nRadius)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemyHero:GetLocation()
                end
            end

            if  J.CanKillTarget(enemyHero, nDamage, DAMAGE_TYPE_PURE)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            and not enemyHero:HasModifier('modifier_oracle_false_promise_timer')
            and not enemyHero:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                local eta = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
                local targetLoc = enemyHero:GetExtrapolatedLocation(eta)

                if GetUnitToUnitDistance(bot, enemyHero) < nCastRange * 0.5
                then
                    targetLoc = enemyHero:GetLocation()
                end

                if  not J.IsHeroBetweenMeAndTarget(bot, enemyHero, targetLoc, nRadius)
                and not J.IsCreepBetweenMeAndTarget(bot, enemyHero, targetLoc, nRadius)
                and not J.IsLocationInChrono(targetLoc)
                and not J.IsLocationInBlackHole(targetLoc)
                then
                    return BOT_ACTION_DESIRE_HIGH, targetLoc
                end
            end
        end
    end

	if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
        local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, true, 5)

        -- Sniper; etc
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)
        for _, enemyHero in pairs(nInRangeEnemy)
        do
            if  J.IsValidHero(enemyHero)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                local nTargetInRangeAlly = enemyHero:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

                if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
                and #nInRangeAlly >= #nTargetInRangeAlly
                and enemyHero:GetUnitName() == 'npc_dota_hero_sniper'
                then
                    local eta = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
                    local targetLoc = enemyHero:GetExtrapolatedLocation(eta)

                    if GetUnitToUnitDistance(bot, enemyHero) < nCastRange * 0.5
                    then
                        targetLoc = enemyHero:GetLocation()
                    end

                    if  not J.IsHeroBetweenMeAndTarget(bot, enemyHero, targetLoc, nRadius)
                    and not J.IsCreepBetweenMeAndTarget(bot, enemyHero, targetLoc, nRadius)
                    and not J.IsLocationInChrono(targetLoc)
                    and not J.IsLocationInBlackHole(targetLoc)
                    then
                        return BOT_ACTION_DESIRE_HIGH, targetLoc
                    end
                end
            end
        end

		if  J.IsValidTarget(strongestTarget)
		and not J.IsSuspiciousIllusion(strongestTarget)
        and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
		then
            local nTargetInRangeAlly = strongestTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                local eta = (GetUnitToUnitDistance(bot, strongestTarget) / nSpeed) + nCastPoint
                local targetLoc = strongestTarget:GetExtrapolatedLocation(eta)

                if  not J.IsHeroBetweenMeAndTarget(bot, strongestTarget, targetLoc, nRadius)
                and not J.IsCreepBetweenMeAndTarget(bot, strongestTarget, targetLoc, nRadius)
                and not J.IsLocationInChrono(targetLoc)
                and not J.IsLocationInBlackHole(targetLoc)
                then
                    if GetUnitToUnitDistance(bot, strongestTarget) < nCastRange * 0.5
                    then
                        targetLoc = strongestTarget:GetLocation()
                    end

                    return BOT_ACTION_DESIRE_HIGH, targetLoc
                end
            end
		end
	end

    if J.IsLaning(bot)
	then
		local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nCastRange, true)

		for _, creep in pairs(nEnemyLaneCreeps)
		do
			if  J.IsValid(creep)
            and J.CanBeAttacked(creep)
			and J.IsKeyWordUnit('siege', creep)
			and creep:GetHealth() <= nDamage
			then
				local nCreepInRangeHero = creep:GetNearbyHeroes(500, false, BOT_MODE_NONE)

				if  ((nCreepInRangeHero ~= nil and #nCreepInRangeHero >= 1)
                    or not J.IsInRange(bot, creep, bot:GetAttackRange() + 25))
                and not J.IsHeroBetweenMeAndTarget(bot, creep, creep:GetLocation(), nRadius)
                and not J.IsNonSiegeCreepBetweenMeAndLocation(bot, creep:GetLocation(), nRadius)
				then
					return BOT_ACTION_DESIRE_HIGH, creep:GetLocation()
				end
			end
		end

        local nInRangeTower = bot:GetNearbyTowers(700, false)
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  nInRangeTower ~= nil and #nInRangeTower >= 1
        and nInRangeEnemy ~= nil and #nInRangeEnemy >= 1
        and J.IsInRange(bot, nInRangeTower[1], 500)
        then
            local towerTarget = nInRangeTower[1]:GetAttackTarget()

            if towerTarget == nil
            then
                for _, enemyHero in pairs(nInRangeEnemy)
                do
                    if  J.IsValidHero(enemyHero)
                    and not J.IsSuspiciousIllusion(enemyHero)
                    and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
                    and not enemyHero:HasModifier('modifier_abaddon_aphotic_shield')
                    then
                        local eta = (GetUnitToUnitDistance(bot, enemyHero) / nSpeed) + nCastPoint
                        local targetLoc = enemyHero:GetExtrapolatedLocation(eta)

                        if GetUnitToUnitDistance(bot, enemyHero) < nCastRange * 0.5
                        then
                            targetLoc = enemyHero:GetLocation()
                        end

                        if  not J.IsHeroBetweenMeAndTarget(bot, enemyHero, targetLoc, nRadius)
                        and not J.IsCreepBetweenMeAndTarget(bot, enemyHero, targetLoc, nRadius)
                        then
                            return BOT_ACTION_DESIRE_HIGH, targetLoc
                        end
                    end
                end
            end
        end
	end

    local nAllyHeroes = bot:GetNearbyHeroes(nCastRange, false, BOT_MODE_NONE)
    for _, allyHero in pairs(nAllyHeroes)
    do
        if  J.IsValidHero(allyHero)
        and not allyHero:IsIllusion()
        and allyHero:HasModifier('modifier_enigma_black_hole_pull')
        and allyHero:HasModifier('modifier_faceless_void_chronosphere_freeze')
        and not J.IsHeroBetweenMeAndTarget(bot, allyHero, allyHero:GetLocation(), nRadius)
        and not J.IsCreepBetweenMeAndTarget(bot, allyHero, allyHero:GetLocation(), nRadius)
        then
            return BOT_ACTION_DESIRE_HIGH, allyHero:GetLocation()
        end

        local nAllyInRangeEnemy = allyHero:GetNearbyHeroes(nCastRange, true, BOT_MODE_NONE)

        if  J.IsValidHero(allyHero)
        and J.IsRetreating(allyHero)
        and allyHero:WasRecentlyDamagedByAnyHero(2.1)
        and not allyHero:IsIllusion()
        and J.GetMP(bot) > 0.31
        then
            if  nAllyInRangeEnemy ~= nil and #nAllyInRangeEnemy >= 1
            and J.IsValidHero(nAllyInRangeEnemy[1])
            and J.IsInRange(bot, nAllyInRangeEnemy[1], nCastRange * 0.5)
            and J.IsRunning(allyHero)
            and nAllyInRangeEnemy[1]:IsFacingLocation(allyHero:GetLocation(), 30)
            and GetUnitToLocationDistance(bot, J.GetEscapeLoc()) > GetUnitToLocationDistance(allyHero, J.GetEscapeLoc())
            and GetUnitToLocationDistance(bot, J.GetEscapeLoc()) - GetUnitToLocationDistance(allyHero, J.GetEscapeLoc()) > nCastRange * 0.5
            and not J.IsSuspiciousIllusion(nAllyInRangeEnemy[1])
            and not J.IsDisabled(nAllyInRangeEnemy[1])
            and not J.IsTaunted(nAllyInRangeEnemy[1])
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_enigma_black_hole_pull')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_faceless_void_chronosphere_freeze')
            and not nAllyInRangeEnemy[1]:HasModifier('modifier_necrolyte_reapers_scythe')
            and not J.IsHeroBetweenMeAndTarget(bot, allyHero, allyHero:GetLocation(), nRadius)
            and not J.IsCreepBetweenMeAndTarget(bot, allyHero, allyHero:GetLocation(), nRadius)
            then
                return BOT_ACTION_DESIRE_HIGH, allyHero:GetLocation()
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        and not J.IsHeroBetweenMeAndTarget(bot, botTarget, botTarget:GetLocation(), nRadius)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, 400)
        and J.IsAttacking(bot)
        and not J.IsHeroBetweenMeAndTarget(bot, botTarget, botTarget:GetLocation(), nRadius)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation()
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0
end

function X.ConsiderRot()
    if not Rot:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

	local nRadius = Rot:GetSpecialValueInt('rot_radius')
    local nEnemyHeroes = bot:GetNearbyHeroes(nRadius, true, BOT_MODE_NONE)
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
    then
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and (J.CanCastOnNonMagicImmune(enemyHero) or #nEnemyHeroes >= 2)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_dazzle_shallow_grave')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                if Rot:GetToggleState() == false
                then
                    return BOT_ACTION_DESIRE_HIGH
                else
                    return BOT_ACTION_DESIRE_NONE
                end
            end
        end
    end

    if J.IsRetreating(bot)
    then
        for _, enemyHero in pairs(nEnemyHeroes)
        do
            if  J.IsValidHero(enemyHero)
            and (J.CanCastOnNonMagicImmune(enemyHero) or #nEnemyHeroes >= 2)
            and not J.IsSuspiciousIllusion(enemyHero)
            and not enemyHero:HasModifier('modifier_abaddon_borrowed_time')
            and not enemyHero:HasModifier('modifier_necrolyte_reapers_scythe')
            then
                if Rot:GetToggleState() == false
                then
                    return BOT_ACTION_DESIRE_HIGH
                else
                    return BOT_ACTION_DESIRE_NONE
                end
            end
        end
    end

    if (J.IsPushing(bot) or J.IsDefending(bot))
    then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)

        if nEnemyLaneCreeps ~= nil
        then
            if  #nEnemyLaneCreeps >= 1
            and Rot:GetToggleState() == false
            and J.IsAttacking(bot)
            and J.GetHP(bot) > 0.2
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if  (#nEnemyLaneCreeps == 0 or J.GetHP(bot) < 0.2)
                and Rot:GetToggleState() == true
                then
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if J.IsFarming(bot)
    then
        local nNeutralCreeps = bot:GetNearbyNeutralCreeps(nRadius)
        if  nNeutralCreeps ~= nil
        then
            if  #nNeutralCreeps >= 1
            and Rot:GetToggleState() == false
            and J.IsAttacking(bot)
            and J.GetHP(bot) > 0.35
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if  (#nNeutralCreeps == 0 or J.GetHP(bot) < 0.35)
                and Rot:GetToggleState() == true
                then
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end

        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        if nEnemyLaneCreeps ~= nil
        then
            if  #nEnemyLaneCreeps >= 1
            and Rot:GetToggleState() == false
            and J.IsAttacking(bot)
            and J.GetHP(bot) > 0.2
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if  (#nEnemyLaneCreeps == 0 or J.GetHP(bot) < 0.2)
                and Rot:GetToggleState() == true
                then
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if J.IsLaning(bot)
	then
        local nEnemyLaneCreeps = bot:GetNearbyLaneCreeps(nRadius, true)
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if  nEnemyLaneCreeps ~= nil
        and nInRangeEnemy ~= nil and #nInRangeEnemy == 0
        then
            if  #nEnemyLaneCreeps >= 1
            and Rot:GetToggleState() == false
            and J.IsAttacking(bot)
            and J.GetHP(bot) > 0.5
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if  (#nEnemyLaneCreeps == 0 or J.GetHP(bot) < 0.5)
                and Rot:GetToggleState() == true
                then
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
	end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        and J.GetHP(bot) > 0.4
        then
            if  Rot:GetToggleState() == false
            and J.GetHP(bot) > 0.4
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if  J.GetHP(bot) < 0.4
                and Rot:GetToggleState() == true
                then
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if J.IsDoingTormentor(bot)
    then
        if  J.IsTormentor(botTarget)
        and J.IsInRange(bot, botTarget, nRadius)
        and J.IsAttacking(bot)
        then
            if Rot:GetToggleState() == false
            then
                return BOT_ACTION_DESIRE_HIGH
            else
                if  J.GetHP(bot) < 0.65
                and Rot:GetToggleState() == true
                then
                    return BOT_ACTION_DESIRE_HIGH
                end

                return BOT_ACTION_DESIRE_NONE
            end
        end
    end

    if Rot:GetToggleState() == true
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderFleshHeap()
    if not FleshHeap:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE
    end

    if bot:HasModifier('modifier_pudge_rot')
    then
        return BOT_ACTION_DESIRE_HIGH
    end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(1000, false, BOT_MODE_NONE)
        local nInRangeEnemy = bot:GetNearbyHeroes(1200, true, BOT_MODE_NONE)

        if  nInRangeAlly ~= nil and nInRangeEnemy ~= nil
        and J.IsValidHero(nInRangeEnemy[1])
        and J.IsRunning(nInRangeEnemy[1])
        and nInRangeEnemy[1]:IsFacingLocation(bot:GetLocation(), 30)
        and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
        and not J.IsDisabled(nInRangeEnemy[1])
        then
            local nTargetInRangeAlly = nInRangeEnemy[1]:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nTargetInRangeAlly ~= nil
            and ((#nTargetInRangeAlly > #nInRangeAlly)
                or (J.GetHP(bot) < 0.7 and bot:WasRecentlyDamagedByAnyHero(2.2)))
            then
                return BOT_ACTION_DESIRE_HIGH
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE
end

function X.ConsiderDismember()
    if not Dismember:IsFullyCastable()
    then
        return BOT_ACTION_DESIRE_NONE, nil
    end

    local nCastRange = J.GetProperCastRange(false, bot, Dismember:GetCastRange())
    local nAttributeStrength = bot:GetAttributeValue(ATTRIBUTE_STRENGTH)
    local nSTRMul = Dismember:GetSpecialValueFloat('strength_damage')
    local nDuration = Dismember:GetSpecialValueFloat('AbilityChannelTime')
    local nDamage = Dismember:GetSpecialValueInt('dismember_damage') + (nAttributeStrength * nSTRMul)
    local botTarget = J.GetProperTarget(bot)

    if J.IsGoingOnSomeone(bot)
	then
        local nInRangeAlly = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
        local strongestTarget = J.GetStrongestUnit(nCastRange, bot, true, true, 5)

		if  J.IsValidTarget(strongestTarget)
		and not J.IsSuspiciousIllusion(strongestTarget)
        and not strongestTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not strongestTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not strongestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not strongestTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nTargetInRangeAlly = strongestTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nInRangeAlly >= #nTargetInRangeAlly
            then
                return BOT_ACTION_DESIRE_HIGH, strongestTarget
            end
		end
	end

    if J.IsRetreating(bot)
    then
        local nInRangeAlly = bot:GetNearbyHeroes(1200, false, BOT_MODE_NONE)
        local weakestTarget = J.GetAttackableWeakestUnit(bot, nCastRange, true, true)

		if  J.IsValidTarget(weakestTarget)
		and not J.IsSuspiciousIllusion(weakestTarget)
        and not weakestTarget:HasModifier('modifier_abaddon_borrowed_time')
        and not weakestTarget:HasModifier('modifier_dazzle_shallow_grave')
        and not weakestTarget:HasModifier('modifier_necrolyte_reapers_scythe')
        and not weakestTarget:HasModifier('modifier_templar_assassin_refraction_absorb')
		then
            local nTargetInRangeAlly = weakestTarget:GetNearbyHeroes(1200, false, BOT_MODE_NONE)

            if  nInRangeAlly ~= nil and nTargetInRangeAlly ~= nil
            and #nTargetInRangeAlly > #nInRangeAlly
            and bot:WasRecentlyDamagedByAnyHero(2)
            then
                return BOT_ACTION_DESIRE_HIGH, weakestTarget
            end
		end
    end

    if J.IsInLaningPhase(bot)
    then
        local nInRangeEnemy = bot:GetNearbyHeroes(nCastRange + 100, true, BOT_MODE_NONE)
        local nInRangeTower = bot:GetNearbyTowers(700, true)

        if  nInRangeEnemy ~= nil and #nInRangeEnemy == 1
        and nInRangeTower ~= nil and #nInRangeTower == 0
        then
            if  J.IsValidHero(nInRangeEnemy[1])
            and J.WillKillTarget(nInRangeEnemy[1], nDamage, DAMAGE_TYPE_MAGICAL, nDuration)
            and not J.IsSuspiciousIllusion(nInRangeEnemy[1])
            and not nInRangeEnemy[1]:HasModifier('modifier_abaddon_borrowed_time')
            and not nInRangeEnemy[1]:HasModifier('modifier_dazzle_shallow_grave')
            and not nInRangeEnemy[1]:HasModifier('modifier_oracle_false_promise_timer')
            and not nInRangeEnemy[1]:HasModifier('modifier_templar_assassin_refraction_absorb')
            then
                return BOT_ACTION_DESIRE_HIGH, nInRangeEnemy[1]
            end
        end
    end

    if J.IsDoingRoshan(bot)
    then
        if  J.IsRoshan(botTarget)
        and J.CanCastOnNonMagicImmune(botTarget)
        and J.IsInRange(bot, botTarget, 500)
        and J.IsAttacking(bot)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget
        end
    end

    return BOT_ACTION_DESIRE_NONE, nil
end

return X