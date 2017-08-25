--Rope
local C = registerClassAuto(getClass(AI_PACKAGE, AI_BASE));

function C:ctor()
	self.KEY_MODE = "mode";
	self.KEY_REPEAT_ANIMATION_SPEED_TRIGGER = "rast";
	self.KEY_REPEAT_ANIMATION_SPEED_SCALE = "rass";

	self.KEY_TYPE = "TYPE";
	self.KEY_ABSOLUTE_X = "ABSOLUTE_X";
	self.KEY_ABSOLUTE_Y = "ABSOLUTE_Y";
	self.KEY_SPRITE_ID = "SPRITE_ID";
	self.KEY_OFFSET_X = "OFFSET_X";
	self.KEY_OFFSET_Y = "OFFSET_Y";

	local createConst = function(pos)
		self[self.KEY_TYPE..pos] = "type"..pos;
		self[self.KEY_ABSOLUTE_X..pos] = "x"..pos;
		self[self.KEY_ABSOLUTE_Y..pos] = "y"..pos;
		self[self.KEY_SPRITE_ID..pos] = "id"..pos;
		self[self.KEY_OFFSET_X..pos] = "ox"..pos;
		self[self.KEY_OFFSET_Y..pos] = "oy"..pos;
	end

	createConst("1");
	createConst("2");

	self.posEP = newClass(GENERAL_PACKAGE, GENERAL_END_POINT);
	self.negEP = newClass(GENERAL_PACKAGE, GENERAL_END_POINT);
