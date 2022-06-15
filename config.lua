Config = Config or {}

Config.categories = {
     ['misc'] = {
          key = 'misc',
          label = 'Misc',
          icon = 'fa-solid fa-tags',
          jobs = {},
     },
     ['weapons'] = {
          key = 'weapons',
          label = 'Weapons',
          icon = 'fa-solid fa-gun',
          jobs = {},
          sub_categories = {
               ['pistol'] = {
                    label = 'Pistol',
               },
               ['smg'] = {
                    label = 'SMG',
               },
          }
     },
     ['medical'] = {
          key = 'medical',
          label = 'Medical',
          icon = 'fa-solid fa-hand-holding-medical',
          jobs = {}
     }
}

Config.permanent_items = {
     'wrench'
}

local misc_recipe = {
     ['repairkit'] = {
          categories = {
               main = 'misc',
          },
          item_settings = {
               label = 'Repair kit',
               icon = 'fa-solid fa-gun',
               object = {
                    name = 'v_ind_cs_toolbox4',
                    rotation = vector3(45.0, 0.0, -45.0)
               },
               image = 'repairkit', -- use inventory's images
               is_gun = false,
               level = 0,
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
     ['bandage'] = {
          categories = {
               main = 'misc',
          },
          item_settings = {
               label = 'Bandage',
               image = 'bandage', -- use inventory's images
               is_gun = false,
               level = 0,
               job = {
                    allowed_list = {},
                    allowed_grades = {}
               }
          },
          crafting = {
               success_rate = 100,
               amount = 1, -- crafted amount
               duration = 3,
               materials = {
                    ["plastic"] = 1,
               },
               exp_per_craft = 5
          }
     },
     ['radio'] = {
          categories = {
               main = 'misc',
          },
          item_settings = {
               label = 'Radio',
               image = 'radio', -- use inventory's images
               object = {
                    name = 'v_serv_radio',
                    rotation = vector3(0.0, 0.0, 0.0)
               },
               is_gun = false,
               level = 0,
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
                    ["steel"] = 5,
                    ["plastic"] = 5,
               },
               exp_per_craft = 5
          }
     },
}

local weapons_recipe = {
     ['w_ar_carbinerifle'] = {
          categories = {
               sub = 'smg',
          },
          item_settings = {
               label = 'Rifle',
               image = 'weapon_advancedrifle', -- use inventory's images
               object = {
                    name = 'w_ar_carbinerifle',
                    rotation = vector3(45.0, 0.0, 0.0)
               },
               is_gun = false,
               level = 0,
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
     ['w_ar_carbineriflemk2_mag1'] = {
          categories = {
               sub = 'smg',
          },
          item_settings = {
               label = 'Rifle Mag',
               image = 'rifle_drummag', -- use inventory's images
               object = {
                    name = 'w_ar_assaultrifle_boxmag',
                    rotation = vector3(45.0, 0.0, 0.0)
               },
               is_gun = false,
               level = 0,
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
     }
}

Config.workbenches = {
     {
          coords = vector3(120.10, 6627.28, 29.55),
          item_show_case_offset = vector3(0.65, 0.5, 1.2),
          rotation = vector3(0.0, 0.0, 45.0),
          job = {
               allowed_list = { 'police' },
               allowed_grades = { ['police'] = {} }
          },
          categories = { Config.categories.weapons },
          recipes = { weapons_recipe },
          radius = 3.0
     },
     {
          coords = vector3(106.51, 6606.23, 29.55),
          rotation = vector3(0.0, 0.0, 135.0),
          job = {
               allowed_list = { 'police' },
               allowed_grades = {}
          },
          categories = { Config.categories.misc, Config.categories.medical },
          recipes = { misc_recipe },
          radius = 3.0
     },
     {
          table_model = 'gr_prop_gr_bench_03a',
          coords = vector3(-1838.76, 2909.63, 38.90),
          rotation = vector3(0.0, 0.0, 150.0),
          job = {
               allowed_list = { 'police' },
               allowed_grades = {}
          },
          categories = { Config.categories.weapons },
          recipes = { weapons_recipe },
          radius = 3.0
     }
}


-- gr_prop_gr_missle_long
-- gr_prop_gr_missle_short
-- gr_int02_generator_01
-- gr_prop_gr_hammer_01

-- w_sr_heavysnipermk2_mag2
-- w_sb_smgmk2_mag2
-- w_sb_smgmk2_mag1
-- w_pi_pistolmk2_mag1
-- w_mg_combatmgmk2_mag1
-- w_ar_carbineriflemk2_mag1
-- w_ar_assaultriflemk2_mag1
-- w_ex_vehiclemissile_3
-- w_ex_vehiclemissile_1
-- w_ex_vehiclemissile_2
-- w_ex_vehiclemortar

-- w_sg_pumpshotgunmk2_mag1
-- w_sg_pumpshotgunh4_mag1
-- gr_prop_gr_adv_case

-- w_at_pi_flsh_2
-- w_at_afgrip_2
-- w_at_muzzle_1
-- w_at_muzzle_3
-- w_at_muzzle_2
-- w_at_muzzle_5
-- w_at_muzzle_6
-- w_at_muzzle_7
-- w_at_muzzle_8
-- w_at_muzzle_9

-- w_at_pi_comp_1
-- w_at_pi_rail_1
-- w_at_scope_macro_2_mk2
-- w_at_scope_small_mk2
-- w_at_scope_medium_2
-- w_at_scope_nv
-- w_at_sights_1
-- w_at_sights_smg
-- w_at_sr_supp3


-- gr_prop_gr_drill_01a

-- gr_prop_gr_driver_01a
-- gr_prop_gr_pliers_01
-- gr_prop_gr_pliers_02
-- gr_prop_gr_rasp_01
-- gr_prop_gr_rasp_02
-- gr_prop_gr_rasp_03
-- gr_prop_gr_sdriver_01
-- gr_prop_gr_sdriver_02
-- gr_prop_gr_sdriver_03

-- gr_prop_gr_vice_01a
