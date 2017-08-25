local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

--====================================

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

	self.KEY_ELAPSED = "et";
	self.KEY_COOL_DOWN = "cd";
	self.KEY_DURATION = "dur";
	self.KEY_LENGTH = "len";

	self.DEFAULT_COOL_DOWN = 2.0;
	self.DEFAULT_DURATION = 4.0;
	self.DEFAULT_LENGTH = 320.0;

	CComponentBehaviorWidget.HLayoutBegin(widgetPtr);

	local hp, elapsedLabel, elapsed = createEditorLineEdit(widgetPtr, "Elapsed");
	self.editorElapsed = elapsed;

	local hp, cdLabel, cd = createEditorLineEdit(widgetPtr, "Cool Down");
	self.editorCD = cd;

	local hp, durLabel, dur = createEditorLineEdit(widgetPtr, "Duration");
	self.editorDur = dur;

	local hp, lenLabel, len = createEditorLineEdit(widgetPtr, "Length");
	self.editorLen = len;

	CComponentBehaviorWidget.HLayoutEnd(widgetPtr);

	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, elapsedLabel, self.KEY_ELAPSED);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, cdLabel, self.KEY_COOL_DOWN);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, durLabel, self.KEY_DURATION);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, lenLabel, self.KEY_LENGTH);

	self.editorElapsedListener = CESLineEdit.setActionListener(elapsed, function()
		editorLineEditChangedUFloat(elapsed, self.editorWidgetPtr, self.KEY_ELAPSED, "0", "0");
	end);

	self.editorCDListener = CESLineEdit.setActionListener(cd, function()
		editorLineEditChangedUFloat(cd, self.editorWidgetPtr, self.KEY_COOL_DOWN, "", tostring(self.DEFAULT_COOL_DOWN));
	end);

	self.editorDurListener = CESLineEdit.setActionListener(dur, function()
		editorLineEditChangedUFloat(dur, self.editorWidgetPtr, self.KEY_DURATION, "", tostring(self.DEFAULT_DURATION));
	end);

	self.editorLenListener = CESLineEdit.setActionListener(len, function()
		editorLineEditChangedUFloat(len, self.editorWidgetPtr, self.KEY_LENGTH, "", tostring(self.DEFAULT_LENGTH));
	end);

	return "AI";
end

function C:editorWidgetRefresh()
	local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_ELAPSED);
	if value == "" then value = "0"; end
	CESLineEdit.setText(self.editorElapsed, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_COOL_DOWN);
	if value == "" then value = tostring(self.DEFAULT_COOL_DOWN); end
	CESLineEdit.setText(self.editorCD, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_DURATION);
	if value == "" then value = tostring(self.DEFAULT_DURATION); end
	CESLineEdit.setText(self.editorDur, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_LENGTH);
	if value == "" then value = tostring(self.DEFAULT_LENGTH); end
	CESLineEdit.setText(self.editorLen, value);
end

function C:editorWidgetDispose()
	if self.editorElapsed ~= nil then
		Cunref(self.editorElapsedListener);
		self.editorElapsed = nil;
	end
	if self.editorCD ~= nil then
		Cunref(self.editorCDListener);
		self.editorCD = nil;
	end
	if self.editorDur ~= nil then
		Cunref(self.editorDurListener);
		self.editorDur = nil;
	end
	if self.editorLen ~= nil then
		Cunref(self.editorLenListener);
		self.editorLen = nil;
	end
end

--=====================================

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.setGlobalCollisionCycle(characterDataPtr, 1.0);

	CCharacterData.loadSound(characterDataPtr, "0", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "1", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE, true);
	CCharacterData.loadSound(characterDataPtr, "2", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "hit", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

	CCharacterData.setFireDamageFactor(characterDataPtr, 0, 0.0, 1.0);

	self.id = CCharacterData.getName(characterDataPtr);

	self:createIdle();
end

function C:damage(attackDataPtr)
	local x, y = CAttackData.getHitPosition(attackDataPtr);

	--[[
	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, 0, x, y, true);
	CBulletBehaviorController.setDoneAnimation(ptr, true);
	CBulletBehaviorController.setAngle(ptr, 360.0 * math.random(), true);
	CBulletBehaviorController.setScale(ptr, 1.4);

	CBullet.createBullet(self.id.."/hit", CAttackData.getAttackerPtr(attackDataPtr), ptr, nil);
	]]--

	local chPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(self.id, "hit"), true);
	CAudioManager.set3DAttributes(chPtr, x, y);
	--CAudioManager.setVolume(chPtr, 0.5);
	CAudioManager.setPaused(chPtr, false);

	return true;
end

function C:createIdle()
	local ptr = createDefaultIdleActionData();
	CGameActionData.setScriptName(ptr, "Idle", false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setRigid(ptr, 0, CRigidAtk.NRM, CRigidDef.LOW);
	CGameActionData.setCollisionForce(ptr, 0, 0.0, 300.0, 0.0, true, 0.0, 300.0, 0.0, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
