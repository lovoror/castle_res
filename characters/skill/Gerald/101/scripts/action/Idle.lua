--Gerald skill 101:Idle
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
	self.LENGTH = 80.0;
end

function C:awake(actionPtr)
	super.awake(self, actionPtr);
end

function C:start(itemPtr)
	self.entityPtr = CGameAction.getEntityPtr(self.actionPtr);
end

function C:tick(time)
	if CEntity.getAttackEnabled(self.entityPtr) then
		local r = -math.rad(CEntity.getRotation(self.entityPtr));
		local x, y = rotatePoint(self.LENGTH, 0.0, math.sin(r), math.cos(r));
		local sx, sy = CEntity.getScale(self.entityPtr);
		local px, py = CEntity.getPosition(self.entityPtr);
		x = px + x * sx;
		y = py + y * sy;
		if not CTileMap.collisionLine(CChapterScene.getTileMapPtr(), px, py, x, y, false, false) then
			CEntity.setDie(self.entityPtr);
		end
	end
end

function C:dispose()
	return true;
end