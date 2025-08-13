local RSGCore = exports['rsg-core']:GetCoreObject()

-- Prompts
local OpenReturn
local CloseReturn
local ReturnPrompt1 = GetRandomIntInRange(0, 0xffffff)
local ReturnPrompt2 = GetRandomIntInRange(0, 0xffffff)

local InMenu = false
local IsBoating = false
local isAnchored
local OwnedData = {}
local MyBoat
local TransferAllow
local BoatInventories = {} -- Table to track boat inventories
local InPreviewMode = false
local CurrentShopId = nil
local CurrentBoatData = nil

-- Variables for boat preview
local BoatCam = nil
local PreviewEntity = nil
local Cam = false
local CurrentBoatModel = nil

-- Initialize Buy and Rotation Prompts using jo.prompt
function InitializeBuyPrompts()
    -- Create prompt group for boat preview
    jo.prompt.create('boat_preview', 'Buy Boat', 0x2CD5343E, false) -- Enter key
    jo.prompt.create('boat_preview', 'Rotate Left', 0xA65EBAB4, false) -- A key  
    jo.prompt.create('boat_preview', 'Rotate Right', 0xDEB34313, false) -- D key
    jo.prompt.create('boat_preview', 'Exit Preview', 0x156F7119, false) -- ESC key
end

-- Create Camera for Boat Preview
function CreateBoatPreviewCamera(shopId)
    if BoatCam then
        DestroyCam(BoatCam, false)
    end
    
    local shop = Config.boatShops[shopId]
    local previewX = shop.previewx or shop.boatx
    local previewY = shop.previewy or shop.boaty
    local previewZ = shop.previewz or shop.boatz
    
    BoatCam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    SetCamCoord(BoatCam, previewX - 5.0, previewY - 5.0, previewZ + 3.0)
    SetCamActive(BoatCam, true)
    PointCamAtCoord(BoatCam, previewX, previewY, previewZ)
    SetCamFov(BoatCam, 25.0)
    
    DoScreenFadeOut(500)
    Wait(500)
    DoScreenFadeIn(500)
    RenderScriptCams(true, false, 0, false, false, 0)
    Cam = true
    
    -- Start camera lighting
    CreateThread(function()
        CameraLighting({x = previewX, y = previewY, z = previewZ})
    end)
end

-- Camera Lighting for Preview
function CameraLighting(coords)
    while Cam do
        Wait(0)
        Citizen.InvokeNative(0xD2D9E04C0DF927F4, coords.x, coords.y, coords.z + 3, 13, 28, 46, 5.0, 10.0)
    end
end

-- Spawn Preview Boat
function SpawnPreviewBoat(boatModel, shopId)
    --print("SpawnPreviewBoat called with model: " .. tostring(boatModel) .. ", shopId: " .. tostring(shopId))
    
    if PreviewEntity and DoesEntityExist(PreviewEntity) then
        --print("Deleting existing preview entity")
        DeleteEntity(PreviewEntity)
    end
    
    local shop = Config.boatShops[shopId]
    local previewX = shop.previewx or shop.boatx
    local previewY = shop.previewy or shop.boaty
    local previewZ = shop.previewz or shop.boatz
    local previewH = shop.previewh or shop.boath or 0.0
    
    --print("Spawn coordinates: " .. previewX .. ", " .. previewY .. ", " .. previewZ .. ", " .. previewH)
    
    local modelHash = GetHashKey(boatModel)
    --print("Model hash: " .. modelHash)
    
    RequestModel(modelHash)
    local timeout = 0
    while not HasModelLoaded(modelHash) and timeout < 5000 do
        Wait(10)
        timeout = timeout + 10
    end
    
    if not HasModelLoaded(modelHash) then
        --print("Failed to load model: " .. boatModel)
        return
    end
    
    --print("Model loaded successfully, creating vehicle...")
    
    PreviewEntity = CreateVehicle(modelHash, previewX, previewY, previewZ, previewH, false, false, false, false)
    
    if PreviewEntity and DoesEntityExist(PreviewEntity) then
        --print("Preview boat spawned successfully with entity ID: " .. PreviewEntity)
        SetEntityAsMissionEntity(PreviewEntity, true, true)
        FreezeEntityPosition(PreviewEntity, true)
        SetEntityInvincible(PreviewEntity, true)
        SetEntityCanBeDamaged(PreviewEntity, false)
        CurrentBoatModel = boatModel
    else
        --print("Failed to spawn preview boat!")
    end
end

