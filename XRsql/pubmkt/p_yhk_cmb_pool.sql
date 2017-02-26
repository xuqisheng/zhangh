
IF OBJECT_ID('p_yhk_cmb_pool') IS NOT NULL
    DROP PROCEDURE p_yhk_cmb_pool;
create proc p_yhk_cmb_pool
as
-----------------------------------------------------------------
-- 查找待合并档案  
-----------------------------------------------------------------
begin tran

delete from cmb_pool

-- 姓名相同 
insert into cmb_pool(no) select a.no from guest a 
	where exists (select b.no from guest b where  b.name2 = a.name2 and b.name2 <> "" 
							and a.class = b.class and b.no <> a.no) 

-- 证件相同 
insert into cmb_pool(no) select a.no from guest a 
	where exists (select b.no from guest b where  b.ident = a.ident and b.ident <> "" 
							and a.class = b.class and b.no <> a.no) 

commit tran

return 0;
