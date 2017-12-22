module JoyStickP {
    provides interface AdcConfigure<const msp430adc12_channel_config_t*> as ConfigX;
    provides interface AdcConfigure<const msp430adc12_channel_config_t*> as ConfigY;
}
implementation{
    const msp430adc12_channel_config_t configX = {
        inch: INPUT_CHANNEL_A6,
        serf: REFERENCE_VREFplus_AVSS,
        ref2_5v: REFVOLT_LEVEL_2_5,
        adc12ssel: SHT_SOURCE_ACLK,
        adc12div: SHT_CLOCK_DIV_1,
        sht:SAMPLE_HOLD_4_CYCLES,
        sampcon_ssel:SAMPCON_SOURCE_SMCLK,
        sampcon_id: SAMPCON_CLOCK_DIV_1,
    };
    const msp430adc12_channel_config_t configY = {
        inch: INPUT_CHANNEL_A7,
        serf: REFERENCE_VREFplus_AVSS,
        ref2_5v: REFVOLT_LEVEL_2_5,
        adc12ssel: SHT_SOURCE_ACLK,
        adc12div: SHT_CLOCK_DIV_1,
        sht:SAMPLE_HOLD_4_CYCLES,
        sampcon_ssel:SAMPCON_SOURCE_SMCLK,
        sampcon_id: SAMPCON_CLOCK_DIV_1,
    };

    async command const msp430adc12_channel_config_t* ConfigX.getConfiguration(){
        return &configX;
    }
    async command const msp430adc12_channel_config_t* ConfigX.getConfiguration(){
        return &configY;
    }
}