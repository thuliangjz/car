#define NEW_PRINTF_SEMANTICS
#include "printf.h"

#define COMM_PORT 0x71
configuration ControlAppC {

}
implementation {
    components MainC, PrintfC, SerialStartC, ActiveMessageC;
    components new AMSenderC(COMM_PORT);
    components new TimerMilliC() as Timer;
    components ButtonC, JoyStickC, ControllerC;
    components HplMsp430GeneralIOC as BtnIO;
    components LedsC;
    ButtonC.port0 -> BtnIO.Port60;
    ButtonC.port1 -> BtnIO.Port21;
    ButtonC.port2 -> BtnIO.Port62;
    ButtonC.port3 -> BtnIO.Port26;
    ButtonC.port4 -> BtnIO.Port61;


    ControllerC.Leds -> LedsC;    
    ControllerC.Button -> ButtonC;
    ControllerC.ReaderX -> JoyStickC.ReadX;
    ControllerC.ReaderY -> JoyStickC.ReadY;
    ControllerC.Boot -> MainC;
    ControllerC.Timer -> Timer;
    ControllerC.Packet -> AMSenderC;
    ControllerC.AMPacket -> AMSenderC;
    ControllerC.AMSend -> AMSenderC;
    ControllerC.AMControl -> ActiveMessageC;
}