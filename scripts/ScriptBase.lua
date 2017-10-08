CHARACTER_CONFIG_PACKAGE = "characters.config";
CHARACTER_CONFIG_BASE = "Base";
CHARACTER_CONFIG_TREASURE_CHEST_BASE = "TreasureChestBase";
CHARACTER_CONFIG_FOOD_BASE = "FoodBase";

CHAPTER_CONFIG_PACKAGE = "chapters.config";
CHAPTER_CONFIG_BASE = "Base";

ACTION_PACKAGE = "entities.actions";
ACTION_BASE = "Base";
ACTION_FOOD_IDLE_BASE = "FoodIdleBase";
ACTION_FOOD_DIE_BASE = "FoodDieBase";

ACTION_CONTROLLER_PACKAGE = "entities.actioncontrollers";
AACTION_CONTROLLER_BASE = "Base";

BUFF_PACKAGE = "buffs";
BUFF_BASE = "Base";

AI_PACKAGE = "entities.ai";
AI_BASE = "Base";
AI_CLASSIC = "Classic";
AI_TREASURE_CHEST_BASE = "TreasureChestBase";

AI_TRIGGER_HELPER = "TriggerHelper";
AI_SKILL = "Skill";
AI_SKILL_MANAGER = "SkillManager";
AI_BIND_TARGET = "BindTarget";

ITEM_PACKAGE = "items";
ITEM_BATTLE_BASE = "BattleBase";
ITEM_UPDRADE_BASE = "UpdradeBase";

GENERAL_PACKAGE = "general";
GENERAL_END_POINT = "EndPoint";

SOUND_3D_DEFAULT_MIN_DISTANCE = 300.0;
SOUND_3D_DEFAULT_MAX_DISTANCE = 1200.0;

SHARE_DATA_KEY_KICK_SUFFER_CLIP = "kickSufferClip";

CESTUS_ACTION_INDEX = "0";
SWORD_ACTION_INDEX = "1";
GREAT_SWORD_ACTION_INDEX = "2";
DAGGER_ACTION_INDEX = "3";
BOW_ACTION_INDEX = "4";
LANCE_ACTION_INDEX = "5";
MAGIC_ACTION_INDEX = "6";
MAGIC_WEAPON_ACTION_INDEX = "7";

CESTUS_SHOOTING_TIME = 0.13;
SWORD_SHOOTING_TIME = 0.2;
MAGIC_SHOOTING_TIME = 0.234;
MAGIC_WEAPON_SHOOTING_TIME = 0.234;

math.randomseed(os.time());

function getProjectileElevation(sx, sy, tx, ty, v, g, minAngle, maxAngle)
	if minAngle == nil then
		minAngle = -math.pi * 2.0;
	end
	if maxAngle == nil then
		maxAngle = math.pi * 2.0;
	end

	local x = tx - sx;
	local y = ty - sy;
	local v2 = v * v;

	local a = v2 * v2 - g * (g * x * x - 2.0 * y * v * v);

	if a < 0.0 then
		return nil;
	end

	local gx = g * x;
	local a_2 = math.sqrt(a);
	local b = math.atan((a_2 - v2) / gx);
	local c = math.atan((-v2 - a_2) / gx);

	if x < 0.0 then
		b = -b;
		c = -c;

		if b < 0.0 then
			b = -math.pi - b;
		else
			b = math.pi - b;
		end

		if c < 0.0 then
			c = -math.pi - c;
		else
			c = math.pi - c;
		end
	end

	local bigRange = minAngle < -math.pi or maxAngle > math.pi ;

	if b < minAngle or b > maxAngle then
		if bigRange then
			local tmp;
			if b < 0.0 then
				tmp = b + math.pi * 2.0;
			else
				tmp = b - math.pi * 2.0;
			end
			if tmp < minAngle or tmp > maxAngle then
				b = nil;
			end
		else
			b = nil;
		end
	end

	if c < minAngle or c > maxAngle then
		if bigRange then
			local tmp;
			if c < 0.0 then
				tmp = c + math.pi * 2.0;
			else
				tmp = c - math.pi * 2.0;
			end
			if tmp < minAngle or tmp > maxAngle then
				c = nil;
			end
		else
			c = nil;
		end
	end

	if b == nil then
		if c == nil then
			return nil;
		else
			return c;
		end
	else
		if c == nil then
			return b;
		else
			if x < 0.0 then
				if y < 0.0 then
					if b > c then
						return c;
					else
						return b;
					end
				else
					if b > c then
						return b;
					else
						return c;
					end
				end
			else
				if b > c then
					return c;
				else
					return b;
				end
			end
		end
	end
