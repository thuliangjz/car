#include "RadioControl.h"

configuration CarMainC {}
implementation {
    components MainC;
    components LedsC;
    components ActiveMessageC;
    components new AMSenderC(AM_RADIO_MSG);
    components new AMReceiverC(AM_RADIO_MSG);
    components CarC;
    components RadioControlC as App;

    App.Boot -> MainC;
    App.Leds -> LedsC;
    App.AMPacket -> AMSenderC;
    App.Receive -> AMReceiverC;
    App.AMSend -> AMSenderC;
    App.AMControl -> ActiveMessageC;
    App.Car -> CarC;

}
