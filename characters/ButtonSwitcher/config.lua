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

	self:createIdle();
	self:createSkill0();
	self:createSkill1();
end

function C:createIdle()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.setTag(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.setResName(ptr, "idle");
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setCollisionCamp(ptr, false, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill0()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_SKILL.."0");
	CGameActionData.setTag(ptr, CGameAction.ACTION_SKILL.."0");
	CGameActionData.setResName(ptr, "down");
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setKeepTime(ptr, 0.0);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setCollisionCamp(ptr, false, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill1()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_SKILL.."1");
	CGameActionData.setTag(ptr, CGameAction.ACTION_SKILL.."1");
	CGameActionData.setResName(ptr, "up");
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setCollisionCamp(ptr, false, true);
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_IDLE);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