end

function rotatePoint(x, y, sinValue, cosValue)
	if cosValue == nil then
		cosValue = math.cos(sinValue);
		sinValue = math.sin(sinValue);
	end
	return x * cosValue - y * sinValue, x * sinValue + y * cosValue;
end

function toint(x)
	return math.tointeger(tonumber(x));
end

-- ↓→ + X
function createInstructionFormula_DFX(x)
	local formulaPtr = CInstructionFormula.create();

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, CGameKeyButtonFlag.DOWN, CGameKeyButtonFlag.UP | CGameKeyButtonFlag.BACK | CGameKeyButtonFlag.FRONT, 0, 0);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, CGameKeyButtonFlag.FRONT, CGameKeyButtonFlag.UP | CGameKeyButtonFlag.BACK, 0, 0);
	CButtonInstructionStep.setTimes(stepPtr, 0.0, 0.2);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, x, 0, 0, 0);
	CButtonInstructionStep.setTimes(stepPtr, 0.0, 0.2);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	return formulaPtr;
end

-- →↓→ + X
function createInstructionFormula_FDFX(x)
	local formulaPtr = CInstructionFormula.create();

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, CGameKeyButtonFlag.FRONT, CGameKeyButtonFlag.UP | CGameKeyButtonFlag.BACK | CGameKeyButtonFlag.DOWN, 0, 0);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, CGameKeyButtonFlag.DOWN, CGameKeyButtonFlag.UP | CGameKeyButtonFlag.BACK, 0, CGameKeyButtonFlag.FRONT);
	CButtonInstructionStep.setTimes(stepPtr, 0.0, 0.2);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, CGameKeyButtonFlag.FRONT, CGameKeyButtonFlag.UP | CGameKeyButtonFlag.BACK, 0, 0);
	CButtonInstructionStep.setTimes(stepPtr, 0.0, 0.2);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, x, 0, 0, 0);
	CButtonInstructionStep.setTimes(stepPtr, 0.0, 0.2);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	return formulaPtr;
end

-- ←↓→ + X
function createInstructionFormula_BDFX(x)
	local formulaPtr = CInstructionFormula.create();

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, CGameKeyButtonFlag.BACK, CGameKeyButtonFlag.UP | CGameKeyButtonFlag.FRONT | CGameKeyButtonFlag.DOWN, 0, 0);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, CGameKeyButtonFlag.DOWN, CGameKeyButtonFlag.UP, 0, CGameKeyButtonFlag.BACK | CGameKeyButtonFlag.FRONT);
	CButtonInstructionStep.setTimes(stepPtr, 0.0, 0.2);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, CGameKeyButtonFlag.FRONT, CGameKeyButtonFlag.UP | CGameKeyButtonFlag.BACK, 0, 0);
	CButtonInstructionStep.setTimes(stepPtr, 0.0, 0.2);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, x, 0, 0, 0);
	CButtonInstructionStep.setTimes(stepPtr, 0.0, 0.2);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	return formulaPtr;
end

-- →↓←→ + X
function createInstructionFormula_FDBFX(x)
	local formulaPtr = CInstructionFormula.create();

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, CGameKeyButtonFlag.FRONT, CGameKeyButtonFlag.UP | CGameKeyButtonFlag.BACK | CGameKeyButtonFlag.DOWN, 0, 0);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, CGameKeyButtonFlag.DOWN, CGameKeyButtonFlag.UP, 0, CGameKeyButtonFlag.BACK | CGameKeyButtonFlag.FRONT);
	CButtonInstructionStep.setTimes(stepPtr, 0.0, 0.2);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, CGameKeyButtonFlag.BACK, CGameKeyButtonFlag.UP, 0, CGameKeyButtonFlag.DOWN | CGameKeyButtonFlag.FRONT);
	CButtonInstructionStep.setTimes(stepPtr, 0.0, 0.2);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, CGameKeyButtonFlag.FRONT, CGameKeyButtonFlag.UP | CGameKeyButtonFlag.DOWN, 0, CGameKeyButtonFlag.BACK);
	CButtonInstructionStep.setTimes(stepPtr, 0.0, 0.2);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	local stepPtr = CButtonInstructionStep.create();
	CButtonInstructionStep.setButtons(stepPtr, x, 0, 0, 0);
	CButtonInstructionStep.setTimes(stepPtr, 0.0, 0.2);
	CInstructionFormula.addStep(formulaPtr, stepPtr);

	return formulaPtr;
