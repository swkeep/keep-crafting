local Blueprints = {
    ['pistol_suppressor'] = {
        item_settings = {
            label = 'Pistol suppressor',
            image = 'pistol_suppressor', -- use inventory's images
            object = {
                name = 'w_at_ar_supp_02',
                rotation = vector3(45.0, 0.0, 0.0)
            },
            level = 5,
            hide_until_reaches_level = true,
            job = {
                allowed_list = {},
                allowed_grades = {}
            }
        },
        crafting = {
            success_rate = 100,
            amount = 1, -- crafted amount
            duration = 60,
            materials = {
                ["metalscrap"] = 50,
                ["steel"] = 60,
                ["rubber"] = 30,
            },
            exp_per_craft = 5
        }
    },
    ['weapon_assaultrifle_mk2'] = {
        item_settings = {
            label = 'Assault Rifle Mk II',
            image = 'weapon_assaultrifle_mk2', -- use inventory's images
            object = {
                name = 'w_ar_assaultrifle',
                rotation = vector3(45.0, 0.0, 0.0)
            },
            level = 0,
            job = {
                allowed_list = {},
                allowed_grades = {}
            }
        },
        crafting = {
            success_rate = 100,
            amount = 1, -- crafted amount
            duration = 5,
            materials = {
                ["plastic"] = 4,
            },
            exp_per_craft = 50
        }
    },
}

-- DO NOT TOUCH CODE BELLOW IF YOU DON"T KNOW WHAT YOU'RE DOING

function IsBlueprint(item_name)
    if Blueprints[item_name] then
        return true
    else
        return false
    end
end

function GetBlueprint(item_name)
    if Blueprints[item_name] then
        return Blueprints[item_name]
    else
        return false
    end
end