-- Rotate Preview Boat
function RotatePreviewBoat(direction)
    --print("RotatePreviewBoat called with direction: " .. tostring(direction))
    
    if PreviewEntity and DoesEntityExist(PreviewEntity) then
        --print("Preview entity exists, rotating...")
        
        -- Skip rotation for specific large boats
        if CurrentBoatModel == 'ship_nbdGuama' or CurrentBoatModel == 'turbineboat' or 
           CurrentBoatModel == 'tugboat2' or CurrentBoatModel == 'horseBoat' then
            --print("Large boat detected, skipping rotation")
            return
        end
        
        local rotationAmount = direction == 'left' and 20 or -20
        local currentHeading = GetEntityHeading(PreviewEntity)
        local newHeading = (currentHeading + rotationAmount) % 360
        
        --print("Current heading: " .. currentHeading .. ", New heading: " .. newHeading)
        
        SetEntityHeading(PreviewEntity, newHeading)
    else
        --print("Preview entity does not exist!")
    end
end

-- Clean up preview
function CleanupBoatPreview()
    --print("CleanupBoatPreview called")
    
    Cam = false
    InPreviewMode = false
    CurrentShopId = nil
    CurrentBoatData = nil
    
    --print("Preview mode variables reset")
    
    if BoatCam then
        --print("Cleaning up camera...")
        SetCamActive(BoatCam, false)
        RenderScriptCams(false, false, 0, false, false, 0)
        DestroyCam(BoatCam, false)
        BoatCam = nil
    end
    
    if PreviewEntity and DoesEntityExist(PreviewEntity) then
        --print("Cleaning up preview entity...")
        DeleteEntity(PreviewEntity)
        PreviewEntity = nil
    end
    
    CurrentBoatModel = nil
    --print("Cleanup completed")
end

-- Handle Preview Mode Prompts using jo.prompt
Citizen.CreateThread(function()
    InitializeBuyPrompts()
    
    while true do
        Wait(0)
        
        if InPreviewMode and CurrentBoatData and CurrentShopId then
            local player = PlayerPedId()
            local coords = GetEntityCoords(player)
            local shop = Config.boatShops[CurrentShopId]
            local shopCoords = vector3(shop.npcx, shop.npcy, shop.npcz)
            local distance = #(coords - shopCoords)
            
            -- Show prompts only when near the shop
            if distance <= 5.0 then
                -- Display prompt group with boat info
                local promptTitle = CurrentBoatData.boatName .. " - $" .. CurrentBoatData.buyPrice
                jo.prompt.displayGroup('boat_preview', promptTitle)
                
                -- Debug: --print when prompts are triggered
                if jo.prompt.isCompleted('boat_preview', 'Buy Boat') then 
                    --print("Buy prompt triggered!")
                    local location = Config.boatShops[CurrentShopId].location
                    CleanupBoatPreview()
                    TriggerServerEvent('sm-boats:BuyBoat', CurrentBoatData, location)
                    ClearPedTasksImmediately(PlayerPedId())
                    DisplayRadar(true)
                end
                
                -- Handle rotation prompts with debug
                if jo.prompt.isPressed('boat_preview', 'Rotate Left') then 
                    --print("Rotate left triggered!")
                    RotatePreviewBoat('left')
                    Wait(100) -- Add small delay to prevent spam
                end
                
                if jo.prompt.isPressed('boat_preview', 'Rotate Right') then 
                    --print("Rotate right triggered!")
                    RotatePreviewBoat('right')
                    Wait(100) -- Add small delay to prevent spam
                end
                
                -- Handle exit prompt with debug
                if jo.prompt.isCompleted('boat_preview', 'Exit Preview') then 
                    --print("Exit prompt triggered!")
                    CleanupBoatPreview()
                    ClearPedTasksImmediately(PlayerPedId())
                    DisplayRadar(true)
                end
                
                -- Alternative: Try using direct key detection as fallback
                if IsControlJustPressed(0, 0x2CD5343E) then -- Enter
                    --print("Direct Enter key detected!")
                    local location = Config.boatShops[CurrentShopId].location
                    TriggerServerEvent('sm-boats:BuyBoat', CurrentBoatData, location)
                    CleanupBoatPreview()
                    ClearPedTasksImmediately(PlayerPedId())
                    DisplayRadar(true)
                end
                
                if IsControlPressed(0, 0xA65EBAB4) then -- A key
                    --print("Direct A key detected!")
                    RotatePreviewBoat('left')
                    Wait(100)
                end
                
                if IsControlPressed(0, 0xDEB34313) then -- D key
                    --print("Direct D key detected!")
                    RotatePreviewBoat('right')
                    Wait(100)
                end
                
                if IsControlJustPressed(0, 0x156F7119) then -- ESC
                    --print("Direct ESC key detected!")
                    CleanupBoatPreview()
                    ClearPedTasksImmediately(PlayerPedId())
                    DisplayRadar(true)
                end
                
            else
                -- Player moved too far, exit preview mode
                CleanupBoatPreview()
                ClearPedTasksImmediately(PlayerPedId())
                DisplayRadar(true)
            end
        else
            Wait(1000)
        end
    end
end)

