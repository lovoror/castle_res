local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

--====================================

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

	self.KEY_ELAPSED = "et";
	self.KEY_COOL_DOWN = "cd";
	self.KEY_APPEAR_TIME = "appear";
	self.KEY_DURATION = "dur";
	self.KEY_LENGTH = "len";
	self.KEY_QUANTITY = "n";
	self.KEY_GAP = "gap";

	self.DEFAULT_COOL_DOWN = 1.0;
	self.DEFAULT_APPEAR_TIME = 0.3;
	self.DEFAULT_DURATION = 1.0;
	self.DEFAULT_LENGTH = 60.0;
	self.DEFAULT_QUANTITY = 5;
	self.DEFAULT_GAP = 2.0;

	CComponentBehaviorWidget.HLayoutBegin(widgetPtr);

	local hp, elapsedLabel, elapsed = createEditorLineEdit(widgetPtr, "Elapsed");
	self.editorElapsed = elapsed;

	local hp, cdLabel, cd = createEditorLineEdit(widgetPtr, "Cool Down");
	self.editorCD = cd;

	local hp, appearLabel, appear = createEditorLineEdit(widgetPtr, "Appear Time");
	self.editorAppear = appear;

	local hp, durLabel, dur = createEditorLineEdit(widgetPtr, "Duration");
	self.editorDur = dur;

	local hp, lenLabel, len = createEditorLineEdit(widgetPtr, "Length");
	self.editorLen = len;

	local hp, quantityLabel, quantity = createEditorLineEdit(widgetPtr, "Quantity");
	self.editorQuantity = quantity;

	local hp, gapLabel, gap = createEditorLineEdit(widgetPtr, "Gap");
	self.editorGap = gap;

	CComponentBehaviorWidget.HLayoutEnd(widgetPtr);

	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, elapsedLabel, self.KEY_ELAPSED);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, cdLabel, self.KEY_COOL_DOWN);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, appearLabel, self.KEY_APPEAR_TIME);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, durLabel, self.KEY_DURATION);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, lenLabel, self.KEY_LENGTH);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, quantityLabel, self.KEY_QUANTITY);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, gapLabel, self.KEY_GAP);

	self.editorElapsedListener = CESLineEdit.setActionListener(elapsed, function()
		editorLineEditChangedUFloat(elapsed, self.editorWidgetPtr, self.KEY_ELAPSED, "0", "0");
	end);

	self.editorCDListener = CESLineEdit.setActionListener(cd, function()
		editorLineEditChangedUFloat(cd, self.editorWidgetPtr, self.KEY_COOL_DOWN, "", tostring(self.DEFAULT_COOL_DOWN));
	end);

	self.editorAppearListener = CESLineEdit.setActionListener(appear, function()
		editorLineEditChangedUFloat(appear, self.editorWidgetPtr, self.KEY_APPEAR_TIME, "", tostring(self.DEFAULT_APPEAR_TIME));
	end);

	self.editorDurListener = CESLineEdit.setActionListener(dur, function()
		editorLineEditChangedUFloat(dur, self.editorWidgetPtr, self.KEY_DURATION, "", tostring(self.DEFAULT_DURATION));
	end);

	self.editorLenListener = CESLineEdit.setActionListener(len, function()
		editorLineEditChangedUFloat(len, self.editorWidgetPtr, self.KEY_LENGTH, "", tostring(self.DEFAULT_LENGTH));
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

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_ELAPSED);
	if value == "" then value = "0"; end
	CESLineEdit.setText(self.editorElapsed, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_COOL_DOWN);
	if value == "" then value = tostring(self.DEFAULT_COOL_DOWN); end
	CESLineEdit.setText(self.editorCD, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_APPEAR_TIME);
	if value == "" then value = tostring(self.DEFAULT_APPEAR_TIME); end
	CESLineEdit.setText(self.editorAppear, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_DURATION);
	if value == "" then value = tostring(self.DEFAULT_DURATION); end
	CESLineEdit.setText(self.editorDur, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_LENGTH);
	if value == "" then value = tostring(self.DEFAULT_LENGTH); end
	CESLineEdit.setText(self.editorLen, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_QUANTITY);
	if value == "" then value = tostring(self.DEFAULT_QUANTITY); end
	CESLineEdit.setText(self.editorQuantity, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_GAP);
	if value == "" then value = tostring(self.DEFAULT_GAP); end
	CESLineEdit.setText(self.editorGap, value);
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
	if self.editorAppear ~= nil then
		Cunref(self.editorAppearListener);
		self.editorAppear = nil;
	end
	if self.editorDur ~= nil then
		Cunref(self.editorDurListener);
		self.editorDur = nil;
	end
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

	CCharacterData.loadSound(characterDataPtr, "0", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "1", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
	CCharacterData.loadSound(characterDataPtr, "hit", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

	self.id = CCharacterData.getName(characterDataPtr);

	self:createIdle();
end

function C:damage(attackDataPtr)
	local x, y = CAttackData.getHitPosition(attackDataPtr);

	--[[
	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, 0, x, y, true);
	CBulletBehaviorController.setDoneActionChanged(ptr, true);
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
	CGameActionData.setCollisionForce(ptr, 0, 400.0, 0.0, 1.0, true, 400.0, 0.0, 1.0, true);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
