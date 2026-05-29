local Logic = {}

function Logic.transfer_items(source, target, is_to_shell)
    if not source.valid or not target.valid then return end
    if target.type == "character" then target.character_inventory_slots_bonus = 1000 end

    local src_invs = is_to_shell and 
        {defines.inventory.character_armor, defines.inventory.character_guns, defines.inventory.character_ammo, defines.inventory.character_main} or 
        {defines.inventory.chest}

    -- Хирургическое распределение
    for _, inv_id in ipairs(src_invs) do
        local inv = source.get_inventory(inv_id)
        if inv then
            for i = 1, #inv do
                local stack = inv[i]
                if stack and stack.valid_for_read then
                    target.insert(stack)
                    stack.clear()
                end
            end
        end
    end
    if target.type == "character" then target.character_inventory_slots_bonus = 0 end
end

return Logic