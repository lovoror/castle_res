local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	self.hp = 3;
	self.crackPtr = nil;
end

function C:start(itemPtr)
	self.entityPtr = CGameAction.getEntityPtr(self.actionPtr);

	local disPtr = CEntity.getDisplayContentPtr(self.entityPtr);
	local sw, sh = CGameNode.getContentSize(disPtr);
	local ax, ay = CGameNode.getAnchorPoint(disPtr);

	self.resW = sw;
	self.resH = sh;
	self.anchorX = ax;
	self.anchorY = ay;

	self.collW = sw;
	self.collH = sh;
	self.collX = (0.5 - ax) * sw;
	self.collY = (ay - 0.5) * sh;

	self.isHost = CEntity.isHost(self.entityPtr);
end

function C:executeSync(bytesPtr)
	if self.hp > 0 then
		self.hp = 0;
		self:_doDie();
	end
end

function C:suffered(attackDataPtr)
    if CAttackData.getValue(attackDataPtr) < 0 and CAttackData.getType(attackDataPtr) == CBattleNumberType.HP and self.hp > 0 then
        self.hp = self.hp - 1;
        if self.hp == 0 then
			if CChapterScene.isNetwork() then
				CProtocol.sendCptActorActionSync(self.actionPtr, function(bytesPtr)
					CByteArray.writeBool(bytesPtr, true);
				end)
			end

            self:_doDie();
		else
			self:_doEffect(false);
        end
    end
end

function C:updateColliders()
	CGameAction.setCollider(self.actionPtr, 1, self.collX, self.collY, 0.0, 1.0, 1.0, 0, self.collW, self.collH, 0);

	return true, true;
end

function C:dispose()
	return true;
end

function C:_doDie()
	self:_doEffect(true);

	CEntity.setDie(self.entityPtr);
end

function C:_doEffect(isDie)
	local entityPtr = self.entityPtr;

	local px, py = CEntity.getPosition(entityPtr);
	local sx, sy = CEntity.getScale(entityPtr);
	local tw = self.resW * sx;
	local th = self.resH * sy;
	local x = px + tw * (0.5 - self.anchorX);
	local y = py + th * (0.5 - self.anchorY);

	local ptr = CBulletBehaviorController.create();
	CBulletBehaviorController.setPosition(ptr, -1, x, y, true);
	CBulletBehaviorController.setDoneActionChanged(ptr, true);

	if isDie then CBulletBehaviorController.setInitActionTag(ptr, CGameAction.ACTION_SKILL.."0"); end
	
	local maxSize = math.max(tw, th);
	local s = maxSize / 80.0;
	if s ~= 1.0 then
		if s > 2.0 then s = 2.0; end
		CBulletBehaviorController.setScale(ptr, s);
	end

	local selfId = CCharacterData.getName(CEntity.getCharacterDataPtr(entityPtr));

	local sndName = "crazing";
	if self.hp == 0 then
		sndName = sndName.."3";
	elseif self.hp == 1 then
		sndName = sndName.."2";
	else
		sndName = sndName.."1";
	end

	local chPtr = CAudioManager.playByName(CGameResource.getCharacterSoundFile(selfId, sndName), true);
	CAudioManager.set3DAttributes(chPtr, x, y);
	CAudioManager.setPaused(chPtr, false);

	if isDie then
		if self.crackPtr ~= nil then
			CEntity.setDie(self.crackPtr);
			self.crackPtr = nil;
		end
	else
		if self.crackPtr == nil then
			local crackPtr = CBullet.createBullet(selfId.."/Crack", entityPtr, nil, nil, 0, CEntity.getLayerPtr(entityPtr));
			self.crackPtr = crackPtr;
			CEntity.setPosition(crackPtr, x, y);
			CEntity.doTrigger(self.crackPtr, "size", tostring(tw)..","..tostring(th));
		end

		local value = "";
		if self.hp == 1 then
			value = "1";
		elseif self.hp > 1 then
			value = "0";
		end
		
		CEntity.doTrigger(self.crackPtr, "type", value);
	end

	CBullet.createBullet(selfId.."/Dust", entityPtr, ptr, nil, 0, CChapterScene.getEffectTopLayerPtr(0));
end