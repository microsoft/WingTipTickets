DROP TABLE IF EXISTS MahoutRecommendations; 
CREATE EXTERNAL TABLE MahoutRecommendations 
(
		CustomerId int, 
		Recommendations string ) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '10' STORED AS TEXTFILE LOCATION '${hiveconf:MAHOUTOUTPUT}';

DROP TABLE IF EXISTS PersonalizedRecommendations; 
CREATE EXTERNAL TABLE PersonalizedRecommendations 
(
                UserId		int, 
                RecommendedProductId 	int) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '10' STORED AS TEXTFILE LOCATION '${hiveconf:RECOMMENDATIONSOUTPUT}';
                
INSERT OVERWRITE TABLE PersonalizedRecommendations
SELECT 
CustomerId, 
split(ProductId,":")[0] AS RecommendedProductId
FROM MahoutRecommendations LATERAL VIEW explode(split(regexp_replace(Recommendations,"\\[|\\]",""),",")) ProductsTable as ProductId;