-- Register NUI Callback for Rotation (jika menggunakan NUI)
RegisterNUICallback('RotateBoat', function(data, cb)
    cb('ok')
    local direction = data.direction
    RotatePreviewBoat(direction)
end)

-- Start Boats
Citizen.CreateThread(function()
    ReturnOpen()
    ReturnClosed()

    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        local coords = GetEntityCoords(player)
        local sleep = true
        local dead = IsEntityDead(player)
        local hour = GetClockHours()

        if InMenu == false and not dead and not InPreviewMode then
            for shopId, shopConfig in pairs(Config.boatShops) do
                if shopConfig.shopHours then
                    if hour >= shopConfig.shopClose or hour < shopConfig.shopOpen then
                        if not Config.boatShops[shopId].BlipHandle and shopConfig.blipAllowed then
                            AddBlip(shopId)
                        end
                        if Config.boatShops[shopId].BlipHandle then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.boatShops[shopId].BlipHandle, GetHashKey(shopConfig.blipColorClosed)) -- BlipAddModifier
                        end
                        if shopConfig.NPC then
                            DeleteEntity(shopConfig.NPC)
                            DeletePed(shopConfig.NPC)
                            SetEntityAsNoLongerNeeded(shopConfig.NPC)
                            shopConfig.NPC = nil
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsBoat = vector3(shopConfig.boatx, shopConfig.boaty, shopConfig.boatz)
                        local distanceBoat = #(coordsDist - coordsBoat)

                        if (distanceBoat <= shopConfig.distanceReturn) and IsPedInAnyBoat(player) then
                            sleep = false
                            local returnClosed = CreateVarString(10, 'LITERAL_STRING', _U("closed") .. shopConfig.shopOpen .. _U("am") .. shopConfig.shopClose .. _U("pm"))
                            PromptSetActiveGroupThisFrame(ReturnPrompt2, returnClosed)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, CloseReturn) then -- UiPromptHasStandardModeCompleted
                                Wait(100)
                                jo.notif.right(_U("shopClosed"), 'inventory_items', 'generic_exotic_order', 'color_white', 5000)
                            end
                        end
                    elseif hour >= shopConfig.shopOpen then
                        if not Config.boatShops[shopId].BlipHandle and shopConfig.blipAllowed then
                            AddBlip(shopId)
                        end
                        if Config.boatShops[shopId].BlipHandle then
                            Citizen.InvokeNative(0x662D364ABF16DE2F, Config.boatShops[shopId].BlipHandle, GetHashKey(shopConfig.blipColorOpen)) -- BlipAddModifier
                        end
                        if not shopConfig.NPC and shopConfig.npcAllowed then
                            SpawnNPC(shopId)
                        end
                        local coordsDist = vector3(coords.x, coords.y, coords.z)
                        local coordsBoat = vector3(shopConfig.boatx, shopConfig.boaty, shopConfig.boatz)
                        local distanceBoat = #(coordsDist - coordsBoat)

                        if (distanceBoat <= shopConfig.distanceReturn) and IsPedInAnyBoat(player) then
                            sleep = false
                            local returnOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                            PromptSetActiveGroupThisFrame(ReturnPrompt1, returnOpen)

                            if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                                local currentLocation = shopConfig.location
                                local boatHome = OwnedData.location
                                local boatName = OwnedData.name
                                if currentLocation == boatHome then
                                    ReturnBoat(shopId)
                                else
                                    if TransferAllow then
                                        local driveTransfer = "driveTransfer"
                                        TriggerServerEvent("sm-boats:TransferBoat", OwnedData, currentLocation, driveTransfer)
                                        ReturnBoat(shopId)
                                        jo.notif.right(_U("your") .. boatName .. _U("available"), 'inventory_items', 'generic_exotic_order', 'color_white', 5000)
                                    else
                                        ReturnBoat(shopId)
                                        jo.notif.right(_U("your") .. boatName .. _U("returned") .. boatHome, 'inventory_items', 'generic_exotic_order', 'color_white', 5000)
                                    end
                                end
                            end
                        end
                    end
                else
                    if not Config.boatShops[shopId].BlipHandle and shopConfig.blipAllowed then
                        AddBlip(shopId)
                    end
                    if Config.boatShops[shopId].BlipHandle then
                        Citizen.InvokeNative(0x662D364ABF16DE2F, Config.boatShops[shopId].BlipHandle, GetHashKey(shopConfig.blipColorOpen)) -- BlipAddModifier
                    end
                    if not shopConfig.NPC and shopConfig.npcAllowed then
                        SpawnNPC(shopId)
                    end
                    local coordsDist = vector3(coords.x, coords.y, coords.z)
                    local coordsBoat = vector3(shopConfig.boatx, shopConfig.boaty, shopConfig.boatz)
                    local distanceBoat = #(coordsDist - coordsBoat)

                    if (distanceBoat <= shopConfig.distanceReturn) and IsPedInAnyBoat(player) then
                        sleep = false
                        local returnOpen = CreateVarString(10, 'LITERAL_STRING', shopConfig.promptName)
                        PromptSetActiveGroupThisFrame(ReturnPrompt1, returnOpen)

                        if Citizen.InvokeNative(0xC92AC953F0A982AE, OpenReturn) then -- UiPromptHasStandardModeCompleted
                            local currentLocation = shopConfig.location
                            local boatHome = OwnedData.location
                            local boatName = OwnedData.name
                            if currentLocation == boatHome then
                                ReturnBoat(shopId)
                            else
                                if TransferAllow then
                                    local driveTransfer = "driveTransfer"
                                    TriggerServerEvent("sm-boats:TransferBoat", OwnedData, currentLocation, driveTransfer)
                                    ReturnBoat(shopId)
                                    jo.notif.right(_U("your") .. boatName .. _U("available"), 'inventory_items', 'generic_exotic_order', 'color_white', 5000)
                                else
                                    ReturnBoat(shopId)
                                    jo.notif.right(_U("your") .. boatName .. _U("returned") .. boatHome, 'inventory_items', 'generic_exotic_order', 'color_white', 5000)
                                end
                            end
                        end
                    end
                end
            end
        end
        if sleep then
            Citizen.Wait(1000)
        end
    end
