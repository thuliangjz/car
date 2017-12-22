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