-- ==========================================
-- ORVION CONFIG SYSTEM
-- Save/Load configuration with JSON persistence
-- ==========================================

local HttpService = game:GetService("HttpService")

local ConfigSystem = {}
ConfigSystem.CurrentConfig = nil
ConfigSystem.ConfigFolder = "OrvionConfigs"

-- ==========================================
-- SAVE CONFIGURATION
-- ==========================================
function ConfigSystem:Save(configName, elementStates)
    if not configName or configName == "" then
        return false, "Config name cannot be empty"
    end
    
    local success, result = pcall(function()
        local configData = {
            Name = configName,
            Timestamp = os.time(),
            Elements = elementStates or {}
        }
        
        local jsonData = HttpService:JSONEncode(configData)
        local fileName = self.ConfigFolder .. "/" .. configName .. ".json"
        
        writefile(fileName, jsonData)
        self.CurrentConfig = configName
        
        return true
    end)
    
    if success then
        return true, "Config saved: " .. configName
    else
        return false, "Failed to save config: " .. tostring(result)
    end
end

-- ==========================================
-- LOAD CONFIGURATION
-- ==========================================
function ConfigSystem:Load(configName)
    if not configName or configName == "" then
        return nil, "Config name cannot be empty"
    end
    
    local success, result = pcall(function()
        local fileName = self.ConfigFolder .. "/" .. configName .. ".json"
        
        if not isfile(fileName) then
            return nil, "Config not found: " .. configName
        end
        
        local jsonData = readfile(fileName)
        local configData = HttpService:JSONDecode(jsonData)
        
        self.CurrentConfig = configName
        return configData
    end)
    
    if success and result then
        return result, nil
    else
        return nil, "Failed to load config: " .. tostring(result)
    end
end

-- ==========================================
-- DELETE CONFIGURATION
-- ==========================================
function ConfigSystem:Delete(configName)
    local success, result = pcall(function()
        local fileName = self.ConfigFolder .. "/" .. configName .. ".json"
        
        if isfile(fileName) then
            delfile(fileName)
            if self.CurrentConfig == configName then
                self.CurrentConfig = nil
            end
            return true
        else
            return false, "Config not found"
        end
    end)
    
    return success, result
end

-- ==========================================
-- LIST ALL CONFIGURATIONS
-- ==========================================
function ConfigSystem:List()
    local configs = {}
    
    pcall(function()
        if not isfolder(self.ConfigFolder) then
            makefolder(self.ConfigFolder)
        end
        
        local files = listfiles(self.ConfigFolder)
        for _, filePath in ipairs(files) do
            local fileName = filePath:match("([^/]+)%.json$")
            if fileName then
                table.insert(configs, fileName)
            end
        end
    end)
    
    return configs
end

-- ==========================================
-- AUTO-LOAD LAST CONFIGURATION
-- ==========================================
function ConfigSystem:AutoLoad()
    if self.CurrentConfig then
        return self:Load(self.CurrentConfig)
    end
    return nil, "No config to auto-load"
end

return ConfigSystem