end)

-- Initialize ox_target for all shop NPCs
Citizen.CreateThread(function()
    Wait(1000) -- Wait for all resources to start
    
    for shopId, shopConfig in pairs(Config.boatShops) do
        -- Only set up target if NPC is allowed for this shop
        if shopConfig.npcAllowed then
            -- Create a specific zone for each shop location instead of using model targeting
            exports.ox_target:addBoxZone({
                coords = vector3(shopConfig.npcx, shopConfig.npcy, shopConfig.npcz),
                size = vector3(2.0, 2.0, 3.0),
                rotation = shopConfig.npch,
                debug = false,
                options = {
                    {
                        name = 'boat_shop_' .. shopId,
                        icon = 'fas fa-ship',
                        label = shopConfig.promptName,
                        canInteract = function(entity, distance, coords, name, bone)
                            local hour = GetClockHours()
                            if shopConfig.shopHours then
                                return hour < shopConfig.shopClose and hour >= shopConfig.shopOpen
                            end
                            return true
                        end,
                        onSelect = function()
                            local hour = GetClockHours()
                            if shopConfig.shopHours and (hour >= shopConfig.shopClose or hour < shopConfig.shopOpen) then
                                jo.notif.right(_U("shopClosed"), 'inventory_items', 'generic_exotic_order', 'color_white', 5000)
                                return
                            end
                            MainMenu(shopId)
                            DisplayRadar(false)
                            TaskStandStill(PlayerPedId(), -1)
                        end
                    }
                }
            })
        end
    end
end)

-- Main Boats Menu
function MainMenu(shopId)
    InMenu = true
    
    -- Create main boat menu
    local menu = jo.menu.create('main_boat_menu', {
        title = Config.boatShops[shopId].shopName,
        subtitle = 'Main Menu',
        numberOnScreen = 8,
        onEnter = function(currentData)
            SetNuiFocus(true, true)
            DisplayRadar(false)
        end,
        onExit = function(currentData)
            SetNuiFocus(false, false)
            InMenu = false
            ClearPedTasksImmediately(PlayerPedId())
            DisplayRadar(true)
        end,
        onBack = function(currentData)
            jo.menu.show(false)
            SetNuiFocus(false, false)
            InMenu = false
            ClearPedTasksImmediately(PlayerPedId())
            DisplayRadar(true)
        end
    })
    
    -- Add menu items
    menu:addItem({
        title = _U("buyBoat"),
        description = _U("newBoat"),
        icon = 'dollar',
        onClick = function(currentData)
            BuyMenu(shopId)
        end
    })
    
    menu:addItem({
        title = _U("own"),
        description = _U("owned"),
        icon = 'canoe',
        onClick = function(currentData)
            local location = Config.boatShops[shopId].location
            TriggerServerEvent('sm-boats:GetOwnedBoats', location, shopId)
        end
    })
    
    -- Send and show menu
    menu:send()
    jo.menu.setCurrentMenu('main_boat_menu')
    jo.menu.show(true, false, true, true, false)
end

