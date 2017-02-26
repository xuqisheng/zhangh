IF OBJECT_ID('t_zk_saleid_insert') IS NOT NULL
    DROP TRIGGER t_zk_saleid_insert
;
CREATE TRIGGER t_zk_saleid_insert
ON saleid
FOR INSERT AS
begin
-- zk 2007-04-09
insert lgfl(columnname,accnt,old,new,empno,date) 
	select 's_profile', code, '', code, cby, changed from inserted
end;
