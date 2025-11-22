local M = {}

local maxAssets = 2000
local maxActiveAssets = 2000
local ActiveAssets = {}
ActiveAssets.__index = ActiveAssets

local activeAssets = nil

function ActiveAssets.new()
    local self = setmetatable({}, ActiveAssets)
    self.assets = {} -- Ensure this is always initialized as an empty table
    return self
end

function ActiveAssets:addAssetList(triggerName, newAssets)
    if not self.assets then
        self.assets = {} -- Reinitialize if it's somehow nil
    end
    -- Create a new asset list for this trigger
    local assetList = {
        triggerName = triggerName,
        assets = newAssets
    }

    -- Add the new asset list
    table.insert(self.assets, assetList)

    -- If we exceed maxActiveAssets, remove and hide the oldest asset list
    if #self.assets > maxActiveAssets then
        local oldestAssetList = table.remove(self.assets, 1)
        self:hideAssetList(oldestAssetList)
    end
end

function ActiveAssets:hideAssetList(assetList)
    if assetList and assetList.assets then
        for _, asset in ipairs(assetList.assets) do
            if asset then
                asset:setHidden(true)
                -- ADDED CHECK: Re-enable collision when showing the asset if the asset is a TSStatic (static mesh)
                if asset:getClassName() == "TSStatic" then
                    -- Use setField to disable the collision
                    asset:setField('collisionType', 0, 'None')
                    asset:setField('decalType', 0, "None")
                    asset:postApply() -- maybe not needed but added anyway
                end
            end
        end
        be:reloadCollision() -- force collision reload after hiding assets
    end
end

function ActiveAssets:hideAllAssets()
    if not self.assets then
        self.assets = {} -- Reinitialize if it's nil
        return
    end
    for _, assetList in ipairs(self.assets) do
        self:hideAssetList(assetList)
    end
    self.assets = {}
end

function ActiveAssets:getOldestAssetList()
    if not self.assets or #self.assets == 0 then
        return nil
    end
    return self.assets[1]
end

function ActiveAssets:displayAssets(data, isAltRoute)
    -- ADD THIS LINE TO CLEAR ALL PREVIOUS ASSETS FIRST
    if isAltRoute then
        self:hideAllAssets()
    end

    local triggerName = data.triggerName
    local newAssets = {}

    for i = 0, maxAssets - 1 do
        local assetName
        if isAltRoute then
            -- New naming for the altRoute
            assetName = "alt_asset" .. i
        else
            -- naming for the main route
            assetName = triggerName .. "asset" .. i
        end

        local asset = scenetree.findObject(assetName)
        if asset then
            asset:setHidden(false)
            -- ADDED CHECK: Re-enable collision when showing the asset if the asset is a TSStatic (static mesh)
            if asset:getClassName() == "TSStatic" then
                -- Use setField to re-enable the collision
                asset:setField('collisionType', 0, 'Collision Mesh')
                asset:setField('decalType', 0, "Collision Mesh")
                asset:postApply() -- maybe not needed but added anyway
            end
            table.insert(newAssets, asset)
        else
            print("no assetes")
            break -- Stop if an asset is not found
        end
    end

    if #newAssets == 0 then
        return
    end

    self:addAssetList(triggerName, newAssets)

    be:reloadCollision() -- force collision reload after displaying assets

    if #self.assets == maxActiveAssets then
        local oldestAssetList = self:getOldestAssetList()
    end
end

local function onExtensionLoaded()
    print("Initializing Active Assets")
end


M.onExtensionLoaded = onExtensionLoaded
M.ActiveAssets = ActiveAssets

return M