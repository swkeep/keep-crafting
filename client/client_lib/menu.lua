------------------
--   Const
local QBCore = exports['qb-core']:GetCoreObject()

--   Variable
local PlayerJob = nil
local PlayerGang = nil
local PlayerBlueprints = {}
local menu = {}
local QbMenu = {}
Workbench = nil
------------------
function Open_menu()
     if Config.menu == 'keep-menu' then
          menu:main_categories()
          return
     end
     QbMenu:main_categories()
end

------------------
--   functions
------------------

local function updatePlayerBluePrints()
     QBCore.Functions.TriggerCallback('keep-crafting:server:get_player_blueprints', function(result)
          PlayerBlueprints = result
     end)
end

local function updatePlayerJob()
     repeat
          Wait(10)
     until QBCore.Functions.GetPlayerData().job ~= nil
     PlayerJob = QBCore.Functions.GetPlayerData().job
     PlayerGang = QBCore.Functions.GetPlayerData().gang
end

local function isJobAllowed(list, type)
     -- check player job
     if not list then return end
     updatePlayerJob()

     local condition = nil
     if type == 'job' then
          condition = PlayerJob
     else
          condition = PlayerGang
     end

     if #list.allowed_list == 0 then return true end

     for _, allowed_job in ipairs(list.allowed_list) do
          if allowed_job == condition.name then
               -- check player grade
               if not list.allowed_grades[condition.name] then
                    return true
               end
               if #list.allowed_grades[condition.name] == 0 then
                    return true
               else
                    for _, allowed_grades in ipairs(list.allowed_grades[condition.name]) do
                         if allowed_grades == condition.grade.level then
                              return true
                         end
                    end
               end
          end
     end
     return false
end

function GetClosest_Workbenches()
     updatePlayerBluePrints()
     local ped = PlayerPedId()
     local playercoords = GetEntityCoords(ped)
     local benches = Config.workbenches

     for _, v in ipairs(benches) do
          local distance = #(playercoords - v.coords)
          if distance < 2.6 then

               if isJobAllowed(v.gang, 'gang') or isJobAllowed(v.job, 'job') then
                    v.id = _
                    return true, v
               else
                    QBCore.Functions.Notify(Lang:t('error.not_authorized'), 'error')
                    return false
               end

          end
     end
     return false
end

local function search_for_items_in_category(category)
     if category == 'blueprints' then
          return PlayerBlueprints
     end
     local tmp = {}
     for key, recipe in pairs(Workbench.recipes) do
          for k, item in pairs(recipe) do
               if not item.categories.sub and item.categories.main and item.categories.main == category then
                    tmp[k] = item
               end
               if not item.categories.main and item.categories.sub and item.categories.sub == category then
                    tmp[k] = item
               end
          end
     end
     return tmp
end

------------------
--   keep-Menu
------------------

function menu:main_categories()
     -- workbench.recipes.categories
     if Workbench == nil then return end
     local Menu = {}
     Menu[#Menu + 1] = {
          header = Lang:t('menu.main_menu_header'),
          icon = 'fa-solid fa-wrench',
          disabled = true
     }
     for key, category in pairs(Workbench.categories) do
          -- main menu + sub menu ref
          if category.sub_categories then
               Menu[#Menu + 1] = {
                    header = category.label,
                    icon = category.icon or 'fa-solid fa-caret-right',
                    submenu = true,
                    args = {
                         category.sub_categories
                    },
                    action = function(args)
                         menu:sub_categories(args)
                    end
               }
          else
               Menu[#Menu + 1] = {
                    header = category.label,
                    icon = category.icon or 'fa-solid fa-caret-right',
                    submenu = true,
                    args = {
                         category.key, 'main'
                    },
                    action = function(arg)
                         menu:crafting_items_list(arg)
                    end
               }
          end
     end

     Menu[#Menu + 1] = {
          header = Lang:t('menu.player_crafting_information'),
          icon = 'fa-solid fa-circle-info',
          args = { 1 },
          action = function()
               menu:player_crafting_information()
          end
     }

     Menu[#Menu + 1] = {
          header = Lang:t('menu.leave'),
          event = "keep-menu:closeMenu",
          leave = true
     }

     exports['keep-menu']:createMenu(Menu)
end

