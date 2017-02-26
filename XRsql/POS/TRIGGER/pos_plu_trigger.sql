if exists(select 1 from sysobjects where name = 't_pos_pluid_delete')
	drop trigger t_pos_pluid_delete
;
create trigger t_pos_pluid_delete
on pos_pluid for delete
as
declare
                @id                     integer,
                @sta                    char(1),
                @pluids         char(10),
                @pluid          int           -- 考虑当前菜谱
select @pluids = value from sysoption where catalog='pos' and item ='pluid'
select @pluid = pluid from deleted
if convert(integer, @pluids) = @pluid
      rollback trigger with raiserror 20000 "该菜谱是当前使用菜谱，不能删除"

if exists(select 1 from pos_plucode a, deleted b where a.pluid = b.pluid )
	rollback trigger with raiserror 20000 "该菜谱下面还有菜本，必须要先删除菜本后，才能删除菜谱"

;
if exists(select 1 from sysobjects where name = 't_pos_plu_insert')
	drop trigger t_pos_plu_insert
;

create trigger t_pos_plu_insert
on pos_plu_all for insert
as
declare
		@id			integer,
		@sta			char(1),
		@pluid		int           -- 考虑当前菜谱
select @pluid = convert(int, value) from sysoption where catalog='pos' and item='pluid'
select @id = id,@sta = sta from inserted
delete pos_plu where id = @id and  pluid = @pluid
insert pos_plu select * from inserted  where pluid = @pluid
insert pos_price(pccode,id,inumber,unit,price,cost,cost_f,halt,logmark,empno,logdate) 
	select '###',a.id,1,'份',0,0,b.cost_f,'F',1,a.empno,getdate() from inserted a,pos_sort_all b where a.pluid=b.pluid and a.plucode=b.plucode and a.sort=b.sort 
;

if exists(select 1 from sysobjects where name = 't_pos_plu_update')
	drop trigger t_pos_plu_update
;

create trigger t_pos_plu_update
on pos_plu_all for update
as
declare
		@id			integer,
		@sta			char(1),
		@pluid		int           -- 考虑当前菜谱
select @pluid = convert(int, value) from sysoption where catalog='pos' and item='pluid'

select @id = id,@sta = sta from inserted

delete pos_plu where id in (select id from deleted)
insert pos_plu select * from inserted  where pluid = @pluid

if update(sta) and @sta = '2'
	delete pos_plu where id = @id

if update(logmark)
	insert pos_plu_log select * from deleted

	
;

if exists(select 1 from sysobjects where name = 't_pos_plu_delete')
	drop trigger t_pos_plu_delete
;

create trigger t_pos_plu_delete
on pos_plu_all for delete
as
if exists(select 1 from pos_dish a,deleted b where a.id = b.id )
	rollback trigger with raiserror 20000 "该菜今天已经被点，不能删除"
else if exists(select 1 from pos_tdish a,deleted b where a.id = b.id )
	rollback trigger with raiserror 20000 "该菜昨天已经被点，不能删除"
else
	begin
	delete pos_plu where id in (select id from deleted)
	delete pos_plu_log where id in (select id from deleted)
	delete pos_price where id in (select id from deleted)
	end
;


if exists(select 1 from sysobjects where name = 't_pos_sort_insert')
	drop trigger t_pos_sort_insert
;

create trigger t_pos_sort_insert
on pos_sort_all for insert
as
declare
		@sort			char(4),
		@old			char(4),
		@halt			char(1),
		@plucode    char(2),
		@oldplucode char(2),
		@pluid		integer,
		@pluidsys	integer

select @pluidsys = convert(integer,value) from sysoption where catalog='pos' and item = 'pluid'

select @pluid = pluid, @sort = sort,@halt = halt,@plucode = plucode from inserted