-- Buy Boats Menu with Preview (Modified to show preview instead of direct purchase)
function BuyMenu(shopId)
    InMenu = true
    
    -- Create buy boat menu
    local menu = jo.menu.create('buy_boat_menu', {
        title = Config.boatShops[shopId].shopName,
        subtitle = 'Select Boat to Preview',
        numberOnScreen = 8,
        onEnter = function(currentData)
            SetNuiFocus(true, true)
            DisplayRadar(false)
        end,
        onExit = function(currentData)
            SetNuiFocus(false, false)
            InMenu = false
            ClearPedTasksImmediately(PlayerPedId())
            DisplayRadar(true)
        end,
        onBack = function(currentData)
            MainMenu(shopId)
        end
    })
    
    -- Add boat items
    for boat, boatConfig in pairs(Config.boatShops[shopId].boats) do
        local inventoryInfo = ""
        if boatConfig.inventorySize then
            inventoryInfo = _U("inventorySize") .. boatConfig.inventorySize .. " kg"
        end
        
        menu:addItem({
            title = boatConfig.boatName,
            icon = 'canoe',
            price = { money = boatConfig.buyPrice },
            description = inventoryInfo .. " - Click to preview",
            onClick = function(currentData)
                -- Enter preview mode instead of buying directly
                jo.menu.show(false)
                SetNuiFocus(false, false)
                InMenu = false
                
                -- Set preview mode variables
                InPreviewMode = true
                CurrentShopId = shopId
                CurrentBoatData = boatConfig
                
                -- Setup preview
                CreateBoatPreviewCamera(shopId)
                SpawnPreviewBoat(boatConfig.boatModel, shopId)
            end
        })
    end
    
    -- Send and show menu
    menu:send()
    jo.menu.setCurrentMenu('buy_boat_menu')
    jo.menu.show(true, false, true, true, false)
end

-- Remove the separate ESC key handler thread since it's now handled in the main prompt thread
-- Menu to Manage Owned Boats at Shop Location
RegisterNetEvent("sm-boats:OwnedBoatsMenu")
AddEventHandler("sm-boats:OwnedBoatsMenu", function(ownedBoats, shopId)
    InMenu = true
    
    -- Create owned boats menu
    local menu = jo.menu.create('owned_boats_menu', {
        title = Config.boatShops[shopId].shopName,
        subtitle = 'Owned Boats',
        numberOnScreen = 8,
        onEnter = function(currentData)
            SetNuiFocus(true, true)
            DisplayRadar(false)
        end,
        onExit = function(currentData)
            -- jo.menu.show(false)
            SetNuiFocus(false, false)
            InMenu = false
            ClearPedTasksImmediately(PlayerPedId())
            DisplayRadar(true)
        end,
        onBack = function(currentData)
            -- Go back to main menu
            MainMenu(shopId)
        end
    })
    
    -- Add owned boat items
    for boat, ownedBoatData in pairs(ownedBoats) do
        menu:addItem({
            title = ownedBoatData.name,
            description = _U("chooseBoat"),
            icon = 'canoe',
            onClick = function(currentData)
                OwnedData = ownedBoatData
                BoatMenu(shopId)
            end
        })
    end
    
    -- Send and show menu
    menu:send()
    jo.menu.setCurrentMenu('owned_boats_menu')
    jo.menu.show(true, false, true, true, false)
end)