end

function setActionDataDefaultBattleData(ptr, index)
	CGameActionData.setRigid(ptr, index, CRigidAtk.NRM, CRigidDef.NRM);
	CGameActionData.setCollisionForce(ptr, index, 200.0, 0.0, 0.0, false, 200.0, 0.0, 1.0, false);
end

function setDefaultInjuredEffect(attackDataPtr)
	local value = CAttackData.getValue(attackDataPtr);
	if value ~= 0 then
		local sufferPtr = CAttackData.getSufferPtr(attackDataPtr);
		local buffPtr = nil;

		local type = CAttackData.getType(attackDataPtr);
		if type == CBattleNumberType.HP then
			if value < 0 then
				buffPtr = CBuff.create(CEntity.getID(sufferPtr), 2, 0.4);
				CBuff.setSharedData(buffPtr, "r", "1.0");
				CBuff.setSharedData(buffPtr, "g", "0.2");
				CBuff.setSharedData(buffPtr, "b", "0.2");
			else
				buffPtr = CBuff.create(CEntity.getID(sufferPtr), 2, 0.8);
				CBuff.setSharedData(buffPtr, "r", "0.5");
				CBuff.setSharedData(buffPtr, "g", "1.0");
				CBuff.setSharedData(buffPtr, "b", "0.5");
			end
		elseif type == CBattleNumberType.MP then
			if value > 0 then
				buffPtr = CBuff.create(CEntity.getID(sufferPtr), 2, 0.8);
				CBuff.setSharedData(buffPtr, "r", "0.5");
				CBuff.setSharedData(buffPtr, "g", "0.5");
				CBuff.setSharedData(buffPtr, "b", "1.0");
			end
		end

		if buffPtr ~= nil then
			CBuff.setSharedData(buffPtr, "a", "1.0");
			CEntity.addBuff(sufferPtr, buffPtr);
		end
	end
end

function createDefaultCreateActionData(name, tag)
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_CREATE);
	CGameActionData.setTag(ptr, CGameAction.ACTION_CREATE);
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setLinkName(ptr, CGameAction.ACTION_IDLE);
	CGameActionData.setSupportRun(ptr, false, false);
	CGameActionData.setSupportJump(ptr, false, false);
	CGameActionData.setSupportVeer(ptr, false, false);
	CGameActionData.setSupportKick(ptr, false, false);
	CGameActionData.setSupportDodge(ptr, false, false);
	CGameActionData.setSupportOneWayUpPass(ptr, false, false);
	CGameActionData.setSupportSlideTackle(ptr, false, false);
	CGameActionData.setCollisionCamp(ptr, false, true);

	return ptr;
end

function createDefaultIdleActionData(name, tag)
	if name == nil then
		name = CGameAction.ACTION_IDLE;
	end

	if tag == nil then
		tag = name;
	end

	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, name);
	CGameActionData.setTag(ptr, tag);
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, false);
	CGameActionData.setSupportKick(ptr, false, false);
	CGameActionData.setSupportDodge(ptr, true, false);
	CGameActionData.setCollisionCamp(ptr, false, true);

	return ptr;
end

function createDefaultRunActionData(name, tag)
	if name == nil then
		name = CGameAction.ACTION_RUN;
	end

	if tag == nil then
		tag = name;
	end

	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, name);
	CGameActionData.setTag(ptr, tag);
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, false);
	CGameActionData.setSupportKick(ptr, false, false);
	CGameActionData.setSupportDodge(ptr, true, false);
	CGameActionData.setSupportOneWayUpPass(ptr, false, false);
	CGameActionData.setCollisionCamp(ptr, false, true);

	return ptr;
end

function createDefaultJumpActionData()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_JUMP);
	CGameActionData.setTag(ptr, CGameAction.ACTION_JUMP);
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, false);
	CGameActionData.setSupportDodge(ptr, false, false);
	CGameActionData.setSupportOneWayUpPass(ptr, false, false);
	CGameActionData.setCollisionCamp(ptr, false, true);

	return ptr;
end

function createDefaultJumpMoreActionData()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_JUMP_MORE);
	CGameActionData.setTag(ptr, CGameAction.ACTION_JUMP_MORE);
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, false);
	CGameActionData.setSupportDodge(ptr, false, false);
	CGameActionData.setSupportOneWayUpPass(ptr, false, false);
	CGameActionData.setCollisionCamp(ptr, false, true);

	return ptr;
