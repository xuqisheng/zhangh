
// ----------------------------------------------------------------
// rate_query_filter - 房价策略 - 房价查询过滤临时表 
// ----------------------------------------------------------------
if exists(select 1 from sysobjects where name = "rate_query_filter")
	drop table rate_query_filter;
CREATE TABLE rate_query_filter 
(
    pc_id   char(4)  NOT NULL,
    class   char(10)  NOT NULL,		-- rmtype, ratecode 
    grp   	char(10) NOT NULL,
    code   	char(10) NOT NULL
);
EXEC sp_primarykey 'rate_query_filter', pc_id,class,code;
CREATE UNIQUE INDEX index1 ON rate_query_filter(pc_id,class,code);
