local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

--====================================

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

	self.KEY_ELAPSED = "et";
	self.KEY_ROTATE_SPEED = "spd";
	self.KEY_UP = "up";
	self.KEY_DOWN = "down";
	self.KEY_LEFT = "left";
	self.KEY_RIGHT = "right";

	CComponentBehaviorWidget.HLayoutBegin(widgetPtr);

	local hp, elapsedLabel, elapsed = createEditorLineEdit(widgetPtr, "Elapsed");
	self.editorElapsed = elapsed;

	local hp, spdLabel, spd = createEditorLineEdit(widgetPtr, "Rotate Speed");
	self.editorSpd = spd;

	local hp, upLabel, up = createEditorCheckBox(widgetPtr, "Up");
	self.editorUp = up;

	local hp, downLabel, down = createEditorCheckBox(widgetPtr, "Down");
	self.editorDown = down;

	local hp, leftLabel, left = createEditorCheckBox(widgetPtr, "Left");
	self.editorLeft = left;

	local hp, rightLabel, right = createEditorCheckBox(widgetPtr, "Right");
	self.editorRight = right;

	CComponentBehaviorWidget.HLayoutEnd(widgetPtr);

	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, elapsedLabel, self.KEY_ELAPSED);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, spdLabel, self.KEY_ROTATE_SPEED);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, upLabel, self.KEY_UP);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, downLabel, self.KEY_DOWN);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, leftLabel, self.KEY_LEFT);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, rightLabel, self.KEY_RIGHT);

	self.editorElapsedListener = CESLineEdit.setActionListener(elapsed, function()
		editorLineEditChangedUFloat(elapsed, self.editorWidgetPtr, self.KEY_ELAPSED, "0", "0");
	end);

	self.editorSpdListener = CESLineEdit.setActionListener(spd, function()
		editorLineEditChangedFloat(spd, self.editorWidgetPtr, self.KEY_ROTATE_SPEED, "0", "0");
	end);

	self.editorUpListener = CESCheckBox.setActionListener(up, function()
		editorCheckBoxChanged(up, self.editorWidgetPtr, self.KEY_UP);
	end);

	self.editorDownListener = CESCheckBox.setActionListener(down, function()
		editorCheckBoxChanged(down, self.editorWidgetPtr, self.KEY_DOWN);
	end);

	self.editorLeftListener = CESCheckBox.setActionListener(left, function()
		editorCheckBoxChanged(left, self.editorWidgetPtr, self.KEY_LEFT);
	end);

	self.editorRightListener = CESCheckBox.setActionListener(right, function()
		editorCheckBoxChanged(right, self.editorWidgetPtr, self.KEY_RIGHT);
	end);

	return "AI";
end

function C:editorWidgetRefresh()
	local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_ELAPSED);
	if value == "" then value = "0"; end
	CESLineEdit.setText(self.editorElapsed, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_ROTATE_SPEED);
	if value == "" then value = "0"; end
	CESLineEdit.setText(self.editorSpd, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_UP);
	CESCheckBox.setChecked(self.editorUp, value == "1");

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_DOWN);
	CESCheckBox.setChecked(self.editorDown, value == "1");

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_LEFT);
	CESCheckBox.setChecked(self.editorLeft, value == "1");

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_RIGHT);
	CESCheckBox.setChecked(self.editorRight, value == "1");
end

function C:editorWidgetDispose()
	if self.editorElapsed ~= nil then
		Cunref(self.editorElapsedListener);
		self.editorElapsed = nil;
	end
	if self.editorSpd ~= nil then
		Cunref(self.editorSpdListener);
		self.editorSpd = nil;
	end
	if self.editorUp ~= nil then
		Cunref(self.editorUpListener);
		self.editorUp = nil;
	end
	if self.editorDown ~= nil then
		Cunref(self.editorDownListener);
		self.editorDown = nil;
	end
	if self.editorLeft ~= nil then
		Cunref(self.editorLeftListener);
		self.editorLeft = nil;
	end
	if self.editorRight ~= nil then
		Cunref(self.editorRightListener);
		self.editorRight = nil;
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
	CGameActionData.setCollisionForce(ptr, 0, 200.0, 0.0, 1.0, false, 200.0, 0.0, 1.0, false);

	local scPtr = CSoundPackage.create();
	CSoundPackage.add(scPtr, CGameResource.getCharacterSoundFile(self.id, "0"));
	CGameActionData.addSound(ptr, scPtr);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
