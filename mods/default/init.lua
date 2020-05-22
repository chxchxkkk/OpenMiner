--
-- =====================================================================================
--
--  OpenMiner
--
--  Copyright (C) 2018-2020 Unarelith, Quentin Bazin <openminer@unarelith.net>
--  Copyright (C) 2019-2020 the OpenMiner contributors (see CONTRIBUTORS.md)
--
--  This file is part of OpenMiner.
--
--  OpenMiner is free software; you can redistribute it and/or
--  modify it under the terms of the GNU Lesser General Public
--  License as published by the Free Software Foundation; either
--  version 2.1 of the License, or (at your option) any later version.
--
--  OpenMiner is distributed in the hope that it will be useful,
--  but WITHOUT ANY WARRANTY; without even the implied warranty of
--  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
--  Lesser General Public License for more details.
--
--  You should have received a copy of the GNU Lesser General Public License
--  along with OpenMiner; if not, write to the Free Software Foundation, Inc.,
--  51 Franklin Street, Fifth Floor, Boston, MA  02110-1301 USA
--
-- =====================================================================================
--
if not mods then mods = {} end

mods["default"] = openminer.mod_loader:register_mod("default")
mod = mods["default"]

dofile("blocks.lua")
dofile("items.lua")
dofile("recipes.lua")
dofile("sky.lua")
dofile("trees.lua")
dofile("biomes.lua")
dofile("dimensions.lua")

-- openminer:add_listener(Event.BlockPlaced, function(pos, block, player, world, client, server)
-- 	server:send_chat_message(0, "Block placed at " .. pos.x .. ";" .. pos.y .. ";" .. pos.z .. " by Client" .. player:client_id(), client)
-- end)

-- openminer:add_listener(Event.BlockDigged, function(pos, block, player, world, client, server)
-- 	server:send_chat_message(0, "Block digged at " .. pos.x .. ";" .. pos.y .. ";" .. pos.z .. " by Client" .. player:client_id(), client)
-- end)

openminer:add_listener(Event.BlockActivated, function(pos, block, player, world, client, server)
	if block:string_id() == "default:portal" then
		server:send_chat_message(0, "Swoosh! Changing dimension...", client)
	end
end)

openminer:add_listener(Event.PlayerConnected, function(pos, player, client, server)
	local starting_items = {
		{"default:workbench",       1},
		{"default:dirt",           64},
		{"default:grass",          64},
		{"default:stone",          64},
		{"default:glass",          64},
		{"default:glowstone",      64},
		{"default:furnace",         1},
		{"default:stone_pickaxe",   1},
		{"default:stone_axe",       1},

		{"default:oak_wood",       64},
		{"default:oak_planks",     64},
		{"default:cobblestone",    64},
		{"default:stick",          64},
		{"default:stone_hoe",       1},
		{"default:stone_shovel",    1},
		{"default:iron_ore",       64},
		{"default:coal",           64},

		{"default:iron_ingot",     64},
		{"default:gold_ingot",     64},
		{"default:diamond",        64}
	}


	local player_inv = player:inventory()
	for _, v in ipairs(starting_items) do
		player_inv:add_stack(v[1], v[2])
	end

	server:send_chat_message(0, "Welcome to OpenMiner!", client)
end)

local modpath = mod:path()

function show_inventory(client, screen_width, screen_height, gui_scale)
	local gui = LuaGUI.new()

	gui:set_size(176, 166)
	gui:set_centered(true)

	gui:image {
		name = "img_background",
		pos = {x = 0, y = 0},

		texture = modpath .. "/textures/gui/inventory.png",
		clip = {x = 0, y = 0, width = 176, height = 166},
	}

	gui:inventory {
		name = "inv_main",
		pos = {x = 7, y = 83},

		inventory = {
			source = "player",
			player = "player",
			inventory_name = "main",
			offset = 9,
			count = 9 * 3,
		},

		size = {x = 9, y = 3},

		shift_destination = "inv_hotbar,inv_main",
	}

	gui:inventory {
		name = "inv_hotbar",
		pos = {x = 7, y = 141},

		inventory = {
			source = "player",
			player = "player",
			inventory_name = "main",
			offset = 0,
			count = 9,
		},

		size = {x = 9, y = 1},

		shift_destination = "inv_main,inv_hotbar",
	}

	gui:crafting {
		name = "inv_crafting",
		pos = {x = 97, y = 17},
		result_pos = {x = 97 + 56, y = 17 + 10},

		inventory = {
			source = "temp",
			size = 2,
		},

		shift_destination = "inv_main,inv_hotbar",
	}

	gui:show(client)
end

mod:entity {
	id = "item_drop",

	properties = {
		visual = {
			type = "inventorycube",
			size = 0.25,
			origin = {0.125, 0.125, 0.125},
		},

		is_rotatable = true,

		animation = {
			{
				type = "rotation",
				axis = {0, 0, 1},
				angle = 0.5
			},
			{
				type = "translation",
				delta = {0, 0, -0.0005},
				min = -0.2,
				max = 0,
				loop = true
			}
		},

		hitbox = {0, 0, 0, 0.25, 0.25, 0.25},
	},

	on_collision = function(entity, player, server)
		mods["default"]:give_item_stack(player, entity:item_stack())
		mods["default"]:despawn_entity(entity)
	end,
}

openminer:add_listener(Event.BlockDigged, function(pos, block, player, world, client, server)
	if ServerConfig.useItemDrops then
		mods["default"]:spawn_entity("default:item_drop", {
			position = {pos.x + 0.5, pos.y + 0.5, pos.z + 0.5},
			dimension = world:dimension():id(),

			item_stack = {block:get_item_drop():item():string_id(), block:get_item_drop():amount()}
		})
	else
		mods["default"]:give_item_stack(player, block:get_item_drop())
	end
end)

