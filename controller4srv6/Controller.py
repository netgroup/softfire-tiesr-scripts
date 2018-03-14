
import time
import os

_SLEEP_TIME = 5

_VNF_1_ADDRESS = ' '
_VNF_2_ADDRESS = ' '
_SURREY_2_ADDRESS = ' '

_TERMINAL_4_ADDRESS = ' '

_ADS_2_DEVICE_NAME = ' '
_ADS_2_ADDRESS = ' '


def serve():
	while True:
		os.system('python Client_srv6_ssh -i ' + _ADS_2_ADDRESS + ' -p '+ _TERMINAL_4_ADDRESS + ' -s ['+ _VNF_1_ADDRESS + _SURREY_2_ADDRESS + '] -d ' + _ADS_2_DEVICE_NAME)
		time.sleep(_SLEEP_TIME)

		os.system('python Client_srv6_ssh -i ' + _ADS_2_ADDRESS + ' -p '+ _TERMINAL_4_ADDRESS + ' -s ['+ _VNF_1_ADDRESS + _VNF_2_ADDRESS + _SURREY_2_ADDRESS + '] -d ' + _ADS_2_DEVICE_NAME)
		time.sleep(_SLEEP_TIME)

		os.system('python Client_srv6_ssh -i ' + _ADS_2_ADDRESS + ' -p '+ _TERMINAL_4_ADDRESS + ' -s ['+ _VNF_2_ADDRESS + _SURREY_2_ADDRESS + '] -d ' + _ADS_2_DEVICE_NAME)
		time.sleep(_SLEEP_TIME)

		os.system('python Client_srv6_ssh -i ' + _ADS_2_ADDRESS + ' -p '+ _TERMINAL_4_ADDRESS + ' -s ['+ _SURREY_2_ADDRESS + '] -d ' + _ADS_2_DEVICE_NAME)
		time.sleep(_SLEEP_TIME)



if __name__ == '__main__':
  serve()
