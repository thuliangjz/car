interface Button {
    command void start();
    command void pinValue(uint8_t btnId);   //同步命令
    //将所有涉及各个button的处理放在ButtonC中,返回包含类型位和数据位的值，取低24位
}