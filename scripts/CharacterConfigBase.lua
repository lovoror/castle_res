local C = registerClassAuto();

function C:ctor()
end

--====================================

function C:editorAwake(comPtr)
	self.editorComponentPtr = comPtr;
end

function C:editorDefaultData()
	return "";
end

function C:editorPublish()
	CChapterEditorComponentBehavior.setPublishDataFromSource(self.editorComponentPtr);
end

function C:editorDispose()
end

function C:editorWidgetCreate(widgetPtr)
	self.editorWidgetPtr = widgetPtr;
	return "AI";
end

function C:editorWidgetRefresh()
end

function C:editorClean(resultPtr)
end

function C:editorWidgetDispose()
end

--=====================================

function C:awake(characterDataPtr)
	self.characterDataPtr = characterDataPtr;

	self:loadGeneric();
end

function C:loadGeneric()
	self.genericAttackEffectID = "shared/GenericAttackEffect";
	CCharacterData.loadCharacterData(self.characterDataPtr, self.genericAttackEffectID);
end

function C:damage(attackDataPtr)
	local x, y = CAttackData.getHitPosition(attackDataPtr);

	self:createGenericHitEffect(attackDataPtr, x, y);
	self:createGenericHitSound(x, y);

	return true;
end

function C:injured(attackDataPtr)
	return false;
end

function C:createGenericHitEffect(attackDataPtr, x, y)
	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, 0, x, y, true);
	CBulletBehaviorController.setDoneActionChanged(ptr, true);
	CBulletBehaviorController.setAngle(ptr, 360.0 * math.random(), true);
	CBulletBehaviorController.setScale(ptr, 1.4);

	CBullet.createBullet(self.genericAttackEffectID, CAttackData.getAttackerPtr(attackDataPtr), ptr, nil);
end

function C:createGenericHitSound(x, y)
	local chPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(self.genericAttackEffectID, "hit"), true);
	CAudioManager.set3DAttributes(chPtr, x, y);
	CAudioManager.setVolume(chPtr, 0.5);
	CAudioManager.setPaused(chPtr, false);
end



--TreasureChestConfigBase
local C = registerClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_TREASURE_CHEST_BASE, getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

--====================================

function C:editorAwake(comPtr)
	super.editorAwake(self, comPtr);

	self.TRIGGER_OPENED_ALL = "TC_opened_all";

	local spritePtr = CChapterEditorComponentBehavior.getSpritePtr(comPtr);
	CChapterEditorSprite.addTriggerName(spritePtr, self.TRIGGER_OPENED_ALL);
end

function C:editorDispose()
	local spritePtr = CChapterEditorComponentBehavior.getSpritePtr(self.editorComponentPtr);
	CChapterEditorSprite.removeTriggerName(spritePtr, self.TRIGGER_OPENED_ALL);
end

--=====================================

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.loadCharacterData(characterDataPtr, "shared/GenericTreasureChestOpenEffect");

	self:createIdle();
	self:createSkill0();
end

function C:createIdle()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.setTag(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.setResName(ptr, "close");
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, false);
	CGameActionData.setCollisionCamp(ptr, false, true);
	CGameActionData.setCollisionTag(ptr, CEntityType.PLAYER);

	self:_createAction(ptr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill0()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_SKILL.."0");
	CGameActionData.setTag(ptr, CGameAction.ACTION_SKILL.."0");
	CGameActionData.setScriptName(ptr, "TreasureChestOpen", true);
	CGameActionData.setResName(ptr, "open");
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setKeepTime(ptr, 0.0);
	CGameActionData.setLock(ptr, true);

	self:_createAction(ptr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:_createAction(actionDataPtr)
end



--FoodConfigBase
local C = registerClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_FOOD_BASE, getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);

	self:createIdle();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setScriptName(ptr, "Idle", false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setCollisionTag(ptr, CEntityType.PLAYER);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
