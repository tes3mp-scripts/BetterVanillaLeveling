local Leveling = {}

Leveling.scriptName = "BetterVanillaLeveling"

Leveling.defaultConfig = {
    attributeModifier = 3,
    luckModifier = 1,
    levelCap = 100,
    healthScale = {
        enabled = true,
        enduranceModifier = 1.5,
        strengthModifier = 0.2,
        levelModifier = 1.5
    },
    progression = {
        enabled = false,
        threshold = 10,
        attributePoints = 1,
        message = "#FFD700Rigorous training has improved your %s by %d!\n",
        showInChat = false
    }
}

Leveling.config = DataManager.loadConfiguration(Leveling.scriptName, Leveling.defaultConfig)

Leveling.ENDURANCE = tes3mp.GetAttributeId("Endurance")
Leveling.STRENGTH = tes3mp.GetAttributeId("Strength")

Leveling.modifierToSkillIncrease = {0, 1, 5, 8, 10}

function Leveling.updateSkillIncrease()
    Leveling.skillIncrease = {}
    for id = 0, 6 do
        Leveling.skillIncrease[id] = 
            Leveling.modifierToSkillIncrease[Leveling.config.attributeModifier]
    end

    Leveling.skillIncrease[7] = 
            Leveling.modifierToSkillIncrease[Leveling.config.luckModifier]
end

Leveling.updateSkillIncrease()


function Leveling.increaseAttribute(pid, id, value)
    local name = tes3mp.GetAttributeName(id)
    Players[pid].data.attributes[name] = Players[pid].data.attributes[name] + value
    Players[pid]:LoadAttributes()
end

function Leveling.progression(pid)
    if not Leveling.config.progression.enabled then
        return
    end
    local player = Players[pid]
    local progress = player.data.customVariables.levelingProgression

    if progress == nil then
        progress = {}
        for id = 0, 7 do
            progress[id] = 0
        end

        player.data.customVariables.levelingProgression = progress
    end

    local attributesChanged = false

    for id = 0, 7 do
        progress[id] = progress[id] + math.max(tes3mp.GetSkillIncrease(pid, id) - Leveling.skillIncrease[id], 0)

        if progress[id] >= Leveling.config.progression.threshold then
            progress[id] = progress[id] - Leveling.config.progression.threshold

            local s = string.format(
                Leveling.config.progression.message,
                tes3mp.GetAttributeName(id),
                Leveling.config.progression.attributePoints
            )

            if Leveling.config.progress.showInChat then
                tes3mp.SendMessage(pid, s)
            else
                tes3mp.MessageBox(pid, -1, s)
            end

            if id == Leveling.STRENGTH or id == Leveling.ENDURANCE then
                attributesChanged = true
            end
            Leveling.increaseAttribute(pid, id, Leveling.config.progression.attributePoints)
        end
    end

    if attributesChanged then
        Leveling.scaleBaseHealth(pid)
    end
end

function Leveling.resetSkillIncreases(pid)
    local name = nil
    for id = 0, 7 do
        name = tes3mp.GetAttributeName(id)
        Players[pid].data.attributes[name].skillIncrease = Leveling.skillIncrease[id]
        tes3mp.SetSkillIncrease(pid, id, Leveling.skillIncrease[id])
        tes3mp.SendAttributes(pid)
    end
end

function Leveling.applyLevelCap(pid)
    local level = tes3mp.GetLevel(pid)
    if level >= Leveling.config.levelCap then
        tes3mp.SetLevelProgress(pid, 0)
        tes3mp.SendLevel(pid)
        Players[pid].data.stats.levelProgress = 0
    end
end

function Leveling.scaleBaseHealth(pid)
    if not Leveling.config.healthScale.enabled then
        return
    end
    local endurance = tes3mp.GetAttributeBase(pid, Leveling.ENDURANCE)
    local strength = tes3mp.GetAttributeBase(pid, Leveling.STRENGTH)
    local level = tes3mp.GetLevel(pid)
    local health = level * Leveling.config.healthScale.levelModifier +
        endurance * Leveling.config.healthScale.enduranceModifier +
        strength * Leveling.config.healthScale.strengthModifier

    local relativeHealth = tes3mp.GetHealthCurrent(pid) / tes3mp.GetHealthBase(pid)
    if relativeHealth <= 1 then
        tes3mp.SetHealthCurrent(pid, relativeHealth * health)
        tes3mp.SendStatsDynamic(pid)
    end
    
    Players[pid]:SetHealthBase(health)
end


function Leveling.OnPlayerSkill(eventStatus, pid)
    if eventStatus.validCustomHandlers then
        --Leveling.progression(pid)
        --[[Leveling.resetSkillIncreases(pid)
        if Leveling.config.levelCap < 100 then
            Leveling.applyLevelCap(pid)
        end]]
    end
end

function Leveling.OnPlayerLevel(eventStatus, pid)
    if eventStatus.validCustomHandlers then
        Leveling.progression(pid)
        Leveling.resetSkillIncreases(pid)
        Leveling.scaleBaseHealth(pid)
    end
end

function Leveling.OnPlayerAuthentified(eventStatus, pid)
    if eventStatus.validCustomHandlers then
        Leveling.scaleBaseHealth(pid)
        Leveling.resetSkillIncreases(pid)
    end
end


customEventHooks.registerHandler("OnPlayerSkill", Leveling.OnPlayerSkill)
customEventHooks.registerHandler("OnPlayerLevel", Leveling.OnPlayerLevel)
customEventHooks.registerHandler("OnPlayerAuthentified", Leveling.OnPlayerAuthentified)
