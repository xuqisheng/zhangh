IF OBJECT_ID('t_zk_saleid_update') IS NOT NULL
    DROP TRIGGER t_zk_saleid_update
;
CREATE TRIGGER t_zk_saleid_update
ON saleid
FOR update AS
begin
-- zk 2007-04-09
if update(logmark)   -- 注意，这里插入的是 deleted
	insert saleid_log 
		select * from deleted
end;