function menu:player_crafting_information()
     QBCore.Functions.TriggerCallback('keep-crafting:server:get_player_information', function(result)
          local job_sub = Lang:t("menu.job_sub")
          job_sub = string.format(job_sub, result.job.name, result.job.grade.name)
          local Menu = {
               {
                    header = Lang:t("menu.back"),
                    back = true,
                    args = { 1 },
                    action = function()
                         menu:main_categories()
                    end
               },
               {
                    header = Lang:t('menu.your_name'),
                    subheader = result.charinfo.firstname .. ' ' .. result.charinfo.lastname,
                    icon = 'fa-solid fa-list-ol',
                    disabled = true
               },
               {
                    header = Lang:t('menu.your_job'),
                    subheader = job_sub,
                    icon = 'fa-solid fa-list-ol',
                    disabled = true
               },
               {
                    header = Lang:t('menu.crafting_exp'),
                    subheader = tostring(result.metadata.craftingrep),
                    icon = 'fa-solid fa-list-ol',
                    disabled = true
               },
               {
                    header = Lang:t('menu.leave'),
                    event = "keep-menu:closeMenu",
                    leave = true
               }
          }
          exports['keep-menu']:createMenu(Menu)
     end)
end

function menu:sub_categories(args)
     -- args[1] is data used by current menu
     -- args[2] is previous menu cached data (make possible to go back in menus)
     local Menu = {}
     Menu[#Menu + 1] = {
          header = Lang:t("menu.back"),
          back = true,
          args = { 1 },
          action = function()
               menu:main_categories()
          end
     }

     for key, sub in pairs(args[1]) do
          Menu[#Menu + 1] = {
               header = sub.label,
               icon = 'fa-solid fa-gun',
               submenu = true,
               args = {
                    key, args
               },
               action = function(arg)
                    menu:crafting_items_list(arg)
               end
          }
     end

     Menu[#Menu + 1] = {
          header = Lang:t('menu.leave'),
          event = "keep-menu:closeMenu",
          leave = true
     }

     exports["keep-menu"]:createMenu(Menu)
end

function menu:crafting_items_list(data)
     local items = search_for_items_in_category(data[1])
     local craftingrep = QBCore.Functions.GetPlayerData().metadata.craftingrep
     local Menu = {}
     if type(data[2]) == "table" then
          Menu[#Menu + 1] = {
               header = Lang:t("menu.back"),
               back = true,
               action = function()
                    menu:sub_categories(data[2])
               end
          }
     elseif data[2] == 'main' then
          Menu[#Menu + 1] = {
               header = Lang:t("menu.back"),
               back = true,
               action = function()
                    menu:main_categories()
               end
          }
     end

     for item_name, item in pairs(items) do
          if not item.item_name then
               item.item_name = item_name -- inject item name into item's data
          end

          -- hide if we set it to hide when players has not reached the level/exp
          if item.item_settings.hide_until_reaches_level then
               if craftingrep >= item.item_settings.level then
                    Menu[#Menu + 1] = {
                         header = item.item_settings.label or item.item_name,
                         subheader = item.blueprint_id and 'Serial: ' .. item.blueprint_id,
                         icon = item.item_settings.icon or 'fa-solid fa-caret-right',
                         submenu = true,
                         image = item.item_settings.image or nil,
                         action = function()
                              menu:crafting_menu(item, data)
                         end
                    }
               end
          else
               Menu[#Menu + 1] = {
                    header = item.item_settings.label or item.item_name,
                    subheader = item.blueprint_id and 'Serial: ' .. item.blueprint_id,
                    icon = item.item_settings.icon or 'fa-solid fa-caret-right',
                    submenu = true,
                    image = item.item_settings.image or nil,
                    action = function()
                         menu:crafting_menu(item, data)
                    end
               }
          end
     end

     Menu[#Menu + 1] = {
          header = Lang:t('menu.leave'),
          leave = true
     }

     exports["keep-menu"]:createMenu(Menu)
end

function menu:crafting_menu(item, data)
     local entity, box, cam

     if item.item_settings.object and next(item.item_settings.object) then
          entity, box, cam = SpawnAndCameraWrapper(item.item_settings.object, Workbench.coords, Workbench.rotation, Workbench.item_show_case_offset)
     end

     local Menu = {
          {
               header = Lang:t("menu.back"),
               back = true,
               action = function()
                    menu:crafting_items_list(data)
               end
          },
          {
               header = Lang:t('menu.item_name'),
               subheader = item.item_settings.label,
               icon = 'fa-solid fa-list-ol',
               disabled = true
          },
          {
               header = Lang:t('menu.craft'),
               subheader = 'craft current item',
               icon = 'fa-solid fa-pen-ruler',
               action = function()
                    TriggerServerEvent('keep-crafting:server:craft_item', {
                         type = 'sell',
                         item_name = item.item_name,
                         blueprint_id = item.blueprint_id or nil,
                         id = Workbench.id
                    })
               end
          },
          {
               header = Lang:t('menu.check_mat_list'),
               subheader = 'check inventory for required materials',
               icon = 'fa-solid fa-clipboard-check',
               action = function()
                    TriggerServerEvent('keep-crafting:check_materials_list', {
                         type = 'sell',
                         item = item,
                         id = Workbench.id
                    })
               end
          },
          {
               header = Lang:t('menu.leave'),
               leave = true
          }
     }

     exports["keep-menu"]:createMenu(Menu)
     if item.item_settings.object and next(item.item_settings.object) then
          if entity and box and cam then
               SpawnAndCameraRemover(entity, box, cam)
          end
     end
