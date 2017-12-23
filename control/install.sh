if [ "$1" == "pre" ]
    then
    sudo chmod 666 /dev/ttyUSB0
    export MOTECOM=serial@/dev/ttyUSB0:telosb
elif [ "$1" == "install" ]
    then
    make telosb install,20
else
    echo "command not found"
fi