#!/usr/bin/env python

print("      | " + "  0x%02X  " * 8 % tuple(x * 0x10 for x in range(8)))
print("------+-" + "--------" * 8)
for row in range(16):
  print(
    " 0x%02X | " % row + " ".join(
      (
        "^%c(%3d)" % (ch + 0x40, ch) if 0x00 <= (ch := col * 16 + row) <= 0x1e else # Control
        " %c(%3d)" % (ch, ch) if 0x20 <= ch <= 0x7e else # Visible
        "  (%3d)"  % ch # Invisible
      ) for col in range(8)
    )
  )
