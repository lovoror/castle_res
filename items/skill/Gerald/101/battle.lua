--Gerald skill battle 101
local C = registerClassAuto(getClass(ITEM_PACKAGE, ITEM_BATTLE_BASE));

function C:ctor()
	self.CD = 1.0;
	self.READY_TIME = 0.6;

	self.cache = {};
	self.numCache = 0;

	self.shootQueue = {};
	self.numQueue = 0;
end

function C:awake(itemPtr)
	super.awake(self, itemPtr);

	self.time = -self.CD;
end

function C:discharge(count)
	if count <= 0 and self.numQueue > 0 then
		for i = 1, self.numQueue do
			local obj = self.shootQueue[i];
			for j = 1, obj.curNum do
				CEntity.setDie(obj.bulletPtrs[j]);
			end

			self.numCache = self.numCache + 1;
			self.cache[self.numCache] = obj;
		end

		self.numQueue = 0;
	end
end

function C:getSkillTag()
	return "*";
end

function C:useCondition()
	return CEntity.isHost(self.entityPtr) and (CChapterScene.getLogicTime() - self.time >= self.CD) and CEntity.getMP(self.entityPtr) >= CItem.getConsumeMP(self.itemPtr);
end

function C:use()
	self:_use();
end

function C:collectSync(bytesPtr)
	CByteArray.writeBool(bytesPtr, true);
end

function C:executeSync(bytesPtr)
	self:_use();
end

function C:preBattle(time)
	local idx = 1;
	while idx <= self.numQueue do
		local obj = self.shootQueue[idx];
		obj.curReadyTime = obj.curReadyTime + time;
		if obj.curReadyTime >= self.READY_TIME then
			if obj.curNum < obj.maxNum then
				self:_createBullet(obj);
			end

			for i = 1, obj.curNum do
				local bulletPtr = obj.bulletPtrs[i];
				CBulletBehaviorController.setEnabled(CEntity.getBehaviorControllerPtr(bulletPtr), true);
				CEntity.setAttackEnabled(bulletPtr, true);
			end

			self.numCache = self.numCache + 1;
			self.cache[self.numCache] = obj;

			for i = idx + 1, self.numQueue do
				self.shootQueue[i - 1] = self.shootQueue[i];
			end
			self.numQueue = self.numQueue - 1;
		else
			self:_createBullet(obj);
			idx = idx + 1;
		end
	end
end

function C:_createBullet(obj)
	local t = obj.curReadyTime;
	if t > self.READY_TIME then t = self.READY_TIME; end

	local num = 1 + math.tointeger(math.floor(t / obj.unitTime));
	if num > obj.maxNum then num = obj.maxNum; end
	
	if num > obj.curNum then
		local res = CItem.getRes(self.itemPtr);
		for i = obj.curNum + 1, num do
			local ptr = CBulletBehaviorController.create();
			CBulletBehaviorController.setEnabled(ptr, false);
			CBulletBehaviorController.setPosition(ptr, -1, obj.x, obj.y, true);
			CBulletBehaviorController.setGravityScale(ptr, 0.0, 0.0);
			CBulletBehaviorController.setVelocity(ptr, 700.0);
			CBulletBehaviorController.setAngle(ptr, math.deg(math.pi * 0.5 - obj.unitRadian * (i - 1)), true);
			CBulletBehaviorController.setDoneDistance(ptr, 600.0);

			CBulletBehaviorController.setATKFactor(ptr, obj.lv * 0.5, 0.5);
			CBulletBehaviorController.setMATFactor(ptr, 0.0, 0.0);
			CBulletBehaviorController.setSlashDamageFactor(ptr, obj.lv * 0.5, 1.0);

			obj.curNum = obj.curNum + 1;
			local bulletPtr = CBullet.createBullet(res, self.entityPtr, ptr, self.itemPtr, 0, CChapterScene.getEffectAnteriorLayerPtr(2));
			CEntity.setAttackEnabled(bulletPtr, false);
			obj.bulletPtrs[obj.curNum] = bulletPtr;
		end
	end
end

function C:_use()
	self.time = CChapterScene.getLogicTime();
	CEntity.appendMP(self.entityPtr, -CItem.getConsumeMP(self.itemPtr));

	local lv = CItem.getLevel(self.itemPtr);

	local obj = self:_getShootObj();
	obj.curReadyTime = 0.0;
	obj.lv = lv;
	obj.maxNum = 3 + lv - 1;
	obj.curNum = 0;
	obj.unitTime = self.READY_TIME / obj.maxNum;
	obj.unitRadian = math.pi * 2.0 / obj.maxNum;

	local bonePtr = CGameAnimate.getBonePtr(CGameAction.getAnimatePtr(CGameActionController.getCurrentActionPtr(CEntity.getActionControllerPtr(self.entityPtr))), "bone_program");
	local cx, cy = CEntity.transformModelToCharacter(self.entityPtr, CGameSpineBone.getWorldPosition(bonePtr));
	local px, py = CEntity.getPosition(self.entityPtr);
	local sx, sy = CEntity.getScale(self.entityPtr);
	obj.x = px + cx * sx;
	obj.y = py + cy * sy;

	self.numQueue = self.numQueue + 1;
	self.shootQueue[self.numQueue] = obj;
end

function C:_getShootObj()
	local obj = nil;

	if self.numCache == 0 then
		obj = {};
		obj.bulletPtrs = {};
	else
		obj = self.cache[self.numCache];
		self.numCache = self.numCache - 1;
	end

	return obj;
end