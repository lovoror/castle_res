--HornBeast
local C = registerClassAuto(getClass(AI_PACKAGE, AI_CLASSIC));

function C:ctor()
	self.EYE_STEP_RND_NEXT = 0;
	self.EYE_STEP_ROTATE = 2;
	self.EYE_STEP_LINE = 1;
	self.EYE_STEP_WAIT = 3;
	self.EYE_STEP_RND_MOVE_WAIT = 4;

	self.SKILL1_CAUTION_TIME = 1.0;
	self.SKILL1_KEEP_TIME = 1.0;

	self.ACTIVATE_DISTANCE = 700.0;
	self.ACTIVATE_DISTANCE_2 = self.ACTIVATE_DISTANCE * self.ACTIVATE_DISTANCE;
end

function C:awake(executorPtr)
	local entityPtr = CAIExecutor.getEntityPtr(executorPtr);
	self.entityPtr = entityPtr;

	self.activated = false;
	self.activating = false;
	self.isDie = false;

	local actionPtr = CGameActionController.getCurrentActionPtr(CEntity.getActionControllerPtr(entityPtr));
	local animatePtr = CGameAction.getAnimatePtr(actionPtr);

	self.eyeBonePtr = CGameAnimate.getBonePtr(animatePtr, "yanzhu");
	local x, y = CGameSpineBone.getPosition(self.eyeBonePtr);
	self.eyeStep = nil;
	self.eyeOriginX = x;
	self.eyeOriginY = y;
	self.eyeCurX = x;
	self.eyeCurY = y;

	self.mandibleBonePtr = CGameAnimate.getBonePtr(animatePtr, "xiaba");
	self.mandibleOriginRotation = CGameSpineBone.getRotation(self.mandibleBonePtr);
	self.mandibleStep = 0;
	self.mandibleCurRotation = 0.0;

	super.awake(self, executorPtr);

	CGameActionController.changeAction(CEntity.getActionControllerPtr(entityPtr), CGameAction.ACTION_SKILL.."10", false, true);

	--CEntity.addBuff(entityPtr, 1, -1);
end

function C:_createSkills()
end

