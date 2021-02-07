#/usr/bin/python3

import socket

sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)

host = "192.168.0.1"

port = 1

def portscanner(port):
	if sock.connect_ex((host,port)):
		print ("close") + %d + "port"
	else:
		print ("open") + %d + "port"

portscanner(port)
