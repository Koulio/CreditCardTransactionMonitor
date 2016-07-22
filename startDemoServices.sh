#!/bin/bash

CLUSTER_NAME=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters |grep cluster_name|grep -Po ': "([a-zA-Z]+)'|grep -Po '[a-zA-Z]+')
HOSTNAME=$(hostname)
#Start Kafka
KAFKASTATUS=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/services/KAFKA | grep '"state" :' | grep -Po '([A-Z]+)')
if [ "$KAFKASTATUS" == INSTALLED ]; then
	echo "Starting Kafka Broker..."
	TASKID=$(curl -u admin:admin -i -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context" :"Start Kafka via REST"}, "Body": {"ServiceInfo": {"maintenance_state" : "OFF", "state": "STARTED"}}}' http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/services/KAFKA | grep "id" | grep -Po '([0-9]+)')
	echo "AMBARI TaskID " $TASKID
	sleep 2

	LOOPESCAPE="false"

	until [ "$LOOPESCAPE" == true ]; do

		TASKSTATUS=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/requests/$TASKID | grep "request_status" | grep -Po '([A-Z]+)')
		if [ "$TASKSTATUS" == COMPLETED ]; then
			LOOPESCAPE="true"
 		fi
		
		echo "Task Status" $TASKSTATUS
		sleep 2
	done
	echo "Kafka Broker Started..."

elif [ "$KAFKASTATUS" == STARTED ]; then
	echo "Kafka Broker Started..."
else
	echo "Kafka Broker in a transition state. Wait for process to complete and then run the install script again."
	exit 1
fi

sleep 1
# Start NIFI service
NIFISTATUS=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/services/NIFI | grep '"state" :' | grep -Po '([A-Z]+)')
if [ "$NIFISTATUS" == INSTALLED ]; then
	echo "Starting NIFI Service"
	TASKID=$(curl -u admin:admin -H "X-Requested-By:ambari" -i -X PUT -d '{"RequestInfo": {"context" :"Start NIFI"}, "Body": {"ServiceInfo": {"maintenance_state" : "OFF", "state": "STARTED"}}}' http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/services/NIFI | grep "id" | grep -Po '([0-9]+)')

	echo "AMBARI TaskID " $TASKID
	sleep 2

	LOOPESCAPE="false"
	until [ "$LOOPESCAPE" == true ]; do

        	TASKSTATUS=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/requests/$TASKID | grep "request_status" | grep -Po '([A-Z]+)')
        	if [ "$TASKSTATUS" == COMPLETED ]; then
                	LOOPESCAPE="true"
        	fi

        	echo "Task Status" $TASKSTATUS
        	sleep 2
	done
        echo "NIFI Service Started..."

elif [ "$NIFISTATUS" == STARTED ]; then
        echo "NIFI Service Started..."
else
        echo "NIFI Service in a transition state. Wait for process to complete and then run the install script again."
        exit 1
fi

sleep 1
#Start HBASE
HBASESTATUS=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/services/HBASE | grep '"state" :' | grep -Po '([A-Z]+)')
if [ "$HBASESTATUS" == INSTALLED ]; then
	echo "Starting  Hbase Service..."
	TASKID=$(curl -u admin:admin -i -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context" :"Start Hbase via REST"}, "Body": {"ServiceInfo": {"maintenance_state" : "OFF", "state": "STARTED"}}}' http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/services/HBASE | grep "id" | grep -Po '([0-9]+)')
	echo "HBASE TaskId " $TASKID
	sleep 2

	LOOPESCAPE="false"

	until [ "$LOOPESCAPE" == true ]; do

		TASKSTATUS=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/requests/$TASKID | grep "request_status" | grep -Po '([A-Z]+)')
		if [ "$TASKSTATUS" == COMPLETED ]; then
			LOOPESCAPE="true"
 		fi

		echo "Task Status" $TASKSTATUS
		sleep 2
	done
	echo "Hbase Service Started..."

elif [ "$HBASESTATUS" == STARTED ]; then
	echo "Hbase Service  Started..."
else
	echo "Hbase Service in a transition state. Wait for process to complete and then run the install script again."
	exit 1
fi