function C:start()
	local bodyMinX = -90.0;
	local bodyMaxX = 90.0;
	local bodyMinY = -5.0;
	local bodyMaxY = 200.0;

	local entityPtr = self.entityPtr;
	local px, py = CEntity.getPosition(entityPtr);
	py = py + 100.0;

	local tileMapPtr = CChapterScene.getTileMapPtr();
	local b, hitX, hitY = CTileMap.collisionLine(tileMapPtr, px, py, px + 5000.0, py, false, true);
	local clampMaxX = hitX;
	self.moveMaxX = clampMaxX - bodyMaxX;

	local b, hitX, hitY = CTileMap.collisionLine(tileMapPtr, px, py, px - 5000.0, py, false, true);
	local clampMinX = hitX;
	self.moveMinX = clampMinX - bodyMinX;

	local b, hitX, hitY = CTileMap.collisionLine(tileMapPtr, px, py, px, py + 5000.0, false, true);
	local clampMaxY  = hitY;
	self.moveMaxY = clampMaxY - bodyMaxY;

	local b, hitX, hitY = CTileMap.collisionLine(tileMapPtr, px, py, px, py - 5000.0, false, true);
	local clampMinY  = hitY;
	self.moveMinY = clampMinY - bodyMinY;

	CAISearchTargetsTask.setClampRange(self.searchTargetsTaskPtr, clampMinX, clampMaxX, clampMinY, clampMaxY);
	CAIExecutor.setGuardRange(self.executorPtr, -5000.0, -5000.0, 5000.0, 5000.0);

	local skill0GroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local moveTaskPtr = self:createCPtrs(CAIMoveTask);
	CAIMoveTask.setFree(moveTaskPtr, true);
	CAIMoveTask.setSpeed(moveTaskPtr, 0.0, 1.0);
	CAIMoveTask.setAcceleratedVelocity(moveTaskPtr, 1000.0);
	CAIMoveTask.setOrientation(moveTaskPtr, CAIMoveTask.ORIENTATION_KEEP);
	CAITaskBase.setStartHandler(moveTaskPtr, "_skill0MoveStartHandler");
	CAIGroupTaskBase.addTask(skill0GroupTaskPtr, moveTaskPtr);
	local dirTask = self:createCPtrs(CAIDirectionTask);
	self.skill0DirTaskPtr = dirTask;
	CAIGroupTaskBase.addTask(skill0GroupTaskPtr, dirTask);
	local actionTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(actionTaskPtr, CGameAction.ACTION_SKILL.."0", false, true);
	CAIActionTask.setDetach(actionTaskPtr, true);
	CAITaskBase.setImmediate(actionTaskPtr, true);
	CAIGroupTaskBase.addTask(skill0GroupTaskPtr, actionTaskPtr);
	local atkTaskPtr = self:createCPtrs(CAIMoveTask);
	self.skill0AtkTaskPtr = atkTaskPtr;
	CAITaskBase.setEndHandler(atkTaskPtr, "_skill0MoveEndHandler");
	CAIMoveTask.setFree(atkTaskPtr, true);
	CAIMoveTask.setSpeed(atkTaskPtr, 0.0, 1.2);
	CAIMoveTask.setAcceleratedVelocity(atkTaskPtr, 1000.0);
	CAIMoveTask.setOrientation(atkTaskPtr, CAIMoveTask.ORIENTATION_KEEP);
	CAIGroupTaskBase.addTask(skill0GroupTaskPtr, atkTaskPtr);
	local actionTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(actionTaskPtr, CGameAction.ACTION_IDLE, false, true);
	CAIActionTask.setDetach(actionTaskPtr, true);
	CAITaskBase.setImmediate(actionTaskPtr, true);
	CAIGroupTaskBase.addTask(skill0GroupTaskPtr, actionTaskPtr);
	local waitTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(waitTaskPtr, 1.0);
	CAIGroupTaskBase.addTask(skill0GroupTaskPtr, waitTaskPtr);

	self:_createSkill(0, 8.0, 5.0, 3.0, nil, skill0GroupTaskPtr, nil, 0);
	--self:_createSkill(0, 0, 0, 0, nil, skill0GroupTaskPtr, nil, 0);


	local skill1GroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local dirTask = self:createCPtrs(CAIDirectionTask);
	CAIDirectionTask.setMode(dirTask, CAIDirectionTask.ORIENTATION_TARGET);
	CAIGroupTaskBase.addTask(skill1GroupTaskPtr, dirTask);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, self.SKILL1_CAUTION_TIME + self.SKILL1_KEEP_TIME);
	CAITaskBase.setStartHandler(emptyTaskPtr, "_skill1StartHandler");
	CAIGroupTaskBase.addTask(skill1GroupTaskPtr, emptyTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 1.0, 0.5);
	CAIGroupTaskBase.addTask(skill1GroupTaskPtr, emptyTaskPtr);

	--self:_createSkill(1, 10, 7, 0, nil, skill1GroupTaskPtr, nil, 0);
	self:_createSkill(1, 6.0, 4.0, 3.0, nil, skill1GroupTaskPtr, nil, 0);



	local attackGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	local actionTaskPtr = self:createCPtrs(CAIActionTask);
	CAIActionTask.setAction(actionTaskPtr, CGameAction.ACTION_SKILL.."2", false, false);
	CAITaskBase.setImmediate(actionTaskPtr, true);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, actionTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.5, 0.5);
	CAIGroupTaskBase.addTask(attackGroupTaskPtr, emptyTaskPtr);

	self:_createSkill(2, 18.0, 4.0, 3.0, rangeCondPtr, attackGroupTaskPtr, trackTaskPtr, 0);


	local rndMoveGroupTaskPtr = self:createCPtrs(CAISequenceGroupTask);
	CAITaskBase.setWeight(rndMoveGroupTaskPtr, 0.5);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, -1.0, 0.0);
	CAITaskBase.setStartHandler(emptyTaskPtr, "_rndWaitStartHandler");
	CAITaskBase.setTickHandler(emptyTaskPtr, "_rndWaitTickHandler");
	CAIGroupTaskBase.addTask(rndMoveGroupTaskPtr, emptyTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 0.7, 0.0);
	CAIGroupTaskBase.addTask(rndMoveGroupTaskPtr, emptyTaskPtr);
	local trackTaskPtr = self:createCPtrs(CAIMoveTask);
	CAIMoveTask.setFree(trackTaskPtr, true);
	CAIMoveTask.setOrientation(trackTaskPtr, CAIMoveTask.ORIENTATION_KEEP);
	CAITaskBase.setStartHandler(trackTaskPtr, "_rndMoveStartHandler");
	CAITaskBase.setEndHandler(trackTaskPtr, "_rndMoveEndHandler");
	CAIGroupTaskBase.addTask(rndMoveGroupTaskPtr, trackTaskPtr);
	local emptyTaskPtr = self:createCPtrs(CAIEmptyTask);
	CAIEmptyTask.setTime(emptyTaskPtr, 1.0, 0.5);
	CAIGroupTaskBase.addTask(rndMoveGroupTaskPtr, emptyTaskPtr);
	local condPtr = self:createCPtrs(CAICustomCondition);
	CAICustomCondition.setHandler(condPtr, "_rndMoveCondHandler");
	CAITaskBase.setCondition(rndMoveGroupTaskPtr, condPtr, true);

	self:_createSkill(3, 0.0, 0.0, 0.0, nil, rndMoveGroupTaskPtr, nil);
