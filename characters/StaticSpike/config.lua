local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

--====================================

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

	self.KEY_LENGTH = "len";
	self.KEY_QUANTITY = "n";
	self.KEY_GAP = "gap";

	self.DEFAULT_QUANTITY = 3;
	self.DEFAULT_GAP = 0.0;

	CComponentBehaviorWidget.HLayoutBegin(widgetPtr);

	local hp, lenLabel, len = createEditorLineEdit(widgetPtr, "Length");
	self.editorLen = len;
	CHorizontalPanel.setSingle(hp, lenLabel, len);
	CComponentBehaviorWidget.addHLayoutPanel(widgetPtr, hp);

	local hp, quantityLabel, quantity = createEditorLineEdit(widgetPtr, "Quantity");
	self.editorQuantity = quantity;

	local hp, gapLabel, gap = createEditorLineEdit(widgetPtr, "Gap");
	self.editorGap = gap;

	CComponentBehaviorWidget.HLayoutEnd(widgetPtr);

	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, lenLabel, self.KEY_LENGTH);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, quantityLabel, self.KEY_QUANTITY);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, gapLabel, self.KEY_GAP);

	self.editorLenListener = CESLineEdit.setActionListener(len, function()
		editorLineEditChangedUFloat(len, self.editorWidgetPtr, self.KEY_LENGTH, "0", "0");
	end);

	self.editorQuantityListener = CESLineEdit.setActionListener(quantity, function()
		editorLineEditChangedUInt(quantity, self.editorWidgetPtr, self.KEY_QUANTITY, "", tostring(self.DEFAULT_QUANTITY));
	end);

	self.editorGapListener = CESLineEdit.setActionListener(gap, function()
		editorLineEditChangedUFloat(gap, self.editorWidgetPtr, self.KEY_GAP, "", tostring(self.DEFAULT_GAP));
	end);

	return "AI";
end

function C:editorWidgetRefresh()
	local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_LENGTH);
	if value == "" then value = "0"; end
	CESLineEdit.setText(self.editorLen, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_QUANTITY);
	if value == "" then value = tostring(self.DEFAULT_QUANTITY); end
	CESLineEdit.setText(self.editorQuantity, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_GAP);
	if value == "" then value = tostring(self.DEFAULT_GAP); end
	CESLineEdit.setText(self.editorGap, value);
end

function C:editorWidgetDispose()
	if self.editorLen ~= nil then
		Cunref(self.editorLenListener);
		self.editorLen = nil;
	end
	if self.editorQuantity ~= nil then
		Cunref(self.editorQuantityListener);
		self.editorQuantity = nil;
	end
	if self.editorGap ~= nil then
		Cunref(self.editorGapListener);
		self.editorGap = nil;
	end
end

--=====================================

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.setGlobalCollisionCycle(characterDataPtr, 1.0);

	self:createIdle();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setScriptName(ptr, "Idle", false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setRigid(ptr, 0, CRigidAtk.NRM, CRigidDef.LOW);
	CGameActionData.setCollisionForce(ptr, 0, 400.0, 0.0, 1.0, true, 400.0, 0.0, 1.0, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
