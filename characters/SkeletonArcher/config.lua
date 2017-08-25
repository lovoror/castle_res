local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

--====================================

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

	self.KEY_GUARDING_AREA_SCALE = "ga";
	self.KEY_NOT_MOVE = "nm";

	CComponentBehaviorWidget.HLayoutBegin(widgetPtr);

	local hp, scaleLabel, scale = createEditorLineEdit(widgetPtr, "Guarding Area Scale");
	self.editorScale = scale;

	local hp, notMoveLabel, notMove = createEditorCheckBox(widgetPtr, "Not Move");
	self.editorMotMove = notMove;

	CComponentBehaviorWidget.HLayoutEnd(widgetPtr);

	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, scaleLabel, self.KEY_GUARDING_AREA_SCALE);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, notMoveLabel, self.KEY_NOT_MOVE);

	self.editorScaleListener = CESLineEdit.setActionListener(scale, function()
		editorLineEditChangedUFloat(scale, self.editorWidgetPtr, self.KEY_GUARDING_AREA_SCALE, "1", "1");
	end);

	self.editorNotMoveListener = CESLineEdit.setActionListener(notMove, function()
		editorCheckBoxChanged(notMove, self.editorWidgetPtr, self.KEY_NOT_MOVE);
	end);

	return "AI";
end

function C:editorWidgetRefresh()
	local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_GUARDING_AREA_SCALE);
	if value == "" then value = "1"; end
	CESLineEdit.setText(self.editorScale, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_NOT_MOVE);
	CESCheckBox.setChecked(self.editorMotMove, value == "1");
end

function C:editorWidgetDispose()
	if self.editorScale ~= nil then
		Cunref(self.editorScaleListener);
		self.editorScale = nil;
	end
	if self.editorMotMove ~= nil then
		Cunref(self.editorNotMoveListener);
		self.editorMotMove = nil;
	end
end

--=====================================

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setGlobalCollisionCycle(characterDataPtr, 1.0);
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/1");

	self:createIdle();
	self:createRun();
	self:createFall();
	self:createLanding();
	self:createSkill0();
	self:createHurt();
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

function C:createRun()
	local ptr = createDefaultRunActionData();
	CGameActionData.setResName(ptr, "yidong");
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createFall()
	local ptr = createDefaultFallActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createLanding()
	local ptr = createDefaultLandingActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setKeepTime(ptr, 0.5);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	setActionDataDefaultBattleData(ptr, 0);

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

function C:createHurt()
	local ptr = createDefaultHurtActionData();
	CGameActionData.setResName(ptr, "shouji");
	CGameActionData.setRigid(ptr, 0, CRigidAtk.LOW, CRigidDef.LOW - 1);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createDie()
	local ptr = createDefaultDieActionData();
	CGameActionData.setResName(ptr, "siwang");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