end

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

	self.EDITOR_TYPE = "editorType";
	self.EDITOR_ABSOLUTE_PANEL = "editorAbsolutePanel";
	self.EDITOR_ABSOLUTE_X = "editorAbsoluteX";
	self.EDITOR_ABSOLUTE_Y = "editorAbsoluteY";
	self.EDITOR_SPRITE_PANEL = "editorSpritePanel";
	self.EDITOR_SPRITE = "editorSprite";
	self.EDITOR_OFFSET_PANEL = "editorOffsetPanel";
	self.EDITOR_OFFSET_X = "editorOffsetX";
	self.EDITOR_OFFSET_Y = "editorOffsetY";

	self.EDITOR_TYPE_LISTENER = "editorTypeListener";
	self.EDITOR_ABSOLUTE_X_LISTENER = "editorAbsoluteXListener";
	self.EDITOR_ABSOLUTE_Y_LISTENER = "editorAbsoluteYListener";
	self.EDITOR_SPRITE_LISTENER = "editorSpriteListener";
	self.EDITOR_OFFSET_X_LISTENER = "editorOffsetXListener";
	self.EDITOR_OFFSET_Y_LISTENER = "editorOffsetYListener";

	CComponentBehaviorWidget.HLayoutBegin(widgetPtr);

	local widgets = CESWidgetVector.create();

	local createEndPoint = function(pos)
		local hp = CHorizontalPanel.create();
		local typeLabel = CESLabel.create(" Type");
		local type = CESComboBox.create();
		CESComboBox.addItem(type, "Relative");
		CESComboBox.addItem(type, "Absolute");
		CESComboBox.addItem(type, "Sprite");
		self[self.EDITOR_TYPE..pos] = type;
		CHorizontalPanel.setSingle(hp, typeLabel, type);
		CComponentBehaviorWidget.addHLayoutPanel(widgetPtr, hp);

		local hp, label, xLabel, x, yLabel, y = createEditorLineEdit2(widgetPtr, widgets, "Position", "X", "Y");
		self[self.EDITOR_ABSOLUTE_PANEL..pos] = hp;
		self[self.EDITOR_ABSOLUTE_X..pos] = x;
		self[self.EDITOR_ABSOLUTE_Y..pos] = y;

		local hp = CHorizontalPanel.create();
		self[self.EDITOR_SPRITE_PANEL..pos] = hp;
		local spriteLabel = CESLabel.create(" Sprite");
		local sprite = CESSpriteRefBox.create();
		self[self.EDITOR_SPRITE..pos] = sprite;
		CHorizontalPanel.setSingle(hp, spriteLabel, sprite);
		CComponentBehaviorWidget.addHLayoutPanel(widgetPtr, hp);

		local hp, label, oxLabel, offsetX, oyLabel, offsetY = createEditorLineEdit2(widgetPtr, widgets, "Offset", "X", "Y");
		self[self.EDITOR_OFFSET_PANEL..pos] = hp;
		self[self.EDITOR_OFFSET_X..pos] = offsetX;
		self[self.EDITOR_OFFSET_Y..pos] = offsetY;

		CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, typeLabel, self[self.KEY_TYPE..pos]);
		CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, xLabel, self[self.KEY_ABSOLUTE_X..pos]);
		CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, yLabel, self[self.KEY_ABSOLUTE_Y..pos]);
		CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, spriteLabel, self[self.KEY_SPRITE_ID..pos]);
		CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, oxLabel, self[self.KEY_OFFSET_X..pos]);
		CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, oyLabel, self[self.KEY_OFFSET_Y..pos]);

		self[self.EDITOR_TYPE_LISTENER..pos] = CESComboBox.setActionListener(type, function()
			local value = editorComboBoxChanged(type, self.editorWidgetPtr, self[self.KEY_TYPE..pos], "0");
			self:_setTypeSwitch(pos, value);
			CComponentBehaviorWidget.updateLayout(self.editorWidgetPtr);
		end);

		self[self.EDITOR_ABSOLUTE_X_LISTENER..pos] = CESLineEdit.setActionListener(ax, function()
			editorLineEditChangedFloat(ax, self.editorWidgetPtr, self[self.KEY_ABSOLUTE_X..pos], "0", "0");
		end);

		self[self.EDITOR_ABSOLUTE_Y_LISTENER..pos] = CESLineEdit.setActionListener(ay, function()
			editorLineEditChangedFloat(ay, self.editorWidgetPtr, self[self.KEY_ABSOLUTE_Y..pos], "0", "0");
		end);

		self[self.EDITOR_SPRITE_LISTENER..pos] = CESSpriteRefBox.setActionListener(sprite, function()
			local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);
			local value = tostring(CESSpriteRefBox.getRef(sprite));
			if value == "0" then value = ""; end
			CChapterEditorComponentBehavior.setValue(com, self[self.KEY_SPRITE_ID..pos], value);
		end);

		self[self.EDITOR_OFFSET_X_LISTENER..pos] = CESLineEdit.setActionListener(offsetX, function()
			editorLineEditChangedFloat(offsetX, self.editorWidgetPtr, self[self.KEY_OFFSET_X..pos], "0", "0");
		end);

		self[self.EDITOR_OFFSET_Y_LISTENER..pos] = CESLineEdit.setActionListener(offsetY, function()
			editorLineEditChangedFloat(offsetY, self.editorWidgetPtr, self[self.KEY_OFFSET_Y..pos], "0", "0");
		end);
	end

	local hp = CHorizontalPanel.create();
	local modeLabel = CESLabel.create("Mode");
	local mode = CESComboBox.create();
	CESComboBox.addItem(mode, "Stretch");
	CESComboBox.addItem(mode, "Repeat");
	self.editorMode = mode;
	CHorizontalPanel.setSingle(hp, modeLabel, mode);
	CComponentBehaviorWidget.addHLayoutPanel(widgetPtr, hp);

	self.editorRepeatAnimationSpeedLabel = CESLabel.create("Repeat Animation Speed");
	CComponentBehaviorWidget.addWidget(widgetPtr, self.editorRepeatAnimationSpeedLabel);

	local hp = CHorizontalPanel.create();
	self.editorRASTriggerPanel = hp;
	local rasTriggerLabel = CESLabel.create(" Trigger");
	local rasTrigger = CESSpriteTriggerBox.create();
	self.editorRASTrigger = rasTrigger;
	CHorizontalPanel.setSingle(hp, rasTriggerLabel, rasTrigger);
	CComponentBehaviorWidget.addHLayoutPanel(widgetPtr, hp);

	local hp, rasScaleLabel, rasScale = createEditorLineEdit(widgetPtr, " Scale");
	self.editorRASScalePanel = hp;
	self.editorRASTScale = rasScale;

	CComponentBehaviorWidget.addWidget(widgetPtr, CESLabel.create("End Point Upper"));
	createEndPoint("1");
	CComponentBehaviorWidget.addWidget(widgetPtr, CESLabel.create("End Point Lower"));
	createEndPoint("2");

	CESWidgetVector.free(widgets);
	CComponentBehaviorWidget.HLayoutEnd(widgetPtr);

	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, modeLabel, self.KEY_MODE);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, rasTriggerLabel, self.KEY_REPEAT_ANIMATION_SPEED_TRIGGER);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, rasScaleLabel, self.KEY_REPEAT_ANIMATION_SPEED_SCALE);

	self.editorModeListener = CESComboBox.setActionListener(mode, function()
			local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);
			local value = tostring(CESComboBox.getCurrentIndex(mode));
			if value == "0" then value = ""; end
			CChapterEditorComponentBehavior.setValue(com, self.KEY_MODE, value);
			self:_setModeSwitch();
			CComponentBehaviorWidget.updateLayout(self.editorWidgetPtr);
		end);

	local changedRASTrigger = function()
		local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);
		local id = CESSpriteRefBox.getRef(CESSpriteTriggerBox.getSpriteRefWidgetPtr(rasTrigger));
		local name = CESTriggerNameComboBox.getCurrentTriggerName(CESSpriteTriggerBox.getTriggerNameWidgetPtr(rasTrigger));
		if id == 0 and name == "" then
			CChapterEditorComponentBehavior.setValue(com, self.KEY_REPEAT_ANIMATION_SPEED_TRIGGER, "");
		else
			CChapterEditorComponentBehavior.setValue(com, self.KEY_REPEAT_ANIMATION_SPEED_TRIGGER, tostring(id)..","..name);
		end
	end

	self.editorRASTriggerIDListener = CESSpriteRefBox.setActionListener(CESSpriteTriggerBox.getSpriteRefWidgetPtr(rasTrigger), function(old)
			changedRASTrigger();
		end);

	self.editorRASTriggerNameListener = CESSpriteRefBox.setActionListener(CESSpriteTriggerBox.getTriggerNameWidgetPtr(rasTrigger), function()
			changedRASTrigger();
		end);

	self.editorRASScaleListener = CESLineEdit.setActionListener(rasScale, function()
			lineEditChanged(rasScale, self.KEY_REPEAT_ANIMATION_SPEED_SCALE, "1");
		end);

	return "Rope";
