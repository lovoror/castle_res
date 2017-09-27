math.randomseed(os.time());

setfenv = setfenv or function(f, t)
    f = (type(f) == 'function' and f or debug.getinfo(f + 1, 'f').func);
    local name;
    local up = 0;
    repeat
        up = up + 1;
        name = debug.getupvalue(f, up);
    until name == '_ENV' or name == nil
    if name then
		debug.upvaluejoin(f, up, function() return t end, 1); -- use unique upvalue, set it to f
    end
end

function stringSplit(content, token, strArray)
    if not content or not token then return; end
    if  strArray == nil then strArray = {}; end
    local i = 0;
    local contentLen = string.len(content);
    while true do
	 	i = i + 1;
        -- trueÊÇÓÃÀ´±ܿªstring.findº¯Êý¶ÔÌØÊâ×ַû¼ì²é ÌØÊâ×ַû "^$*+?.([%-"
        local beginPos, endPos = string.find(content, token, 1, true);
        if not beginPos then
            strArray[i] = string.sub(content, 1, contentLen);
            break;
        end
        strArray[i] = string.sub(content, 1, beginPos - 1);
        content = string.sub(content, endPos + 1, contentLen);
        contentLen = contentLen - endPos;
       
    end
    return strArray, i;
end

__classTable = {};

local __class = {};

function class(super)
	local class_type = {};
	class_type.ctor = false;
	class_type.super = super;
	class_type.new = function(...)
			local obj = {};
			--obj.super = super;
			setmetatable(obj, {__index = __class[class_type]});
			do
				local create;
				create = function(c, ...)
					if c.super then
						create(c.super, ...);
					end
					if c.ctor then
						c.ctor(obj, ...);
					end
				end

				create(class_type, ...);
			end

			return obj;
		end
	local vtbl = {};
	vtbl.super = __class[super];
	__class[class_type] = vtbl;

	setmetatable(class_type, {__newindex =
		function(t, k, v)
			vtbl[k] = v;
		end
	})

	if super then
		setmetatable(vtbl, {__index =
			function(t, k)
				local ret = __class[super][k];
				vtbl[k] = ret;
				return ret;
			end
		})
	end

	setmetatable(class_type, {__newindex =
		function(t, k, v)
			vtbl[k]=v;
			local newgt = {}     -- create new environment
			setmetatable(newgt,
				{__index =
					function(t1, k1)
						local v1 = vtbl[k1]
						if v1 ~= nil then
							return v1
						end

						 v1 = _G[k1];
						if v1 ~= nil then
							return v1;
						end
						return v1;
					end
				}
			)
			setfenv(v, newgt);
		end
	})

	return class_type;
end

function getFullClassName(packageName, className)
	full = packageName;

	if full == "" then
		full = className;
	else
		full = full.."."..className;
	end

	return full;
end

function _clearTempName()
	__classTable["__packageName"] = "";
	__classTable["__className"] = "";
end

function registerClass(packageName, className, super)
	local c = class(super);
	__classTable[getFullClassName(packageName, className)] = c;
	return c;
end

function registerClassAuto(super)
	packageName = __classTable["__packageName"];
	className = __classTable["__className"];
	_clearTempName();
	return registerClass(packageName, className, super);
end

function getClass(packageName, className)
	return __classTable[getFullClassName(packageName, className)];
end

function newClass(packageName, className, ...)
	local c = getClass(packageName, className);
	if c == nil then
		return nil;
	else
		return c.new(...);
	end
end

_clearTempName();