-- Menu to Launch, Sell or Transfer Owned Boats
function BoatMenu(shopId)
    InMenu = true
    
    local boatName = OwnedData.name
    local boatModel = OwnedData.model
    local boatData = Config.boatShops[shopId].boats[boatModel]
    local sellPrice = boatData.sellPrice
    TransferAllow = Config.transferAllow
    
    local descTransfer
    if TransferAllow then
        descTransfer = _U("transfer") .. boatName .. _U("transferShop")
    else
        descTransfer = _U("transferDisabledMenu")
    end
    
    -- Create boat actions menu
    local menu = jo.menu.create('boat_actions_menu', {
        title = Config.boatShops[shopId].shopName,
        subtitle = boatName,
        numberOnScreen = 8,
        onEnter = function(currentData)
            SetNuiFocus(true, true)
            DisplayRadar(false)
        end,
        onExit = function(currentData)
            jo.menu.show(false)
            SetNuiFocus(false, false)
            InMenu = false
            ClearPedTasksImmediately(PlayerPedId())
            DisplayRadar(true)
        end,
        onBack = function(currentData)
            -- Go back to owned boats menu
            TriggerServerEvent('sm-boats:GetOwnedBoats', Config.boatShops[shopId].location, shopId)
        end
    })
    
    -- Add action items
    menu:addItem({
        title = _U("launch"),
        description = _U("launchBoat") .. boatName,
        icon = 'canoe',
        onClick = function(currentData)
            jo.menu.show(false)
            SetNuiFocus(false, false)
            InMenu = false
            ClearPedTasksImmediately(PlayerPedId())
            DisplayRadar(true)
            SpawnBoat()
        end
    })
    
    menu:addItem({
        title = _U("sellBoat"),
        description = _U("sell") .. boatName .. _U("frcash") .. sellPrice,
        icon = 'dollar',
        price = { money = sellPrice },
        onClick = function(currentData)
            jo.menu.show(false)
            SetNuiFocus(false, false)
            TriggerServerEvent('sm-boats:SellBoat', OwnedData, boatData)
            InMenu = false
            ClearPedTasksImmediately(PlayerPedId())
            DisplayRadar(true)
        end
    })
    
    menu:addItem({
        title = _U("transferBoat"),
        description = descTransfer,
        icon = 'book_opened',
        disabled = not TransferAllow,
        onClick = function(currentData)
            if TransferAllow then
                TransferBoat(boatData, shopId)
            else
                jo.notif.right(_U("transferDisabled"), 'inventory_items', 'generic_exotic_order', 'color_white', 5000)
            end
        end
    })
    
    -- Send and show menu
    menu:send()
    jo.menu.setCurrentMenu('boat_actions_menu')
    jo.menu.show(true, false, true, true, false)
end

-- Menu to Choose Shop to Transfer Boat
function TransferBoat(boatData, shopId)
    InMenu = true
    
    local name = OwnedData.name
    local location = OwnedData.location
    local transferPrice = boatData.transferPrice
    
    -- Create transfer boat menu
    local menu = jo.menu.create('transfer_boat_menu', {
        title = name,
        subtitle = 'Transfer Boat',
        numberOnScreen = 8,
        onEnter = function(currentData)
            SetNuiFocus(true, true)
            DisplayRadar(false)
        end,
        onExit = function(currentData)
            jo.menu.show(false)
            SetNuiFocus(false, false)
            InMenu = false
            ClearPedTasksImmediately(PlayerPedId())
            DisplayRadar(true)
        end,
        onBack = function(currentData)
            -- Go back to boat actions menu
            BoatMenu(shopId)
        end
    })
    
    -- Add shop locations
    for shopLocId, shopConfig in pairs(Config.boatShops) do
        menu:addItem({
            title = shopConfig.shopName,
            description = _U("transfer") .. name .. _U("frcash") .. transferPrice,
            icon = 'book_opened',
            disabled = shopConfig.location == location,
            price = { money = transferPrice },
            onClick = function(currentData)
                local transferLocation = shopConfig.location
                local menuTransfer = "menuTransfer"
                local shopName = shopConfig.shopName
                
                jo.menu.show(false)
                SetNuiFocus(false, false)
                TriggerServerEvent("sm-boats:TransferBoat", OwnedData, transferLocation, menuTransfer, boatData, shopName)
                InMenu = false
                ClearPedTasksImmediately(PlayerPedId())
                DisplayRadar(true)
            end
        })
    end
    
    -- Send and show menu
    menu:send()
    jo.menu.setCurrentMenu('transfer_boat_menu')
    jo.menu.show(true, false, true, true, false)
end

-- Boat Anchor Operation and Boat Return at Non-Shop Locations
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(10)
        if IsControlJustReleased(0, Config.optionKey) then
            if IsPedInAnyBoat(PlayerPedId()) and IsBoating == true then
                BoatOptionsMenu()
            else
                return
            end
        end
    end
end)