end

function C:editorWidgetRefresh()
	local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_MODE);
	if value == "" then value = "0"; end
	CESComboBox.setCurrentIndex(self.editorMode, toint(value));
	self:_setModeSwitch();

	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_REPEAT_ANIMATION_SPEED_TRIGGER);
	if value == "" then
		CESSpriteRefBox.setRef(CESSpriteTriggerBox.getSpriteRefWidgetPtr(self.editorRASTrigger), 0);
		CESTriggerNameComboBox.setCurrentTriggerName(CESSpriteTriggerBox.getTriggerNameWidgetPtr(self.editorRASTrigger), "");
	else
		local arr = stringSplit(value, ",");
		CESSpriteRefBox.setRef(CESSpriteTriggerBox.getSpriteRefWidgetPtr(self.editorRASTrigger), toint(arr[1]));
		CESTriggerNameComboBox.setCurrentTriggerName(CESSpriteTriggerBox.getTriggerNameWidgetPtr(self.editorRASTrigger), arr[2]);
	end

	local refreshLineEdit = function(widget, key, default)
		local value = CChapterEditorComponentBehavior.getValue(com, key);
		if value == "" then value = default; end
		CESLineEdit.setText(widget, value);
	end

	refreshLineEdit(self.editorRASTScale, self.KEY_REPEAT_ANIMATION_SPEED_SCALE, "1");

	local fn = function(pos)
		local value = CChapterEditorComponentBehavior.getValue(com, self[self.KEY_TYPE..pos]);
		if value == "" then value = "0"; end
		CESComboBox.setCurrentIndex(self["editorType"..pos], toint(value));
		self:_setTypeSwitch(pos, value);

		refreshLineEdit(self[self.EDITOR_ABSOLUTE_X..pos], self[self.KEY_ABSOLUTE_X..pos], "0");
		refreshLineEdit(self[self.EDITOR_ABSOLUTE_Y..pos], self[self.KEY_ABSOLUTE_Y..pos], "0");

		local value = CChapterEditorComponentBehavior.getValue(com, self[self.KEY_SPRITE_ID..pos]);
		if value == "" then value = "0"; end
		CESSpriteRefBox.setRef(self[self.EDITOR_SPRITE..pos], toint(value));

		refreshLineEdit(self[self.EDITOR_OFFSET_X..pos], self[self.KEY_OFFSET_X..pos], "0");
		refreshLineEdit(self[self.EDITOR_OFFSET_Y..pos], self[self.KEY_OFFSET_Y..pos], "0");
	end

	fn("1");
	fn("2");

	CComponentBehaviorWidget.updateLayout(self.editorWidgetPtr);
