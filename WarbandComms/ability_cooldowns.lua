function WarbandComms.InitAbilityCooldownHook()
	WarbandComms.__ActionButton_UpdateCooldownAnimation = ActionButton.UpdateCooldownAnimation
	ActionButton.UpdateCooldownAnimation = WarbandComms.OnAbilityUpdate
end

function WarbandComms.OnAbilityUpdate( ... )
	local self = ...
	local initialMaxCooldown = self.m_MaxCooldown
    -- Call the original function
	WarbandComms.__ActionButton_UpdateCooldownAnimation( ... )
	-- Perform the ability update
	WarbandComms.PerformAbilityUpdate( self.m_ActionId, self.m_Cooldown, initialMaxCooldown, self.m_MaxCooldown )
end

function WarbandComms.PerformAbilityUpdate( abilityId, cooldown, initialMaxCooldown, currentMaxCooldown )
    local ability = WarbandComms.trackedAbilities[abilityId]
    if not ability then return end

    local tracker = ability.tracker
    local enabled = WarbandComms.Settings[tracker]
    if not enabled then return end

    WarbandComms.Cooldowns[abilityId] = {
        currentCooldown = cooldown,
        maxCooldown = currentMaxCooldown,
    }
end