end

function createDefaultFallActionData()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_FALL);
	CGameActionData.setTag(ptr, CGameAction.ACTION_FALL);
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, false);
	CGameActionData.setSupportDodge(ptr, false, false);
	CGameActionData.setSupportOneWayUpPass(ptr, false, false);
	CGameActionData.setCollisionCamp(ptr, false, true);

	return ptr;
end

function createDefaultKickActionData()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_KICK);
	CGameActionData.setTag(ptr, CGameAction.ACTION_KICK);
	CGameActionData.setScriptName(ptr, "Kick", true);
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setSupportRun(ptr, false, false);
	CGameActionData.setSupportJump(ptr, false, false);
	CGameActionData.setSupportVeer(ptr, false, false);
	CGameActionData.setSupportKick(ptr, false, false);
	CGameActionData.setSupportDodge(ptr, false, false);
	CGameActionData.setSupportOneWayUpPass(ptr, false, false);
	CGameActionData.setLandingDone(ptr, true);
	CGameActionData.setCollisionCycle(ptr, 0.0001);
	CGameActionData.setCollisionCamp(ptr, false, true);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setMATFactor(ptr, 0, 0.0, 0.0);

	return ptr;
end

function createDefaultSlideTrackleActionData()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_SLIDE_TACKLE);
	CGameActionData.setTag(ptr, CGameAction.ACTION_SLIDE_TACKLE);
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setSupportRun(ptr, false, false);
	CGameActionData.setSupportJump(ptr, false, false);
	CGameActionData.setSupportVeer(ptr, false, false);
	CGameActionData.setSupportKick(ptr, false, false);
	CGameActionData.setSupportDodge(ptr, false, false);
	CGameActionData.setSupportOneWayUpPass(ptr, false, false);
	CGameActionData.setLandingDone(ptr, true);
	CGameActionData.setInAirDone(ptr, true);
	CGameActionData.setCollisionCycle(ptr, 0.0001);
	CGameActionData.setCollisionCamp(ptr, false, true);
	CGameActionData.setCollisionBehavior(ptr, CCollisionBehavior.DAMAGE);
	CGameActionData.setMATFactor(ptr, 0, 0.0, 0.0);

	return ptr;
end

function createDefaultDodgeActionData()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_DODGE);
	CGameActionData.setTag(ptr, CGameAction.ACTION_DODGE);
	CGameActionData.setScriptName(ptr, "BackwardDodge", true);
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setSupportRun(ptr, false, false);
	CGameActionData.setSupportJump(ptr, false, false);
	CGameActionData.setSupportVeer(ptr, false, false);
	CGameActionData.setSupportKick(ptr, false, false);
	CGameActionData.setSupportDodge(ptr, false, false);
	CGameActionData.setSupportOneWayUpPass(ptr, false, false);
	CGameActionData.setLandingDone(ptr, true);
	CGameActionData.setInAirDone(ptr, true);
	CGameActionData.setCollisionCamp(ptr, false, true);

	return ptr;
end

function createDefaultSquatActionData()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_SQUAT);
	CGameActionData.setTag(ptr, CGameAction.ACTION_SQUAT);
	CGameActionData.setLoop(ptr, true);
	CGameActionData.setLock(ptr, false);
	CGameActionData.setSupportRun(ptr, false, false);
	CGameActionData.setSupportKick(ptr, false, false);
	CGameActionData.setSupportJump(ptr, false, false);
	CGameActionData.setSupportDodge(ptr, true, false);
	CGameActionData.setSupportOneWayUpPass(ptr, true, true);
	CGameActionData.setCollisionCamp(ptr, false, true);

	return ptr;
end

function createDefaultLandingActionData()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_LANDING);
	CGameActionData.setTag(ptr, CGameAction.ACTION_LANDING);
	CGameActionData.setScriptName(ptr, "Landing", true);
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setSupportRun(ptr, false, false);
	CGameActionData.setSupportJump(ptr, false, false);
	CGameActionData.setSupportVeer(ptr, false, false);
	CGameActionData.setSupportKick(ptr, false, false);
	CGameActionData.setSupportDodge(ptr, false, false);
	CGameActionData.setSupportOneWayUpPass(ptr, false, false);
	CGameActionData.setCollisionCamp(ptr, false, true);

	return ptr;
end

