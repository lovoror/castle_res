local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_TREASURE_CHEST_BASE));

--====================================

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

	self.KEY_CHAPTER_CLEAR = "clear";

	CComponentBehaviorWidget.HLayoutBegin(widgetPtr);

	local hp, clearLabel, clear = createEditorCheckBox(widgetPtr, "Chapter Clear");
	self.editorClear = clear;

	CComponentBehaviorWidget.HLayoutEnd(widgetPtr);

	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, clearLabel, self.KEY_CHAPTER_CLEAR);

	self.editorClearListener = CESCheckBox.setActionListener(clear, function()
		editorCheckBoxChanged(clear, self.editorWidgetPtr, self.KEY_CHAPTER_CLEAR);
	end);

	return "AI";
end

function C:editorWidgetRefresh()
	local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_CHAPTER_CLEAR);
	CESCheckBox.setChecked(self.editorClear, value == "1");
end

function C:editorWidgetDispose()
	if self.editorClear ~= nil then
		Cunref(self.editorClearListener);
		self.editorClear = nil;
	end
end

--=====================================

function C:awake(characterDataPtr)
    super.awake(self, characterDataPtr);

	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/CreateEffect");
    CCharacterData.loadCharacterData(characterDataPtr, "@(self)/IdleEffect");

	self:createCreate();
end

function C:createCreate()
	local ptr = createDefaultCreateActionData();
	CGameActionData.setResName(ptr, "chusheng");
	CGameActionData.setScriptName(ptr, "Create");

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:_createAction(actionDataPtr)
	if CGameActionData.getTag(actionDataPtr) == CGameAction.ACTION_IDLE then
		CGameActionData.setScriptName(actionDataPtr, "Idle");
	end
end