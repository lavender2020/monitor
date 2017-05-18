#!/usr/bin/env python
# -*- coding: utf-8 -*-
# @Date    : 2017-05-16 11:09:34
# @Author  : lavendergeng@gmail.com

import os
import sys
import subprocess

basepath = os.path.split(os.path.realpath(sys.argv[0]))[0]  # 获取程序的运行目录
ceph_txt = basepath + '/result.txt'
# ceph_txt = 'd:\\ceph.txt'

def set_unit(unit_txt):  # disk to M,net to k

    if (str(unit_txt).upper().find('HEALTH') > -1):
        return str(unit_txt).split("_")[1]
    elif (str(unit_txt) == ''):
        return 0
    elif (str(unit_txt).upper().find('KB/S') > -1):
        return float(unit_txt[0:-4])
    elif (str(unit_txt).upper().find('KB/S') > -1):
        return float(unit_txt[0:-4])
    elif (str(unit_txt).upper().find('MB/S') > -1):
        return float(unit_txt[0:-4]) * 1024
    elif (str(unit_txt).upper().find('GB/S') > -1):
        return float(unit_txt[0:-4]) * 1024 * 1024
    elif (str(unit_txt).upper().find('B/S') > -1):
        return float(unit_txt[0:-3]) / 1024
    elif (str(unit_txt).upper().find('G') > -1):
        return float(unit_txt[0:-1]) * 1024
    elif (str(unit_txt).upper().find('T') > -1):
        return float(unit_txt[0:-1]) * 1024 * 1024
    elif (str(unit_txt).upper().find('OP/S') > -1):
        return float(unit_txt[0:-4])
    else:
        return unit_txt


with open(ceph_txt, 'r') as f:
    ceph_sender=''
    for line in f.readlines():
        line_lst = (line.strip()).split(':')
        ceph_sender =ceph_sender+ '"$hostname_script"' + ' ' + 'ceph.' + str(line_lst[0]) + ' ' + str(set_unit(line_lst[1]))+'\n'
    with open(basepath + '/ceph_sender.txt','w') as f:
        f.write(ceph_sender)

cmd = r"/usr/local/zabbix/bin/zabbix_sender -z $ip_zabbix_server -i %s"%(basepath + '/ceph_sender.txt')
subprocess.call(cmd, shell=True)
