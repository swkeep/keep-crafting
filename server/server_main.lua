local QBCore = exports['qb-core']:GetCoreObject()

QBCore.Functions.CreateCallback('keep-crafting:server:get_player_information', function(source, cb)
     local player = QBCore.Functions.GetPlayer(source)
     cb({
          charinfo = player.PlayerData.charinfo,
          job = player.PlayerData.job,
          metadata = {
               craftingrep = player.PlayerData.metadata.craftingrep,
               dealerrep = player.PlayerData.metadata.dealerrep,
               jobrep = player.PlayerData.metadata.jobrep,
               licences = player.PlayerData.metadata.licences,
          }
     })
end)

RegisterNetEvent('keep-crafting:server:craft_item', function(data)
     local src = source
     StartCraftProcess(src, data)
end)

local function get_item_data_from_config(data)
     if Config.workbenches[data.id].recipes then
          for key, recipe in pairs(Config.workbenches[data.id].recipes) do
               if recipe[data.item.item_name] then
                    return recipe[data.item.item_name]
               end
          end
     end
     return nil
end

local function do_player_have_materials(src, Player, item_config)
     local total = 0
     local count = 0
     for k, v in pairs(item_config.crafting.materials) do
          total = total + 1
          local material = Player.Functions.GetItemByName(k)
          if material ~= nil and material.amount >= v then
               count = count + 1
          end
     end

     if total == count then
          return true
     end
     TriggerClientEvent('QBCore:Notify', src, 'You dont have enough materials', "error")
     return false
end

local function remove_item(src, Player, name, amount)
     Player.Functions.RemoveItem(name, amount)
     TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[name],
          "remove")
end

function StartCraftProcess(src, data)
     local Player = QBCore.Functions.GetPlayer(src)
     local item_config = get_item_data_from_config(data)
     local can_craft = false

     if item_config then
          can_craft = do_player_have_materials(src, Player, item_config)
          if not can_craft then return end

          for material_name, amount in pairs(item_config.crafting.materials) do
               if not Config.permanent_items[material_name] then
                    remove_item(src, Player, material_name, amount)
               end
          end
     end

     TriggerClientEvent("keep-crafting:client:start_crafting", src, data, item_config)
end

local function increase_exp(Player, exp)
     Player.Functions.SetMetaData("craftingrep", Player.PlayerData.metadata["craftingrep"] + exp)
end

RegisterServerEvent("keep-crafting:server:crafting_is_done", function(data)
     local src = source
     local Player = QBCore.Functions.GetPlayer(src)
     local item_config = get_item_data_from_config(data)
     if not item_config then return end

     local chance = math.random(0, 100)
     local SuccessRate = item_config.crafting.success_rate

     if not (SuccessRate >= chance) then
          TriggerClientEvent('QBCore:Notify', src, 'Crafting Failed! ^.^', 'error')
          return
     end

     increase_exp(Player, item_config.crafting.exp_per_craft)

     Player.Functions.AddItem(data.item.item_name, item_config.crafting.amount)
     TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[data.item.item_name], "add")
     TriggerClientEvent('QBCore:Notify', src, 'Successful assembly', 'success')
end)
