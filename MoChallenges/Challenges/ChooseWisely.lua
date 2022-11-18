local CustomChallenge = {}

local challengeId = Isaac.GetChallengeIdByName("Choose wisely")
local EntityData = require("MoChallenges.Utility.EntityData")
local deathCertificateUsed = false
local itemPickedUpAfterDeathCertificate = false

function CustomChallenge:ItemUsed()
    deathCertificateUsed = true
end

---@param pickup EntityPickup
function CustomChallenge:PickupInit(pickup)
    if pickup.Variant == PickupVariant.PICKUP_COLLECTIBLE then
        if Isaac.GetChallenge() == challengeId then
            if not deathCertificateUsed or (deathCertificateUsed and itemPickedUpAfterDeathCertificate) then
                pickup:Remove()
            end
        end
    end
end

function CustomChallenge:NewGame(isContinuedGame)
    if not isContinuedGame then
        deathCertificateUsed = false
        itemPickedUpAfterDeathCertificate = false
    end
end

---@param player EntityPlayer
function CustomChallenge:PostPeffectUpdate(player)
    if Isaac.GetChallenge() ~= challengeId then
        return
    end

    EntityData:GetEntityData(player).QueuedItem = player.QueuedItem.Item or EntityData:GetEntityData(player).QueuedItem

    if itemPickedUpAfterDeathCertificate and not player:IsItemQueueEmpty() or not EntityData:GetEntityData(player).QueuedItem then
        return
    end

    if Isaac.GetChallenge() == challengeId then
        if deathCertificateUsed and not itemPickedUpAfterDeathCertificate then
            itemPickedUpAfterDeathCertificate = true
        end
    end
end

return function (MoChallenges)
    MoChallenges:AddCallback(ModCallbacks.MC_POST_PICKUP_UPDATE, CustomChallenge.PickupInit)
    MoChallenges:AddCallback(ModCallbacks.MC_USE_ITEM, CustomChallenge.ItemUsed, CollectibleType.COLLECTIBLE_DEATH_CERTIFICATE)
    MoChallenges:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, CustomChallenge.PostPeffectUpdate)
    MoChallenges:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, CustomChallenge.NewGame)
end