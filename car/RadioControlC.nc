#include <Timer.h>
module RadioControlC {
  uses {
    interface Boot;
    interface Leds;

    interface SplitControl as AMControl;

    interface AMSend;
    interface Receive;
    interface AMPacket;
    interface Car;
    interface Timer<TMilli> as Timer;
  }
}

implementation {

    uint8_t type = 0;
    uint8_t counter = 0;

    event void Boot.booted () {
        call Car.init();
        call AMControl.start();
    }

    event void AMControl.startDone (error_t err) {
        // call Timer.startPeriodic(1000);
    }
    
    event void Timer.fired () {
        /*
        call Leds.led0Toggle();
        call Car.commandDeal((counter / 10) + 2, 1, 244);
        call Car.commandDeal((counter / 10) + 3, 1, 244);
        counter += 5;
        
        if(counter >= 40)
            call Timer.stop();
        */
    }


    task void ledControl () {
        if (type & 0x01)
            call Leds.led0On();
        else 
            call Leds.led0Off();
        if (type & 0x02)
            call Leds.led1On();
        else
            call Leds.led1Off();
        if (type & 0x04)
            call Leds.led2On();
        else
            call Leds.led2Off();
    }

    //02: right 03: left   04: forward   05: backward  
    event message_t* Receive.receive(message_t *msg, void *payload, uint8_t len) {
        input_msg_t *inputData = (input_msg_t *)payload;
        type = inputData->type;
        post ledControl();
        call Car.commandDeal(inputData->type, inputData->data1, inputData->data2);
        return msg;
    }

    event void Car.readDone (error_t state, uint8_t data1, uint8_t data2) {}
    
    event void AMControl.stopDone (error_t error) {}

    event void AMSend.sendDone (message_t* msg, error_t error) {}
}