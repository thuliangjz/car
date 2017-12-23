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
         call Timer.startPeriodic(1000);
    }
    
    event void Timer.fired () {
        uint8_t data1, data2;
        uint16_t data = 4500;
        call Leds.led0Toggle();
        if(counter <= 40)
            call Car.commandDeal((counter / 10) + 2, 1, 244);
        else if(counter <= 50) {
            data1 = data >> 8;
            data2 = data;
            call Car.commandDeal(1, data1, data2);
        }
        else if(counter <= 60) {
            data = 500;
            data1 = data >> 8;
            data2 = data;
            call Car.commandDeal(1, data1, data2);
        }
        else {
            call Car.commandDeal(6, 0, 0);
            call Timer.stop();
        }
        counter += 5;
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
        uint32_t content = *(uint32_t*)payload;
        uint8_t data1, data2;
        type = (content >> 16);
        data1 = (content >> 8);
        data2 = content;
        post ledControl();
        call Car.commandDeal(type, data1, data2);
        return msg;
    }

    event void Car.readDone (error_t state, uint8_t data1, uint8_t data2) {}
    
    event void AMControl.stopDone (error_t error) {}

    event void AMSend.sendDone (message_t* msg, error_t error) {}
}