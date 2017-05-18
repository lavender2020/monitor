#!/bin/sh

#define
ZB_COM="/usr/local/zabbix/bin/zabbix_sender"
ZB_SERVER_IP="$ip_zabbix_server"
ZB_HOSTNAME="$hostname_script"

#define monitor command
health=`ceph health |awk '{print $1}'`
MonAct=`ceph mon stat |awk '{print $2}'`
MonAll=`ceph mon dump|grep ":6789" |wc -l`
pools=`ceph -s |awk '/pgmap / {print $5}'`
ClusterCapacity=`ceph df|grep GLOBAL -A 2 |tail -n 1|awk '{print $1}'`
UsedCapacity=`ceph df|grep GLOBAL -A 2 |tail -n 1|awk '{print $3}'`
AvailableCapacity=`ceph df|grep GLOBAL -A 2 |tail -n 1|awk '{print $2}'`
Used100Percent=`ceph df|grep GLOBAL -A 2 |tail -n 1|awk '{print $4}'`
UsedPercent=`echo "scale=2;${Used100Percent}/100"|bc`
OsdNum=`ceph osd stat |awk '{print $3}'`
OsdIn=`ceph osd stat |awk '{print $7}'`
OsdOut=`ceph osd dump |grep out|wc -l`
OsdUp=`ceph osd stat |awk '{print $5}'`
OsdDown=`ceph osd tree |grep down |wc -l`
AvePgs=`ceph pg stat|awk '{print $2}'`
AvePgsPerOsd=`echo "$AvePgs"/"$OsdNum"|bc`
ApplyLatency=`ceph osd perf |grep -v osd |awk '{ SumApply+=$3 } END { print SumApply }'`
AveOsdApplyLatency=`echo "$ApplyLatency"/"$OsdNum"|bc`
CommitLantency=`ceph osd perf |grep -v osd |awk '{ SumCommit+=$2 } END { print SumCommit }'`
AveOsdCommitLantency=`echo "$CommitLantency"/"$OsdNum"|bc`
AveMonitorLantency=`ceph health detail |grep -i mon |awk -F 'latency ' '{print $2}'|awk -F 's' '{print $1}'`
ClusterIOPS=`ceph -s|grep "client io"|awk '{print $9}'`
ClusterThoughputRead=`ceph -s |grep "client io"|awk '{print $3$4}'`
ClusterThoughputWrite=`ceph -s |grep "client io"|awk '{print $6$7}'`
ClusterObjects=`ceph pg stat |awk -F ';' '{print $4}'|awk -F '[/]|[ ]' '{print $3}'`
DegradedObjects=`ceph pg stat |awk -F 'objects degraded|;' '{print $5}' |awk -F '[(]|[%]' '{print $2}'` #%
MisplacedObjects=`ceph pg stat |awk -F 'objects misplaced|;' '{print $6}' |awk -F '[(]|[%]' '{print $2}'` #%
OsdPgs=`ceph pg stat |awk '{print $2}'`
DegradedPgs=`ceph pg dump_stuck degraded |grep -v "pg_stat"|wc -l`
StalePgs=`ceph pg dump_stuck stale |grep -v "pg_stat"|wc -l`
UncleanPgs=`ceph pg dump_stuck unclean |grep -v "pg_stat"|wc -l`
UndersizedPgs=`ceph pg dump_stuck undersized |grep -v "pg_stat"|wc -l`
StuchPgs=`ceph pg dump_stuck|grep -v "pg_stat"|wc -l`
RecoveryBytes=`ceph -s|grep "recovery io" |awk -F '[ ]|[,]' '{print $3$4}'`
RecoveryKeys=0
RecoveryObjects=`ceph -s|grep "recovery io" |awk '{print $5}'`
MdsActive=`ceph mds dump|grep active|wc -l`
MdsStandby=`ceph mds dump|grep standby|wc -l`

echo "health:$health" > result.txt
echo "MonAct:$MonAct" >> result.txt
echo "MonAll:$MonAll" >> result.txt
echo "pools:$pools" >> result.txt
echo "ClusterCapacity:$ClusterCapacity" >> result.txt
echo "UsedCapacity:$UsedCapacity" >> result.txt
echo "AvailableCapacity:$AvailableCapacity" >> result.txt
echo "UsedPercent:$UsedPercent" >> result.txt
echo "OsdNum:$OsdNum" >> result.txt
echo "OsdIn:$OsdIn" >> result.txt
echo "OsdOut:$OsdOut" >> result.txt
echo "OsdUp:$OsdUp" >> result.txt
echo "OsdDown:$OsdDown" >> result.txt
echo "AvePgsPerOsd:$AvePgsPerOsd" >> result.txt
echo "AveOsdApplyLatency:$AveOsdApplyLatency" >> result.txt
echo "AveOsdCommitLantency:$AveOsdCommitLantency" >> result.txt
echo "AveMonitorLantency:$AveMonitorLantency" >> result.txt
echo "ClusterIOPS:$ClusterIOPS" >> result.txt
echo "ClusterThoughputRead:$ClusterThoughputRead" >> result.txt
echo "ClusterThoughputWrite:$ClusterThoughputWrite" >> result.txt
echo "ClusterObjects:$ClusterObjects" >> result.txt
echo "DegradedObjects:$DegradedObjects" >> result.txt
echo "MisplacedObjects:$MisplacedObjects" >> result.txt
echo "OsdPgs:$OsdPgs" >> result.txt
echo "DegradedPgs:$DegradedPgs" >> result.txt
echo "StalePgs:$StalePgs" >> result.txt
echo "UncleanPgs:$UncleanPgs" >> result.txt
echo "UndersizedPgs:$UndersizedPgs" >> result.txt
echo "StuchPgs:$StuchPgs" >> result.txt
echo "RecoveryBytes:$RecoveryBytes" >> result.txt
echo "RecoveryKeys:$RecoveryKeys" >> result.txt
echo "RecoveryObjects:$RecoveryObjects" >> result.txt
echo "MdsActive:$MdsActive" >> result.txt
echo "MdsStandby:$MdsStandby" >> result.txt


# python deal with unit
/usr/bin/python CephSender.py
