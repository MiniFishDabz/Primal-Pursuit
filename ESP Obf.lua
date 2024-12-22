local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local highlightTemplate = Instance.new("Highlight")
highlightTemplate.Name = "Highlight"
highlightTemplate.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
highlightTemplate.OutlineTransparency = 0  -- Ensures the outline is always visible
highlightTemplate.FillTransparency = 0.5  -- Slight transparency for the fill, adjust as needed

local activeHighlights = {}  -- Table to keep track of active highlights for each player

-- Function to apply highlights to a player's character based on their team
local function applyHighlightToPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = player.Character.HumanoidRootPart
        -- Ensure the player doesn't already have a highlight
        if not humanoidRootPart:FindFirstChild("Highlight") then
            -- Clone the highlight template
            local highlightClone = highlightTemplate:Clone()
            highlightClone.Adornee = player.Character
            highlightClone.Parent = humanoidRootPart
            
            -- Check the player's team and set the color accordingly
            if player.Team then
                if player.Team.Name == "Dinosaur" then
                    highlightClone.FillColor = Color3.fromRGB(255, 0, 0)  -- Red for Dinosaur
                    highlightClone.OutlineColor = Color3.fromRGB(255, 0, 0)
                elseif player.Team.Name == "Survivor" then
                    highlightClone.FillColor = Color3.fromRGB(0, 255, 51)  -- Green for Survivor
                    highlightClone.OutlineColor = Color3.fromRGB(0, 255, 51)
                else
                    highlightClone:Destroy()  -- If the player is not in Dinosaur or Survivor, don't show highlight
                    return
                end
            end
            -- Store the highlight in the table
            activeHighlights[player] = highlightClone
        end
    end
end

-- Function to remove highlight for a player
local function removeHighlightFromPlayer(player)
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        local highlight = player.Character.HumanoidRootPart:FindFirstChild("Highlight")
        if highlight then
            highlight:Destroy()
            activeHighlights[player] = nil
        end
    end
end

-- Cleanup when players leave
Players.PlayerRemoving:Connect(function(player)
    removeHighlightFromPlayer(player)
end)

-- Apply highlight to new players joining the game
Players.PlayerAdded:Connect(function(player)
    player.CharacterAdded:Connect(function()
        if player.Team and (player.Team.Name == "Dinosaur" or player.Team.Name == "Survivor") then
            applyHighlightToPlayer(player)
        end
    end)
end)

-- Continuously check for new players or updates every frame
RunService.Heartbeat:Connect(function()
    for _, player in pairs(Players:GetPlayers()) do
        -- Only apply the highlight if the player is in the Dinosaur or Survivor team
        if player.Team and (player.Team.Name == "Dinosaur" or player.Team.Name == "Survivor") then
            if not activeHighlights[player] then
                applyHighlightToPlayer(player)
            end
        else
            -- If not in valid team, remove highlight
            removeHighlightFromPlayer(player)
        end
    end
end)

-- Add a cleanup function
local function cleanupESP()
    -- Remove all active highlights
    for _, player in pairs(Players:GetPlayers()) do
        removeHighlightFromPlayer(player)
    end
end

-- Return the cleanup function so it can be called from the main script
return cleanupESP