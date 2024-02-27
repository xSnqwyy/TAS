import os

attack1 = "1"
attack2 = "2"
attack3 = "3"
attack4 = "4"

attackslist = ["[1] DDos Attack","[2] Brute Force Attack","[3] Phishing Attack","[4] Hydra Attack"]

for attacklist in attackslist:
  print(attacklist)
  
attacks = input("Choose an attack tool: ")

if attacks == "1":
  print("DDos attack loading...")
elif attacks == "1":
    print("DDos tool cannot loading because no files please install...")
    
