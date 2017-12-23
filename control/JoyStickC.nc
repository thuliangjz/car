configuration JoyStickC {
    provides interface Read<uint16_t> as ReadX;
    provides interface Read<uint16_t> as ReadY;
}
implementation{
    components new AdcReadClientC() as ReaderX;
    components new AdcReadClientC() as ReaderY;
    components JoyStickP;
    ReaderX.AdcConfigure -> JoyStickP.ConfigX;
    ReaderY.AdcConfigure -> JoyStickP.ConfigY;

    ReadX = ReaderX.Read;
    ReadY = ReaderY.Read;
}