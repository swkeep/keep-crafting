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
     TriggerClientEvent('QBCore:Notify', src, Lang:t('error.need_more_mat'), "error")
     return false
end

local function remove_item(src, Player, name, amount)
     Player.Functions.RemoveItem(name, amount)
     TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[name], "remove")
end

local function is_job_allowed(Player, data, type)
     local condition = nil
     if type == 'job' then
          condition = Player.PlayerData.job
     else
          condition = Player.PlayerData.gang
     end
     local allowed_jobs = data.allowed_list
     local allowed_grades = data.allowed_grades

     if allowed_jobs == nil or #allowed_jobs == 0 then return true end
     for _, allowed_job in ipairs(allowed_jobs) do
          if allowed_job == condition.name then
               -- check player grade
               if not allowed_grades[condition.name] then
                    return true
               end
               if #allowed_grades[condition.name] == 0 then
                    return true
               else
                    for _, allowed_grade in ipairs(allowed_grades[condition.name]) do
                         if allowed_grade == condition.grade.level then
                              return true
                         end
                    end
               end
          end
     end
     return false
end

function StartCraftProcess(src, data)
     local Player = QBCore.Functions.GetPlayer(src)
     local item_config = get_item_data_from_config(data)
     local can_craft = false

     if item_config then
          if item_config.item_settings.level and
              not (Player.PlayerData.metadata.craftingrep >= item_config.item_settings.level) then
               TriggerClientEvent('QBCore:Notify', src, Lang:t('error.need_more_exp'), "error")
               return
          end

          local condition = nil
          if item_config.item_settings.job then
               condition = {
                    type = 'job',
                    data = item_config.item_settings.job
               }
          end
          if item_config.item_settings.gang then
               condition = {
                    type = 'gang',
                    data = item_config.item_settings.gang
               }
          end

          local restricted_by_job = is_job_allowed(Player, condition.data, condition.type)
          if not restricted_by_job then
               TriggerClientEvent('QBCore:Notify', src, Lang:t('error.crafting_is_restricted'), "error")
               return
          end

          can_craft = do_player_have_materials(src, Player, item_config)
          if not can_craft then return end

          for material_name, amount in pairs(item_config.crafting.materials) do
               if not Config.permanent_items[material_name] then
                    remove_item(src, Player, material_name, amount)
               end
          end

          TriggerClientEvent("keep-crafting:client:start_crafting", src, data, item_config)
          return
     end
     TriggerClientEvent('QBCore:Notify', src, Lang:t('error.crafting_failed'), "error")
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
          TriggerClientEvent('QBCore:Notify', src, Lang:t('error.crafting_failed'), 'error')
          return
     end

     increase_exp(Player, item_config.crafting.exp_per_craft)

     Player.Functions.AddItem(data.item.item_name, item_config.crafting.amount)
     TriggerClientEvent('qb-inventory:client:ItemBox', src, QBCore.Shared.Items[data.item.item_name], "add")
     TriggerClientEvent('QBCore:Notify', src, Lang:t('success.successful_crafting'), 'success')
end)


RegisterServerEvent('keep-crafting:check_materials_list', function(data)
     local Player = QBCore.Functions.GetPlayer(source)
     local item_config = get_item_data_from_config(data)
     local level = nil

     local gender = Lang:t('info.mr')
     if Player.PlayerData.charinfo.gender == 1 then
          gender = Lang:t('info.mrs')
     end
     local charinfo = Player.PlayerData.charinfo

     if item_config.crafting.show_level_in_mail then
          level = item_config.item_settings.level
          level = tostring(level)
     else
          level = nil
     end

     local condition = nil
     local restricted = false
     if item_config.item_settings.job then
          condition = {
               type = 'job',
               data = item_config.item_settings.job
          }
     end

     if item_config.item_settings.gang then
          condition = {
               type = 'gang',
               data = item_config.item_settings.gang
          }
     end

     if (item_config.item_settings.gang or item_config.item_settings.job) then
          restricted = not is_job_allowed(Player, condition.data, condition.type)
     end

     if condition == nil then restricted = false end

     if item_config then
          TriggerClientEvent('keep-crafting:client:local_mailer', source, {
               gender = gender,
               charinfo = charinfo,
               item_name = data.item.item_settings.label,
               materials = item_config.crafting.materials,
               success_rate = item_config.crafting.success_rate,
               restricted = restricted,
               level = level
          })
     end

end)
