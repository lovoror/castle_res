--EvilCat Skill1
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:attacked(attackDataPtr)
	self.isAttacked = true;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;

	local mode = toint(CEntity.getSharedData(entityPtr, "mode"));
	local px = tonumber(CEntity.getSharedData(entityPtr, "px"));
	local py = tonumber(CEntity.getSharedData(entityPtr, "py"));
	local ix = tonumber(CEntity.getSharedData(entityPtr, "ix"));
	local iy = tonumber(CEntity.getSharedData(entityPtr, "iy"));

	mode = (mode >> 4) & 0xF;
	self.px = px;
	self.py = py;

	if mode == 0 then
		ix = 0.0;
		CGameAction.setReverse(actionPtr, false);
	elseif mode == 1 then
		if CEntity.getDirection(entityPtr) == CDirectionEnum.LEFT then
			ix = -ix;
		end
		CGameAction.setReverse(actionPtr, false);
	elseif mode == 2 then
		if CEntity.getDirection(entityPtr) == CDirectionEnum.RIGHT then
			ix = -ix;
		end
		CGameAction.setReverse(actionPtr, true);
	elseif mode == 3 then
		if CEntity.getDirection(entityPtr) == CDirectionEnum.LEFT then
			ix = -ix;
		end
		self.distance = iy;
		iy = 0.0;
		CGameAction.setReverse(actionPtr, false);
	end

	self.mode = mode;
	self.ix = ix;
	self.iy = iy;
	self.springback = false;
	self.isAttacked = false;
	self.isFall = false;

	if mode == 0 then
		CGameAction.setLinkActionName(actionPtr, CGameAction.ACTION_SKILL.."3");
	else
		CGameAction.setLinkActionName(actionPtr, CGameAction.ACTION_SKILL.."2");
	end

	self.done = false;
end

function C:tick(time)
	local entityPtr = self.entityPtr;

	local hx, hy = CEntity.getHitBlockVector(entityPtr);
	if hy > 0.0 then
		self.isFall = true;
		self.iy = 0.0;
	end

	CEntity.appendInstantVelocity(entityPtr, self.ix, self.iy);

	if self.mode == 0 then
		local vx, vy = CEntity.getTotalVelocity(entityPtr);
		if vy <= 0.0 then
			self.done = true;
		end
	else
		if not self.springback then
			if self.isAttacked then
				self.springback = true;
			end

			if not self.springback then
				if math.abs(hx) >= 1.0 then
					self.springback = (self.ix < 0.0 and hx <= -1.0) or (self.ix > 0.0 and hx >= 1.0);
				end
			end

			if self.springback then
				local actionPtr = self.actionPtr;
				CGameAction.setReverse(actionPtr, true);
				self.ix = -self.ix;
				if not self.isFall then
					self.iy = 600.0;
				end
				CEntity.setInstantVelocity(entityPtr, self.ix, self.iy);
				CEntity.setPersistVelocity(entityPtr, 0.0, 0.0);
			end
		end

		if (not self.springback) and self.mode == 3 then
			local px, py = CEntity.getPosition(entityPtr);
			if math.abs(px - self.px) >= self.distance then
				self.done = true;
			end

			if not self.done then
				local vx, vy = CEntity.getTotalVelocity(entityPtr);
				if vx < 0.0 then
					if px <= 0.0 then
						self.done = true;
					end
				elseif vx > 0.0 then
					if px >= CBaseTileMap.getMaxWidth(CChapterScene.getTileMapPtr()) then
						self.done = true;
					end
				end
			end
		end
	end
end

function C:isDone(result)
	if self.done then
		return true, true;
	else
		return false, false;
	end
end

function C:dispose()
	return true;
end