end

------------------
--    qb-menu
------------------

function QbMenu:main_categories()
     -- workbench.recipes.categories
     if Workbench == nil then return end
     local Menu = {}
     Menu[#Menu + 1] = {
          header = Lang:t('menu.main_menu_header'),
          icon = 'fa-solid fa-wrench',
          disabled = true
     }

     for key, category in pairs(Workbench.categories) do
          -- main menu + sub menu ref
          if category.sub_categories then
               Menu[#Menu + 1] = {
                    header = category.label,
                    icon = category.icon or 'fa-solid fa-caret-right',
                    params = {
                         args = {
                              category.sub_categories
                         },
                         event = 'keep-crafting:client_lib:sub_categories'
                    }
               }
          else
               Menu[#Menu + 1] = {
                    header = category.label,
                    icon = category.icon or 'fa-solid fa-caret-right',
                    params = {
                         args = {
                              category.key, 'main'
                         },
                         event = 'keep-crafting:client_lib:crafting_items_list'
                    }
               }
          end
     end

     Menu[#Menu + 1] = {
          header = Lang:t('menu.player_crafting_information'),
          icon = 'fa-solid fa-circle-info',
          params = {
               event = 'keep-crafting:client_lib:player_crafting_information'
          },
     }

     Menu[#Menu + 1] = {
          header = Lang:t('menu.leave'),
          icon = 'fa-solid fa-circle-xmark',
          params = {
               event = "qb-menu:closeMenu",
          },
     }

     exports['qb-menu']:openMenu(Menu)
end

function QbMenu:player_crafting_information()
     QBCore.Functions.TriggerCallback('keep-crafting:server:get_player_information', function(result)
          local job_sub = Lang:t("menu.job_sub")
          job_sub = string.format(job_sub, result.job.name, result.job.grade.name)
          local Menu = {
               {
                    header = Lang:t("menu.back"),
                    params = {
                         event = 'keep-crafting:client_lib:main_categories'
                    }
               },
               {
                    header = Lang:t('menu.your_name'),
                    txt = result.charinfo.firstname .. ' ' .. result.charinfo.lastname,
                    icon = 'fa-solid fa-list-ol',
                    disabled = true
               },
               {
                    header = Lang:t('menu.your_job'),
                    txt = job_sub,
                    icon = 'fa-solid fa-list-ol',
                    disabled = true
               },
               {
                    header = Lang:t('menu.crafting_exp'),
                    txt = tostring(result.metadata.craftingrep),
                    icon = 'fa-solid fa-list-ol',
                    disabled = true
               },
               {
                    header = Lang:t('menu.leave'),
                    icon = 'fa-solid fa-circle-xmark',
                    params = {
                         event = "qb-menu:closeMenu",
                    },
               }
          }
          exports['qb-menu']:openMenu(Menu)
     end)
end

function QbMenu:sub_categories(args)
     -- args[1] is data used by current menu
     -- args[2] is previous menu cached data (make possible to go back in menus)
     local Menu = {}
     Menu[#Menu + 1] = {
          header = Lang:t("menu.back"),
          icon = 'fa-solid fa-angle-left',
          params = {
               event = 'keep-crafting:client_lib:main_categories'
          }
     }

     for key, sub in pairs(args[1]) do
          Menu[#Menu + 1] = {
               header = sub.label,
               icon = 'fa-solid fa-gun',
               params = {
                    args = {
                         key, args
                    },
                    event = 'keep-crafting:client_lib:crafting_items_list'
               }
          }
     end

     Menu[#Menu + 1] = {
          header = Lang:t('menu.leave'),
          params = {
               event = 'qb-menu:closeMenu'
          }
     }

     exports["qb-menu"]:openMenu(Menu)
end

