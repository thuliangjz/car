#include "printf.h"

#define QUERY_INTERVAL 200
#define COUNT_BTN 5
#define CAR_NODE_ID 30
#define MSG_QUE_LENGTH 12
#define HANDLE_MID_DELTA 500
#define STEER_ANGLE_MID 3000
#define STEER_ANGLE_DELTA 200
#define STEER_ANGLE_MIN 500
#define STEER_ANGLE_MAX 4500
#define MAX_STOP_INS_COUNT 5

module ControllerC {
    uses {
        //获取输入
        interface Read<uint16_t> as ReaderX;
        interface Read<uint16_t> as ReaderY;
        interface Button;
        //控制逻辑
        interface Boot;
        interface Timer<TMilli> as Timer;
        interface Packet;
        interface AMPacket;
        interface AMSend;
        interface SplitControl as AMControl;

        //调试用
        interface Leds;
    }
}
implementation {
    bool busy = FALSE;  //上一个时钟周期的事件处理是否还未完成
    bool msgDroped = FALSE; //在队列已经满了之后又收到了请求
    int16_t delta = 1;
    //如果队列已满则不再接受新的数据
    message_t msgBuffer[MSG_QUE_LENGTH];
    int8_t head = 0, tail = 0;
    int8_t queSize = 0;
    //读到的数据
    int16_t handleX, handleY;
    int8_t btnPressed;
    //保存的小车状态
    uint16_t angle1 = STEER_ANGLE_MID, 
        angle2 = STEER_ANGLE_MID;        //记录两个舵机当前角度
    bool moving = FALSE;   
    int8_t stopPktCount = 0; 
    task void sendMsg();    //发送队列中的控制信息,如果发现有msgDroped位应该置busy为FALSE
    message_t* getNextBuffer();
    void prepareMsg();      //在获取完所有的数据后决定发送什么类型的控制指令（以及个数）
    message_t *getNextBuffer();
    void deallocateOne();
    void popQue();
    void steer1Left(message_t *pMsg);
    void steer1Right(message_t *pMsg);
    void steer2Left(message_t *pMsg);
    void steer2Right(message_t *pMsg);
    void steerReset(message_t* pMsg1, message_t* pMsg2);
    void carMove(message_t *pMsg);
    /*
    节点每到一定时间点检查button和摇杆的输出的信号，保留所有能读到的信息
    摇杆的控制逻辑：
    如果x方向有值则不再读y方向的值，
    x方向与y方向都没有值则发送停止命令
    */

    event void Boot.booted(){
        call AMControl.start(); 
        call Button.start();
    }
    event void AMControl.startDone(error_t err){
        call Timer.startPeriodic(QUERY_INTERVAL);
    }
    event void AMControl.stopDone(error_t err){
    }
    event void Timer.fired(){

        uint8_t i;
        bool active;
       
        if(busy)
            return;
        busy = TRUE;
        for(i = 0; i < COUNT_BTN; ++i){
            active = call Button.pinValue(i);
            if(active){
                btnPressed = i;
                break;
            }
        }
        call ReaderX.read();
    }
    event void ReaderX.readDone(error_t err, uint16_t xVal){
        handleX = (int16_t) xVal;
        handleX -= 2048;
        handleX = -handleX;
        call ReaderY.read();
    }
    event void ReaderY.readDone(error_t err,uint16_t yVal){
        handleY = (int16_t) yVal;
        handleY -= 2048;
        handleY = -handleY;
        //所有数据读取完成
        prepareMsg();
    }
    /*
    发送控制命令的规则：
    如果有按钮按下，则按按钮规则进行处理
    如果没有则按摇杆按下处理
    */
    void prepareMsg(){
        message_t *pMsg = getNextBuffer(), *pMsg1;
        if(!pMsg){
            //注意这里没有置busy为TRUE,这意味着队列已满的情况下，
            //Timer触发fired事件时，不会进行数据的获取
            //同时注意在sendMsg中当发送完一个消息时如果检测到msgDroped,
            //则应同时将msgDroped和busy置为TRUE
            msgDroped = TRUE;
            return;
        }
       if(btnPressed >= 0){
            switch(btnPressed){
                case 0:
                    steer1Left(pMsg);
                    break;
                case 1:
                    steer1Right(pMsg);
                    break;
                case 2:
                    steer2Left(pMsg);
                    break;
                case 3:
                    steer2Right(pMsg);
                    break;
                default:
                    pMsg1 = getNextBuffer();
                    if(!pMsg1){
                        deallocateOne();
                        busy = FALSE;
                        btnPressed = -1;
                        return;
                    }
                    steerReset(pMsg, pMsg1);
                    break;
            }
        }
        else{
            carMove(pMsg);
        }
        post sendMsg();
        //所有数据归位
        atomic{
            busy = FALSE;
            btnPressed = -1;
        }
    }
    task void sendMsg(){
        if(tail == head)
            return;
        //发送head指向的message
        call Leds.led2Toggle();
        call AMSend.send(CAR_NODE_ID,&msgBuffer[head], sizeof(uint32_t));
    }
    event void AMSend.sendDone(message_t *msg, error_t err){
        popQue();
        if(msgDroped){
            msgDroped = FALSE;
            busy = FALSE;
        }
        post sendMsg();
    }
    message_t* getNextBuffer(){
        int8_t tmp;
        if(queSize >= MSG_QUE_LENGTH){
            //队列已满
            return 0;
        }
        tmp = tail++;
        tail = tail >= MSG_QUE_LENGTH ? 0 : tail;
        ++queSize;
        return &msgBuffer[tmp];
    }
    //撤销新分配的buffer
    void deallocateOne(){
        if(queSize == 0)
            return;
        --tail;
        tail = tail >= 0 ? tail : MSG_QUE_LENGTH;
        --queSize;
    }
    void popQue(){
        if(queSize == 0)
            return;
        ++head;
        head = head >= MSG_QUE_LENGTH ? 0 : head;
        --queSize;
    }
    /*
    下面的处理函数只要填写message信息并更新小车状态变量即可
    */
    //btn0
    void steer1Left(message_t *pMsg){
        uint32_t content = 0;
        uint32_t *payload = (uint32_t*)(call Packet.getPayload(pMsg, sizeof(uint32_t)));
        angle1 -= STEER_ANGLE_DELTA;
        angle1 = angle1 <= STEER_ANGLE_MIN ? STEER_ANGLE_MIN : angle1;
        content = angle1;
        content |= 0x10000;
        *payload = content;
    }
    //btn1
    void steer1Right(message_t *pMsg){
        uint32_t content = 0;
        uint32_t *payload = (uint32_t*)(call Packet.getPayload(pMsg, sizeof(uint32_t)));
        angle1 += STEER_ANGLE_DELTA;
        angle1 = angle1 >= STEER_ANGLE_MAX ? STEER_ANGLE_MAX : angle1;
        content = angle1;
        content |= 0x10000;
        *payload = content;
    }
    //btn2
    void steer2Left(message_t *pMsg){
        uint32_t content = 0;
        uint32_t *payload = (uint32_t*)(call Packet.getPayload(pMsg, sizeof(uint32_t)));
        angle2 -= STEER_ANGLE_DELTA;
        angle2 = angle2 <= STEER_ANGLE_MIN ? STEER_ANGLE_MIN : angle2;
        content = angle2;
        content |= 0x70000;
        *payload = content;
    }
    //btn3
    void steer2Right(message_t *pMsg){
        uint32_t content = 0;
        uint32_t *payload = (uint32_t*)(call Packet.getPayload(pMsg, sizeof(uint32_t)));
        angle2 += STEER_ANGLE_DELTA;
        angle2 = angle2 >= STEER_ANGLE_MAX ? STEER_ANGLE_MAX : angle2;
        content = angle2;
        content |= 0x70000;
        *payload = content;
    }
    //btn4
    void steerReset(message_t* pMsg1, message_t* pMsg2){
        uint32_t *payload;
        angle1 = STEER_ANGLE_MID;
        angle2 = STEER_ANGLE_MID;
        payload = (uint32_t*)(call Packet.getPayload(pMsg1, sizeof(uint32_t)));
        *payload = (uint32_t)angle1 | 0x10000;
        payload = (uint32_t*)(call Packet.getPayload(pMsg2, sizeof(uint32_t)));
        *payload = (uint32_t)angle2 | 0x70000;
    }
    //手柄被按下的逻辑
    /*
    摇杆的控制逻辑：
    如果x方向有值则不再读y方向的值，
    x方向与y方向都没有值则发送停止命令
    */
    void carMove(message_t* pMsg){
        uint32_t *payload = (uint32_t*)(call Packet.getPayload(pMsg, sizeof(uint32_t)));
        uint32_t content = 0;
        uint16_t vAbs = 500;
        if(handleX > HANDLE_MID_DELTA || handleX < -HANDLE_MID_DELTA){
            //只进行转弯, handleX大于零右转否则左转
            content |= handleX > 0 ? 0x20000 : 0x30000;
            content |= (uint32_t)vAbs;

            moving = TRUE;
        }
        else if(handleY > HANDLE_MID_DELTA || handleY < -HANDLE_MID_DELTA){
            //沿直线行进
            content |= handleY > 0 ? 0x40000 : 0x50000;

            content |= (uint32_t)vAbs;
            moving = TRUE;
        }
        else{
            content = 0x60000;
            if(moving){
                //停止信息码
                moving = FALSE;
                stopPktCount = 0;
            }
            else if(!moving && stopPktCount < MAX_STOP_INS_COUNT){
                //继续发送停止消息
                ++stopPktCount;
            }
            else{
                //不发送任何消息
                deallocateOne();
            }
        }
        *payload = content;
    }
}