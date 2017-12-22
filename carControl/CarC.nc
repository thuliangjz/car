#include "Car.h"
#include "msp430usart.h"

configuration CarC {
    provides interface Car;
}

implementation {
    components CarP, HplMsp430Usart0C, Msp430Uart0C, HplMsp430GeneralIOC;
    
    Car = CarP;

    CarP.Usart -> HplMsp430Usart0C.HplMsp430Usart;
    Carp.UsartInt -> HplMsp430Usart0C.HplMsp430UsartInterrupts;
    Carp.Resource -> Msp430Uart0C->Resource;
    Carp.UsartGIO -> HplMsp430GeneralIOC.Port20;


}