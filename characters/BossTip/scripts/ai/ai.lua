local C = registerClassAuto(getClass(AI_PACKAGE, AI_BASE));

function C:ctor()
	self.KEY_ID = "id";
	self.KEY_TYPE = "type";
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	self.isShow = false;

	self.id = 0;
	local value = CEntity.getSharedData(self.entityPtr, self.KEY_ID);
	if value ~= "" then
		self.id = toint(value);
	end

	self.type = CBossTipType.GOLD;
	local value = CEntity.getSharedData(self.entityPtr, self.KEY_TYPE);
	if value ~= "" then
		local type = toint(value);
		if type == "1" then
			self.type = CBossTipType.SILVER;
		end
	end
end

function C:tick(time)
	local show = false;

	if CChapterScene.getCurrentMapViewScaleLevel() == 3 then
		local targetPtr = nil;
		local genPtr = CChapterScene.getEntityGeneratorPtr(self.id);
		if not CisNullptr(genPtr) then
			targetPtr = CEntityGenerator.getEntityPtr(genPtr);
		end

		if not CisNullptr(targetPtr) then
			show = CGameActionData.getActivated(CGameAction.getActionDataPtr(CEntity.getCurrentActionPtr(targetPtr))) == false;
		end
	end

	if self.isShow ~= show then
		self.isShow = show;

		if show then
			CChapterScene.showBossTip(self.entityPtr, self.type);
		else
			CChapterScene.showBossTip(self.entityPtr, CBossTipType.NONE);
		end
	end
end
