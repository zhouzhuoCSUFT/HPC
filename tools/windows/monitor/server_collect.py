#!/bin/python3
# author:zhouzhuo
# create time: 2021/8/27
# update time: 2021/9/1
# description
# this script use to collect all windows information and monitor resource
# status: commited 

import socket
import datetime
def inforecv():
    udp_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    local_addr = ("", 30000)
    udp_socket.bind(local_addr)
    recv_data = udp_socket.recvfrom(1024)
    data = recv_data[0].decode('gbk')
    info =data.split("|")
    udp_socket.close()
    return info

def monitor(info):
    host = info[0]
    collect_time = info[1]
    cpu_lv = info[2]
    memory_lv = info[3]
    swap_lv = info[4]
    boot_time = info[5]
    warning = ""
    if(float(cpu_lv)>80):
        warning = "warning time:{} host:{} CPU load over 80%, current value:{}%".format(collect_time,host,cpu_lv)

    if(float(memory_lv)>80):
        warning = "warning time:{} host:{} memory load over 80% current value:{}%".format(collect_time,host, memory_lv)

    if(float(swap_lv)>98):
        warning = "warning time:{} host:{} swap load over 98%,current value:{}%".format(collect_time,host, swap_lv)

    if(collect_time.split(" ")[0]==boot_time):
        warning = "warning time:{} host:{} it seems boot today: {}".format(collect_time,host,boot_time)

    if(len(warning)!=0):
        savewarning(warning)

    if(int(collect_time.split(" ")[1].split(":")[1])%3 == 0):
        info = "record time:{} host:{} CPU load:{}% memory load:{}% swap load:{}% boot time:{}" \
                    .format(collect_time,host,cpu_lv,memory_lv,swap_lv,boot_time)
        saveinfo(info)

def savewarning(warning):
    filename = datetime.datetime.now().strftime('%Y-%m-%d')
    with open('/data/hpcwork/group/systemcheck/windows/logs/warning_' + filename, 'a+',encoding='utf-8') as logfile:
        logfile.write(warning + '\n')

def saveinfo(info):
    filename = datetime.datetime.now().strftime('%Y-%m-%d')
    with open('/data/hpcwork/group/systemcheck/windows/logs/info_'+filename,'a+',encoding='utf-8') as logfile:
        logfile.write(info+'\n')

if __name__ == '__main__':
    while (True):
        info = inforecv()
        monitor(info)

