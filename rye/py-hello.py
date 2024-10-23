# Print working directory.
import os
print(os.getcwd())

# Print the passed arguments.
import sys
print(sys.argv)

print("9e66f77", sys.executable)

print("b5e8d76", sys.path);

# .venv の Python で動いているので、その .venv 内の site-packages は読める。Python ではインタプリタがいずれかによって探索パスが決まる
import invoke
