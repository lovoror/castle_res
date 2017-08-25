local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

--====================================

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

	self.KEY_TURN_BACK_DISTANCE = "dis";

	self.DEFAULT_TURN_BACK_DISTANCE = 1000;

	CComponentBehaviorWidget.HLayoutBegin(widgetPtr);

	local hp, disLabel, dis = createEditorLineEdit(widgetPtr, "Turn Back Distance");
	self.editorDis = dis;

	CComponentBehaviorWidget.HLayoutEnd(widgetPtr);

	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, disLabel, self.KEY_TURN_BACK_DISTANCE);

	self.editorDisListener = CESLineEdit.setActionListener(dis, function()
		editorLineEditChangedUFloat(dis, self.editorWidgetPtr, self.KEY_TURN_BACK_DISTANCE, "", tostring(self.DEFAULT_TURN_BACK_DISTANCE));
	end);

	return "AI";
end

function C:editorWidgetRefresh()
	local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_TURN_BACK_DISTANCE);
	if value == "" then value = tostring(self.DEFAULT_TURN_BACK_DISTANCE); end
	CESLineEdit.setText(self.editorDis, value);
end

function C:editorWidgetDispose()
	if self.editorDis ~= nil then
		Cunref(self.editorDisListener);
		self.editorDis = nil;
	end
end

--=====================================

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setActionMix(characterDataPtr, "daiji", "yidong", 0.3);
	CCharacterData.setActionMix(characterDataPtr, "yidong", "shouji", 0.3);

	CCharacterData.setGlobalCollisionCycle(characterDataPtr, 1.0);

	self:createIdle();
	self:createRun();
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
