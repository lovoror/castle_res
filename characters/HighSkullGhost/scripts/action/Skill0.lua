local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.ROTATE_PER_SECOND = 400.0;
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;

	self.targetX = tonumber(CEntity.getSharedData(entityPtr, "targetX"));
	self.targetY = tonumber(CEntity.getSharedData(entityPtr, "targetY"));

	self:_calculateAngle();
end

function C:collectSync(bytesPtr)
	CByteArray.writeFloat(bytesPtr, self.targetX);
	CByteArray.writeFloat(bytesPtr, self.targetY);
end

function C:executeSync(bytesPtr)
	self.targetX = CByteArray.readFloat(bytesPtr);
	self.targetY = CByteArray.readFloat(bytesPtr);

	CEntity.setSharedData(self.entityPtr, "targetX", tostring(self.targetX));
	CEntity.setSharedData(self.entityPtr, "targetY", tostring(self.targetY));

	self:_calculateAngle();
end

function C:tick(time)
	local r = CEntity.getRotation(self.entityPtr);
	if not (r == self.targetAngle) then
		local dr = self.targetAngle - r;
		local a = self.ROTATE_PER_SECOND * time;
		if a < math.abs(dr) then
			if dr < 0.0 then
				CEntity.setRotation(self.entityPtr, r - a);
			else
				CEntity.setRotation(self.entityPtr, r + a);
			end
		else
			CEntity.setRotation(self.entityPtr, self.targetAngle);
		end
	end
end

function C:dispose()
	return true;
end

function C:_calculateAngle()
	local px, py = CEntity.getPosition(self.entityPtr);
	local tx = self.targetX;
	if CEntity.getDirection(self.entityPtr) == CDirectionEnum.LEFT then
		tx = px + px - tx;
	end
	local dx = tx - px;
	local dy = self.targetY - py;
	self.targetAngle = -math.deg(math.atan(dy, dx));
end
