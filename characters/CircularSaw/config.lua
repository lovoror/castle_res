local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

--====================================

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

	self.KEY_FORE_ROTATE_SPEED = "fspd";
	self.KEY_BACK_ROTATE_SPEED = "bspd";
	self.KEY_ELAPSED = "et";
	self.KEY_VELOCITY = "v";
	self.KEY_MOTION_MODE = "mode";
	self.KEY_DELAY = "delay";
	self.KEY_PATH = "path";

	self.DEFAULT_FORE_ROTATE_SPEED = -90.0;
	self.DEFAULT_BACK_ROTATE_SPEED = 90.0;

	CComponentBehaviorWidget.HLayoutBegin(widgetPtr);

	local hp, fgLabel, fgSpeed = createEditorLineEdit(widgetPtr, "Fore Rotate Speed");
	self.editorFgSpeed = fgSpeed;

	local hp, bgLabel, bgSpeed = createEditorLineEdit(widgetPtr, "Back Rotate Speed");
	self.editorBgSpeed = bgSpeed;

	local hp, elapsedLabel, elapsed = createEditorLineEdit(widgetPtr, "Elapsed");
	self.editorElapsed = elapsed;

	local hp, vLabel, v = createEditorLineEdit(widgetPtr, "Velocity");
	self.editorV = v;

	local hp = CHorizontalPanel.create();
	local modeLabel = CESLabel.create("Motion Mode");
	local mode = CESComboBox.create("Motion Mode");
	CESComboBox.addItem(mode, "PingPong");
	CESComboBox.addItem(mode, "Circular");
	self.editorMode = mode;
	CHorizontalPanel.setSingle(hp, modeLabel, mode);
	CComponentBehaviorWidget.addHLayoutPanel(widgetPtr, hp);

	local hp, delayLabel, delay = createEditorLineEdit(widgetPtr, "Delay");
	self.editorDelayPanel = hp;
	self.editorDelay = delay;

	local hp = CHorizontalPanel.create();
	local pathLabel = CESLabel.create("Path");
	CHorizontalPanel.setNone(hp, pathLabel);
	CComponentBehaviorWidget.addHLayoutPanel(widgetPtr, hp);

	local path = CESDynamicPositionListWidget.create();
	self.editorPath = path;
	CComponentBehaviorWidget.addWidget(widgetPtr, path);

	CComponentBehaviorWidget.HLayoutEnd(widgetPtr);

	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, fgLabel, self.KEY_FORE_ROTATE_SPEED);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, bgLabel, self.KEY_BACK_ROTATE_SPEED);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, elapsedLabel, self.KEY_ELAPSED);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, vLabel, self.KEY_VELOCITY);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, modeLabel, self.KEY_MOTION_MODE);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, modeLabel, self.KEY_DELAY);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, pathLabel, self.KEY_PATH);

	self.editorFgSpeedListener = CESLineEdit.setActionListener(fgSpeed, function()
		editorLineEditChangedFloat(fgSpeed, self.editorWidgetPtr, self.KEY_FORE_ROTATE_SPEED, "", tostring(self.DEFAULT_FORE_ROTATE_SPEED));
	end);

	self.editorBgSpeedListener = CESLineEdit.setActionListener(bgSpeed, function()
		editorLineEditChangedFloat(bgSpeed, self.editorWidgetPtr, self.KEY_BACK_ROTATE_SPEED, "", tostring(self.DEFAULT_BACK_ROTATE_SPEED));
	end);

	self.editorElapsedListener = CESLineEdit.setActionListener(elapsed, function()
		editorLineEditChangedFloat(elapsed, self.editorWidgetPtr, self.KEY_ELAPSED, "0", "0");
	end);

	self.editorVListener = CESLineEdit.setActionListener(v, function()
		editorLineEditChangedUFloat(v, self.editorWidgetPtr, self.KEY_VELOCITY, "0", "0");
	end);

	self.editorModeListener = CESComboBox.setActionListener(mode, function()
		editorComboBoxChanged(mode, self.editorWidgetPtr, self.KEY_MOTION_MODE, "0");
		CESWidget.setVisible(self.editorDelayPanel, CESComboBox.getCurrentIndex(mode) == 0);
		CComponentBehaviorWidget.updateLayout(self.editorWidgetPtr);
	end);

	self.editorDelayListener = CESLineEdit.setActionListener(delay, function()
		editorLineEditChangedUFloat(delay, self.editorWidgetPtr, self.KEY_DELAY, "0", "0");
	end);

	local pathChanged = function()
		local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);

		local num = CESDynamicListWidget.getNumItems(path);
		local value = "";
		for i = 1, num do
			if i ~= 1 then
				value = value..",";
			end
			local x, y = CESDynamicPositionListWidget.getPosition(path, i - 1);
			value = value..tostring(x)..","..tostring(y);
		end

		CChapterEditorComponentBehavior.setValue(com, self.KEY_PATH, value);
	end

	self.editorPathAddListener = CESDynamicListWidget.setAddListener(path, function(itemPtr)
		pathChanged();
		CComponentBehaviorWidget.updateLayout(self.editorWidgetPtr, itemPtr);
	end);

	self.editorPathDelListener = CESDynamicListWidget.setDeleteListener(path, function(itemPtr, index)
		pathChanged();
		CComponentBehaviorWidget.updateLayout(self.editorWidgetPtr);
	end);

	self.editorPathMoveListener = CESDynamicListWidget.setMoveListener(path, function(index, offset)
		pathChanged();
	end);

	self.editorPathChangedListener = CESDynamicPositionListWidget.setChangedListener(path, function(index)
		pathChanged();
	end);

	return "AI";
