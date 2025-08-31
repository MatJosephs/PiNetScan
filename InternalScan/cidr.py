#!/bin/python3
import socket
import fcntl
import struct

def get_ip_and_netmask(ifname):
	s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
	ip = socket.inet_ntoa(fcntl.ioctl(s.fileno(), 0x8915, struct.pack('256s', ifname[:15].encode('utf-8')))[20:24])

	netmask = socket.inet_ntoa(fcntl.ioctl(s.fileno(), 0x891b, struct.pack('256s', ifname[:15].encode('utf-8')))[20:24])
	return ip, netmask

def netmask_to_cidr(netmask):
	return sum([bin(int(octet)).count('1') for octet in netmask.split('.')])

def get_network(ip, cidr):
	ip_bin = ''.join([format(int(o), '08b') for o in ip.split('.')])
	net_bin = ip_bin[:cidr] + '0' * (32-cidr)
	net_octets = [str(int(net_bin[i:i+8], 2)) for i in range(0, 32, 8)]
	return '.'.join(net_octets) + f'/{cidr}'
if __name__ == "__main__":
	ip, netmask = get_ip_and_netmask('eth0')
	cidr = netmask_to_cidr(netmask)
	network = get_network(ip, cidr)
	print(network)
