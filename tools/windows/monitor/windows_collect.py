#!/usr/bin/python3
# author:zhouzhuo
# create time: 2021/8/27
# update time: 2021/9/1
# description
# this script use to collect windows CPU and Memory infomation
# status: commited 

import psutil
import time
import datetime
import socket

def get_sysinfo():
    now = datetime.datetime.now().strftime('%Y-%m-%d %H:%M:%S')
    hostname = socket.gethostname()
    bootTimeStamp = psutil.boot_time()
    bootTime = time.strftime("%Y-%m-%d",time.localtime(bootTimeStamp))

    memory = psutil.virtual_memory()
    memory_lv = round((memory.used/memory.total)* 100,2)

    swapInfo = psutil.swap_memory()
    swap_lv = round(swapInfo.percent)
    cpu_lv = psutil.cpu_percent()
    #print("time:{};system boot time: {};cpu load: {}%;memory load:{}%; swap load:{}%"
    #      .format(now,bootTime,cpu_lv,memory_lv,swap_lv))
    return str(hostname)+"|"+str(now)+"|"+str(cpu_lv)+"|"\
           +str(memory_lv)+"|"+str(swap_lv)+"|"+str(bootTime)

def sendinfo(sysinfo):
    client_socket = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    # send information to server:10.1.1.1
    client_socket.sendto(sysinfo.encode("utf-8"), ("10.1.1.1", 30000))
    client_socket.close()

while(True):
    # collect resource information interval: 60s
    time.sleep(60)
    sysinfo = get_sysinfo()
    sendinfo(sysinfo)