end

function C:editorWidgetRefresh()
	local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_FORE_ROTATE_SPEED);
	if value == "" then value = tostring(self.DEFAULT_FORE_ROTATE_SPEED); end
	CESLineEdit.setText(self.editorFgSpeed, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_BACK_ROTATE_SPEED);
	if value== "" then value = tostring(self.DEFAULT_BACK_ROTATE_SPEED); end
	CESLineEdit.setText(self.editorBgSpeed, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_ELAPSED);
	if value== "" then value = "0"; end
	CESLineEdit.setText(self.editorElapsed, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_VELOCITY);
	if value== "" then value = "0"; end
	CESLineEdit.setText(self.editorV, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_MOTION_MODE);
	if value== "" then value = "0"; end
	CESComboBox.setCurrentIndex(self.editorMode, toint(value));

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_DELAY);
	if value== "" then value = "0"; end
	CESLineEdit.setText(self.editorDelay, value);
	CESWidget.setVisible(self.editorDelayPanel, CESComboBox.getCurrentIndex(self.editorMode) == 0);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_PATH);
	local path = stringSplit(value, ",");
	local sizeData = (#path) * 0.5;
	local sizeItem = CESDynamicListWidget.getNumItems(self.editorPath);
	for i = 1, sizeData do
		local idx = i * 2 - 1;
		local x = path[idx];
		local y = path[idx + 1];
		if i <= sizeItem then
			CESDynamicPositionListWidget.setPosition(self.editorPath, i - 1, x, y);
		else
			CESDynamicPositionListWidget.pushItem(self.editorPath, x, y);
		end
	end

	local newSizeItem = CESDynamicListWidget.getNumItems(self.editorPath);
	local n = newSizeItem - sizeData;
	while (n > 0) do
		n = n - 1;
		newSizeItem = newSizeItem - 1;
		CESDynamicListWidget.deleteItemAt(self.editorPath, newSizeItem);
	end

	CComponentBehaviorWidget.updateLayout(self.editorWidgetPtr, self.editorPath);
end

function C:editorWidgetDispose()
	if self.editorFgSpeed ~= nil then
		Cunref(self.editorFgSpeedListener);
		self.editorFgSpeed = nil;
	end
	if self.editorBgSpeed ~= nil then
		Cunref(self.editorBgSpeedListener);
		self.editorBgSpeed = nil;
	end
	if self.editorElapsed ~= nil then
		Cunref(self.editorElapsedListener);
		self.editorElapsed = nil;
	end
	if self.editorV ~= nil then
		Cunref(self.editorVListener);
		self.editorV = nil;
	end
	if self.editorMode ~= nil then
		Cunref(self.editorModeListener);
		self.editorMode = nil;
	end
	if self.editorPath ~= nil then
		Cunref(self.editorPathAddListener);
		Cunref(self.editorPathDelListener);
		Cunref(self.editorPathMoveListener);
		Cunref(self.editorPathChangedListener);
		self.editorPath = nil;
	end
end

--=====================================

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.setGlobalCollisionCycle(characterDataPtr, 1.0);

	CCharacterData.loadSound(characterDataPtr, "0", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE, true);
	CCharacterData.loadSound(characterDataPtr, "hit", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);

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
	CGameActionData.setSlashDamageFactor(ptr, 0, 0.0, 1.0);
	CGameActionData.setCollisionForce(ptr, 0, 200.0, 0.0, 1.0, false, 200.0, 0.0, 1.0, false);
	CGameActionData.setSlashDamageFactor(ptr, 0, 0.0, 1.0);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "0"));
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
