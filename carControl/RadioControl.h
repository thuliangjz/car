#ifndef RADIOCONTROL_H
#define RADIOCONTROL_H

typedef nx_struct input_msg_t{
    uint8_t nouse;
    uint8_t type;
    uint8_t data1;
    uint8_t data2;
}input_msg_t;

enum {
    MSG_LENGTH = 12;
    AM_RADIO_MSG = 0x63;
};
#endif