end

function C:_skill0MoveStartHandler(ptr)
	local x;
	local y;
	local toX;
	local dir;

	local r = math.random();
	if r <= 0.5 then
		dir = -1;
		x = self.moveMinX + 5.0;
		toX = self.moveMaxX - 5.0;
	else
		dir = 1;
		x = self.moveMaxX - 5.0;
		toX = self.moveMinX + 5.0;
	end

	local px, py;
	local targetPtr = CAIExecutor.getTargetPtr(self.executorPtr, 0);
	if CisNullptr(targetPtr) then
		px = self.moveMinX + (self.moveMaxX - self.moveMinX) * math.random();
		py = self.moveMinY + (self.moveMaxY - self.moveMinY) * math.random();
	else
		px, py = CBattleCollider.getPosition(targetPtr);
	end
	y = py;
	if y > self.moveMaxY then
		y = self.moveMaxY;
	elseif y < self.moveMinY then
		y = self.moveMinY;
	end

	CAIMoveTask.setMoveTo(ptr, true, x, y);
	CAIMoveTask.setMoveTo(self.skill0AtkTaskPtr, true, toX, y);

	if dir == -1 then
		if CEntity.getDirection(self.entityPtr) == CDirectionEnum.LEFT then
			CAIDirectionTask.setMode(self.skill0DirTaskPtr, CAIDirectionTask.ORIENTATION_RIGHT);
			CAIObject.setEnabled(self.skill0DirTaskPtr, true);
		else
			CAIObject.setEnabled(self.skill0DirTaskPtr, false);
		end
	else
		if CEntity.getDirection(self.entityPtr) == CDirectionEnum.RIGHT then
			CAIDirectionTask.setMode(self.skill0DirTaskPtr, CAIDirectionTask.ORIENTATION_LEFT);
			CAIObject.setEnabled(self.skill0DirTaskPtr, true);
		else
			CAIObject.setEnabled(self.skill0DirTaskPtr, false);
		end
	end
end

function C:_skill0MoveEndHandler(ptr)
	local px, py = CEntity.getPosition(self.entityPtr);
	CChapterScene.shake(px, py, 20.0, 3000.0, 0.2);

	local chPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr)), "skill0_2"), true);
	CAudioManager.set3DAttributes(chPtr, px, py);
	CAudioManager.setPaused(chPtr, false);
end

function C:_skill1StartHandler(ptr)
	local px, py;
	local targetPtr = CAIExecutor.getTargetPtr(self.executorPtr, 0);
	if CisNullptr(targetPtr) then
		local minX, maxX;
		local x, y = CEntity.getPosition(self.entityPtr);
		if CEntity.getDirection(self.entityPtr) == CDirectionEnum.LEFT then
			minX =self.moveMinX;
			maxX = x;
		else
			minX = x;
			maxX = self.moveMaxX;
		end
		px = minX + (maxX - minX) * math.random();
		py = self.moveMinY + (self.moveMaxY - self.moveMinY) * math.random();
	else
		px, py = CBattleCollider.getPosition(targetPtr);
	end

	self:_shotLaser(px, py);

	if CChapterScene.isNetwork() and self.isHost then
		CProtocol.sendCptActorBehaviorSync(self.entityPtr,
		function(baPtr)
			CByteArray.writeUInt8(baPtr, 1);
			CByteArray.writeFloat(baPtr, px);
			CByteArray.writeFloat(baPtr, py);
		end);
	end
