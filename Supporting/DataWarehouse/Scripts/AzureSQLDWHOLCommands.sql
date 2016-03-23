/*Step 23 Retrieve Connection information*/

SELECT * FROM sys.dm_pdw_nodes_exec_connections;
SELECT * FROM sys.dm_pdw_nodes_exec_sessions;

/*Step 24 Retrieve Current Connection information*/

SELECT * 
FROM sys.dm_pdw_nodes_exec_connections AS c 
   JOIN sys.dm_pdw_nodes_exec_sessions AS s 
   ON c.session_id = s.session_id 
WHERE c.session_id = @@SPID;

/*Step 25 View Running Queries*/

SELECT * FROM sys.dm_pdw_exec_requests WHERE status = 'Running';

SELECT * FROM sys.dm_pdw_exec_requests ORDER BY total_elapsed_time DESC;

/*Step 26 View queries waiting for resources*/

SELECT waits.session_id,
      waits.request_id,  
      requests.command,
      requests.status, 
      requests.start_time,  
      waits.type,  
      waits.object_type, 
      waits.object_name,  
      waits.state  
FROM   sys.dm_pdw_waits waits 
   JOIN  sys.dm_pdw_exec_requests requests
   ON waits.request_id=requests.request_id 
ORDER BY waits.object_name, waits.object_type, waits.state;

/*Step 27 View long running Query*/

SELECT * FROM sys.dm_pdw_request_steps
WHERE request_id = 'QID<request_ID Number>'
ORDER BY step_index;

/*Step 28 View total elapsed time for long-running query*/

SELECT * FROM sys.dm_pdw_sql_requests
WHERE request_id = 'QID<request_ID Number>' AND step_index = <Step Index>;