function createDefaultSkillActionData(index, name)
	if name == nil then
		name = index;
	end

	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_SKILL..name);
	CGameActionData.setTag(ptr, CGameAction.ACTION_SKILL..index);
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setSupportRun(ptr, false, true);
	CGameActionData.setSupportJump(ptr, false, false);
	CGameActionData.setSupportVeer(ptr, false, false);
	CGameActionData.setSupportKick(ptr, false, false);
	CGameActionData.setSupportDodge(ptr, true, false);
	CGameActionData.setSupportOneWayUpPass(ptr, false, false);
	CGameActionData.setLandingDone(ptr, true);
	CGameActionData.setCollisionCamp(ptr, false, true);

	return ptr;
end

function createDefaultHurtActionData()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_HURT);
	CGameActionData.setTag(ptr, CGameAction.ACTION_HURT);
	CGameActionData.setScriptName(ptr, "Hurt", true);
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setSupportRun(ptr, false, false);
	CGameActionData.setSupportJump(ptr, false, false);
	CGameActionData.setSupportVeer(ptr, false, false);
	CGameActionData.setSupportKick(ptr, false, false);
	CGameActionData.setSupportDodge(ptr, false, false);
	CGameActionData.setSupportOneWayUpPass(ptr, false, false);

	return ptr;
end

function createDefaultDieActionData()
	local ptr = CGameActionData.create();
	CGameActionData.setName(ptr, CGameAction.ACTION_DIE);
	CGameActionData.setTag(ptr, CGameAction.ACTION_DIE);
	CGameActionData.setLoop(ptr, false);
	CGameActionData.setLock(ptr, true);
	CGameActionData.setSupportRun(ptr, false, false);
	CGameActionData.setSupportJump(ptr, false, false);
	CGameActionData.setSupportVeer(ptr, false, false);
	CGameActionData.setSupportKick(ptr, false, false);
	CGameActionData.setSupportDodge(ptr, false, false);
	CGameActionData.setSupportOneWayUpPass(ptr, false, false);
	CGameActionData.setCollisionCamp(ptr, false, true);

	return ptr;
end

function showBattleNumber(entityPtr, value, type)
	local x, y = CEntity.getPosition(entityPtr);

	CChapterScene.showNumber(value, type, x, y + 160.0);
end

function showBattleNumberWithPos(x, y, value, type)
	CChapterScene.showNumber(value, type, x, y + 160.0, false);
end

function showChangedHPMPEffect(entityPtr, changedHP, changedMP)
	local x, y;
	if changedHP ~= 0 and changedMP ~= 0 then
		x, y = CEntity.getPosition(entityPtr);
		x, y = CBattleNumber.calcRandomPosition(x, y, CBattleNumber.getDefaultRandomRange());
	end

	if changedHP ~= 0 then
		if x == nil then
			showBattleNumber(entityPtr, changedHP, CBattleNumberType.HP);
		else
			showBattleNumberWithPos(x, y + 10.0, changedHP, CBattleNumberType.HP);
		end

		CAttackData.create(entityPtr, entityPtr, changedHP, CBattleNumberType.HP, 0.0, 0.0, function(adPtr)
			setDefaultInjuredEffect(adPtr);
		end);
	end

	if changedMP ~= 0 then
		if x == nil then
			showBattleNumber(entityPtr, changedMP, CBattleNumberType.MP);
		else
			showBattleNumberWithPos(x, y - 10.0, changedMP, CBattleNumberType.MP);
		end

		CAttackData.create(entityPtr, entityPtr, changedMP, CBattleNumberType.MP, 0.0, 0.0, function(adPtr)
			setDefaultInjuredEffect(adPtr);
		end);
	end
end

--=========================================================================
function createEditorLineEdit(container, title)
	local hp = CHorizontalPanel.create();
	local label = CESLabel.create(title);
	local p = CESLineEdit.create();
	CHorizontalPanel.setSingle(hp, label, p);
	CComponentBehaviorWidget.addHLayoutPanel(container, hp);

	return hp, label, p;
end

function createEditorLineEdit2(container, widgetVector, title, param1, param2)
	local hp = CHorizontalPanel.create();
	local p1Label = CESLabel.create(param1);
	CESWidgetVector.pushBack(widgetVector, CHorizontalPanel.setFixed(p1Label));
	CESWidgetVector.pushBack(widgetVector, CESSpacing.create());
	local p1 = CESLineEdit.create();
	CESWidgetVector.pushBack(widgetVector, p1);
	CESWidgetVector.pushBack(widgetVector, CESSpacing.createBig());
	local p2Label = CESLabel.create(param2);
	CESWidgetVector.pushBack(widgetVector, CHorizontalPanel.setFixed(p2Label));
	CESWidgetVector.pushBack(widgetVector, CESSpacing.create());
	local p2 = CESLineEdit.create();
	CESWidgetVector.pushBack(widgetVector, p2);
	local label = CESLabel.create(" "..title);
	CHorizontalPanel.setVector(hp, label, widgetVector);
	CComponentBehaviorWidget.addHLayoutPanel(container, hp);
	CESWidgetVector.clear(widgetVector);

	return hp, label, p1Label, p1, p2Label, p2;