if @pluid = @pluidsys
	begin
	delete pos_sort where plucode=@plucode and sort = @sort and pluid = @pluid
	insert pos_sort select * from pos_sort_all where plucode=@plucode and sort = @sort and pluid = @pluid
	end
;


if exists(select 1 from sysobjects where name = 't_pos_sort_update')
	drop trigger t_pos_sort_update
;

create trigger t_pos_sort_update
on pos_sort_all for update
as
declare
		@sort			char(4),
		@oldsort		char(4),
		@halt			char(1),
		@plucode    char(2),
		@oldplucode char(2),
		@pluid		integer,
		@pluidsys	integer

select @pluidsys = convert(integer,value) from sysoption where catalog='pos' and item = 'pluid'


select @pluid = pluid,@sort = sort,@halt = halt,@plucode = plucode from inserted
select @oldplucode = plucode,@oldsort = sort from deleted

delete pos_sort where plucode =@plucode and sort = @sort and pluid = @pluid

if @pluid = @pluidsys
	insert pos_sort select * from pos_sort_all where plucode =@plucode and sort = @sort and pluid = @pluid

if update(halt) and @halt = 'T'
	begin
	update pos_plu_all set sta = '2' ,logmark = logmark +1  where plucode =@plucode and  pluid = @pluid and sort = @sort and sta = '0'
	delete pos_plu where plucode =@plucode and sort = @sort and pluid = @pluid
	delete pos_sort where plucode =@plucode and sort = @sort and pluid = @pluid
	end
if update(halt) and @halt = 'F'
	begin
	update pos_plu_all set sta = '0' ,logmark = logmark +1  where pluid = @pluid and plucode =@oldplucode and sort = @oldsort and sta = '2'
	end
if update(plucode)
	begin
	update pos_plu_all set plucode = @plucode where pluid = @pluid and plucode =@oldplucode  and sort = @oldsort
	update pos_plu set plucode = @plucode where pluid = @pluid and plucode =@oldplucode  and sort = @oldsort
	end
if update(sort)
	begin
	update pos_plu_all set sort = @sort where pluid = @pluid and plucode =@oldplucode  and sort = @oldsort
	update pos_plu set sort = @sort where pluid = @pluid and plucode =@oldplucode  and sort = @oldsort
	end
if update(logmark)
	begin
	insert pos_sort_log select * from deleted
	end;


if exists(select 1 from sysobjects where name = 't_pos_sort_delete')
	drop trigger t_pos_sort_delete
;

create trigger t_pos_sort_delete
on pos_sort_all for delete
as
if exists(select 1 from pos_plu_all a, deleted b where a.pluid = b.pluid and a.plucode=b.plucode and a.sort=b.sort and b.halt='F')
	rollback trigger with raiserror 20000 "该菜类下面还有菜，必须要先删除菜后，才能删除菜类"
delete pos_sort from pos_sort, deleted where pos_sort.pluid = deleted.pluid and pos_sort.plucode=deleted.plucode and pos_sort.sort=deleted.sort
;


if exists(select 1 from sysobjects where name = 't_pos_plucode_delete')
	drop trigger t_pos_plucode_delete
;

create trigger t_pos_plucode_delete
on pos_plucode for delete
as
if exists(select 1 from pos_sort_all a, deleted b where a.pluid = b.pluid and a.plucode=b.plucode)
	rollback trigger with raiserror 20000 "该菜本下面还有菜类，必须要先删除菜类后，才能删除菜本"
;

if exists(select 1 from sysobjects where name = 't_pos_price_update')
	drop trigger t_pos_price_update
;
create trigger t_pos_price_update
on pos_price for update
as
if update(logmark)
	insert into pos_price_log select * from deleted
;

if exists(select 1 from sysobjects where name = 't_pos_price_delete')
	drop trigger t_pos_price_delete
;
create trigger t_pos_price_delete
on pos_price for delete
as
	delete pos_price_log where id in(select id from deleted) and inumber in (select inumber from deleted)
;