end

function C:editorWidgetDispose()
	self:_disposeListener(self.editorModeListener, "");
	self:_disposeListener(self.editorRASTriggerIDListener, "");
	self:_disposeListener(self.editorRASTriggerNameListener, "");
	self:_disposeListener(self.editorRASScaleListener, "");

	local fn = function(pos)
		self:_disposeListener(self.EDITOR_TYPE_LISTENER, pos);
		self:_disposeListener(self.EDITOR_ABSOLUTE_X_LISTENER, pos);
		self:_disposeListener(self.EDITOR_ABSOLUTE_Y_LISTENER, pos);
		self:_disposeListener(self.EDITOR_SPRITE_LISTENER, pos);
		self:_disposeListener(self.EDITOR_OFFSET_X_LISTENER, pos);
		self:_disposeListener(self.EDITOR_OFFSET_Y_LISTENER, pos);
	end

	fn("1");
	fn("2");
end

function C:editorPublish()
	local com = self.editorComponentPtr;
	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_MODE);
	if value == "1" then
		CChapterEditorComponentBehavior.setPublishValue(com, self.KEY_MODE, value);
		local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_REPEAT_ANIMATION_SPEED_TRIGGER);
		if value ~= "" then
			local arr = stringSplit(value, ",");
			if arr[1] ~= "" and arr[1] ~= "0" and arr[2] ~= "" then
				CChapterEditorComponentBehavior.setPublishValue(com, self.KEY_REPEAT_ANIMATION_SPEED_TRIGGER, value);
				local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_REPEAT_ANIMATION_SPEED_SCALE);
				if value ~= "" and value ~= "1" then
					CChapterEditorComponentBehavior.setPublishValue(com, self.KEY_REPEAT_ANIMATION_SPEED_SCALE, value);
				end
			end
		end
	end

	local writeValue = function(key)
		local value = CChapterEditorComponentBehavior.getValue(com, key);
		if value ~= "" and value ~= "0" then
			CChapterEditorComponentBehavior.setPublishValue(com, key, value);
		end
	end

	local epPublish = function(pos)
		local key = self[self.KEY_TYPE..pos];
		local value = CChapterEditorComponentBehavior.getValue(com, key);
		if value == "" or value == "0" then
			writeValue(self[self.KEY_OFFSET_X..pos]);
			writeValue(self[self.KEY_OFFSET_Y..pos]);
		elseif value == "1" then
			CChapterEditorComponentBehavior.setPublishValue(com, key, value);
			writeValue(self[self.KEY_ABSOLUTE_X..pos]);
			writeValue(self[self.KEY_ABSOLUTE_Y..pos]);
		else
			CChapterEditorComponentBehavior.setPublishValue(com, key, value);
			writeValue(self[self.KEY_SPRITE_ID..pos]);
			writeValue(self[self.KEY_OFFSET_X..pos]);
			writeValue(self[self.KEY_OFFSET_Y..pos]);
		end
	end

	epPublish("1");
	epPublish("2");
