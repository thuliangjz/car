#define CONTROL_NODE_ID 80
configuration ControlAppC {

}
implementation {
    components MainC, ActiveMessageC;
    components new AMSenderC(CONTROL_NODE_ID);
    components new TimerMilliC() as Timer;
    components ButtonC, JoyStickC, ControllerC;
    components HplMsp430GeneralIOC as BtnIO;
    ButtonC.port0 -> BtnIO.Port60;
    ButtonC.port1 -> BtnIO.Port21;
    ButtonC.port2 -> BtnIO.Port61;
    ButtonC.port3 -> BtnIO.Port23;
    ButtonC.port4 -> BtnIO.Port62;
    ButtonC.port5 -> BtnIO.Port26;
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