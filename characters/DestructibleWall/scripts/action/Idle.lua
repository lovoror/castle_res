local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:awake(actionPtr)
	super.awake(self, actionPtr);

	self.hp = 3;
end

function C:start(itemPtr)
	self.entityPtr = CGameAction.getEntityPtr(self.actionPtr);

	local disPtr = CEntity.getDisplayContentPtr(self.entityPtr);
	local sw, sh = CGameNode.getContentSize(disPtr);
	local ax, ay = CGameNode.getAnchorPoint(disPtr);

	self.collW = sw;
	self.collH = sh;
	self.collX = (0.5 - ax) * sw;
	self.collY = (ay - 0.5) * sh;

	self.isHost = CEntity.isHost(self.entityPtr);
end

function C:suffered(attackDataPtr)
    if CAttackData.getValue(attackDataPtr) <= 0 and CAttackData.getType(attackDataPtr) == CBattleNumberTypeEnum.HP and self.hp > 0 then
        self.hp = self.hp - 1;
        if self.hp == 0 then
			if CChapterScene.isNetwork() then
				CProtocol.sendCptEntityDied(self.entityPtr);
			end

            CEntity.setDie(self.entityPtr);
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
