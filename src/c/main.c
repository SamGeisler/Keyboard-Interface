#include "windows.h"
#include "stdio.h"
#include "stdint.h"

int main(){

    DCB dcb;
    HANDLE hCom = CreateFile( "COM4",
        GENERIC_READ | GENERIC_WRITE,
        0,
        NULL,
        OPEN_EXISTING,
        0,
        NULL);
    
    if(hCom == INVALID_HANDLE_VALUE){
        printf("CreateFile failed with error %d.\n", GetLastError());
        return 1;
    }

    BOOL fSuccess = GetCommState(hCom, &dcb);
    if(!fSuccess){
        printf("Failed to read COM4 port state. Error %d\n",GetLastError());
        return 2;
    }

    dcb.DCBlength = sizeof(DCB);
    dcb.BaudRate = CBR_115200;
    dcb.ByteSize = 8;
    dcb.Parity = NOPARITY;
    dcb.StopBits = ONESTOPBIT;

    fSuccess = SetCommState(hCom, &dcb);
    if(!fSuccess){
        printf("Failed to set COM4 port state. Error %d\n",GetLastError());
        return 3;
    }

    printf("Port established:\nBaudRate = %d, ByteSize = %d, Parity = %d, StopBits = %d\n", dcb.BaudRate, dcb.ByteSize, dcb.Parity, dcb.StopBits);

    uint8_t buf = 'X';
    DWORD bytesRead;
    while(1){
        ReadFile(hCom, &buf, 1, &bytesRead, NULL);
        //printf("%c", buf);
        printf("0x%x: %c\n",buf,buf);
    }

    return 0;
}