local DISABLED = {
    0, -- Next Camera
    -- 1,   -- Look Left/Right
    -- 2,   -- Look up/Down
    14, -- INPUT_WEAPON_WHEEL_NEXT
    15, -- INPUT_WEAPON_WHEEL_PREV
    16, -- INPUT_SELECT_NEXT_WEAPON
    17, -- INPUT_SELECT_PREV_WEAPON
    17, -- Select Previous Weapon
    -- 22, -- Jump
    23, -- Enter vehicle
    24, -- Attack
    25, -- Aim
    26, -- Look Behind
    29, -- INPUT_SPECIAL_ABILITY_SECONDARY
    -- 30,  -- Player Movement
    -- 31,  -- Player Movement
    36,  -- Input Duck/Sneak
    37,  -- Weapon Wheel
    38,  -- INPUT_PICKUP
    44,  -- Cover
    45,  -- INPUT_RELOAD
    46,  -- INPUT_TALK
    47,  -- Detonate
    51,  -- INPUT_CONTEXT
    55,  -- Dive
    58,  -- INPUT_THROW_GRENADE
    69,  -- Vehicle attack
    73,  -- INPUT_VEH_DUCK
    81,  -- Next Radio (Vehicle)
    82,  -- Previous Radio (Vehicle)
    91,  -- Passenger Aim (Vehicle)
    92,  -- Passenger Attack (Vehicle)
    99,  -- Select Next Weapon (Vehicle)
    105, -- INPUT_VEH_DROP_PROJECTILE
    106, -- Control Override (Vehicle)
    113, -- INPUT_VEH_FLY_UNDERCARRIAGE
    114, -- Fly Attack (Flying)
    115, -- Next Weapon (Flying)
    121, -- Fly Camera (Flying)
    122, -- Control OVerride (Flying)
    135, -- Control OVerride (Sub)
    140, -- Melee attack light
    142, -- Attack alternate
    154, -- INPUT_PARACHUTE_SMOKE
    199, -- Pause menu (P)
    200, -- Pause Menu (ESC)
    244, -- INPUT_INTERACTION_MENU
    245, -- Chat
    257, -- Attack 2
    263, -- INPUT_MELEE_ATTACK1
    301, -- INPUT_REPLAY_NEWMARKER
    303, -- INPUT_REPLAY_SCREENSHOT
    305, -- INPUT_REPLAY_STARTPOINT
    309, -- INPUT_REPLAY_TOOLS
    311, -- INPUT_REPLAY_SHOWHOTKEY
}

-- https://github.com/overextended/ox_lib/blob/master/imports/raycast/client.lua
local glm_sincos = require 'glm'.sincos
local glm_rad = require 'glm'.rad
local math_abs = math.abs
local GetFinalRenderedCamCoord = GetFinalRenderedCamCoord
local GetFinalRenderedCamRot = GetFinalRenderedCamRot

local function getForwardVector()
    local sin, cos = glm_sincos(glm_rad(GetFinalRenderedCamRot(2)))
    return vec3(-sin.z * math_abs(cos.x), cos.z * math_abs(cos.x), sin.x)
end

local function roundToDecimals(num, decimals)
    if not decimals then decimals = 2 end
    local mult = 10 ^ decimals
    return math.floor(num * mult + 0.5) / mult
end

RegisterCommand('rcc', function()
    local loop = true
    local destination
    local hit, hitEntity, endCoords, surfaceNormal
    local distance = 3.0
    CreateThread(function()
        while loop do
            local coords = GetFinalRenderedCamCoord()
            destination = coords + getForwardVector() * (distance or 10)

            hit, hitEntity, endCoords, surfaceNormal = lib.raycast.fromCoords(GetFinalRenderedCamCoord(), destination, 511, 4)
            Wait(5)
        end
    end)
    while loop do
        for i = 1, #DISABLED do
            DisableControlAction(0, DISABLED[i], true)
        end

        if IsDisabledControlPressed(0, 16) then
            distance -= 0.01
            print('Distance: ', distance)
        elseif IsDisabledControlPressed(0, 17) then
            distance += 0.01
            print('Distance: ', distance)
        end

        local targetCoords = destination
        if hit then
            targetCoords = endCoords
        end

        if targetCoords then
            local pedCoords = GetEntityCoords(cache.ped)
            DrawLine(pedCoords.x, pedCoords.y, pedCoords.z, targetCoords.x, targetCoords.y, targetCoords.z, 255, 0, 0, 255)
            DrawSphere(targetCoords.x, targetCoords.y, targetCoords.z, 0.06, 255, 255, 255, 0.7)

            local vec3Str = ('vec3(%s, %s, %s)'):format(roundToDecimals(targetCoords.x), roundToDecimals(targetCoords.y), roundToDecimals(targetCoords.z))
            -- print('Target Coords: ', vec3Str)

            if IsDisabledControlJustReleased(0, 24) then
                lib.setClipboard(vec3Str)
                loop = false
            elseif IsDisabledControlJustReleased(0, 202) then
                loop = false
            end
        end

        Wait(1)
    end
end)
