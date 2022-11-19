local CustomChallenge = {}
local EntityData = require("MoChallenges.Utility.EntityData")

local challengeId = Isaac.GetChallengeIdByName("Heretic")
local rebound = Isaac.GetItemIdByName("Holy Rebound")
local floorCount = 0
local currentFloor = nil

function CustomChallenge:NewFloor()
    if Isaac.GetChallenge() == challengeId then
        floorCount = floorCount + 1
        currentFloor = nil
        for _, entity in ipairs(Isaac.FindByType(EntityType.ENTITY_DARK_ESAU)) do
            entity:Remove()
        end
    end
end

function CustomChallenge:GameStart(continued)
    if not continued then
    
        floorCount = 0
        currentFloor = nil
    end
end

---@param player EntityPlayer
function CustomChallenge:UseItem(_, _, player, _, activeSlot)
    if activeSlot ~= -1 and Isaac.GetChallenge() == challengeId then
        for _ = 0, floorCount do
            ---@diagnostic disable-next-line: param-type-mismatch
            player:UseActiveItem(CollectibleType.COLLECTIBLE_ANIMA_SOLA, 0, -1)
        end
    end
end

---@param effect EntityEffect
function CustomChallenge:EntityKill(effect)
    if effect.Variant == EffectVariant.ANIMA_CHAIN and Isaac.GetChallenge() == challengeId then -- remove them all
        local chains = Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.ANIMA_SOLA)
        if #chains ~= 0 then
            for i, effect in ipairs(chains) do
                print(i)
                effect:Die()
            end
        end
    end
end

---@param player EntityPlayer
function CustomChallenge:CharacterInit(player)
    if Isaac.GetChallenge() == challengeId then
        player:RemoveCollectible(CollectibleType.COLLECTIBLE_ANIMA_SOLA, true, ActiveSlot.SLOT_POCKET)
        player:SetPocketActiveItem(rebound, ActiveSlot.SLOT_POCKET, false)
    end
end

---@param npc EntityNPC
function CustomChallenge:EnemyInit(npc)
    if Isaac.GetChallenge() == challengeId then
        if currentFloor == nil then
            currentFloor = true
            for _ = 0, floorCount do
                Isaac.Spawn(EntityType.ENTITY_DARK_ESAU, 0, 0, npc.Position, Vector(0, 0), npc)
            end
        end
    end
end

---@param esau EntityNPC
function CustomChallenge:EsauUpdate(esau)
    if esau.State == NpcState.STATE_ATTACK2 and Isaac.GetChallenge() == challengeId then -- dashing
        esau.Velocity = esau.Velocity * 0.9
    end
end

return function (MoChallenges)
    MoChallenges:AddCallback(ModCallbacks.MC_POST_NEW_LEVEL, CustomChallenge.NewFloor)
    MoChallenges:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, CustomChallenge.GameStart)
    MoChallenges:AddCallback(ModCallbacks.MC_POST_NPC_INIT, CustomChallenge.EnemyInit, EntityType.ENTITY_DARK_ESAU)
    MoChallenges:AddCallback(ModCallbacks.MC_USE_ITEM, CustomChallenge.UseItem, CollectibleType.COLLECTIBLE_ANIMA_SOLA)
    MoChallenges:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, CustomChallenge.CharacterInit, PlayerType.PLAYER_JACOB_B)
    MoChallenges:AddCallback(ModCallbacks.MC_NPC_UPDATE, CustomChallenge.EsauUpdate, EntityType.ENTITY_DARK_ESAU)
    MoChallenges:AddCallback(ModCallbacks.MC_POST_ENTITY_REMOVE, CustomChallenge.EntityKill, EntityType.ENTITY_EFFECT)
end