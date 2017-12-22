configuration JoyStickC {
    provides interface Read<uint16_t> as ReadX;
    provides interface Read<uint16_t> as ReadY;
}
implementation{
    components new AdcReadClientC() as ReaderX;
    components new AdcReadClientC() as ReaderY;
    components JoySticP;
    ReaderX.AdcConfigure -> JoySticP.ConfigX;
    ReaderY.AdcConfigure -> JoySticP.ConfigY;

    ReadX = ReaderX.Read;
    ReadY = ReaderY.Read;
}