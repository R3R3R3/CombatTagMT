
-- CombatTag

local COMBAT_TAG_TIMER = 10

function combat_tag.get_tag(player)
   local meta = player:get_meta()
   local tag_end = meta:get_int("combat_tag_end")
   if tag_end == 0 then
      return nil
   end

   local current_time = os.time(os.date("!*t"))
   if current_time > tag_end then
      return nil
   else
      return tag_end
   end
end

function combat_tag.tag(player, length)
   local player_tag_end = combat_tag.get_tag(player)
   if not player_tag_end then
      minetest.chat_send_player(
         player:get_player_name(),
         "You've been combat tagged for " .. tostring(length) .. "s."
      )
   end
   local meta = player:get_meta()
   -- meta:mark_as_private("combat_tag_end")
   meta:set_int(
      "combat_tag_end",
      os.time(os.date("!*t")) + length
   )
end

minetest.register_on_punchplayer(
   function(target, hitter, time_from_last_punch, tool_capabilities, unused_dir, damage)
      if target:get_hp() == 0 then
         return
      end

      combat_tag.tag(target, COMBAT_TAG_TIMER)
      combat_tag.tag(hitter, COMBAT_TAG_TIMER)
end)

minetest.register_on_leaveplayer(function(player)
      local pname = player:get_player_name()

      if combat_tag.get_tag(player) then
         -- TODO: temporary, need a better combat log effect...
         minetest.chat_send_all(pname .. " combat logged!")
         player:set_hp(0) -- RIP
      end
end)
