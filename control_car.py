from pal.products.qcar import QCar
import keyboard

throttle=0
streeing=0

robot= QCar(readMode=1,frequency=10)

try :
    while True:
        robot.read() 
        robot.write(throttle=throttle,steering=streeing)

        if keyboard.is_pressed('u'):
            throttle=1
        elif keyboard.is_pressed('j'):
            throttle=-1
        elif keyboard.is_pressed('k'):
            streeing=0.5
        elif keyboard.is_pressed('h'):
            streeing=-0.5
        else:
            throttle=0
            streeing=0

except KeyboardInterrupt:
    print("robot stoped")



    # robot.read() 
    # robot.write(throttle=throttle,steering=streeing)
    # print("ACC:",robot.accelerometer)
    # print("BATTY:",robot.batteryVoltage)
    # print("GYRO:", robot.gyroscope)
    # print("FREQ",robot.frequency)
    # robot

    









    

