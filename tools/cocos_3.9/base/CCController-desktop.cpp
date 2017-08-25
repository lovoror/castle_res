#include "CCController-desktop.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_MAC || CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_LINUX)
#include "CCGLViewImpl-desktop.h"
#include "base/CCEventController.h"
#include "cocos2d.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
#define DIRECTINPUT_VERSION 0x0800
#define INITGUID
#include <initguid.h>
#include <dinput.h>
#pragma comment(lib, "dinput8.lib")

#include <XInput.h>
#pragma comment(lib,"xinput.lib") 
#endif

NS_CC_BEGIN

ControllerImpl::ControllerImpl(Controller* controller)
	: _controller(controller) {
	axes = nullptr;
	buttons = nullptr;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	_pDev = nullptr;
#endif
}

ControllerImpl::~ControllerImpl() {
	if (axes != nullptr) {
		delete[] axes;
		axes = nullptr;
	}
	if (buttons != nullptr) {
		delete[] buttons;
		buttons = nullptr;
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	if (_pDev != nullptr) {
		IDirectInputDevice8* pDev = (IDirectInputDevice8*)_pDev;
		pDev->Unacquire();
		pDev->Release();
		_pDev = nullptr;
	}
#endif
}

long long ControllerImpl::notConnectedCheckDelay = 1000;

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
void* ControllerImpl::_pFac = nullptr;
unsigned int _numDev = 0;

void* ControllerImpl::_caps = new XINPUT_CAPABILITIES();
void* ControllerImpl::_state = new XINPUT_STATE();
void* ControllerImpl::_vibration = new XINPUT_VIBRATION();

BOOL CALLBACK DIEnumDevicesCallback(const DIDEVICEINSTANCE* lpddi, VOID* pvRef) {
	_numDev++;
	if (_numDev == 1) {
		*(GUID*)pvRef = lpddi->guidInstance;
	}

	return DIENUM_CONTINUE;
}

BOOL CALLBACK EnumObjectsCallback(const DIDEVICEOBJECTINSTANCE* pdidoi, VOID* pContext) {
	IDirectInputDevice8 *pDev = (IDirectInputDevice8*)pContext;

	if (pdidoi->dwType & DIDFT_AXIS) {
		DIPROPRANGE diprg;
		diprg.diph.dwSize = sizeof(DIPROPRANGE);
		diprg.diph.dwHeaderSize = sizeof(DIPROPHEADER);
		diprg.diph.dwHow = DIPH_BYID;
		diprg.diph.dwObj = pdidoi->dwType;
		diprg.lMin = -1000;
		diprg.lMax = 1000;
		pDev->SetProperty(DIPROP_RANGE, &diprg.diph);

		DIPROPDWORD dipdw;
		dipdw.diph.dwSize = sizeof(dipdw);
		dipdw.diph.dwHeaderSize = sizeof(dipdw.diph);
		diprg.diph.dwObj = pdidoi->dwType;
		dipdw.diph.dwHow = DIPH_DEVICE;
		dipdw.dwData = 100;
		pDev->SetProperty(DIPROP_DEADZONE, &dipdw.diph);
	}

	return DIENUM_CONTINUE;
}
#endif

void ControllerImpl::initDevice(int deviceID, const std::string& name) {
	_controller->_deviceId = deviceID;
	_controller->_deviceName = name;
	_controller->setTag(deviceID);
	_controller->onConnected();
}

void ControllerImpl::setVibration(float left, float right) {
	XINPUT_VIBRATION* vibration = (XINPUT_VIBRATION*)_vibration;
	vibration->wLeftMotorSpeed = left * 65535;
	vibration->wRightMotorSpeed = right * 65535;
	XInputSetState(0, vibration);
}

void ControllerImpl::initStatus(const float* axes, int axesCount, const unsigned char* buttons, int btnsCount) {
	this->axes = new float[axesCount];
	for (int i = 0; i < axesCount; i++) {
		this->axes[i] = axes[i];
	}
	this->buttons = new unsigned char[btnsCount];
	for (int i = 0; i < btnsCount; i++) {
		this->buttons[i] = buttons[i];
	}
}

void ControllerImpl::updateStatus(const float* axes, int axesCount, const unsigned char* buttons, int btnsCount) {
	for (int i = 0; i < axesCount; i++) {
		float value = axes[i];
		if (this->axes[i] != value) {
			this->axes[i] = value;

			_controller->onAxisEvent(i, value, true);
		}
	}

	for (int i = 0; i < btnsCount; i++) {
		unsigned char value = buttons[i];
		if (this->buttons[i] != value) {
			this->buttons[i] = value;

			_controller->onButtonEvent(i + 100, value == GLFW_PRESS, value, false);
		}
	}
}

ControllerImpl* ControllerImpl::getOrCreate(int id, bool* isCreate) {
	Controller* c = Controller::getControllerByTag(id);
	if (c == nullptr) {
		c = new Controller();
		Controller::s_allController.push_back(c);
		*isCreate = true;
	} else {
		*isCreate = false;
	}

	return c->_impl;
}

bool ControllerImpl::releaseController(int id) {
	for (auto itr = Controller::s_allController.begin(); itr != Controller::s_allController.end(); itr++) {
		Controller* c = *itr;
		if (c->_deviceId == id) {
			Controller::s_allController.erase(itr);
			c->onDisconnected();
			return true;
		}
	}

	return false;
}

void ControllerImpl::check(int id) {
	if (glfwJoystickPresent(id)) {
		int axesCount = 0;
		const float* axes = glfwGetJoystickAxes(id, &axesCount);

		int btnsCount = 0;
		const unsigned char* btns = glfwGetJoystickButtons(id, &btnsCount);

		bool isCreate = false;
		ControllerImpl* impl = ControllerImpl::getOrCreate(id, &isCreate);
		if (isCreate) {
			impl->initStatus(axes, axesCount, btns, btnsCount);
			impl->initDevice(id, glfwGetJoystickName(id));
		}

		impl->updateStatus(axes, axesCount, btns, btnsCount);
	} else {
		ControllerImpl::releaseController(id);
	}
}

void ControllerImpl::checkWin32DirectInput() {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	int id = 0;

	Controller* c = Controller::getControllerByTag(id);

	if (c == nullptr) {
		if (_pFac == nullptr) {
			if (FAILED(DirectInput8Create(GetModuleHandle(nullptr), DIRECTINPUT_VERSION, IID_IDirectInput8, (void**)&_pFac, nullptr))) {
				_pFac = nullptr;
			}
		}

		if (_pFac != nullptr && GetForegroundWindow() == Director::getInstance()->getOpenGLView()->getWin32Window()) {
			IDirectInput8* pFac = (IDirectInput8*)_pFac;
			GUID guid;
			_numDev = 0;
			pFac->EnumDevices(DI8DEVCLASS_GAMECTRL, DIEnumDevicesCallback, &guid, DIEDFL_ATTACHEDONLY);

			IDirectInputDevice8* pDev = nullptr;
			if (_numDev > 0 && SUCCEEDED(pFac->CreateDevice(guid, &pDev, nullptr))) {
				pDev->SetDataFormat(&c_dfDIJoystick);
				DIPROPDWORD pro = { { sizeof(pro), sizeof(pro.diph), }, 16 };
				pDev->SetProperty(DIPROP_BUFFERSIZE, &pro.diph);
				pDev->SetCooperativeLevel(WindowFromDC(wglGetCurrentDC()), DISCL_EXCLUSIVE | DISCL_FOREGROUND);
				DIDEVICEINSTANCE di;
				di.dwSize = sizeof(di);
				if (SUCCEEDED(pDev->GetDeviceInfo(&di))) {
					std::string devName;
					char buf[MAX_PATH];
					if (WideCharToMultiByte(CP_UTF8, 0, di.tszInstanceName, lstrlenW(di.tszInstanceName) + 1, buf, ARRAYSIZE(buf), nullptr, nullptr)) {
						devName = buf;
					}
					pDev->EnumObjects(EnumObjectsCallback, (VOID*)pDev, DIDFT_ALL);

					c = new Controller();
					Controller::s_allController.push_back(c);
					ControllerImpl* impl = c->_impl;
					float axes[5] = { 0.0f };
					unsigned char btns[14] = { 0 };
					impl->_pDev = pDev;
					impl->initStatus(axes, 5, btns, 14);
					impl->initDevice(id, devName);
				} else {
					pDev->Release();
				}
			}
		}
	}

	if (c != nullptr) {
		IDirectInputDevice8* pDev = (IDirectInputDevice8*)c->_impl->_pDev;

		if (FAILED(pDev->Poll())) {
			pDev->Acquire();
		}
		DIJOYSTATE dijs;
		HRESULT hr = pDev->GetDeviceState(sizeof(DIJOYSTATE), &dijs);
		if (SUCCEEDED(hr)) {
			float axes[5];
			axes[0] = (float)dijs.lX / 1000.0f;
			axes[1] = (float)dijs.lY / 1000.0f;
			axes[2] = (float)dijs.lZ / 1000.0f;
			axes[3] = (float)dijs.lRy / 1000.0f;
			axes[4] = (float)dijs.lRx / 1000.0f;

			unsigned char btns[14] = { 0 };
			for (unsigned char i = 0; i < 10; i++) {
				btns[i] = dijs.rgbButtons[i] == 0 ? 0 : 1;
			}
			int pov = dijs.rgdwPOV[0];
			if (pov != -1) {
				if (pov > 27000) {
					btns[10] = 1;
					btns[13] = 1;
				} else if (pov == 27000) {
					btns[13] = 1;
				} else if (pov > 18000) {
					btns[12] = 1;
					btns[13] = 1;
				} else if (pov == 18000) {
					btns[12] = 1;
				} else if (pov > 9000) {
					btns[11] = 1;
					btns[12] = 1;
				} else if (pov == 9000) {
					btns[11] = 1;
				} else if (pov > 0) {
					btns[10] = 1;
					btns[11] = 1;
				} else {
					btns[10] = 1;
				}
			}
			c->_impl->updateStatus(axes, 5, btns, 14);
		} else {
			if (GetForegroundWindow() == Director::getInstance()->getOpenGLView()->getWin32Window()) {
				if (hr != DIERR_OTHERAPPHASPRIO) {
					ControllerImpl::releaseController(id);
				}
			}
		}
	}
#endif
}

void ControllerImpl::checkWin32XInput() {
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	int id = 0;
	bool connected = false;

	XINPUT_CAPABILITIES* caps = (XINPUT_CAPABILITIES*)_caps;

	DWORD capsResult = XInputGetCapabilities(id, XINPUT_FLAG_GAMEPAD, caps);
	if (capsResult == ERROR_SUCCESS) {
		XINPUT_STATE* state = (XINPUT_STATE*)_state;

		DWORD stateResult = XInputGetState(id, state);
		if (stateResult == ERROR_SUCCESS) {
			connected = true;

			Controller* c = Controller::getControllerByTag(id);
			if (c == nullptr) {
				c = new Controller();
				Controller::s_allController.push_back(c);
				ControllerImpl* impl = c->_impl;
				float axes[6] = { 0.0f };
				unsigned char btns[14] = { 0 };
				impl->initStatus(axes, 6, btns, 14);
				impl->initDevice(id, "");
			}

			if (GetForegroundWindow() != Director::getInstance()->getOpenGLView()->getWin32Window()) {
				ZeroMemory(_state, sizeof(XINPUT_STATE));
			}

			XINPUT_GAMEPAD& gp = state->Gamepad;
			WORD wButtons = gp.wButtons;

			ControllerImpl* impl = c->_impl;
			float axes[6] = { 0.0f };
			unsigned char btns[14] = { 0 };

			if (gp.sThumbLX < 0.0f) {
				axes[0] = gp.sThumbLX / 32768.0f;
			} else if (gp.sThumbLX > 0.0f) {
				axes[0] = gp.sThumbLX / 32767.0f;
			}

			if (gp.sThumbLY < 0.0f) {
				axes[1] = gp.sThumbLY / -32768.0f;
			} else if (gp.sThumbLY > 0.0f) {
				axes[1] = gp.sThumbLY / -32767.0f;
			}

			if (gp.sThumbRX < 0.0f) {
				axes[2] = gp.sThumbRX / 32768.0f;
			} else if (gp.sThumbRX > 0.0f) {
				axes[2] = gp.sThumbRX / 32767.0f;
			}

			if (gp.sThumbRY < 0.0f) {
				axes[3] = gp.sThumbRY / -32768.0f;
			} else if (gp.sThumbRY > 0.0f) {
				axes[3] = gp.sThumbRY / -32767.0f;
			}

			axes[4] = gp.bLeftTrigger / 255.0f;
			axes[5] = gp.bRightTrigger / 255.0f;

			btns[0] = (wButtons & XINPUT_GAMEPAD_A) == 0 ? 0 : 1;
			btns[1] = (wButtons & XINPUT_GAMEPAD_B) == 0 ? 0 : 1;
			btns[2] = (wButtons & XINPUT_GAMEPAD_X) == 0 ? 0 : 1;
			btns[3] = (wButtons & XINPUT_GAMEPAD_Y) == 0 ? 0 : 1;
			btns[4] = (wButtons & XINPUT_GAMEPAD_LEFT_SHOULDER) == 0 ? 0 : 1;
			btns[5] = (wButtons & XINPUT_GAMEPAD_RIGHT_SHOULDER) == 0 ? 0 : 1;
			btns[6] = (wButtons & XINPUT_GAMEPAD_BACK) == 0 ? 0 : 1;
			btns[7] = (wButtons & XINPUT_GAMEPAD_START) == 0 ? 0 : 1;
			btns[8] = (wButtons & XINPUT_GAMEPAD_LEFT_THUMB) == 0 ? 0 : 1;
			btns[9] = (wButtons & XINPUT_GAMEPAD_RIGHT_THUMB) == 0 ? 0 : 1;
			btns[10] = (wButtons & XINPUT_GAMEPAD_DPAD_UP) == 0 ? 0 : 1;
			btns[11] = (wButtons & XINPUT_GAMEPAD_DPAD_RIGHT) == 0 ? 0 : 1;
			btns[12] = (wButtons & XINPUT_GAMEPAD_DPAD_DOWN) == 0 ? 0 : 1;
			btns[13] = (wButtons & XINPUT_GAMEPAD_DPAD_LEFT) == 0 ? 0 : 1;

			impl->updateStatus(axes, 6, btns, 14);
		}
	}

	if (!connected) {
		ControllerImpl::releaseController(id);
	}
#endif
}

int ControllerImpl::joystickPresent(int id) {
	return glfwJoystickPresent(id);
}

const float* ControllerImpl::getJoystickAxes(int joy, int* count) {
	return glfwGetJoystickAxes(joy, count);
}

const unsigned char* ControllerImpl::getJoystickButtons(int joy, int* count) {
	return glfwGetJoystickButtons(joy, count);
}

const char* ControllerImpl::getJoystickName(int joy) {
	return glfwGetJoystickName(joy);
}

Controller::~Controller() {
	delete _impl;

	delete _connectEvent;
	delete _keyEvent;
	delete _axisEvent;
}

Controller::Controller()
	: _controllerTag(TAG_UNSET)
	, _impl(new ControllerImpl(this))
	, _connectEvent(nullptr)
	, _keyEvent(nullptr)
	, _axisEvent(nullptr) {
	init();
}

EventListenerCustom* _updateListener = nullptr;
long long t1 = 0;
long long t2 = 0;

void Controller::registerListeners() {
}

void onUpdateHandler(EventCustom* e) {
	if (Controller::getAllController().size() == 0) {
		struct timeval tv;
		gettimeofday(&tv, NULL);
		t2 = tv.tv_sec * 1000 + tv.tv_usec / 1000;

		if (t2 - t1 < 1000) {
			return;
		} else {
			t1 = t2;
		}
	}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32)
	//ControllerImpl::checkWin32DirectInput();
	ControllerImpl::checkWin32XInput();
#else
	ControllerImpl::check(0);
#endif
}

void Controller::startDiscoveryController() {
	if (_updateListener == nullptr) {
		_updateListener = Director::getInstance()->getEventDispatcher()->addCustomEventListener(Director::EVENT_BEFORE_UPDATE, &onUpdateHandler);
	}
}

void Controller::stopDiscoveryController() {
	if (_updateListener != nullptr) {
		Director::getInstance()->getEventDispatcher()->removeEventListener(_updateListener);
		_updateListener = nullptr;
	}
}

void Controller::setVibration(float left, float right) {
	_impl->setVibration(left, right);
}

NS_CC_END

#endif // #if (CC_TARGET_PLATFORM == ...)