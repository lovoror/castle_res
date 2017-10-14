--UVAnimator
local C = registerClassAuto(getClass(AI_PACKAGE, AI_BASE));

function C:ctor()
	self.KEY_U = "u";
	self.KEY_V = "v";
	self.KEY_COLOR= "color";
	self.KEY_RECT_COLOR = "rectColor";

	self.tmpArr = {};
end

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

	CComponentBehaviorWidget.HLayoutBegin(widgetPtr);

	local widgets = CESWidgetVector.create();

	local hp, label, uLabel, u, vLabel, v = createEditorLineEdit2(widgetPtr, widgets, "Motion", "U", "V");
	self.editorU = u;
	self.editorV = v;

	local hp = CHorizontalPanel.create();
	local colorLabel = CESLabel.create("Color");
	local color = CESColorBox.create(true);
	self.editorColor = color;
	CHorizontalPanel.setSingle(hp, colorLabel, color);
	CComponentBehaviorWidget.addHLayoutPanel(widgetPtr, hp);

	local hp = CHorizontalPanel.create();
	local rectColorLabel = CESLabel.create("Rect Color");
	local rectColorLT = CESColorBox.create(true);
	self.editorRectColorLT = rectColorLT;
	CESWidgetVector.pushBack(widgets, rectColorLT);
	CESWidgetVector.pushBack(widgets, CESSpacing.createBig());
	local rectColorRT = CESColorBox.create(true);
	self.editorRectColorRT = rectColorRT;
	CESWidgetVector.pushBack(widgets, rectColorRT);
	CHorizontalPanel.setVector(hp, rectColorLabel, widgets);
	CComponentBehaviorWidget.addHLayoutPanel(widgetPtr, hp);
	CESWidgetVector.clear(widgets);

	local hp = CHorizontalPanel.create();
	local rectColorLB = CESColorBox.create(true);
	self.editorRectColorLB = rectColorLB;
	CESWidgetVector.pushBack(widgets, rectColorLB);
	CESWidgetVector.pushBack(widgets, CESSpacing.createBig());
	local rectColorRB = CESColorBox.create(true);
	self.editorRectColorRB = rectColorRB;
	CESWidgetVector.pushBack(widgets, rectColorRB);
	CHorizontalPanel.setVector(hp, CESLabel.create(""), widgets);
	CComponentBehaviorWidget.addHLayoutPanel(widgetPtr, hp);

	CESWidgetVector.free(widgets);
	CComponentBehaviorWidget.HLayoutEnd(widgetPtr);

	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, uLabel, self.KEY_U);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, vLabel, self.KEY_V);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, colorLabel, self.KEY_COLOR);
	CComponentBehaviorWidget.bindPrefabContextMenu(widgetPtr, rectColorLabel, self.KEY_RECT_COLOR);

	local uvFn = function(editor, key)
		local com = self.editorComponentPtr;

		local value = CESLineEdit.getText(editor);
		if CStringHelper.isFloat(value) then
			CChapterEditorComponentBehavior.setValue(com, key, value);
		end

		local uv = CChapterEditorComponentBehavior.getValue(com, key);
		if uv == "" then uv = "0"; end
		CESLineEdit.setText(editor, uv);
	end

	local rectColorFn = function()
		local colorStrFn = function(editor)
			return string.format("%x", CESColorBox.getColor(editor));
		end
		local value = colorStrFn(self.editorRectColorLB)..","..colorStrFn(self.editorRectColorLT)..","..colorStrFn(self.editorRectColorRT)..","..colorStrFn(self.editorRectColorRB);
		if value == "FFFFFFFF,FFFFFFFF,FFFFFFFF,FFFFFFFF" then
			value = "";
		end
		CChapterEditorComponentBehavior.setValue(self.editorComponentPtr, self.KEY_RECT_COLOR, value);
	end

	self.editorUListener = CESLineEdit.setActionListener(u, function()
		uvFn(self.editorU, self.KEY_U);
	end);

	self.editorVListener = CESLineEdit.setActionListener(v, function()
		uvFn(self.editorV, self.KEY_V);
	end);

	self.editorColorListener = CESColorBox.setActionListener(color, function()
		local c = CESColorBox.getColor(self.editorColor);
		local value = "";
		if c ~= 0xFFFFFFFF then
			value = string.format("%x", c);
		end
		CChapterEditorComponentBehavior.setValue(self.editorComponentPtr, self.KEY_COLOR, value);
	end);

	self.editorRectColorLTListener = CESColorBox.setActionListener(rectColorLT, function()
		rectColorFn();
	end);
	self.editorRectColorLBListener = CESColorBox.setActionListener(rectColorLB, function()
		rectColorFn();
	end);
	self.editorRectColorRTListener = CESColorBox.setActionListener(rectColorRT, function()
		rectColorFn();
	end);
	self.editorRectColorRBListener = CESColorBox.setActionListener(rectColorRB, function()
		rectColorFn();
	end);

	return "UV Animator";
