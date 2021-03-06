#!/bin/bash

COMMAND="${1}"
IP="${2}"

export PATH=/usr/local/bin:${PATH}

if [ ! -f /tmp/mavlink_router_pipe ]; then 
    sleep 1
fi

if [[ ${COMMAND} == "old" || ${COMMAND} == "add" ]]; then
    echo "add ${IP}" > /dev/udp/127.0.0.1/9120
    echo "add ${IP}" > /dev/udp/127.0.0.1/9121
    echo "add ${IP}" > /dev/udp/127.0.0.1/9122
    echo "add ${IP}" > /dev/udp/127.0.0.1/9123
    echo "add ${IP}" > /dev/udp/127.0.0.1/9124
    echo "add udp ${IP} ${IP} 14550 0" > /tmp/mavlink_router_pipe
 
    qstatus "External device connected: ${IP}" 5
    
    PINGFAIL=0
    IPTHERE=1
    while [ ${IPTHERE} -eq 1 ]; do
        ping -c 3 -W 1 -n -q ${IP} > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            IPTHERE=1
            PINGFAIL=0
        else
            ping -c 1 -W 10 -n -q ${IP} > /dev/null 2>&1
            if [ $? -ne 0 ]; then
                if [ ${PINGFAIL} -ge 6 ]; then
                    IPTHERE=0

                    echo "del ${IP}" > /dev/udp/127.0.0.1/9120
                    echo "del ${IP}" > /dev/udp/127.0.0.1/9121
                    echo "del ${IP}" > /dev/udp/127.0.0.1/9122
                    echo "del ${IP}" > /dev/udp/127.0.0.1/9123
                    echo "del ${IP}" > /dev/udp/127.0.0.1/9124
                else
                    PINGFAIL=$((PINGFAIL+1))
                fi
            fi
        fi

        sleep 1
    done

    qstatus "External device gone: ${IP}" 5
fi
