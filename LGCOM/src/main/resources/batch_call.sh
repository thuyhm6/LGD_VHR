#!/bin/sh

JAVA_HOME=/opt/java7
JEUS_HOME=/engn001/juscom01/jeus7
SORC_HOME=/sorc001/juscom01/LGCOM/war/WEB-INF
LOG_HOME=/logs001/juscom01/batch

CLASSPATH=.:$JEUS_HOME/lib/system/javaee.jar
CLASSPATH=$CLASSPATH:$JEUS_HOME/lib/datasource/ojdbc6.jar
CLASSPATH=$CLASSPATH:$SORC_HOME/lib/*
CLASSPATH=$CLASSPATH:$SORC_HOME/classes/*

echo "***************************************************************"
echo "  - JAVA_HOME      : $JAVA_HOME
echo "  - JEUS_HOME      : $JEUS_HOME
echo "  - SORC_HOME      : $SORC_HOME
echo "  - LOG_HOME       : $LOG_HOME
echo "  - CLASSPATH      : $CLASSPATH
echo "  - PARAM1         : $1
echo "  - PARAM2         : $2
echo "  - PARAM3         : $3
echo "  - PARAM4         : $4
echo "  - PARAM5         : $5
echo "***************************************************************"

cd $SORC_HOME/classes

$JAVA_HOME/bin/java -Dfile.encoding=utf-8 -cp $CLASSPATH com.lgd.lgcom.common.batch.BatchRunner $1 $2 $3 $4 $5
