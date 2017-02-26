drop proc p_cq_pos_report_item_query;
create proc p_cq_pos_report_item_query
		@pccodes		char(100), 
		@menu			char(10),
		@empno		char(10),
		@itemcode	char(100) ,
		@date			datetime

as
declare
		@bdate		datetime,
		@plu_code	char(10),
		@id			int,
		@tocode1		char(3),
		@tocode2		char(100),
		@pccode		char(3),
		@code			char(6),
		@name1		char(60),
		@date0		datetime

create table #out
(
	pccode		char(3)			null,
	menu			char(10)			null,
	empno			char(10)			null,
	code			char(15)			null,
	id				integer			null,
	name1			char(80)			null,
	date			datetime			null,
	tocode1		char(3)			null,
	descript		char(60)			null,
	tocode2		char(100)		null
)


select @bdate = bdate1 from sysdata
if @date = @bdate
	declare c_dish cursor for 
	select b.pccode,a.sort+a.code,a.id,a.menu,a.empno,a.code,a.name1,a.date0 from pos_dish a,pos_menu b
		 where a.menu = b.menu and  (charindex(b.pccode,@pccodes)>0 or @pccodes = '')
		and (b.menu = @menu or @menu = '') and (a.empno = @empno or @empno = '') and charindex(rtrim(a.code),'XYZ')=0
else
	declare c_dish cursor for 
	select b.pccode,a.sort+a.code,a.id,a.menu,a.empno,a.code,a.name1,a.date0 from pos_hdish a,pos_hmenu b
		 where a.menu = b.menu and  (charindex(b.pccode,@pccodes)>0 or @pccodes = '') and b.bdate = @date
		and (b.menu = @menu or @menu = '') and (a.empno = @empno or @empno = '') and charindex(rtrim(a.code),'XYZ')=0

open c_dish
fetch c_dish into @pccode,@plu_code,@id,@menu,@empno,@code,@name1,@date0
while @@sqlstatus = 0
	begin
	select @tocode2 = isnull(tocode,'') from pos_plu_all where id = @id
	exec p_cq_pos_get_item_code @pccode,@plu_code,@id,@tocode1 out
	if charindex(@tocode1,@itemcode) > 0 or @itemcode = ''
		insert #out select @pccode,@menu,@empno,@code,@id,@name1,@date0,@tocode1,'',@tocode2
	fetch c_dish into @pccode,@plu_code,@id,@menu,@empno,@code,@name1,@date0
	end

close c_dish
update #out set descript = pos_namedef.descript from pos_namedef where #out.tocode1 = pos_namedef.code
select * from #out order by tocode1

;