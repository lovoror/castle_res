--kick suffer clip
local C = registerClassAuto(getClass(BUFF_PACKAGE, BUFF_BASE));

function C:ctor()
end

function C:awake(buffPtr)
	local b = super.awake(self, buffPtr);

	CBuff.setKind(self.buffPtr, 4);

	self.kickSufferClip = 0.0;
	local value = CBuff.getSharedData(buffPtr, SHARE_DATA_KEY_KICK_SUFFER_CLIP);
	if value ~= "" then
		self.kickSufferClip = tonumber(value);
	end

	self.entityPtr = CBuff.getOwnerPtr(buffPtr);
	local sx, sy = CEntity.getScale(self.entityPtr);
	self.kickSufferClip = self.kickSufferClip * sy;

	return true;
end

function C:start()
	CEntity.setKickSufferClip(self.entityPtr, self.kickSufferClip);
end

function C:dispose()
	CEntity.setKickSufferClip(self.entityPtr, 0.0);

	return true;
end
