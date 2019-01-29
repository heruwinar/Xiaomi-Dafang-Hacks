#!/bin/sh

# Script to calculate the camera movement
# The screen is split as below (0,1,2,3 are the parameters of the script)
#           +--------------------------------------+
#           |                    |                 |
#           |           0        |      1          |
#           |                    |                 |
#           +--------------------------------------+
#           |                    |                 |
#           |          2         |      3          |
#           |                    |                 |
#           +--------------------------------------+

. /system/sdcard/scripts/common_functions.sh

STEPS=$STEP
FILECAMERAPOS=/system/sdcard/config/cameraposition

motorLeft(){
      /system/sdcard/bin/motor -d l -s ${1}
}

motorRight(){
      /system/sdcard/bin/motor -d r -s ${1}
}

motorUp() {
      /system/sdcard/bin/motor -d u -s ${1}
}

motorDown() {
      /system/sdcard/bin/motor -d d -s ${1}
}

backtoOrigin() {
    # return to origin for both axis

    # Get values in saved config file
    if [ -f ${FILECAMERAPOS} ]; then
	    origin_x_axis=`grep "x:" ${FILECAMERAPOS} | sed "s/x: //"`
	    origin_y_axis=`grep "y:" ${FILECAMERAPOS} | sed "s/y: //"`
    else
	    /system/sdcard/bin/motor -d s > ${FILECAMERAPOS}
    fi

    /system/sdcard/scripts/PTZpresets.sh $origin_x_axis $origin_y_axis

    # Let some time for the motor to turn
    sleep 1
}

#################### Start ###

# If no argument that's mean the camera need to return to its original position
if [ $# -eq 0 ]
then
    backtoOrigin
    return 0;
fi

UP=0
DOWN=0
LEFT=0
RIGHT=0

# Display the areas ...
echo $1 $2
echo $3 $4


# Sum all the parameters, that gives the number of region detected
# Only 2 are supported
if [ $((${1} + ${2} + ${3} +${4})) -gt 2 ]
then
	echo "No move if more than 3 detected regions"
    return 0
fi

# Basic algorithm to calculate the movement
# Not optimized, if you have ideas to simplify it ...

if  [ "${1}" == "1" ] || [ "${2}" == "1" ]
then
	UP=1
fi	

if [ "${1}" == "1" ] || [ "${3}" == "1" ]
then
	LEFT=1
fi

if [ "${2}" == "1" ] || [ "${4}" == "1" ]
then
	RIGHT=1
fi

if [ "${3}" == "1" ] || [ "${4}" == "1" ]
then
	DOWN=1
fi

# Some sanity checks
if [ "${UP}" != 0 ] && [ "${DOWN}" != 0 ]
then
	echo "no move: up and down at the same time"
	return 0
fi
if [ "${RIGHT}" != 0 ] && [ "${LEFT}" != 0 ]
then
	echo "no move: right and left at the same time"
	return 0
fi

if [ ${RIGHT} != 0 ]
then
	echo "Right move"
	motorRight ${STEPS}
fi
if [ ${LEFT} != 0 ]
then
	echo "Left move"
	motorLeft ${STEPS}
fi
if [ ${UP} != 0 ]
then
	echo "Up move"
	motorUp ${STEPS}
fi
if [ ${DOWN} != 0 ]
then
	echo "Down move"
	motorDown ${STEPS}
fi
