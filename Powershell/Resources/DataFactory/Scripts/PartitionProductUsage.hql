SET hive.exec.dynamic.partition=true;
SET hive.exec.dynamic.partition.mode = nonstrict;

DROP TABLE IF EXISTS RawProductUsageEvents; 
CREATE EXTERNAL TABLE RawProductUsageEvents 
(
               	UserID 		string, 
                ProductID 	string, 
                IsPlayed 	int,
		TimeStamp	string
) ROW FORMAT DELIMITED FIELDS TERMINATED BY ',' LINES TERMINATED BY '10' STORED AS TEXTFILE LOCATION '${hiveconf:RAWINPUT}'; 

DROP TABLE IF EXISTS PartitionedProductUsageEvents; 
CREATE EXTERNAL TABLE PartitionedProductUsageEvents 
(
                UserID 		string, 
                ProductID 	string,
                IsPlayed 	int,				
                TimeStamp 	string) partitioned by (YearNo int, MonthNo int) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '10' STORED AS TEXTFILE LOCATION '${hiveconf:PARTITIONEDOUTPUT}';

DROP TABLE IF EXISTS Stage_RawProductUsageEvents; 
CREATE TABLE IF NOT EXISTS Stage_RawProductUsageEvents 
(
                UserID 		string, 
                ProductID 	string, 
		IsPlayed 	int,
                TimeStamp 	string,
		YearNo 		int,
		MonthNo 	int) ROW FORMAT delimited fields terminated by '\t' LINES TERMINATED BY '10';

INSERT OVERWRITE TABLE Stage_RawProductUsageEvents
SELECT
	UserID,
	ProductID,
	IsPlayed,
	TimeStamp,
	Year(TimeStamp),
	Month(TimeStamp)
FROM RawProductUsageEvents WHERE Year(TimeStamp) = ${hiveconf:Year} AND Month(TimeStamp) = ${hiveconf:Month}; 

INSERT OVERWRITE TABLE PartitionedProductUsageEvents PARTITION(YearNo, MonthNo) 
SELECT
	UserID,
	ProductID,
	IsPlayed,
	TimeStamp,
	YearNo,
	MonthNo
FROM Stage_RawProductUsageEvents WHERE YearNo = ${hiveconf:Year} AND MonthNo = ${hiveconf:Month};
