-- ================================================================
-- Clean up Tables
-- ================================================================

SELECT  'DROP ' + CASE WHEN is_external = 1 THEN 'EXTERNAL ' ELSE '' END + 'TABLE ' + s.name + '.' + t.name + ';'
FROM 	sys.tables AS t
JOIN 	sys.schemas AS s ON t.schema_id = s.schema_id
ORDER BY s.name
       , t.name