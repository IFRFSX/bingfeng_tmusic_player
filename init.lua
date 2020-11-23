music = {
     list = {}
}

music_playing = nil

local song = {}

minetest.mkdir(minetest.get_modpath("bingfeng_tmusic_player") .. "/sounds")

function music_list()
        music.list = minetest.get_dir_list(minetest.get_modpath("bingfeng_tmusic_player") ..
	"/sounds", false)
        local s = minetest.serialize(music.list)
        return s:gsub("_", ""):gsub("return ",""):gsub("tmusicplayer", ""):
	gsub("%.ogg", ""):gsub("{", ""):gsub("}", ""):gsub("\"", ""):gsub(" ", "")
end

function music_form(player)
        minetest.log(player:get_player_name())
        minetest.show_formspec(player:get_player_name(), "tmusic_player:songs",
		"size[12,12]" ..
		"label[0,0;可以播放的歌曲(Playable songs)：]" ..
	     	"image[7.5,0;6,1.6;bingfeng_tmusic_player.png]" ..
	     	"textlist[.5,1;8,11;song_list;".. music_list() .. "]" ..
	     	"button[9,8.5;3,1;stop;停止]" ..
	     	"button[9,7.5;3,1;loop_current;循环当前歌曲]" ..
	     	"button[9,9.5;3,1;help;帮助]" ..
	     	"button_exit[9,10.5;3,1;exit;关闭]")
end

minetest.register_chatcommand("music", {
        func = function(name, param)
	        local player = minetest.get_player_by_name(name)
	        music_form(player)
        end
})

minetest.setting_set("individual_loop", "true")

minetest.register_on_player_receive_fields(function(player, formname, fields)
     if formname == "tmusic_player:songs" then
          	if fields.stop then
               		if music_playing == nil then
                    		return false
               		else
				song = {}
                    		music_playing = minetest.sound_stop(music_playing)
                    		minetest.setting_set("individual_loop", "false")
               		end
          	end
          	if fields.loop_current then
               		if minetest.setting_getbool("individual_loop") == true then
                    		if music_playing ~= nil then
                         		music_playing = minetest.sound_stop(
					music_playing)
				end
                         	if music_playing == nil then
                              		music_playing = minetest.sound_play(
					song, {
                                   	gain = 10,
                                   	to_player = player:get_player_name(),
					loop = true
                              		})
                         	end
                    
               		end
          	end
          	if fields.help then
          	--[[
              	for x,y in pairs(minetest.get_connected_players()) do
              	    minetest.log("前：" .. x .. "||后：" .. y:get_player_name())
              	end
          	--]]
               		minetest.show_formspec(player:get_player_name(),
			"tmusic_player:help",
                        "size[9,9]" ..
                    	"label[4,0;帮助]" ..
                    	"label[.25,.5;添加音乐：]" ..
                    	"label[0,1;本程序只支持OGG Vorbis格式的音频，\n" ..
			"您需要转换音乐格式为ogg，并且将文件名设置为\n" ..
			"“tmusic_player_xyz.ogg”，\n" ..
			"而'xyz'就是播放器在使用时显示的名称，\n" .. 
			"然后将这个文件放入“sounds”文件夹。]" ..
			"label[.25,3;播放：请在聊天中输入“/music”，]" ..
			"label[0,3.5;打开主界面，然后单击你想听的歌曲。]" ..
			
                    	"label[.25,4;停止播放：]" ..
                    	
                    	"label[0,4.5;点击“停止”按钮，" ..
			"如果没有音乐正在播放，" ..
			"那么什么都不会发生。]" ..
                    	"label[.25,5;循环播放音乐：]" ..
                    	"label[0,5.5;单击选择音乐后，按“循环播放音乐”。]" ..

                    	"image[2,6;8,2;bingfeng_tmusic_player.png]" ..
                    	"button[0,8;2,1;back;返回]" ..
                    	"button_exit[2,8;2,1;exit;关闭]")
          	end
		local event = minetest.explode_textlist_event(fields.song_list)
		if event.type == "CHG" then
			if #music.list >= 1 then
				if music_playing ~= nil then
					music_playing = minetest.sound_stop(
					music_playing)
				end
				if music_playing == nil then
					song = music.list[event.index]:gsub("%.ogg", "")
					music_playing = minetest.sound_play(song, {
					gain = 10,
					to_player = player:get_player_name()
					})
				end
			end
		end
     	end
     	if formname == "tmusic_player:help" then
	     	if fields.back then
                  	music_form(player)
             	end
	end
end)
