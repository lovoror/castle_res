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

CharacterBattery = {};
CharacterBattery.VELOCITY = 600.0;
CharacterBattery.GRAVITY_SCALE = 0.2;

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.loadCharacterData(characterDataPtr, "@(self)/1");

	self:createIdle();
	self:createSkill0();
	self:createSkill1();
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setScriptName(ptr, "Idle", false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill0()
	local ptr = createDefaultSkillActionData("0");
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setResName(ptr, "daiji");
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_SKILL.."1");
	CGameActionData.setScriptName(ptr, "Skill0", false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end

function C:createSkill1()
	local ptr = createDefaultSkillActionData("1");
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.setResName(ptr, "gongji");
	CGameActionData.setScriptName(ptr, "Skill1", false);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
