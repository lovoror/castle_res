#include "main.h"
#include <windows.h>
#include <tchar.h>
#include <string>
#include "AppDelegate.h"
//#include "cocos2d.h"
#include "shellapi.h"

int WINAPI wWinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPTSTR lpCmdLine, int nCmdShow) {
	WCHAR wpath[MAX_PATH];
	GetModuleFileNameW(NULL, wpath, sizeof(wpath));
	unsigned int idx = 0;
	for (unsigned int i = 0; i < MAX_PATH; i++) {
		WCHAR c = wpath[i];
		if (c == '\\') {
			idx = i;
		} else if (c == '\0') {
			break;
		}
	}
	wpath[idx + 1] = 'r';
	wpath[idx + 2] = 'u';
	wpath[idx + 3] = 'n';
	wpath[idx + 4] = 't';
	wpath[idx + 5] = 'i';
	wpath[idx + 6] = 'm';
	wpath[idx + 7] = 'e';
	wpath[idx + 8] = '\0';
	SetDllDirectoryW(wpath);

    UNREFERENCED_PARAMETER(hPrevInstance);
    UNREFERENCED_PARAMETER(lpCmdLine);

	int argc = 0;
	std::string chapterPath = "";
	LPWSTR *lpszArgv = NULL;
	//分割命令行参数  
	lpszArgv = CommandLineToArgvW(GetCommandLine(), &argc);
	if (argc > 1) {
		LPTSTR pf = lpszArgv[1];
		char *pFileName = (char *)malloc(2 * wcslen(pf) + 1);
		wcstombs(pFileName, pf, 2 * wcslen(pf) + 1);
		chapterPath = pFileName;
	}
	
    // create the application instance
	return AppDelegate(chapterPath).run();
    //return Application::getInstance()->run();
}