-- Enhanced boat options menu with inventory access
function BoatOptionsMenu()
    InMenu = true
    
    -- Create boat options menu
    local menu = jo.menu.create('boat_options_menu', {
        title = _U("boatMenu"),
        subtitle = 'Boat Options',
        numberOnScreen = 8,
        onEnter = function(currentData)
            SetNuiFocus(true, true)
            DisplayRadar(false)
        end,
        onExit = function(currentData)
            jo.menu.show(false)
            SetNuiFocus(false, false)
            InMenu = false
            ClearPedTasksImmediately(PlayerPedId())
            DisplayRadar(true)
        end,
        onBack = function(currentData)
            jo.menu.show(false)
            SetNuiFocus(false, false)
            InMenu = false
            ClearPedTasksImmediately(PlayerPedId())
            DisplayRadar(true)
        end
    })
    
    -- Add option items
    menu:addItem({
        title = _U("anchorMenu"),
        description = _U("anchorAction"),
        icon = 'canoe',
        onClick = function(currentData)
            local player = PlayerPedId()
            if IsPedInAnyBoat(player) then
                local playerBoat = GetVehiclePedIsIn(player, true)
                if not isAnchored then
                    SetBoatAnchor(playerBoat, true)
                    SetBoatFrozenWhenAnchored(playerBoat, true)
                    isAnchored = true  
                    jo.notif.right("You anchored the boat", 'inventory_items', 'generic_exotic_order', 'color_white', 5000)
                else
                    SetBoatAnchor(playerBoat, false)
                    isAnchored = false
                    jo.notif.right("You raised the anchor back up", 'inventory_items', 'generic_exotic_order', 'color_white', 5000)
                end
            end
            jo.menu.show(false)
            SetNuiFocus(false, false)
            InMenu = false
        end
    })
    
    menu:addItem({
        title = _U("inventoryMenu") or "Boat Inventory",
        description = _U("inventoryAction") or "Access boat storage",
        icon = 'propsets',
        onClick = function(currentData)
            if OwnedData and OwnedData.model then
                local invId = 'boat_' .. OwnedData.id
                jo.menu.show(false)
                SetNuiFocus(false, false)
                OpenBoatInventory(invId, OwnedData.model)
            else
                jo.notif.right("This boat doesn't have any storage", 'inventory_items', 'generic_exotic_order', 'color_white', 5000)
                jo.menu.show(false)
                SetNuiFocus(false, false)
            end
            InMenu = false
        end
    })
    
    -- menu:addItem({
    --     title = _U("returnMenu"),
    --     description = _U("returnAction"),
    --     icon = 'home',
    --     onClick = function(currentData)
    --         TaskLeaveVehicle(PlayerPedId(), MyBoat, 0)
    --         jo.menu.show(false)
    --         SetNuiFocus(false, false)
    --         InMenu = false
    --         IsBoating = false
    --         Wait(15000)
    --         DeleteEntity(MyBoat)
    --     end
    -- })
    
    -- Send and show menu
    menu:send()
    jo.menu.setCurrentMenu('boat_options_menu')
    jo.menu.show(true, false, true, true, false)
end

-- Function to open boat inventory
function OpenBoatInventory(invId, boatModel)
    -- Find the boat's inventory size from any shop config
    local inventorySize = 0
    for shopId, shopConfig in pairs(Config.boatShops) do
        if shopConfig.boats[boatModel] and shopConfig.boats[boatModel].inventorySize then
            inventorySize = shopConfig.boats[boatModel].inventorySize
            break
        end
    end
    
    if inventorySize <= 0 then
        jo.notif.right("This boat doesn't have any storage", 'inventory_items', 'generic_exotic_order', 'color_white', 5000)
        return
    end
    
    TriggerServerEvent('sm-boats:OpenBoatInventory', invId, inventorySize)
end

-- Event to open inventory (client side)
RegisterNetEvent('sm-boats:OpenInventory')
AddEventHandler('sm-boats:OpenInventory', function(invId, inventorySize)
    exports.ox_inventory:openInventory('stash', {id = invId, weight = inventorySize * 1000})
end)

-- Spawn New or Owned Boat
function SpawnBoat()
    if MyBoat then
        DeleteEntity(MyBoat)
    end
    local player = PlayerPedId()
    local name = OwnedData.name
    local model = OwnedData.model
    local location = OwnedData.location
    local boatConfig = Config.boatShops[location]
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(500)
    end
    MyBoat = CreateVehicle(model, boatConfig.boatx, boatConfig.boaty, boatConfig.boatz, boatConfig.boath, true, false)
    SetVehicleOnGroundProperly(MyBoat)
    SetModelAsNoLongerNeeded(model)
    SetEntityInvincible(MyBoat, 1)
    DoScreenFadeOut(500)
    Wait(500)
    SetPedIntoVehicle(player, MyBoat, -1)
    Wait(500)
    DoScreenFadeIn(500)
    local boatBlip = Citizen.InvokeNative(0x23F74C2FDA6E7C61, -1749618580, MyBoat) -- BlipAddForEntity
    SetBlipSprite(boatBlip, GetHashKey("blip_canoe"), true)
    Citizen.InvokeNative(0x9CB1A1623062F402, boatBlip, name) -- SetBlipName
    IsBoating = true
    
    -- Set up ox_target for the boat after spawning
    exports.ox_target:addLocalEntity(MyBoat, {
        {
            name = 'boat_inventory_' .. OwnedData.id,
            icon = 'fas fa-box',
            label = 'Access Boat Storage',
            canInteract = function()
                -- Only allow interaction when boat is anchored
                return isAnchored
            end,
            onSelect = function()
                local invId = 'boat_' .. OwnedData.id
                OpenBoatInventory(invId, OwnedData.model)
            end
        }
    })
    
    jo.notif.right("You brought out a boat", 'inventory_items', 'generic_exotic_order', 'color_white', 5000)
