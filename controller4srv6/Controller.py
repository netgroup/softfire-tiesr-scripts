
import time
import os

_SLEEP_TIME = 5

_VNF_1_ADDRESS = 'fd01:f1::1'
_VNF_2_ADDRESS = 'fd03:f1::1'
_SURREY_2_ADDRESS = 'fdff::4'
#'fdf0:0:0:2::2'

_TERMINAL_4_ADDRESS = 'fd04:1::1'

_ADS_2_DEVICE_NAME = 'br1term1'#@if24'
_ADS_2_ADDRESS = 'fdff::2'
#'fd02:1::fe'

_CONTROLLER_DEVICE_NAME = 'eth0'#@if79'


def serve():
	while True:
		#cmnd = 'python Client_srv6_ssh.py changesr -i ' + _ADS_2_ADDRESS + '\%' + _CONTROLLER_DEVICE_NAME + ' -p '+ _TERMINAL_4_ADDRESS + ' -s \''+ _VNF_1_ADDRESS + ',' + _SURREY_2_ADDRESS + '\' -d ' + _ADS_2_DEVICE_NAME
		cmnd = 'python Client_srv6_ssh.py changesr -i ' + _ADS_2_ADDRESS + ' -p '+ _TERMINAL_4_ADDRESS + ' -s \''+ _VNF_1_ADDRESS + ',' + _SURREY_2_ADDRESS + '\' -d ' + _ADS_2_DEVICE_NAME
		print "New Command: "
		os.system(cmnd)
		time.sleep(_SLEEP_TIME)

		os.system('python Client_srv6_ssh.py changesr -i ' + _ADS_2_ADDRESS + ' -p '+ _TERMINAL_4_ADDRESS + ' -s \''+ _VNF_1_ADDRESS + ',' + _VNF_2_ADDRESS + ',' + _SURREY_2_ADDRESS + '\' -d ' + _ADS_2_DEVICE_NAME)
		print "new command: "
		os.system(cmnd)
		time.sleep(_SLEEP_TIME)

		os.system('python Client_srv6_ssh.py changesr -i ' + _ADS_2_ADDRESS + ' -p '+ _TERMINAL_4_ADDRESS + ' -s \''+ _VNF_2_ADDRESS + ',' + _SURREY_2_ADDRESS + '\' -d ' + _ADS_2_DEVICE_NAME)
		print "new command: "
		os.system(cmnd)
		time.sleep(_SLEEP_TIME)

		os.system('python Client_srv6_ssh.py changesr -i ' + _ADS_2_ADDRESS + ' -p '+ _TERMINAL_4_ADDRESS + ' -s \''+ _SURREY_2_ADDRESS + '\' -d ' + _ADS_2_DEVICE_NAME)
		print "new command: "
		os.system(cmnd)
		time.sleep(_SLEEP_TIME)



if __name__ == '__main__':
  serve()
