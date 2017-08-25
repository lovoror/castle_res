local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

--====================================

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

	self.KEY_ID = "id";
	self.KEY_TYPE = "type";

	CComponentBehaviorWidget.HLayoutBegin(widgetPtr);

	local hp = CHorizontalPanel.create();
	local entityLabel = CESLabel.create("Entity");
	local entity = CESSpriteRefBox.create();
	self.editorEntity = entity;
	CHorizontalPanel.setSingle(hp, entityLabel, entity);
	CComponentBehaviorWidget.addHLayoutPanel(widgetPtr, hp);

	local hp = CHorizontalPanel.create();
	local typeLabel = CESLabel.create("Type");
	local type = CESComboBox.create();
	CESComboBox.addItem(type, "Gold");
	CESComboBox.addItem(type, "Silver");
	self.editorType = type;
	CHorizontalPanel.setSingle(hp, typeLabel, type);
	CComponentBehaviorWidget.addHLayoutPanel(widgetPtr, hp);

	CComponentBehaviorWidget.HLayoutEnd(widgetPtr);

	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, entityLabel, self.KEY_ID);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, typeLabel, self.KEY_TYPE);

	self.editorEntityListener = CESSpriteRefBox.setActionListener(entity, function()
		local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);
		local value = tostring(CESSpriteRefBox.getRef(entity));
		if value == "0" then value = ""; end
		CChapterEditorComponentBehavior.setValue(com, self.KEY_ID, value);
	end);

	self.editorTypeListener = CESSpriteRefBox.setActionListener(type, function()
		local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);
		local value = tostring(CESComboBox.getCurrentIndex(type));
		if value == "0" then value = ""; end
		CChapterEditorComponentBehavior.setValue(com, self.KEY_TYPE, value);
	end);

	return "AI";
end

function C:editorWidgetRefresh()
	local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_ID);
	if value == "" then value = "0"; end
	CESSpriteRefBox.setRef(self.editorEntity, toint(value));

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_TYPE);
	if value == "" then value = "0"; end
	CESComboBox.setCurrentIndex(self.editorType, toint(value));
end

function C:editorWidgetDispose()
	if self.editorEntity ~= nil then
		Cunref(self.editorEntityListener);
		self.editorEntity = nil;
	end

	if self.editorType ~= nil then
		Cunref(self.editorTypeListener);
		self.editorType = nil;
	end
end

--=====================================

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);

	self:createIdle();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setLock(ptr, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
