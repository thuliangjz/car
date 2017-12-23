#include "Car.h"
#include "msp430usart.h"


configuration CarC {
    provides interface Car;
}

implementation {
    components CarP, HplMsp430Usart0C,  HplMsp430GeneralIOC;
    components new Msp430Uart0C();
    Car = CarP;

    CarP.Usart -> HplMsp430Usart0C.HplMsp430Usart;
    CarP.UsartInt -> HplMsp430Usart0C.HplMsp430UsartInterrupts;
    CarP.Resource -> Msp430Uart0C.Resource;
    CarP.UsartGIO -> HplMsp430GeneralIOC.Port20;


}