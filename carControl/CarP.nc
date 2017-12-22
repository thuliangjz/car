#include "Car.h"
#include "msp430usart.h"

interface Car {
    command void init();
    /*command error_t Angle(uint8_t data1, uint8_t data2);
    command error_t Angle_Sec(uint8_t data1, uint8_t data2);
    command error_t Angle_Third(uint8_t data1, uint8_t data2);
    command error_t Forward(uint8_t data1, uint8_t data2);
    command error_t Back(uint8_t data1, uint8_t data2);
    command error_t Left(uint8_t data1, uint8_t data2);
    command error_t Right(uint8_t data1, uint8_t data2);
    command error_t Pause();*/
    command error_t commandDeal(uint8_t type, uint8_t data1, uint8_t data2);
    event void readDone(error_t state, uint8_t data1, uint8_t data2);
}

module CarP () {
    provides interface Car;
    uses {
        interface HplMsp430Usart as Usart;
        interface HplMsp430UsartInterrupts as UsartInt;
        interface HplMsp430UsartGeneralIO as UsartGIO;
        interface Resource;
    }
}

implementation {
    my_msg_t msgQueue[MSG_LENGTH];
    bool busy = FALSE, full = FALSE;
    uint8_t msgIn, msgOut;
    uint8_t msgInit[8] = {0x01, 0x02, 0, 0, 0, 0xFF, 0xFF, 0};

    msp430_uart_union_config_t config1 = { 
        {
            utxe : 1, 
            urxe : 1, 
            ubr : UBR_1MHZ_115200, 
            umctl : UMCTL_1MHZ_115200, 
            ssel : 0x02, 
            pena : 0, 
            pev : 0, 
            spb : 0, 
            clen : 1, 
            listen : 0, 
            mm : 0, 
            ckpl : 0, 
            urxse : 0, 
            urxeie : 0, 
            urxwie : 0,
            utxe : 1,
            urxe : 1
        } 
    };


    task void writeMsgToCar () {
        atomic{
            if (msgIn == msgOut && !full) {
                busy = FALSE;
                return;
            }
            if (!call Resource.request()) {
                // signal Car.readDone(FAIL, msg[3], msg[4]);
                post writeMsgToCar();
            }
        }
    }

    event void granted () {
        my_msg_t *currentMsg;
        currentMsg = &msgQueue[msgOut];
        call Usart.setModeUart(&config1);
        call Usart.enableUart();
        U0CTL &= ~SYNC;
        while(!Usart.isTxEmpty()){}
        call Usart.tx(currentMsg->data[0]);
        while(!Usart.isTxEmpty()){}
        call Usart.tx(currentMsg->data[1]);
        while(!Usart.isTxEmpty()){}
        call Usart.tx(currentMsg->data[2]);
        while(!Usart.isTxEmpty()){}
        call Usart.tx(currentMsg->data[3]);
        while(!Usart.isTxEmpty()){}
        call Usart.tx(currentMsg->data[4]);
        while(!Usart.isTxEmpty()){}
        call Usart.tx(currentMsg->data[5]);
        while(!Usart.isTxEmpty()){}
        call Usart.tx(currentMsg->data[6]);
        while(!Usart.isTxEmpty()){}
        call Usart.tx(currentMsg->data[7]);
        call Resource.release();
        msgOut ++;
        if (msgOut == MSG_LENGTH) {
            msgOut = 0;
        }
        full = FALSE;
        signal Car.readDone(SUCCESS, msg[3], msg[4]);
        post writeMsgToCar();
    }

    command void Car.init () {
        uint8_t i, j;
        for (i = 0; i < MSG_LENGTH; i++) {
            for (j = 0; j < 8; j++) {
                msgQueue[i].data[j] = msgInit[j];
            }
        }
    }

    command error_t commandDeal(uint8_t type, uint8_t data1, uint8_t data2) {
        my_msg_t *msgPtr;
        atomic {
            if (!full) {
                msgPtr = &msgQueue[msgIn];
                msgPtr->data[2] = type;
                msgPtr->data[3] = data1;
                msgPtr->data[4] = data2;
                msgIn ++;
                if (msgIn == MSG_LENGTH) {
                    msgIn = 0;
                }
                if (msgIn == msgOut) {
                    full = TRUE;
                }
                if (!busy) {
                    post writeMsgToCar();
                    busy = TRUE;
                }
                return SUCCESS;
            }
            return FAIL;
        }
    }
    /*
    command error_t Car.Angle (uint8_t data1, uint8_t data2) {
        my_msg_t *msgPtr;
        atomic{
            if (!full) {
                msgPtr = &msgQueue[msgIn];
                msgPtr->data[2] = 1;
                msgPtr->data[3] = data1;
                msgPtr->data[4] = data2;
                msgIn ++;
                if (msgIn == MSG_LENGTH) {
                    msgIn = 0;
                }
                if (msgIn == msgOut) {
                    full = TRUE;
                }
                if (!busy) {
                    post writeMsgToCar();
                    busy = TRUE;
                }
            }
        }
    }*/
    
}