end

function C:editorWidgetRefresh()
	local com = self.editorComponentPtr;

	local u = CChapterEditorComponentBehavior.getValue(com, self.KEY_U);
	if u == "" then u = "0"; end
	CESLineEdit.setText(self.editorU, u);

	local v = CChapterEditorComponentBehavior.getValue(com, self.KEY_V);
	if v == "" then v = "0"; end
	CESLineEdit.setText(self.editorV, v);

	local color = CChapterEditorComponentBehavior.getValue(com, self.KEY_COLOR);
	if color == "" then
		CESColorBox.setColor(self.editorColor, 0xFFFFFFFF);
	else
		CESColorBox.setColor(self.editorColor, tonumber(color, 16));
	end

	local rectColor = CChapterEditorComponentBehavior.getValue(com, self.KEY_RECT_COLOR);
	if rectColor == "" then
		CESColorBox.setColor(self.editorRectColorLT, 0xFFFFFFFF);
		CESColorBox.setColor(self.editorRectColorRT, 0xFFFFFFFF);
		CESColorBox.setColor(self.editorRectColorLB, 0xFFFFFFFF);
		CESColorBox.setColor(self.editorRectColorRB, 0xFFFFFFFF);
	else
		local arr = stringSplit(rectColor, ",", self.tmpArr);
		CESColorBox.setColor(self.editorRectColorLB, tonumber(arr[1], 16));
		CESColorBox.setColor(self.editorRectColorLT, tonumber(arr[2], 16));
		CESColorBox.setColor(self.editorRectColorRT, tonumber(arr[3], 16));
		CESColorBox.setColor(self.editorRectColorRB, tonumber(arr[4], 16));
	end
end

function C:editorWidgetDispose()
	if self.editorU ~= nil then
		Cunref(self.editorUListener);
		self.editorU = nil;
	end
	if self.editorV ~= nil then
		Cunref(self.editorVListener);
		self.editorV = nil;
	end
	if self.editorColor ~= nil then
		Cunref(self.editorColorListener);
		self.editorColor = nil;
	end
	if self.editorRectColorLT ~= nil then
		Cunref(self.editorRectColorLTListener);
		self.editorRectColorLT = nil;
	end
	if self.editorRectColorRT ~= nil then
		Cunref(self.editorRectColorRTListener);
		self.editorRectColorRT = nil;
	end
	if self.editorRectColorLB ~= nil then
		Cunref(self.editorRectColorLBListener);
		self.editorRectColorLB = nil;
	end
	if self.editorRectColorRB ~= nil then
		Cunref(self.editorRectColorRBListener);
		self.editorRectColorRB = nil;
	end
end

--===================================================

function C:awake(executorPtr)
	super.awake(self, executorPtr);

	local entityPtr = CAIExecutor.getEntityPtr(executorPtr);
	self.entityPtr = entityPtr;

	local disPtr = CEntity.getDisplayContentPtr(entityPtr);
	local animatorPtr = CUVAnimator.create();
	CGameNode.runAction(disPtr, animatorPtr);

	local u = 0.0;
	local value = CEntity.getSharedData(entityPtr, self.KEY_U);
	if value ~= "" then
		u = tonumber(value);
	end

	local v = 0.0;
	local value = CEntity.getSharedData(entityPtr, self.KEY_V);
	if value ~= "" then
		v = tonumber(value);
	end

	CUVAnimator.setSpeed(animatorPtr, u, v);

	local value = CEntity.getSharedData(entityPtr, self.KEY_COLOR);
	if value ~= "" then
		CUVAnimator.setColor(animatorPtr, tonumber(value, 16));
	end

	local value = CEntity.getSharedData(entityPtr, self.KEY_RECT_COLOR);
	if value ~= "" then
		local arr = stringSplit(value, ",", self.tmpArr);
		CUVAnimator.setRectColor(animatorPtr, true, tonumber(arr[1], 16), tonumber(arr[2], 16), tonumber(arr[3], 16), tonumber(arr[4], 16));
	end
end

function C:tick(time)
end
