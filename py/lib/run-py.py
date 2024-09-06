import sys
# print(sys.argv)
original_wokrking_dir_path = sys.argv[1]
# Change the working directory.
import os
# Python interpreter path.
# print(sys.executable)
import subprocess
# Run the script with all rest arguments.
scr_path = os.path.abspath(sys.argv[2])
os.chdir(original_wokrking_dir_path)
process = subprocess.Popen([sys.executable, scr_path] + sys.argv[3:])
process.wait()
# Then return the return code of the process.
sys.exit(process.returncode)