end

function C:_setModeSwitch()
	local com = CComponentBehaviorWidget.getEditorComponent(self.editorWidgetPtr);
	local value = CChapterEditorComponentBehavior.getValue(com, self.KEY_MODE);
	local visible = value == "1";
	CESWidget.setVisible(self.editorRepeatAnimationSpeedLabel, visible);
	CESWidget.setVisible(self.editorRASTriggerPanel, visible);
	CESWidget.setVisible(self.editorRASScalePanel, visible);
end

function C:_setTypeSwitch(pos, type)
	if type == "0" or type == "" then
		CESWidget.setVisible(self[self.EDITOR_ABSOLUTE_PANEL..pos], false);
		CESWidget.setVisible(self[self.EDITOR_SPRITE_PANEL..pos], false);
		CESWidget.setVisible(self[self.EDITOR_OFFSET_PANEL..pos], true);
	elseif type == "1" then
		CESWidget.setVisible(self[self.EDITOR_ABSOLUTE_PANEL..pos], true);
		CESWidget.setVisible(self[self.EDITOR_SPRITE_PANEL..pos], false);
		CESWidget.setVisible(self[self.EDITOR_OFFSET_PANEL..pos], false);
	elseif type == "2" then
		CESWidget.setVisible(self[self.EDITOR_ABSOLUTE_PANEL..pos], false);
		CESWidget.setVisible(self[self.EDITOR_SPRITE_PANEL..pos], true);
		CESWidget.setVisible(self[self.EDITOR_OFFSET_PANEL..pos], true);
	else
		CESWidget.setVisible(self[self.EDITOR_ABSOLUTE_PANEL..pos], false);
		CESWidget.setVisible(self[self.EDITOR_SPRITE_PANEL..pos], false);
		CESWidget.setVisible(self[self.EDITOR_OFFSET_PANEL..pos], false);
	end
end

function C:_disposeListener(name, pos)
	local fullName = name..pos;
	if self[fullName] ~= nil then
		Cunref(self[fullName]);
		self[fullName] = nil;
	end
end

--===================================================

function C:awake(executorPtr)
	super.awake(self, executorPtr);

	if self.epUpper == nil then
		self.epUpper = newClass(GENERAL_PACKAGE, GENERAL_END_POINT);
		self.epLower = newClass(GENERAL_PACKAGE, GENERAL_END_POINT);
	end

	self:_initEP(self.epUpper, "1");
	self:_initEP(self.epLower, "2");

	local disPtr = CEntity.getDisplayContentPtr(self.entityPtr);
	self.spriteFramePtr = CGameSprite.getSpriteFramePtr(disPtr);
	local w, h = CGameNode.getContentSize(disPtr);
	self.unitLength = h;
	local x, y = CGameNode.getAnchorPoint(disPtr);
	self.anchorY = y;

	local value = CEntity.getSharedData(self.entityPtr, self.KEY_MODE);
	if value == "" or value == "0" then
		self:_awakeMode0();
	else
		self:_awakeMode1();
	end
end

function C:_awakeMode0()
	self.mode = 0;
end