sleep 1
# Start Storm
STORMSTATUS=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/services/STORM | grep '"state" :' | grep -Po '([A-Z]+)')
if [ "$STORMSTATUS" == INSTALLED ]; then
	echo "Starting Storm Service..."
	TASKID=$(curl -u admin:admin -i -H 'X-Requested-By: ambari' -X PUT -d '{"RequestInfo": {"context" :"Start Storm via REST"}, "Body": {"ServiceInfo": {"maintenance_state" : "OFF", "state": "STARTED"}}}' http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/services/STORM | grep "id" | grep -Po '([0-9]+)')
	echo "STORM TaskId " $TASKID
	sleep 2

	LOOPESCAPE="false"

	until [ "$LOOPESCAPE" == true ]; do

		TASKSTATUS=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/requests/$TASKID | grep "request_status" | grep -Po '([A-Z]+)')
		if [ "$TASKSTATUS" == COMPLETED ]; then
			LOOPESCAPE="true"
 		fi
		
		echo "Task Status" $TASKSTATUS
		sleep 2
	done
	echo "Storm Service Started..."

elif [ "$STORMSTATUS" == STARTED ]; then
	echo "Storm Service Started..."
else
	echo "Storm Service in a transition state. Wait for process to complete and then run the install script again."
	exit 1
fi

# Start LogSearch
LOGSEARCHSTATUS=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters/Sandbox/services/LOGSEARCH | grep '"status" : ' | grep -Po '([0-9]+)')
if [ !"$LOGSEARCHSTATUS" == 404 ]; then
	LOGSEARCHSTATUS=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/services/LOGSEARCH | grep '"state" :' | grep -Po '([A-Z]+)')
	if [ "$LOGSEARCHSTATUS" == INSTALLED ]; then
		echo "Starting Log Search Service..."
		TASKID=$(curl -u admin:admin -H "X-Requested-By:ambari" -i -X PUT -d '{"RequestInfo": {"context" :"Start Log Search"}, "Body": {"ServiceInfo": {"maintenance_state" : "OFF", "state": "STARTED"}}}' http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/services/LOGSEARCH | grep "id" | grep -Po '([0-9]+)')
		echo "LOGSEARCHSTATUS TaskId " $TASKID
		sleep 2

		LOOPESCAPE="false"

		until [ "$LOOPESCAPE" == true ]; do

			TASKSTATUS=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/requests/$TASKID | grep "request_status" | grep -Po '([A-Z]+)')
			if [ "$TASKSTATUS" == COMPLETED ]; then
				LOOPESCAPE="true"
 			fi
		
			echo "Task Status" $TASKSTATUS
			sleep 2
		done
		echo "Log Search Service Started..."

	elif [ "$LOGSEARCHSTATUS" == STARTED ]; then
		echo "Log Search Service Started..."
	else
		echo "Log Search Service in a transition state. Wait for process to complete and then run the install script again."
		exit 1
	fi
else
	echo "Log Search Service does not exist, skipping..."
fi

# Start Atlas
ATLASSTATUS=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/services/ATLAS | grep '"state" :' | grep -Po '([A-Z]+)')
if [ "$ATLASSTATUS" == INSTALLED ]; then
	echo "Starting Atlas Service..."
	TASKID=$(curl -u admin:admin -H "X-Requested-By:ambari" -i -X PUT -d '{"RequestInfo": {"context" :"Start Log Search"}, "Body": {"ServiceInfo": {"maintenance_state" : "OFF", "state": "STARTED"}}}' http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/services/ATLAS | grep "id" | grep -Po '([0-9]+)')
	echo "ATLASSTATUS TaskId " $TASKID
	sleep 2

	LOOPESCAPE="false"

	until [ "$LOOPESCAPE" == true ]; do

		TASKSTATUS=$(curl -u admin:admin -X GET http://sandbox.hortonworks.com:8080/api/v1/clusters/$CLUSTER_NAME/requests/$TASKID | grep "request_status" | grep -Po '([A-Z]+)')
		if [ "$TASKSTATUS" == COMPLETED ]; then
			LOOPESCAPE="true"
 		fi
		
		echo "Task Status" $TASKSTATUS
		sleep 2
	done
	echo "Atlas Service Started..."

elif [ "$ATLASSTATUS" == STARTED ]; then
	echo "Atlas Service Started..."
else
	echo "Atlas Service in a transition state. Wait for process to complete and then run the install script again."
	exit 1
fi

# Clear Slider working directory
sudo -u hdfs hadoop fs -rm -R /user/root/.slider/cluster
# Ensure docker service is running
service docker start
# Start UI servlet on Yarn using Slider
slider create transactionmonitorui --template /home/docker/dockerbuild/transactionmonitorui/appConfig.json --metainfo /home/docker/dockerbuild/transactionmonitorui/metainfo.json --resources /home/docker/dockerbuild/transactionmonitorui/resources.json
