import cv2
from pal.products.qcar import QCarRealSense, IS_PHYSICAL_QCAR
imor

camera =QCarRealSense(mode='RGB, Depth')


try :

    while True:
        camera.read_RGB()
        cv2.imshow("RGB_image",camera.imageBufferRGB)

        camera.read_depth()

        cv2.imshow("depth",camera.imageBufferDepthPX)
        print(type(camera.imageBufferDepthPX))
        print(camera.imageBufferDepthPX.shape)


        if cv2.waitKey(1) & 0xFF =='ord':
            print("exit")
            break

except KeyboardInterrupt:
    print("stop")


cv2.destroyAllWindows()