end

function C:_shotLaser(x, y)
	local bbcPtr = CBulletBehaviorController.create();
	CBulletBehaviorController.setFollowOwner(bbcPtr, true);
	CBulletBehaviorController.setPosition(bbcPtr, 0, 0.0, 0.0);
	CBulletBehaviorController.setDoneDie(bbcPtr, true);

	CBulletBehaviorController.setATKFactor(bbcPtr, 0.0, 0.0);
	CBulletBehaviorController.setMATFactor(bbcPtr, 0.0, 0.8);

	local baPtr = CEntity.getBattleAttributePtr(self.entityPtr);
	local mat = CBattleAttribute.getFinalMAT(baPtr);
	CBulletBehaviorController.setElectricityDamageFactor(bbcPtr, mat * 0.8, 1.0);

	local bulletPtr = CBullet.createBullet(CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr)).."/1", self.entityPtr, bbcPtr);

	CEntity.setSharedData(bulletPtr, "targetX", tostring(x));
	CEntity.setSharedData(bulletPtr, "targetY", tostring(y));
	CEntity.setSharedData(bulletPtr, "cautionTime", tostring(self.SKILL1_CAUTION_TIME));
	CEntity.setSharedData(bulletPtr, "keepTime", tostring(self.SKILL1_KEEP_TIME));
end

function C:_rndMoveCondHandler(ptr)
	return self.eyeStep == self.EYE_STEP_WAIT;
end

function C:_rndWaitStartHandler(ptr)
	self.requestEyeStep = self.EYE_STEP_RND_MOVE_WAIT;
end

function C:_rndWaitTickHandler(ptr)
	if self.eyeStep == self.EYE_STEP_WAIT and self.requestEyeStep ~= self.EYE_STEP_RND_MOVE_WAIT then
		self.eyeStep = -1;
		CAITaskBase.setDone(ptr, true);

		self:_sendEyeStep();
	elseif self.eyeStep == self.EYE_STEP_RND_MOVE_WAIT then
		local entityPtr = self.entityPtr;

		local px, py = CEntity.getPosition(entityPtr);
		local dir = CEntity.getDirection(entityPtr);
		local toX = self.moveMinX + (self.moveMaxX - self.moveMinX) * math.random();
		local toY = self.moveMinY + (self.moveMaxY - self.moveMinY) * math.random();
		local a = math.atan(self.eyeCurY - self.eyeOriginY, self.eyeCurX - self.eyeOriginX);
		local a2 = math.atan(toY - py, toX - px);
		if dir == CDirectionEnum.LEFT then
			if a2 < 0.0 then
				a2 = -math.pi - a2;
			else
				a2 = math.pi - a2;
			end
		end

		a = a2 - a;

		self.moveToX = toX;
		self.moveToY = toY;
		self.eyeStep = self:_setEyeRotate(a);

		self:_sendEyeStep();
	end
end

function C:_rndMoveStartHandler(ptr)
	CAIMoveTask.setMoveTo(ptr, true, self.moveToX, self.moveToY);
end

function C:_rndMoveEndHandler(ptr)
	self.eyeStep = self.EYE_STEP_WAIT;
	self.eyeCurWaitTime = 0.0;

	self:_sendEyeStep();
end

function C:tick(time)
	super.tick(self, time);

	if self.activated then
		self:_eyeAnimStep(time);
		self:_mandibleAnimStep(time);

		self:_updateAnim();
	end
end

function C:actionStart()
	self:_updateAnim();
end

