--CClient.setAddress("127.0.0.1", 6000);

if CGameDebugger.isDebug() then
	--CGameDebugger.setPlayerCreatePosition(3759, -8610);
	--CGameDebugger.setPlayerCreatePosition(1000, -7800);
	--CGameDebugger.setPlayerCreatePosition(7340, -5520);
	--CGameDebugger.setPlayerCreatePosition(15146, -917);
	--CGameDebugger.setPlayerCreatePosition(7760, -5536);
	--CGameDebugger.setPlayerCreatePosition(8655, -6869);
	--CGameDebugger.setPlayerCreatePosition(10393, -8784);
	--CGameDebugger.setPlayerCreatePosition(14489, -1582); --boss
	--CGameDebugger.setPlayerCreatePosition(3927, -7900);
	CGameDebugger.setShowDebugCanvas(true);
	--CGameDebugger.setCreateMonsters(false);
	if CGameDebugger.getCustomChapterDataPath() == "" then
		--CGameDebugger.setPlayerCreatePosition(13000, -7180);
		CGameDebugger.setCustomChapterPath("E:/Users/Sephiroth/Desktop/aaa.cpt", "E:/Users/Sephiroth/Desktop/config.lua");
	end
else
	--CGameDebugger.setPlayerCreatePosition(792, -1010);
	--CGameDebugger.setPlayerCreatePosition(2041, -6176);
	--CGameDebugger.setPlayerCreatePosition(7340, -5520);
	--CGameDebugger.setPlayerCreatePosition(14242, -6066);
	--CGameDebugger.setPlayerCreatePosition(8994, -6779);
	--CGameDebugger.setPlayerCreatePosition(14800, -1582); --boss
	--CGameDebugger.setShowDebugCanvas(true);
	--CGameDebugger.setCreateMonsters(false);
	--CGameDebugger.setCustomChapterPath("E:/Users/Sephiroth/Desktop/aaa.cpt", "E:/Users/Sephiroth/Desktop/config.lua");
end

--[[
CGameDebugger.setItem(4, 1); --weapon/3
CGameDebugger.setItem(5, 1); --weapon/4
CGameDebugger.setItem(6, 7); --weapon/5
CGameDebugger.setItem(7, 1); --weapon/6
CGameDebugger.setItem(27, 1); --boot/1
CGameDebugger.setItem(37, 7, 8); --skill/Elementalist/100
CGameDebugger.setItem(38, 7, 9); --skill/Elementalist/101
CGameDebugger.setItem(39, 7, 9); --skill/Elementalist/102
CGameDebugger.setItem(40, 7, 9); --skill/Elementalist/103
CGameDebugger.setItem(33, 3); --ring/301
CGameDebugger.setItem(34, 10); --item/1
--CGameDebugger.setItem(2, 10);
--CGameDebugger.setItem(3, 10);
CGameDebugger.setItem(41, 10);
CGameDebugger.setItem(8, 10);
CGameDebugger.setItem(9, 10);
CGameDebugger.setItem(10, 10);
CGameDebugger.setItem(11, 10);
CGameDebugger.setItem(12, 10);
CGameDebugger.setItem(17, 10);
CGameDebugger.setItem(29, 10);
CGameDebugger.setItem(31, 10);
CGameDebugger.setItem(32, 10);
]]--
CGameDebugger.setItem(13, 10);
CGameDebugger.setItem(14, 10);
CGameDebugger.setItem(15, 10);
CGameDebugger.setItem(16, 10);
CGameDebugger.setItem(18, 10);
CGameDebugger.setItem(19, 10);
CGameDebugger.setItem(20, 10);
CGameDebugger.setItem(21, 10);
CGameDebugger.setItem(22, 10);
CGameDebugger.setItem(23, 10);
CGameDebugger.setItem(24, 10);
CGameDebugger.setItem(25, 10);
CGameDebugger.setItem(26, 10);

CGameDebugger.setItem(34, 10); --item/1
CGameDebugger.setItem(35, 10);
CGameDebugger.setItem(36, 10);

CGameDebugger.setItem(46, 10);
CGameDebugger.setItem(47, 10);
CGameDebugger.setItem(48, 10);

CGameDebugger.setItem(49, 10);

CGameDebugger.writeSaveData();

function chapterEditorBehaviorComponentInit(fn)
	fn("AI", "ai");
	fn("Destructible Wall", "@DestructibleWall");
	fn("Rope", "@Rope");
	fn("UV Animator", "@UVAnimator");
end
