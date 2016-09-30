import subprocess 
import sys
from shutil import copyfile

def run_game():
	command = [r'C:\Users\Bartek\Desktop\spring_103.0_win32_portable\spring-103.0_win32\spring-headless.exe', 
		r'C:\Users\Bartek\AppData\Roaming\springlobby\script.txt']
	process = subprocess.Popen(command, stdout=subprocess.PIPE, universal_newlines=True)
	while True:
		output = process.stdout.readline()
		print(output, end='')
		words = output.split()
		if(len(words) >= 4 and words[2] == 'Game' and words[3] == 'Over:'):
			process.kill()
			break
	return 
	
if __name__ == '__main__':
	N = 50
	if len(sys.argv) >= 2:
		N = int(sys.argv[1])
	print('Uruchamianie serii %d gier.' % N)
	for i in range(3):
		print('Rozpoczęcie %d. gry.' % i)
		run_game()
		#copyfile(src, dst)