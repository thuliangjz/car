#ifndef CARP_H
#define CARP_H

typedef nx_struct my_msg_t{
    uint8_t data[8];
}my_msg_t;

enum {
    MSG_LENGTH = 12;
};
#endif