function C:_awakeMode1()
	self.mode = 1;

	if self.bodiesPool == nil then
		self.bodiesPool = {};
		self.disPtrsPool = {};
	end

	self.bodyHead = nil;
	self.bodyTail = nil;
	self.posLen = 0.0;
	self.negLen = 0.0;
	self.numDisPtrsPool = 0;
	self.numBodiesPool = 0;
	self.moveSpeed = 0.0;

	local value = CEntity.getSharedData(self.entityPtr, self.KEY_REPEAT_ANIMATION_SPEED_TRIGGER);
	
	if value == "" then
		self.moveSpeedScale = 1.0;
	else
		local arr = stringSplit(value, ",");
		self.mode1TriggerPtr = CEntityTrigger.addTrigger(arr[2], 0, toint(arr[1]), function(name, value)
			self.moveSpeed = self.moveSpeed + tonumber(value);
		end);
		local value = CEntity.getSharedData(self.entityPtr, self.KEY_REPEAT_ANIMATION_SPEED_SCALE);
		if value == "" then
			self.moveSpeedScale = 1.0;
		else
			self.moveSpeedScale = tonumber(value);
		end
	end

	local disPtr = CGameSprite.create();
	CGameNode.setAnchorPoint(disPtr, 0.5, 0.0);
	self.disPtr = disPtr;
	CEntity.setDisplayContent(self.entityPtr, disPtr);
end

function C:_initEP(ep, pos)
	local head = "ep"..pos;

	ep:reset();

	local value = CEntity.getSharedData(self.entityPtr, self[self.KEY_TYPE..pos]);
	if value == "" or value == "0" then
		ep.type = 0;
		ep.offsetX = self:_readFloatSharedData(self[self.KEY_OFFSET_X..pos]);
		ep.offsetY = self:_readFloatSharedData(self[self.KEY_OFFSET_Y..pos]);
	elseif value == "1" then
		ep.type = 1;
		ep.x = self:_readFloatSharedData(self[self.KEY_ABSOLUTE_X..pos]);
		ep.y = self:_readFloatSharedData(self[self.KEY_ABSOLUTE_Y..pos]);
	else
		ep.type = 2;
		ep.id = toint(self:_readFloatSharedData(self[self.KEY_SPRITE_ID..pos]));
		ep.offsetX = self:_readFloatSharedData(self[self.KEY_OFFSET_X..pos]);
		ep.offsetY = self:_readFloatSharedData(self[self.KEY_OFFSET_Y..pos]);
	end
end

function C:_readFloatSharedData(key)
	local value = CEntity.getSharedData(self.entityPtr, key);
	if value == "" then
		return 0.0;
	else
		return tonumber(value);
	end;
end

function C:tick(time)
end

function C:ticked(time)
	if self.mode == 0 then
		self:_tickedMode0(time);
	else
		self:_tickedMode1(time);
	end
end

function C:_tickedMode0(time)
	local entityPtr = self.entityPtr;

	local px, py = CEntity.getPosition(entityPtr);

	local sx, sy = self.epUpper:getPosition(entityPtr);
	local ex, ey = self.epLower:getPosition(entityPtr);

	local dx = sx - ex;
	local dy = sy - ey;
	local len = math.sqrt(dx * dx + dy * dy);

	local a = math.deg(math.atan(dy, dx)) - 90.0;
	CEntity.setRotation(entityPtr, -a);
	CEntity.setScale(entityPtr, CEntity.getScaleX(entityPtr), len / self.unitLength);
	CEntity.setMoveTo(entityPtr, ex + (sx - ex) * self.anchorY, ey + (sy - ey) * self.anchorY, true);
end

