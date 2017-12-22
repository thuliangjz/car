#ifndef RADIOCONTROL_H
#define RADIOCONTROL_H

typedef nx_struct input_msg_t{
    nx_uint8_t nouse;
    nx_uint8_t type;
    nx_uint8_t data1;
    nx_uint8_t data2;
}input_msg_t;

enum {
    AM_RADIO_MSG = 0x63
};
#endif