function QbMenu:crafting_items_list(data)
     local items = search_for_items_in_category(data[1])
     local craftingrep = QBCore.Functions.GetPlayerData().metadata.craftingrep
     local Menu = {}

     if type(data[2]) == "table" then
          Menu[#Menu + 1] = {
               header = Lang:t("menu.back"),
               icon = 'fa-solid fa-angle-left',
               params = {
                    args = data[2],
                    event = 'keep-crafting:client_lib:sub_categories'
               }
          }
     elseif data[2] == 'main' then
          Menu[#Menu + 1] = {
               header = Lang:t("menu.back"),
               icon = 'fa-solid fa-angle-left',
               params = {
                    event = 'keep-crafting:client_lib:main_categories'
               }
          }
     end

     for item_name, item in pairs(items) do
          if item.blueprint_id then
               item_name = item.item_name
               item.item_name = item_name
          else
               item.item_name = item_name
          end
          if item.item_settings.hide_until_reaches_level then
               if craftingrep >= item.item_settings.level then
                    Menu[#Menu + 1] = {
                         header = item.item_settings.label or item_name,
                         icon = item.item_settings.icon or 'fa-solid fa-caret-right',
                         params = {
                              args = {
                                   item, data
                              },
                              event = 'keep-crafting:client_lib:crafting_menu'
                         }
                    }
               end
          else
               Menu[#Menu + 1] = {
                    header = item.item_settings.label or item_name,
                    icon = item.item_settings.icon or 'fa-solid fa-caret-right',
                    params = {
                         args = {
                              item, data
                         },
                         event = 'keep-crafting:client_lib:crafting_menu'
                    }
               }
          end
     end

     Menu[#Menu + 1] = {
          header = Lang:t('menu.leave'),
          icon = 'fa-solid fa-circle-xmark',
          params = {
               event = 'qb-menu:closeMenu'
          }
     }

     exports["qb-menu"]:openMenu(Menu)
end

local nui_traker = false

function QbMenu:crafting_menu(args)
     local item = args[1]
     local entity, box, cam
     local obj = item.item_settings.object

     local w_coord = Workbench.coords
     local w_rotation = Workbench.rotation
     local w_offset = Workbench.item_show_case_offset

     nui_traker = false

     if obj and next(obj) then
          entity, box, cam = SpawnAndCameraWrapper(obj, w_coord, w_rotation, w_offset)
     end

     local Menu = {
          {
               header = Lang:t("menu.back"),
               icon = 'fa-solid fa-angle-left',
               params = {
                    args = args[2],
                    event = 'keep-crafting:client_lib:crafting_items_list',
               }
          },
          {
               header = Lang:t('menu.item_name'),
               txt = item.item_settings.label,
               icon = 'fa-solid fa-list-ol',
               disabled = true
          },
          {
               header = Lang:t('menu.craft'),
               txt = 'craft current item',
               icon = 'fa-solid fa-pen-ruler',
               params = {
                    args     = {
                         type = 'sell',
                         item_name = item.item_name,
                         blueprint_id = item.blueprint_id or nil,
                         id = Workbench.id
                    },
                    event    = 'keep-crafting:server:craft_item',
                    isServer = true
               }
          },
          {
               header = Lang:t('menu.check_mat_list'),
               txt = 'check inventory for required materials',
               icon = 'fa-solid fa-clipboard-check',
               params = {
                    args = { 'sell', item, Workbench.id },
                    event = 'keep-crafting:client_lib:check_materials_list'
               }
          },
          {
               header = Lang:t('menu.leave'),
               icon = 'fa-solid fa-circle-xmark',
               params = {
                    event = 'qb-menu:closeMenu'
               }
          }
     }

     exports["qb-menu"]:openMenu(Menu)

     NUI_tracker(item, entity, box, cam)
end

function NUI_tracker(item, entity, box, cam)
     repeat Wait(50) until (IsNuiFocused() == false or nui_traker == true)
     if item.item_settings.object and next(item.item_settings.object) then
          if entity and box and cam then
               SpawnAndCameraRemover(entity, box, cam)
          end
     end
end

------------------------
--    qb-menu events
------------------------

AddEventHandler('keep-crafting:client_lib:main_categories', function()
     Open_menu()
end)

AddEventHandler('keep-crafting:client_lib:sub_categories', function(args)
     QbMenu:sub_categories(args)
end)

AddEventHandler('keep-crafting:client_lib:player_crafting_information', function(args)
     QbMenu:player_crafting_information()
end)

AddEventHandler('keep-crafting:client_lib:crafting_items_list', function(args)
     nui_traker = true
     QbMenu:crafting_items_list(args)
end)

AddEventHandler('keep-crafting:client_lib:crafting_menu', function(args)
     QbMenu:crafting_menu(args)
end)

-- crafting_menu
AddEventHandler('keep-crafting:client_lib:check_materials_list', function(args)
     TriggerServerEvent('keep-crafting:check_materials_list', { type = args[1], item = args[2], id = args[3] })
end)

------------------
--    Events
------------------

RegisterKeyMapping('+crafting_menu', 'crafting_menu', 'keyboard', 'e')
RegisterCommand('+crafting_menu', function()
     local state, workbench = GetClosest_Workbenches()
     if not IsPauseMenuActive() and state then
          Workbench = workbench
          menu:main_categories()
          return
     end
end, false)