function C:_tickedMode1(time)
	local entityPtr = self.entityPtr;

	--self.anchorY = 1.0;

	local px, py = CEntity.getPosition(entityPtr);

	local sx, sy = self.epUpper:getPosition(entityPtr);
	local ex, ey = self.epLower:getPosition(entityPtr);

	local dx = sx - ex;
	local dy = sy - ey;
	local len = math.sqrt(dx * dx + dy * dy);

	local curNegLen = self.anchorY * len;
	local curPosLen = (1.0 - self.anchorY) * len;

	if curPosLen ~= self.posLen then
		self:_moveHead(curPosLen - self.posLen);
		self.posLen = curPosLen;
	end

	if curNegLen ~= self.negLen then
		self:_moveTail(curNegLen - self.negLen);
		self.negLen = curNegLen;
	end

	self:_move(self.moveSpeed * self.moveSpeedScale);
	self.moveSpeed = 0.0;

	local a = math.deg(math.atan(dy, dx)) - 90.0;
	CEntity.setRotation(entityPtr, -a);
	CEntity.setMoveTo(entityPtr, ex + (sx - ex) * self.anchorY, ey + (sy - ey) * self.anchorY, true);
end

function C:destroy()
	super.destroy(self);

	if self.mode == 1 then
		local node = self.bodyHead;
		while node ~= nil do
			self:_pushNode(node);
			node = node.next;
		end

		self.bodyHead = nil;
		self.bodyTail = nil;

		for i = 1, self.numDisPtrsPool do
			CGameRef.release(self.disPtrsPool[i]);
		end
		self.numDisPtrsPool = 0;
		self.numBodiesPool = 0;

		CEntityTrigger.removeTrigger(self.mode1TriggerPtr);
		self.mode1TriggerPtr = nil;
	end

	return true;
end

function C:_moveHead(offset)
	if offset > 0.0 then
		while offset > 0.0 do
			local lastLen = 0.0;
			if self.bodyHead ~= nil then
				lastLen = self.bodyHead.pos * self.unitLength;
			end

			if lastLen > 0.0 then
				if lastLen >= offset then
					self.bodyHead.pos = self.bodyHead.pos - offset / self.unitLength;
					self:_setSubTextureRect(self.bodyHead);
					offset = 0.0;
				else
					self.bodyHead.pos = 0.0;
					self:_setSubTextureRect(self.bodyHead);
					offset = offset - lastLen;
				end
			else
				local node = self:_getNode();

				if self.unitLength > offset then
					node.pos = 1.0 - offset / self.unitLength;
					offset = 0.0;
				else
					node.pos = 0.0;
					offset = offset - self.unitLength;
				end

				node.neg = 1.0;
				self:_setSubTextureRect(node);

				if self.bodyHead == nil then
					CGameNode.setPosition(node.value, 0.0, 0.0);
					self.bodyHead = node;
					self.bodyTail = node;
				else
					local x, y = CGameNode.getPosition(self.bodyHead.value);
					CGameNode.setPosition(node.value, 0.0, y + (self.bodyHead.neg - self.bodyHead.pos) * self.unitLength);

					local old = self.bodyHead;
					self.bodyHead = node;
					node.next = old;
					old.prev = node;
				end
			end
		end
	else
		while offset < 0.0 do
			local lastLen = 0.0;
			if self.bodyHead ~= nil then
				lastLen = (self.bodyHead.neg - self.bodyHead.pos) * self.unitLength;
			end

			if lastLen > 0.0 then
				if lastLen > -offset then
					self.bodyHead.pos = self.bodyHead.pos - offset / self.unitLength;
					self:_setSubTextureRect(self.bodyHead);
					offset = 0.0;
				else
					self:_pushNode(self.bodyHead);
					if self.bodyHead == self.bodyTail then
						self.bodyHead = nil;
						self.bodyTail = nil;
					else
						self.bodyHead = self.bodyHead.next;
						self.bodyHead.prev = nil;
					end

					offset = offset + lastLen;
				end
			else
				offset = 0.0;
			end
		end
	end
end

