module ButtonC {
    uses {
        //0~5分别对应端口A-F
        interface HplMsp430GeneralIO as port0;
        interface HplMsp430GeneralIO as port1;
        interface HplMsp430GeneralIO as port2;
        interface HplMsp430GeneralIO as port3;
        interface HplMsp430GeneralIO as port4;
        interface HplMsp430GeneralIO as port5;
    }
    provides interface Button;
}
implementation {
    command void Button.start(){
        call port0.clr();
        call port1.clr();
        call port2.clr();
        call port3.clr();
        call port4.clr();
        call port5.clr();

        call port0.makeInput();
        call port1.makeInput();
        call port2.makeInput();
        call port3.makeInput();
        call port4.makeInput();
        call port5.makeInput();
    }
    command bool Button.pinValue(uint8_t btnId){
        switch(btnId){
            case 0:
                return !(call port0.get());
            case 1:
                return !(call port1.get());
            case 2:
                return !(call port2.get());
            case 3:
                return !(call port3.get());
            case 4:
                return !(call port4.get());
            case 5:
                return !(call port5.get());
            default :
                return FALSE;
        }
    }
}