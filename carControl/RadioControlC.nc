module RadioControlC {
  uses {
    interface Boot;
    interface Leds;

    interface SplitControl as AMControl;

    interface AMSend;
    interface Receive;
    interface AMPacket;
    interface Car;
  }
}

implementation {

    uint8_t type;

    event void Boot.booted () {}

    event void AMControl.startDone (error_t err) {}
    
    task void ledControl () {
        if ((type & 1) == 1) {
            call Leds.led0On();
        }
        else {
            call Leds.led0Off();
        }
        if ((type & 2) == 1) {
            call Leds.led1On();
        }
        else {
            call Leds.led1Off();
        }
        if ((type & 4) == 1) {
            call Leds.led2On();
        }
        else {
            call Leds.led2Off();
        }
    }

    event message_t* Receive.receive(message_t *msg, void *payload, uint8_t len) {
        input_msg_t *inputData = (input_msg_t *)payload;
        type = inputData->type;
        post ledControl();
        call Car.commandDeal(inputData->type, inputData->data1, inputData->data2);
    }

    event void Car.readDone (error_t state, uint8_t data1, uint8_t data2) {}
    
    event void AMControl.stopDone (error_t error) {}

    event void AMSend.sendDone (message_t* msg, error_t error) {}
}