end

function createEditorCheckBox(container, title)
	local hp = CHorizontalPanel.create();
	local label = CESLabel.create(title);
	local p = CESCheckBox.create();
	CHorizontalPanel.setSingle(hp, label, p);
	CComponentBehaviorWidget.addHLayoutPanel(container, hp);

	return hp, label, p;
end

function editorLineEditChanged(widget, editorWidget, key, defaultValue, defaultEditorValue, checkTypeFnName)
	local com = CComponentBehaviorWidget.getEditorComponent(editorWidget);

	local value = CESLineEdit.getText(widget);
	if CStringHelper[checkTypeFnName](value) then
		if value == defaultValue then value = ""; end
		CChapterEditorComponentBehavior.setValue(com, key, value);
	end

	local value = CChapterEditorComponentBehavior.getValue(com, key);
	if value == "" then value = defaultEditorValue; end
	CESLineEdit.setText(widget, value);

	return value;
end

function editorLineEditChangedInt(widget, editorWidget, key, defaultValue, defaultEditorValue)
	return editorLineEditChanged(widget, editorWidget, key, defaultValue, defaultEditorValue, "isInt");
end

function editorLineEditChangedUInt(widget, editorWidget, key, defaultValue, defaultEditorValue)
	return editorLineEditChanged(widget, editorWidget, key, defaultValue, defaultEditorValue, "isUInt");
end

function editorLineEditChangedFloat(widget, editorWidget, key, defaultValue, defaultEditorValue)
	return editorLineEditChanged(widget, editorWidget, key, defaultValue, defaultEditorValue, "isFloat");
end

function editorLineEditChangedUFloat(widget, editorWidget, key, defaultValue, defaultEditorValue)
	return editorLineEditChanged(widget, editorWidget, key, defaultValue, defaultEditorValue, "isUFloat");
end

function editorComboBoxChanged(widget, editorWidget, key, defaultValue)
	local com = CComponentBehaviorWidget.getEditorComponent(editorWidget);

	local value = tostring(CESComboBox.getCurrentIndex(widget));
	if value == defaultValue then value = ""; end
	CChapterEditorComponentBehavior.setValue(com, key, value);

	return value;
end

function editorCheckBoxChanged(widget, editorWidget, key)
	local com = CComponentBehaviorWidget.getEditorComponent(editorWidget);

	local value = CESCheckBox.isChecked(widget);
	if value then
		value = "1";
	else
		value = "";
	end
	CChapterEditorComponentBehavior.setValue(com, key, value);

	return value == "1";
end
--=========================================================================


local C = registerClass(GENERAL_PACKAGE, GENERAL_END_POINT, nil);

function C:ctor()
	self:reset();
end

function C:reset()
	self.type = 0; --0=relative, 1=absolute, 2=id
	self.x = 0.0;
	self.y = 0.0;
	self.offsetX = 0.0;
	self.offsetY = 0.0;
	self.id = 0;
	self.targetPtr = nil;
end

function C:getTargetPtr()
	if self._targetPtr == nil and self.id ~= 0 then
		local genPtr = CChapterScene.getEntityGeneratorPtr(self.id);
		if not CisNullptr(genPtr) then
			self._targetPtr = CEntityGenerator.getEntityPtr(genPtr);
		end
	end

	return self._targetPtr;
end

function C:getPosition(entityPtr)
	local x;
	local y;

	if self.type == 0 then
		local px, py = CEntity.getPosition(entityPtr);
		x = self.x + px;
		y = self.y + py;
	elseif self.type == 1 then
		x = self.x;
		y = self.y;
	else
		local ptr = self:getTargetPtr();
		if CisNullptr(ptr) then
			local px, py = CEntity.getPosition(entityPtr);
			x = px;
			y = py;
		else
			local px, py = CEntity.getPosition(ptr);
			x = px;
			y = py;
		end
	end

	return x + self.offsetX, y + self.offsetY;
end
