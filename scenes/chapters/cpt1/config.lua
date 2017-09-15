local C = registerClassAuto(getClass(CHAPTER_CONFIG_PACKAGE, CHAPTER_CONFIG_BASE));

function C:awake()
    local listPtr = CChapterScene.createLootList("TreasureChestCommon");
    --head
    CChapterLootList.addItem(listPtr, 8, 0.1, CChapterDifficulty.NORMAL);
    --chest
    CChapterLootList.addItem(listPtr, 13, 0.1, CChapterDifficulty.NORMAL);
    --boots
    CChapterLootList.addItem(listPtr, 27, 0.1, CChapterDifficulty.NORMAL);
    --item
    CChapterLootList.addItem(listPtr, 34, 0.2, CChapterDifficulty.NORMAL);

    local listPtr = CChapterScene.createLootList("TreasureChestUnommon");
    --head
    CChapterLootList.addItem(listPtr, 9, 0.1, CChapterDifficulty.NORMAL);
    --chest
    CChapterLootList.addItem(listPtr, 14, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 18, 0.1, CChapterDifficulty.NORMAL);
    --boots
    CChapterLootList.addItem(listPtr, 28, 0.1, CChapterDifficulty.NORMAL);
    --item
    CChapterLootList.addItem(listPtr, 35, 0.2, CChapterDifficulty.NORMAL);

    local listPtr = CChapterScene.createLootList("TreasureChestRare");
    --chest
    CChapterLootList.addItem(listPtr, 15, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 19, 0.1, CChapterDifficulty.NORMAL);
    --boots
    CChapterLootList.addItem(listPtr, 29, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 30, 0.1, CChapterDifficulty.NORMAL);
    --item
    CChapterLootList.addItem(listPtr, 36, 0.2, CChapterDifficulty.NORMAL);

    local listPtr = CChapterScene.createLootList("TreasureChestEpic");
    --weapon
    CChapterLootList.addItem(listPtr, 4, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 5, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 6, 0.2, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 7, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 41, 0.1, CChapterDifficulty.NORMAL);
    --head
    CChapterLootList.addItem(listPtr, 10, 0.2, CChapterDifficulty.NORMAL);
    --necklace
    CChapterLootList.addItem(listPtr, 11, 0.2, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 12, 0.2, CChapterDifficulty.NORMAL);
    --chest
    CChapterLootList.addItem(listPtr, 16, 0.2, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 20, 0.2, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 22, 0.2, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 23, 0.2, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 25, 0.2, CChapterDifficulty.NORMAL);
    --boots
    CChapterLootList.addItem(listPtr, 29, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 30, 0.1, CChapterDifficulty.NORMAL);
    --ring
    CChapterLootList.addItem(listPtr, 31, 0.2, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 32, 0.2, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 33, 0.2, CChapterDifficulty.NORMAL);
    --skill
    CChapterLootList.addItem(listPtr, 40, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 44, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 45, 0.1, CChapterDifficulty.NORMAL);

    local listPtr = CChapterScene.createLootList("TreasureChestLegendary");
    --weapon
    CChapterLootList.addItem(listPtr, 4, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 5, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 6, 0.2, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 7, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 41, 0.1, CChapterDifficulty.NORMAL);
    --chest
    CChapterLootList.addItem(listPtr, 17, 0.2, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 21, 0.2, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 24, 0.2, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 26, 0.2, CChapterDifficulty.NORMAL);
    --skill
    CChapterLootList.addItem(listPtr, 40, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 44, 0.1, CChapterDifficulty.NORMAL);
    CChapterLootList.addItem(listPtr, 45, 0.1, CChapterDifficulty.NORMAL);

    local listPtr = CChapterScene.createLootList("SkeletonMage");
    --skill
    CChapterLootList.addItem(listPtr, 39, 0.1, CChapterDifficulty.NORMAL);
end