end

-- Return Boat Using Prompt at Shop Location
function ReturnBoat(shopId)
    local player = PlayerPedId()
    local shopConfig = Config.boatShops[shopId]
    local coords = vector3(shopConfig.playerx, shopConfig.playery, shopConfig.playerz)
    TaskLeaveVehicle(player, MyBoat, 0)
    DoScreenFadeOut(500)
    Wait(500)
    SetEntityCoords(player, coords.x, coords.y, coords.z)
    Wait(500)
    DoScreenFadeIn(500)
    IsBoating = false
    DeleteEntity(MyBoat)
    jo.notif.right("You docked the boat", 'inventory_items', 'generic_exotic_order', 'color_white', 5000)
end

-- Prevents Boat from Sinking
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        local player = PlayerPedId()
        if IsPedInAnyBoat(player) then
            SetPedResetFlag(player, 364, 1)
        end
    end
end)

-- Keep only return prompts
function ReturnOpen()
    local str = _U("returnPrompt")
    OpenReturn = PromptRegisterBegin()
    PromptSetControlAction(OpenReturn, Config.returnKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(OpenReturn, str)
    PromptSetEnabled(OpenReturn, 1)
    PromptSetVisible(OpenReturn, 1)
    PromptSetStandardMode(OpenReturn, 1)
    PromptSetGroup(OpenReturn, ReturnPrompt1)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, OpenReturn, true) -- UiPromptSetUrgentPulsingEnabled
    PromptRegisterEnd(OpenReturn)
end

function ReturnClosed()
    local str = _U("returnPrompt")
    CloseReturn = PromptRegisterBegin()
    PromptSetControlAction(CloseReturn, Config.returnKey)
    str = CreateVarString(10, 'LITERAL_STRING', str)
    PromptSetText(CloseReturn, str)
    PromptSetEnabled(CloseReturn, 1)
    PromptSetVisible(CloseReturn, 1)
    PromptSetStandardMode(CloseReturn, 1)
    PromptSetGroup(CloseReturn, ReturnPrompt2)
    Citizen.InvokeNative(0xC5F428EE08FA7F2C, CloseReturn, true) -- UiPromptSetUrgentPulsingEnabled
    PromptRegisterEnd(CloseReturn)
end

-- Blips (unchanged)
function AddBlip(shopId)
    local shopConfig = Config.boatShops[shopId]
    if shopConfig.blipAllowed then
        shopConfig.BlipHandle = N_0x554d9d53f696d002(1664425300, shopConfig.npcx, shopConfig.npcy, shopConfig.npcz) -- BlipAddForCoords
        SetBlipSprite(shopConfig.BlipHandle, shopConfig.blipSprite, 1)
        SetBlipScale(shopConfig.BlipHandle, 0.2)
        Citizen.InvokeNative(0x9CB1A1623062F402, shopConfig.BlipHandle, shopConfig.blipName) -- SetBlipName
    end
end

-- NPCs (unchanged)
function LoadModel(npcModel)
    local model = GetHashKey(npcModel)
    RequestModel(model)
    while not HasModelLoaded(model) do
        RequestModel(model)
        Citizen.Wait(100)
    end
end

function SpawnNPC(shopId)
    local shopConfig = Config.boatShops[shopId]
    LoadModel(shopConfig.npcModel)
    if shopConfig.npcAllowed then
        local npc = CreatePed(shopConfig.npcModel, shopConfig.npcx, shopConfig.npcy, shopConfig.npcz, shopConfig.npch, false, true, true, true)
        Citizen.InvokeNative(0x283978A15512B2FE, npc, true) -- SetRandomOutfitVariation
        SetEntityCanBeDamaged(npc, false)
        SetEntityInvincible(npc, true)
        Wait(500)
        FreezeEntityPosition(npc, true)
        SetBlockingOfNonTemporaryEvents(npc, true)
        Config.boatShops[shopId].NPC = npc
    end
end

AddEventHandler('onResourceStop', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
        return
    end
    if InMenu == true then
        ClearPedTasksImmediately(PlayerPedId())
        PromptDelete(OpenShops)
        PromptDelete(CloseShops)
        PromptDelete(OpenReturn)
        PromptDelete(CloseReturn)
        lib.hideContext()
    end

    if MyBoat then
        DeleteEntity(MyBoat)
    end

    for _, shopConfig in pairs(Config.boatShops) do
        if shopConfig.BlipHandle then
            RemoveBlip(shopConfig.BlipHandle)
        end
        if shopConfig.NPC then
            DeleteEntity(shopConfig.NPC)
            DeletePed(shopConfig.NPC)
            SetEntityAsNoLongerNeeded(shopConfig.NPC)
        end
    end
end)