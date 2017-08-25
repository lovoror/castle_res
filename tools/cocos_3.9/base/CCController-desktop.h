#include "CCController.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)

NS_CC_BEGIN

class CC_DLL ControllerImpl {
public:
	float* axes;
	unsigned char* buttons;

	static long long notConnectedCheckDelay;

	ControllerImpl(Controller* controller);
	virtual ~ControllerImpl();
	Controller* getController() { return _controller; }
	void initDevice(int deviceID, const std::string& name);
	void setVibration(float left, float right);
	static void check(int id);
	static void checkWin32DirectInput();
	static void checkWin32XInput();

	static int joystickPresent(int id);
	static const float* getJoystickAxes(int joy, int* count);
	static const unsigned char* getJoystickButtons(int joy, int* count);
	static const char* getJoystickName(int joy);

	void initStatus(const float* axes, int axesCount, const unsigned char* buttons, int btnsCount);
	void updateStatus(const float* axes, int axesCount, const unsigned char* buttons, int btnsCount);

	static ControllerImpl* getOrCreate(int id, bool* isCreate);
	static bool releaseController(int id);

private:
	Controller* _controller;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	static void* _pFac;
	void* _pDev;

	static void* _caps;
	static void* _state;
	static void* _vibration;
#endif
};

NS_CC_END

#endif // #if (CC_TARGET_PLATFORM == ...)