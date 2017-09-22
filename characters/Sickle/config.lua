local C = registerClassAuto(getClass(CHARACTER_CONFIG_PACKAGE, CHARACTER_CONFIG_BASE));

--====================================

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

	self.KEY_ELAPSED = "et";
	self.KEY_MAX_ANGLE = "a";
	self.KEY_CYCLE = "cycle";
	self.KEY_CHAINS = "n";

	self.DEFAULT_CHAINS = 12;

	CComponentBehaviorWidget.HLayoutBegin(widgetPtr);

	local hp, elapsedLabel, elapsed = createEditorLineEdit(widgetPtr, "Elapsed");
	self.editorElapsed = elapsed;

	local hp, angleLabel, angle = createEditorLineEdit(widgetPtr, "Max Angle");
	self.editorAngle = angle;

	local hp, cycleLabel, cycle = createEditorLineEdit(widgetPtr, "Cycle");
	self.editorCycle = cycle;

	local hp, chainsLabel, chains = createEditorLineEdit(widgetPtr, "Chains");
	self.editorChains = chains;

	CComponentBehaviorWidget.HLayoutEnd(widgetPtr);

	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, elapsedLabel, self.KEY_ELAPSED);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, angleLabel, self.KEY_MAX_ANGLE);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, cycleLabel, self.KEY_CYCLE);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, chainsLabel, self.KEY_CHAINS);

	self.editorElapsedListener = CESLineEdit.setActionListener(elapsed, function()
		editorLineEditChangedUFloat(elapsed, self.editorWidgetPtr, self.KEY_ELAPSED, "0", "0");
	end);

	self.editorAngleListener = CESLineEdit.setActionListener(angle, function()
		editorLineEditChangedUFloat(angle, self.editorWidgetPtr, self.KEY_MAX_ANGLE, "0", "0");
	end);

	self.editorCycleListener = CESLineEdit.setActionListener(cycle, function()
		editorLineEditChangedUFloat(cycle, self.editorWidgetPtr, self.KEY_CYCLE, "0", "0");
	end);

	self.editorChainsListener = CESLineEdit.setActionListener(chains, function()
		editorLineEditChangedUInt(chains, self.editorWidgetPtr, self.KEY_CHAINS, "", tostring(self.DEFAULT_CHAINS));
	end);

	return "AI";
end

function C:editorWidgetRefresh()
	local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_ELAPSED);
	if value == "" then value = "0"; end
	CESLineEdit.setText(self.editorElapsed, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_MAX_ANGLE);
	if value == "" then value = "0"; end
	CESLineEdit.setText(self.editorAngle, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_CYCLE);
	if value == "" then value = "0"; end
	CESLineEdit.setText(self.editorCycle, value);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_CHAINS);
	if value == "" then value = tostring(self.DEFAULT_CHAINS); end
	CESLineEdit.setText(self.editorChains, value);
end

function C:editorWidgetDispose()
	if self.editorElapsed ~= nil then
		Cunref(self.editorElapsedListener);
		self.editorElapsed = nil;
	end
	if self.editorAngle ~= nil then
		Cunref(self.editorAngleListener);
		self.editorAngle = nil;
	end
	if self.editorCycle ~= nil then
		Cunref(self.editorCycleListener);
		self.editorCycle = nil;
	end
	if self.editorChains ~= nil then
		Cunref(self.editorChainsListener);
		self.editorChains = nil;
	end
end

--=====================================

function C:awake(characterDataPtr)
	super.awake(self, characterDataPtr);

	CCharacterData.setCustomSync(characterDataPtr, true);
	CCharacterData.setGlobalCollisionCycle(characterDataPtr, 1.0);

	CCharacterData.loadSound(characterDataPtr, "0", SOUND_3D_DEFAULT_MIN_DISTANCE, SOUND_3D_DEFAULT_MAX_DISTANCE);
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
	CGameActionData.setSlashDamageFactor(ptr, 0, 0.0, 1.0);
	CGameActionData.setCollisionForce(ptr, 0, 350.0, 0.0, 1.0, false, 350.0, 0.0, 1.0, false);
	CGameActionData.setSlashDamageFactor(ptr, 0, 0.0, 1.0);

	CCharacterData.setActionData(self.characterDataPtr, ptr);
end
