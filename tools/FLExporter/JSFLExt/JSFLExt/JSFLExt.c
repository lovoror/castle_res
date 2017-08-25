#define _CRT_SECURE_NO_WARNINGS

#include <TChar.h>
#include "mm_jsapi.h"
#include <stdlib.h>
#include <stdio.h>  
#include <wchar.h>  
#include <stdlib.h> 

#ifdef _WIN32
#else
#define MAX_PATH 1024 
FILE* wfopen(const wchar_t* filename, const wchar_t* mode) {
	char fn[MAX_PATH];
	char m[MAX_PATH];
	wcstombs(fn, filename, MAX_PATH);
	wcstombs(m, mode, MAX_PATH);
	return fopen(fn, m);
}
#endif

unsigned int convert16BitTo10Bit(unsigned char value) {
	if (value >= 48 && value <= 57) {
		return value - 48;
	}
	else if (value >= 65 && value <= 70) {
		return value - 55;
	}
	else {
		return value - 87;
	}
}

char* convertBytesFromString(unsigned char* data, unsigned int size, unsigned int* dstLen) {
	*dstLen = size * 0.25;
	char* bytes = malloc(*dstLen);

	unsigned int index = 0;
	for (unsigned int i = 0; i < size; i += 4) {
		bytes[index++] = (convert16BitTo10Bit(data[i]) << 4) | convert16BitTo10Bit(data[i + 2]);
	}

	return bytes;
}

// A sample function
// Every implementation of a Javascript function must have this signature
JSBool computeSum(JSContext *cx, JSObject *obj, unsigned int argc, jsval *argv, jsval *rval)
{
	long a, b, sum;

	// Make sure the right number of arguments were passed in
	if (argc != 2)
		return JS_FALSE;

	// Convert the two arguments from jsvals to longs
	if (JS_ValueToInteger(cx, argv[0], &a) == JS_FALSE ||
		JS_ValueToInteger(cx, argv[1], &b) == JS_FALSE)
		return JS_FALSE;

	// Perform the actual work
	sum = a + b;

	// Package the return value as a jsval
	*rval = JS_IntegerToValue(sum);

	// Indicate success
	return JS_TRUE;
}

JSBool writeBinary(JSContext *cx, JSObject *obj, unsigned int argc, jsval *argv, jsval *rval) {
	if (argc != 2) {
		JS_StringToValue(cx, L"argv error", 0, rval);

		return JS_FALSE;
	}

	unsigned int jsPathLen;
	wchar_t* jsPath = JS_ValueToString(cx, argv[0], &jsPathLen);
	unsigned int jsDataLen;
	unsigned char* jsData = (unsigned char*)JS_ValueToString(cx, argv[1], &jsDataLen);

	unsigned int bytesLen;
	char* bytes = convertBytesFromString(jsData, jsDataLen * 2, &bytesLen);

	FILE* fp = _wfopen(jsPath, L"wb");
	if (fp == NULL) {
		wchar_t info[1024];
		info[0] = '\0';
		wcscat(&info, L"open file error : ");
		wcscat(&info, jsPath);
		JS_StringToValue(cx, &info, 0, rval);
	} else {
		fwrite(bytes, bytesLen, 1, fp);
		fclose(fp);

		wchar_t info[1024];
		info[0] = '\0';
		wcscat(&info, L"write file success : ");
		wcscat(&info, jsPath);
		JS_StringToValue(cx, &info, 0, rval);
	}
	
	free(bytes);

	return JS_TRUE;
}


// MM_STATE is a macro that expands to some definitions that are
// needed in order interact with Flash.  This macro must be
// defined exactly once in your library
MM_STATE


// Flash calls MM_Init when your library is loaded
void
MM_Init()
{
	// sample function
	JS_DefineFunction(_T("writeBinary"), writeBinary, 0);
}


void
MM_Terminate()
{
	// clean up memory here
}
