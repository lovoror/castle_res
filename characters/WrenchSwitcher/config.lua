local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

--====================================

function C:editorAwake(comPtr)
	super.editorAwake(self, comPtr);

	self.TRIGGER_SWITCH_ON = "Switch_on";
	self.TRIGGER_SWITCH_OFF = "Switch_off";

	local spritePtr = CChapterEditorComponentBehavior.getSpritePtr(comPtr);
	CChapterEditorSprite.addTriggerName(spritePtr, self.TRIGGER_SWITCH_ON);
	CChapterEditorSprite.addTriggerName(spritePtr, self.TRIGGER_SWITCH_OFF);
end

function C:editorDispose()
	local spritePtr = CChapterEditorComponentBehavior.getSpritePtr(self.editorComponentPtr);
	CChapterEditorSprite.removeTriggerName(spritePtr, self.TRIGGER_SWITCH_ON);
	CChapterEditorSprite.removeTriggerName(spritePtr, self.TRIGGER_SWITCH_OFF);
end

--=====================================

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.setGlobalCollisionCycle(characterDataPtr, 1.0);

	CCharacterData.loadSound(characterDataPtr, "start", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "end", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

	self:createIdle();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setScriptName(ptr, "Idle", false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setCollisionCamp(ptr, false, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
