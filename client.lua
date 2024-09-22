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

local function roundToDecimals(num, decimals)
    if not decimals then decimals = 2 end
    local mult = 10 ^ decimals
    return math.floor(num * mult + 0.5) / mult
end

RegisterCommand('rcc', function()
    local loop = true
    local hit, hitEntity, endCoords, surfaceNormal
    CreateThread(function()
        while loop do
            hit, hitEntity, endCoords, surfaceNormal = lib.raycast.fromCamera(1, 4, 50.0)
            Wait(5)
        end
    end)
    while loop do
        for i = 1, #DISABLED do
            DisableControlAction(0, DISABLED[i], true)
        end

        if endCoords then
            if hit then
                local pedCoords = GetEntityCoords(cache.ped)
                DrawLine(pedCoords.x, pedCoords.y, pedCoords.z, endCoords.x, endCoords.y, endCoords.z, 255, 0, 0, 255)
                DrawSphere(endCoords.x, endCoords.y, endCoords.z, 0.06, 255, 255, 255, 0.7)

                local vec3Str = ('vec3(%s, %s, %s)'):format(roundToDecimals(endCoords.x), roundToDecimals(endCoords.y), roundToDecimals(endCoords.z))
                print(vec3Str)

                if IsDisabledControlJustReleased(0, 24) then
                    lib.setClipboard(vec3Str)
                    loop = false
                elseif IsDisabledControlJustReleased(0, 202) then
                    loop = false
                end
            end
        end

        Wait(1)
    end
end)
