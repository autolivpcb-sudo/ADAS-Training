from pal.products.qcar import QCar
import cv2
import numpy as np
import time
from pal.products.qcar import QCarRealSense, IS_PHYSICAL_QCAR
from acc_setup import setup
thrl=2
stree=0
setup()
stop_dis , nominal_dis = 20,50



def read_images(camera):
    camera.read_RGB()
    rgb=camera.imageBufferRGB
    camera.read_depth()
    depth=camera.imageBufferDepthPX
    return rgb,depth

def depth_cal(depth):
    if depth is None:
        return None,None
    
    d=np.squeeze(depth)
    h,w= d.shape
    #set the upper limit and lower limit
    #do the same thing for w and x -axis
    #uy,ly= h//3,(2*h)//3
    uy,ly=261,262
    lx,rx=w//3,(2*w)//3
    crop=d[uy:ly,lx:rx]
    obj_dis=np.min(crop)
    return crop, obj_dis


def ACC(obj_dis, thrl):
    if obj_dis is None:
        return thrl
    
    if obj_dis <= stop_dis:
        return 0.0
    

    frac =1.0 
   # if stop_dis<obj_dis<nominal_dis:
     #   frac=(obj_dis-stop_dis)/(nominal_dis-stop_dis)

    return thrl*frac


# robot control
robot= QCar(readMode=1,frequency=10)
camera =QCarRealSense(mode='RGB, Depth')
try :
    while True:
        robot.read() 
        rgb,depth=read_images(camera)
        crop, obj_dis=depth_cal(depth)
        T=ACC(obj_dis, thrl)
        print(" speed ",T,  " distance ", obj_dis)
        
        robot.write(throttle=T,steering=stree)
        if cv2.waitKey(1) & 0xFF =='ord':
            print("exit")
            break

except KeyboardInterrupt:
    robot.write(0,0)
    print("stop")
    setup()
cv2.destroyAllWindows()