function C:_eyeAnimStep(time)
	local eyeRadius = 12.0;
	local eyeAngle = math.rad(360.0);
	local eyeSpeed = 150.0;
	local waitTime = 1.0;
	local eyeStep = self.eyeStep;

	local needSync = false;

	if eyeStep == nil then
		if CEntity.isHost(self.entityPtr) then
			eyeStep = self.EYE_STEP_LINE;
			local a = 360.0 * math.random();
			a = math.rad(a);
			self.eyeAngle = a;
			self.eyeSin = math.sin(a);
			self.eyeCos = math.cos(a);
			self.eyeDistance = eyeRadius;

			needSync = true;
		end
	elseif eyeStep == self.EYE_STEP_RND_NEXT then
		if CEntity.isHost(self.entityPtr) then
			if math.random() < 0.5 then
				eyeStep = self.EYE_STEP_LINE;
				local x, y = CGameSpineBone.getPosition(self.eyeBonePtr);
				local a = math.atan(self.eyeOriginY - y, self.eyeOriginX - x);
				self.eyeAngle = a;
				self.eyeSin = math.sin(a);
				self.eyeCos = math.cos(a);
				self.eyeDistance = eyeRadius * 2.0;
			else
				eyeStep = self.EYE_STEP_ROTATE;
				self.eyeAngle = math.random() * math.pi * 2.0;
				self.eyeCurAngle = 0.0;
			end

			needSync = true;
		end
	elseif eyeStep == self.EYE_STEP_LINE then
		local v = eyeSpeed * time;
		if v > self.eyeDistance then
			v = self.eyeDistance;
		end
		local x = self.eyeCos * v;
		local y = self.eyeSin * v;
		self.eyeCurX = self.eyeCurX + x;
		self.eyeCurY = self.eyeCurY + y;
		self.eyeDistance = self.eyeDistance - v;

		if self.eyeDistance <= 0.0 then
			eyeStep = self.EYE_STEP_WAIT;
			self.eyeCurX = self.eyeOriginX + self.eyeCos * eyeRadius;
			self.eyeCurY = self.eyeOriginY + self.eyeSin * eyeRadius;
			self.eyeCurWaitTime = 0.0;
		end
	elseif eyeStep == self.EYE_STEP_ROTATE then
		local a = eyeAngle * time;
		if self.eyeCurAngle + a > self.eyeAngle then
			a = self.eyeAngle - self.eyeCurAngle;
		end
		local sinValue = math.sin(a);
		local cosValue = math.cos(a);
		local x = self.eyeCurX - self.eyeOriginX;
		local y = self.eyeCurY - self.eyeOriginY;
		local px = x * cosValue - y * sinValue;
		local py = x * sinValue + y * cosValue;
		self.eyeCurX = self.eyeOriginX + px;
		self.eyeCurY = self.eyeOriginY + py;
		self.eyeCurAngle = self.eyeCurAngle + a;

		if self.eyeCurAngle >= self.eyeAngle then
			eyeStep = self.EYE_STEP_WAIT;
			self.eyeCurWaitTime = 0.0;
		end
	elseif eyeStep == self.EYE_STEP_WAIT then
		self.eyeCurWaitTime = self.eyeCurWaitTime + time;
		if self.eyeCurWaitTime >= waitTime then
			if self.requestEyeStep ~= nil then
				eyeStep = self.requestEyeStep;
				self.requestEyeStep = nil;
			else
				eyeStep = self.EYE_STEP_RND_NEXT;
			end
		end
	end

	self.eyeStep = eyeStep;
	if needSync then self:_sendEyeStep(); end
end

function C:_sendEyeStep()
	if CChapterScene.isNetwork() and CEntity.isHost(self.entityPtr) then
		CProtocol.sendCptActorBehaviorSync(self.entityPtr,
		function(baPtr)
			CByteArray.writeUInt8(baPtr, 2);
			CByteArray.writeInt328(baPtr, self.eyeStep);
			CByteArray.writeFloat(baPtr, self.eyeCurX);
			CByteArray.writeFloat(baPtr, self.eyeCurY);

			if self.eyeStep == self.EYE_STEP_LINE then
				CByteArray.writeFloat(baPtr, self.eyeAngle);
				CByteArray.writeFloat(baPtr, self.eyeDistance);
			elseif self.eyeStep == self.EYE_STEP_ROTATE then
				CByteArray.writeFloat(baPtr, self.eyeAngle);
			end
		end);
	end
end

function C:_setEyeRotate(angle)
	self.eyeAngle = angle;
	self.eyeCurAngle = 0.0;
	return self.EYE_STEP_ROTATE;
end

