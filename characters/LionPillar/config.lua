local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

--====================================

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

	self.KEY_GUARDING_AREA_SCALE = "ga";

	CComponentBehaviorWidget.HLayoutBegin(widgetPtr);

	local hp, scaleLabel, scale = createEditorLineEdit(widgetPtr, "Guarding Area Scale");
	self.editorScale = scale;

	CComponentBehaviorWidget.HLayoutEnd(widgetPtr);

	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, scaleLabel, self.KEY_GUARDING_AREA_SCALE);

	self.editorScaleListener = CESLineEdit.setActionListener(scale, function()
		editorLineEditChangedUFloat(scale, self.editorWidgetPtr, self.KEY_GUARDING_AREA_SCALE, "1", "1");
	end);

	return "AI";
end

function C:editorWidgetRefresh()
	local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_GUARDING_AREA_SCALE);
	if value == "" then value = "1"; end
	CESLineEdit.setText(self.editorScale, value);
end

function C:editorWidgetDispose()
	if self.editorScale ~= nil then
		Cunref(self.editorScaleListener);
		self.editorScale = nil;
	end
end

--=====================================

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/1");
	CCharacterData.setBodyType(characterDataPtr, CBodyTypeEnum.ALL);
	CCharacterData.setMass(characterDataPtr, 0.0);

	self:createIdle();
	self:createVeer();
	self:createSkill0();
	self:createDie();
end

function C:injured(attackDataPtr)
	setDefaultInjuredEffect(attackDataPtr);

	return true;
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createVeer()
	local ptr = createDefaultIdleActionData(CGameAction.ACTION_VEER);
	CGameActionData.setResName(ptr, "zhuanshen");
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_IDLE);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill0()
	local ptr = createDefaultSkillActionData("0");
	CGameActionData.setResName(ptr, "gongji");
	CGameActionData.setScriptName(ptr, "Skill0", false);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "siwang");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end