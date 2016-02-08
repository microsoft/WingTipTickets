DROP TABLE IF EXISTS MahoutProductSimilarity; 
CREATE EXTERNAL TABLE MahoutProductSimilarity 
(
                ProductId1	int, 
                ProductId2 	int, 
                Similarity 	double) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '10' STORED AS TEXTFILE LOCATION '${hiveconf:MAHOUTOUTPUT}';

                
DROP TABLE IF EXISTS SimilarProducts; 
CREATE EXTERNAL TABLE SimilarProducts 
(
                ProductId		int, 
                RecommendedProductId 	int) ROW FORMAT DELIMITED FIELDS TERMINATED BY '\t' LINES TERMINATED BY '10' STORED AS TEXTFILE LOCATION '${hiveconf:SIMILARPRODUCTSOUTPUT}';
                
INSERT OVERWRITE TABLE SimilarProducts
SELECT
	MPS.ProductId1,
	MPS.ProductId2
FROM MahoutProductSimilarity MPS
WHERE MPS.Similarity > 0.7;