function C:_mandibleAnimStep(time)
	local maxAngle = 20.0;
	local angle = 20.0;
	local step = self.mandibleStep;
	if step == 0 then
		self.mandibleCurRotation = self.mandibleCurRotation + angle * time;
		if self.mandibleCurRotation >= maxAngle then
			self.mandibleCurRotation = maxAngle;
			step = 1;
		end
	else
		self.mandibleCurRotation = self.mandibleCurRotation - angle * time;
		if self.mandibleCurRotation <= 0.0 then
			self.mandibleCurRotation = 0.0;
			step = 0;
		end
	end

	self.mandibleStep = step;
end

function C:executeSync(bytesPtr)
	local type = CByteArray.readUInt8(bytesPtr);

	if type == 1 then
		local px = CByteArray.readFloat(bytesPtr);
		local py = CByteArray.readFloat(bytesPtr);
		self:_shotLaser(px, py);
	elseif type == 2 then
		self.eyeStep = CByteArray.readInt328(bytesPtr);
		self.eyeCurX = CByteArray.readFloat(bytesPtr);
		self.eyeCurY = CByteArray.readFloat(bytesPtr);

		if self.eyeStep == self.EYE_STEP_LINE then
			self.eyeAngle = CByteArray.readFloat(bytesPtr);
			self.eyeDistance = CByteArray.readFloat(bytesPtr);
			self.eyeSin = math.sin(self.eyeAngle);
			self.eyeCos = math.cos(self.eyeAngle);
		elseif self.eyeStep == self.EYE_STEP_ROTATE then
			self.eyeAngle = CByteArray.readFloat(bytesPtr);
			self.eyeCurAngle = 0.0;
		elseif self.eyeStep == self.EYE_STEP_WAIT then
			self.eyeAngle = CByteArray.readFloat(bytesPtr);
			self.eyeCurWaitTime = 0.0;
		end
	end
end

function C:_updateAnim()
	if self.isDie or CGameAction.getTag(CEntity.getCurrentActionPtr(self.entityPtr)) == CGameAction.ACTION_VEER then
		CGameSpineBone.setX(self.eyeBonePtr, self.eyeOriginX);
		CGameSpineBone.setY(self.eyeBonePtr, self.eyeOriginY);

		CGameSpineBone.setRotation(self.mandibleBonePtr, mandibleOriginRotation);
	else
		CGameSpineBone.setX(self.eyeBonePtr, self.eyeCurX);
		CGameSpineBone.setY(self.eyeBonePtr, self.eyeCurY);

		CGameSpineBone.setRotation(self.mandibleBonePtr, self.mandibleOriginRotation - self.mandibleCurRotation);
	end
end

function C:_skillManagerTick(time)
	if self.activated then
		self.skillManager:tick(time);
	end
end

function C:actionStart()
	if CGameAction.getTag(CEntity.getCurrentActionPtr(self.entityPtr)) == CGameAction.ACTION_DIE then
		self.isDie = true;
	end
end

function C:actionEnd()
	if not self.activated then
		if CGameAction.getTag(CEntity.getCurrentActionPtr(self.entityPtr)) == CGameAction.ACTION_SKILL.."11" then
			self.activated = true;
			self.activating = false;
		end
	end
end

function C:_tick(time)
	if self.first == nil then
		self.first = true;
		return;
	end

	local executorPtr = self.executorPtr;

	local numTargets = CAIExecutor.getNumTargets(executorPtr);

	if self.activated then
		if numTargets > 0 then
			if self.dirCondPtr == nil or CAIExecutor.runCondition(executorPtr, self.dirCondPtr) then
				CAIExecutor.setTask(executorPtr, self.actionBehaviorPtr);
			else
				CAIExecutor.setTask(executorPtr, self.dirTaskPtr);
			end
		else
			CAIExecutor.setTask(executorPtr, self.actionBehaviorPtr);
		end
	else
		if (not self.activating) and numTargets > 0 then
			local bcPtr = CAIExecutor.getTargetPtr(self.executorPtr, 0);
			local tx, ty = CBattleCollider.getPosition(bcPtr);
			local sx, sy = CEntity.getPosition(self.entityPtr);
			local dx = tx - sx;
			local dy = ty - sy;
			if dx * dx + dy * dy <= self.ACTIVATE_DISTANCE_2 then
				self.activating = true;
				CGameActionController.changeAction(CEntity.getActionControllerPtr(self.entityPtr), CGameAction.ACTION_SKILL.."11", false, true);
			end
		end
	end
end