function C:_moveTail(offset)
	if offset > 0.0 then
		while offset > 0.0 do
			local lastLen = 0.0;
			if self.bodyTail ~= nil then
				lastLen = (1.0 - self.bodyTail.neg) * self.unitLength;
			end

			if lastLen > 0.0 then
				if lastLen >= offset then
					self.bodyTail.neg = self.bodyTail.neg + offset / self.unitLength;
					self:_setSubTextureRect(self.bodyTail);
					CGameNode.appendPosition(self.bodyTail.value, 0.0, -offset);
					offset = 0.0;
				else
					self.bodyTail.neg = 1.0;
					self:_setSubTextureRect(self.bodyTail);
					CGameNode.appendPosition(self.bodyTail.value, 0.0, -lastLen);
					offset = offset - lastLen;
				end
			else
				local node = self:_getNode();

				if self.unitLength > offset then
					node.neg = offset / self.unitLength;
					offset = 0.0;
				else
					node.neg = 1.0;
					offset = offset - self.unitLength;
				end

				node.pos = 0.0;
				self:_setSubTextureRect(node);

				if self.bodyTail == nil then
					CGameNode.setPosition(node.value, 0.0, -node.neg * self.unitLength);
					self.bodyHead = node;
					self.bodyTail = node;
				else
					local x, y = CGameNode.getPosition(self.bodyTail.value);
					CGameNode.setPosition(node.value, 0.0, y - node.neg * self.unitLength);

					local old = self.bodyTail;
					self.bodyTail = node;
					node.prev = old;
					old.next = node;
				end
			end
		end
	else
		while offset < 0.0 do
			local lastLen = 0.0;
			if self.bodyTail ~= nil then
				lastLen = (self.bodyTail.neg - self.bodyTail.pos) * self.unitLength;
			end

			if lastLen > 0.0 then
				if lastLen > -offset then
					self.bodyTail.neg = self.bodyTail.neg + offset / self.unitLength;
					self:_setSubTextureRect(self.bodyTail);
					CGameNode.appendPosition(self.bodyTail.value, 0.0, -offset);
					offset = 0.0;
				else
					self:_pushNode(self.bodyTail);
					if self.bodyHead == self.bodyTail then
						self.bodyHead = nil;
						self.bodyTail = nil;
					else
						self.bodyTail = self.bodyTail.prev;
						self.bodyTail.next = nil;
					end

					offset = offset + lastLen;
				end
			else
				offset = 0.0;
			end
		end
	end
end

function C:_move(offset)
	if offset ~= 0.0 then
		local node = self.bodyHead;
		while node ~= nil do
			CGameNode.appendPosition(node.value, 0.0, offset);
			node = node.next;
		end

		self:_moveHead(-offset);
		self:_moveTail(offset);
	end
end

function C:_setSubTextureRect(node)
	CGameSprite.setSubTextureRect(node.value, 0.0, node.pos, 1.0, node.neg - node.pos);
end

function C:_getNode()
	local node = nil;
	if self.numBodiesPool == 0 then
		node = {};
	else
		node = self.bodiesPool[self.numBodiesPool];
		self.numBodiesPool = self.numBodiesPool - 1;
	end

	node.prev = nil;
	node.next = nil;
	node.value = self:_getDisPtr();
	node.pos = 0.0;
	node.neg = 0.0;

	return node;
end

function C:_pushNode(node)
	self.numBodiesPool = self.numBodiesPool + 1;
	self.bodiesPool[self.numBodiesPool] = node;

	self:_pushDisPtr(node.value);
end

function C:_getDisPtr()
	local disPtr = nil;

	if self.numDisPtrsPool == 0 then
		disPtr = CGameSprite.createWithSpriteFrame(self.spriteFramePtr);
		CGameRef.retain(disPtr);
		CGameNode.setAnchorPoint(disPtr, 0.5, 0.0);
	else
		disPtr = self.disPtrsPool[self.numDisPtrsPool];
		self.numDisPtrsPool = self.numDisPtrsPool - 1;
	end

	CGameNode.addChild(self.disPtr, disPtr);

	return disPtr;
end

function C:_pushDisPtr(disPtr)
	self.numDisPtrsPool = self.numDisPtrsPool + 1;
	self.disPtrsPool[self.numDisPtrsPool] = disPtr;
	CGameNode.removeFromParent(disPtr);
end
