import keyboard

while True:
    key = keyboard.read_key()
    if key == "w":
        print("UP")
        if(keyboard.is_pressed('w')):
            print("UP")
        else:
            print("RR")
    elif key == "a":
        print("LEFT")
    elif key == "d":
        print("RIGHT")
    elif key == "s":
        print("DOWN")
    else:
        print(key)