local C = registerClassAuto(getClass(ITEM_PACKAGE, ITEM_BATTLE_BASE));

function C:ctor()
	self.MAX_SCALE = 0.5;
end

function C:awake(itemPtr)
	super.awake(self, itemPtr);

	self.count = 0;
	self.scale = 0.0;
end

function C:equipment(count)
	if count == 1 then
		self.entityPtr = CItem.getEntityPtr(self.itemPtr);
		self.battleAttributePtr = CEntity.getBattleAttributePtr(self.entityPtr);
	end

	self.count = count;
	self:_update();
end

function C:discharge(count)
	self.count = count;
	self:_update();
end

function C:preBattle(time)
	self:_update();
end

function C:_update()
	local entityPtr = self.entityPtr;

	local curHP = CEntity.getHP(entityPtr);
	local maxHP = CBattleAttribute.getFinalHP(self.battleAttributePtr);

	local scale;
	if maxHP <= 1 then
		scale = 0.0;
	else
		if curHP == 1 then
			scale = self.MAX_SCALE;
		else
			scale = (curHP - 1.0) / (maxHP - 1.0);
			if scale < 0.0 then
				scale = 0.0;
			end
			scale = self.MAX_SCALE * (1.0 - scale);
		end
	end

	scale = scale * self.count;

	if self.scale ~= scale then
		local ptr = self.battleAttributePtr;
		local sub = scale - self.scale;

		CBattleAttribute.setATKScale(ptr, CBattleAttribute.getATKScale(ptr) + sub);
		CBattleAttribute.updateATK(ptr);

		CBattleAttribute.setMATScale(ptr, CBattleAttribute.getMATScale(ptr) + sub);
		CBattleAttribute.updateMAT(ptr);

		self.scale = scale;
	end
end
