local C = registerClassAuto(getClass(CHAPTER_CONFIG_PACKAGE, CHAPTER_CONFIG_BASE));

function C:setBuyItems(shopPtr, id, diff)
    local fn = function(id)
         CUIShopView.addBuyItem(shopPtr, id);
    end

    if id == "" then
        fn(4);
        fn(5);
        fn(6);
        fn(7);
        fn(8);
    elseif id == "1" then
       if diff == ChapterDifficulty.NORMAL then
            --todo
       elseif diff == ChapterDifficulty.HARD then
            --todo
       end
    end
end