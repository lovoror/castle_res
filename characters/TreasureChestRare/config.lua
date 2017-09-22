local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_TREASURE_CHEST_BASE));

function C:awake(characterDataPtr)
    super.awake(self, characterDataPtr);

    CCharacterData.loadCharacterData(characterDataPtr, "@(self)/IdleEffect");
end