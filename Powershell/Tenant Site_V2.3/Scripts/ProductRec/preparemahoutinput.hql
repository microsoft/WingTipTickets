DROP TABLE IF EXISTS MahoutInput; 
CREATE EXTERNAL TABLE MahoutInput 
(
               	UserID 		string, 
                ProductID 	string,
		IsPlayed	string
) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '10' STORED AS TEXTFILE LOCATION '${hiveconf:MAHOUTINPUT}'; 

DROP TABLE IF EXISTS PartitionProductUsageEvents; 
CREATE EXTERNAL TABLE PartitionProductUsageEvents 
(
                UserID 		string, 
                ProductID 	string,
		IsPlayed  	int,
                TimeStamp 	string) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '10' STORED AS TEXTFILE LOCATION '${hiveconf:PARTITIONEDOUTPUT}';

INSERT OVERWRITE TABLE MahoutInput
SELECT
	UserID,
	ProductID,
	IsPlayed
FROM PartitionProductUsageEvents;