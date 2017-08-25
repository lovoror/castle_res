--DestructibleWall
local C = registerClassAuto(getClass(AI_PACKAGE, AI_BASE));

function C:ctor()
end

function C:editorAwake(comPtr)
    super.editorAwake(self, comPtr);

    CChapterEditorComponentBehavior.setCharacterName(comPtr, "DestructibleWall");
end

function C:editorWidgetCreate(widgetPtr)
	super.editorWidgetCreate(self, widgetPtr);

    return "Destructible Wall";
end

function C:editorDispose()
    CChapterEditorComponentBehavior.setCharacterName(self.editorComponentPtr, "");

    super.editorDispose(self);
end

--===================================================