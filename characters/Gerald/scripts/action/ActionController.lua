local C = registerClassAuto(getClass(ACTION_CONTROLLER_PACKAGE, AACTION_CONTROLLER_BASE));

function C:changedPhysicsState()
	local state = CEntity.getPhysicsState(self.entityPtr);
	if state == CPhysicsState.STAND then
		CEntity.playSound(self.entityPtr, CGameResource.getCharacterSoundFile(CCharacterData.getName(CEntity.getCharacterDataPtr(self.entityPtr)), "landing"));
	end
end
