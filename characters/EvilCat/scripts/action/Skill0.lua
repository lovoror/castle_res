--EvilCat Skill0
local C = registerClassAuto(getClass(ACTION_PACKAGE, ACTION_BASE));

function C:ctor()
end

function C:start(itemPtr)
	local actionPtr = self.actionPtr;
	local entityPtr = CGameAction.getEntityPtr(actionPtr);
	self.entityPtr = entityPtr;

	CGameAction.setLinkActionName(actionPtr, CGameAction.ACTION_SKILL.."1");

	if (not CChapterScene.isNetwork()) or CEntity.isHost(entityPtr) then
		local tx = CEntity.getSharedData(entityPtr, "targetX");
		if tx ~= "" then
			tx = tonumber(tx);
			local ty = tonumber(CEntity.getSharedData(entityPtr, "targetY"));

			local isJump = CGameAction.getTag(actionPtr) == CGameAction.ACTION_SKILL.."0";

			local px, py = CEntity.getPosition(entityPtr);
			local ix, iy;

			local mode = 0;
			local mode2 = 0;

			if isJump then
				local rnd = math.random();
				if rnd < 0.333 then
					mode = 0;
					ix = 100.0 + math.random() * 100.0;
					iy = 800.0;

					local rnd2 = math.random();
					if rnd2 < 0.5 then
						mode2 = 1;
					else
						mode2 = 2;
					end
				elseif rnd < 0.666 then
					mode = 1; --front
					ix = 150.0 + math.random() * 250.0;
					iy = 800.0;
				else
					mode = 2; --back
					ix = 100.0 + math.random() * 100.0;
					iy = 800.0 - math.random() * 200.0;
				end
			else
				mode = 3;
				ix = 400.0;
				iy = math.abs(tx - px) + 200.0;
			end

			self.mode = (mode << 4) | mode2;

			CEntity.setSharedData(entityPtr, "mode", tostring(self.mode));
			CEntity.setSharedData(entityPtr, "px", tostring(px));
			CEntity.setSharedData(entityPtr, "py", tostring(py));
			CEntity.setSharedData(entityPtr, "ix", tostring(ix));
			CEntity.setSharedData(entityPtr, "iy", tostring(iy));
		end
	end
end

function C:collectSync(bytesPtr)
	local entityPtr = self.entityPtr;
	CByteArray.writeUInt8(self.mode);
	CByteArray.writeFloat(bytesPtr, tonumber(CEntity.getSharedData(entityPtr, "px")));
	CByteArray.writeFloat(bytesPtr, tonumber(CEntity.getSharedData(entityPtr, "py")));
	CByteArray.writeFloat(bytesPtr, tonumber(CEntity.getSharedData(entityPtr, "iy")));
	CByteArray.writeFloat(bytesPtr, tonumber(CEntity.getSharedData(entityPtr, "iy")));
end

function C:executeSync(bytesPtr)
	local mode = CByteArray.readUInt8(bytesPtr);
	local px = CByteArray.readFloat(bytesPtr);
	local py = CByteArray.readFloat(bytesPtr);
	local ix = CByteArray.readFloat(bytesPtr);
	local iy = CByteArray.readFloat(bytesPtr);

	local entityPtr = self.entityPtr;

	CEntity.setSharedData(entityPtr, "mode", tostring(mode));
	CEntity.setSharedData(entityPtr, "px", tostring(px));
	CEntity.setSharedData(entityPtr, "py", tostring(py));
	CEntity.setSharedData(entityPtr, "ix", tostring(ix));
	CEntity.setSharedData(entityPtr, "iy", tostring(iy));
end

function C:dispose()
	return true;
end
