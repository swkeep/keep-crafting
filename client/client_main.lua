local QBCore = exports['qb-core']:GetCoreObject()
local benches_entites = {}
local loaded = false

local spawn_bench = function(model, coord, rotation)
     model = model or Config.workbench_default_model
     local modelHash = GetHashKey(model)

     if not HasModelLoaded(modelHash) then
          RequestModel(modelHash)
          while not HasModelLoaded(modelHash) do
               Wait(10)
          end
     end
     local entity = CreateObject(modelHash, coord, false)
     SetEntityAsMissionEntity(entity, true, true)
     while not DoesEntityExist(entity) do Wait(10) end
     SetEntityRotation(entity, rotation, 0.0, true)
     FreezeEntityPosition(entity, true)
     SetEntityProofs(entity, 1, 1, 1, 1, 1, 1, 1, 1)

     exports['qb-target']:AddTargetEntity(entity, {
          options = { {
               icon = "fas fa-sack-dollar",
               label = "Craft",
               action = function(entity)
                    local state, workbench = GetClosest_Workbenches()
                    Workbench = workbench
                    Open_menu()
                    return true
               end
          }
          },
          distance = 1.5
     })

     return entity
end

function Load_tables()
     if loaded then return end
     CreateThread(function()
          for key, value in pairs(Config.workbenches) do
               benches_entites[#benches_entites + 1] = spawn_bench(value.table_model, value.coords, value.rotation)
          end
          loaded = true
     end)
end

local spawn_object = function(model, position)
     local coord = position.coord
     local modelHash = GetHashKey(model)
     local table_offset = position.offset or vector3(0.15, 0.0, 2.45)
     local timer = 0
     local timeout = Config.model_loading.timeout
     local wait_timer = Config.model_loading.dealy
     if not HasModelLoaded(modelHash) then
          RequestModel(modelHash)
          while not HasModelLoaded(modelHash) do
               Wait(wait_timer)
               timer = timer + wait_timer
               if timer >= timeout then
                    break
               end
          end
     end

     if not HasModelLoaded(modelHash) then
          return nil, nil
     end

     local entity = CreateObject(modelHash, coord.x + table_offset.x, coord.y + table_offset.y, coord.z + table_offset.z
          , 0,
          0, 0)

     while not DoesEntityExist(entity) do Wait(10) end
     SetEntityRotation(entity, position.object_rotation, 0.0, true)
     FreezeEntityPosition(entity, true)
     SetEntityProofs(entity, 1, 1, 1, 1, 1, 1, 1, 1)
     local tmp_vec = vector3(coord.x + table_offset.x, coord.y + table_offset.y, coord.z + table_offset.z)
     local box = BoxZone:Create(tmp_vec, 1, 1, {
          name = "object_" .. entity,
          heading = 45,
          minZ = coord.z + table_offset.z - 0.4,
          maxZ = coord.z + table_offset.z + 0.4,
          scale = { 1.0, 1.0, 1.0 },
          debugPoly = false
     })

     SetEntityCoords(entity, coord.x + table_offset.x, coord.y + table_offset.y, coord.z + table_offset.z, 0.0, 0.0, 0.0
          , true)

     SetModelAsNoLongerNeeded(modelHash)
     return entity, box
end

SpawnAndCameraWrapper = function(object, coord, rotation, offset)
     local entity, box = spawn_object(object.name, {
          coord = coord,
          object_rotation = vector3(object.rotation.x, object.rotation.y, object.rotation.z),
          table_rotation = rotation,
          offset = offset
     })

     if not entity and not box then
          print('failed to load model')
          return nil, nil, nil
     end

     CreateThread(function()
          while DoesEntityExist(entity) do
               local roration = GetEntityRotation(entity)
               SetEntityRotation(entity, roration.x, roration.y, roration.z + 1.0, 2, 1)
               Wait(30)
          end
     end)

     local plyped = PlayerPedId()
     local e_coord = GetEntityCoords(plyped)
     local cam = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", e_coord.x, e_coord.y, e_coord.z + 1.75, 0.0
          , 0.0, 0.0, 30.0,
          true, 2)
     PointCamAtEntity(cam, entity, 0.0, 0.0, 0.0, true)
     RenderScriptCams(true, true, 1000, true, true)

     return entity, box, cam
end

SpawnAndCameraRemover = function(entity, box, cam)
     RenderScriptCams(0, true, 200, true, true)
     DestroyCam(cam, false)
     box:destroy()
     DeleteEntity(entity)
end

local function makeEntityFaceCoord(entity1, coord)
     local p1 = GetEntityCoords(entity1, true)
     local p2 = coord

     local dx = p2.x - p1.x
     local dy = p2.y - p1.y

     local heading = GetHeadingFromVector_2d(dx, dy)
     SetEntityHeading(entity1, heading)
end

RegisterNetEvent('keep-crafting:client:start_crafting', function(data, item_config)
     local plyped = PlayerPedId()

     TriggerEvent('animations:client:EmoteCommandStart', { "mechanic4" })
     makeEntityFaceCoord(plyped, Workbench.coords)
     QBCore.Functions.Progressbar("keep_Crafting", "Crafting ", item_config.crafting.duration * 1000, false, false, {
          disableMovement = true,
          disableCarMovement = true,
          disableMouse = false,
          disableCombat = true
     }, {}, {}, {}, function()
          TriggerEvent('animations:client:EmoteCommandStart', { "c" })
     end)
end)

AddEventHandler('onResourceStop', function(resourceName)
     if resourceName == GetCurrentResourceName() then
          for key, value in pairs(benches_entites) do
               DeleteObject(value)
          end
     end
end)

AddEventHandler('onResourceStart', function(resourceName)
     if (GetCurrentResourceName() ~= resourceName) then
          return
     end
     Load_tables()
end)

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
     Wait(1500)
     Load_tables()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
     Wait(1500)
     DeleteEntity(Tmp_entity)
end)
