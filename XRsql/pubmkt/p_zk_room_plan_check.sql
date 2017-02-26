if exists (select * from sysobjects where name ='p_zk_room_plan_check' and type ='P')
	drop proc p_zk_room_plan_check;
create proc p_zk_room_plan_check
	@pc_id			char(4),
	@begin			datetime,
	@end				datetime,
	@no				char(10),
	@retmode			char(1) = 'S',
	@rmnum			integer = 0,
	@class			char(1) = 'A',
	@rmnum_before	int	=	0
	
as
	
---------------------------------------------
-- 住店时间段房价与房数预测
---------------------------------------------
declare
	@bdate		datetime

select @rmnum = @rmnum - @rmnum_before

delete rsv_plan_check where pc_id = @pc_id

create table #snum(pc_id	char(4),
						id			char(10),
						date		datetime,
						num		integer)	

insert rsv_plan_check select @pc_id,a.id,a.no,a.date,a.class,a.quan,a.lmt,a.leaf,a.flag,a.rmtypes,a.ratecodes,a.cmt,a.remark,0,0
			from gzhs_rsv_plan a,guest b where a.no = b.no and datediff(dd,a.date,@begin) <= 0 and datediff(dd,a.date,@end) >= 0 and (a.no = @no or @no = '%')
					and (a.class = @class or @class = 'A')

if @class = 'F'
	begin
	insert #snum select c.pc_id,c.id,c.date,sum(a.quantity)/count(a.accnt) from rsvsrc_detail a,master b,rsv_plan_check c where a.accnt = b.accnt and a.date_ = c.date 
										and (b.cusno = c.no or b.agent = c.no or b.source = c.no) and b.sta <> 'X'
										and (charindex(rtrim(a.ratecode) + ',',rtrim(c.ratecodes) + ',') > 0 or rtrim(c.ratecodes) = null)
										and (charindex(rtrim(a.type) + ',',rtrim(c.rmtypes) + ',') > 0 or rtrim(c.rmtypes) = null) and (b.groupno = '' and b.class = 'F')
										and c.class = 'F' and c.pc_id = @pc_id
										group by c.pc_id,c.id,c.date,a.saccnt
	update rsv_plan_check set used = isnull((select sum(num) from #snum a where rsv_plan_check.id = a.id and a.pc_id = rsv_plan_check.pc_id 
												and a.date = rsv_plan_check.date),0) where pc_id = @pc_id
//	update rsv_plan_check set used = isnull((select sum(a.quantity)/count(a.accnt) from rsvsrc_detail a,master b where a.accnt = b.accnt and a.date_ = rsv_plan_check.date 
//										and (b.cusno = rsv_plan_check.no or b.agent = rsv_plan_check.no or b.source = rsv_plan_check.no)
//										and (charindex(rtrim(a.ratecode) + ',',rtrim(rsv_plan_check.ratecodes) + ',') > 0 or rtrim(rsv_plan_check.ratecodes) = null)
//										and (charindex(rtrim(a.type) + ',',rtrim(rsv_plan_check.rmtypes) + ',') > 0 or rtrim(rsv_plan_check.rmtypes) = null) and b.groupno = '' and b.class = 'F'
//										group by a.saccnt ),0)
//							where class = 'F' and pc_id = @pc_id
	update rsv_plan_check set leftn = quan - used - @rmnum , used = used + @rmnum where class = 'F' and pc_id = @pc_id
	update rsv_plan_check set flag = '' where flag = 'F' and class = 'F' and pc_id = @pc_id
	update rsv_plan_check set leftn = - @rmnum where (convert(char(20),dateadd(dd, - lmt,date),111) < convert(char(20),getdate(),111) and lmt > 0) and class = 'F' and pc_id = @pc_id
	update rsv_plan_check set leftn = - used where flag = 'T'  and class = 'F' and pc_id = @pc_id
	update rsv_plan_check set leftn = quan - used where class = 'G' and pc_id = @pc_id
	update rsv_plan_check set flag = '' where flag = 'F' and class = 'G' and pc_id = @pc_id
	update rsv_plan_check set leftn = - used where flag = 'T'  and class = 'G' and pc_id = @pc_id
	end
else if @class = 'G'
	begin
	insert #snum select c.pc_id,c.id,c.date,sum(a.quantity)/count(a.accnt) from rsvsrc_detail a,master b,rsv_plan_check c where a.accnt = b.accnt and a.date_ = c.date 
										and (b.cusno = c.no or b.agent = c.no or b.source = c.no) and b.sta <> 'X'
										and (charindex(rtrim(a.ratecode) + ',',rtrim(c.ratecodes) + ',') > 0 or rtrim(c.ratecodes) = null)
										and (charindex(rtrim(a.type) + ',',rtrim(c.rmtypes) + ',') > 0 or rtrim(c.rmtypes) = null) and (b.groupno <> '' or b.class <> 'F')
										and c.class = 'G' and c.pc_id = @pc_id
										group by c.pc_id,c.id,c.date,a.saccnt
	update rsv_plan_check set used = isnull((select sum(num) from #snum a where rsv_plan_check.id = a.id and a.pc_id = rsv_plan_check.pc_id 
												and a.date = rsv_plan_check.date),0) where pc_id = @pc_id
//	update rsv_plan_check set used = isnull((select sum(a.quantity)/count(a.accnt) from rsvsrc_detail a,master b where a.accnt = b.accnt and a.date_ = rsv_plan_check.date 
//										and (b.cusno = rsv_plan_check.no or b.agent = rsv_plan_check.no or b.source = rsv_plan_check.no)
//										and (charindex(rtrim(a.ratecode) + ',',rtrim(rsv_plan_check.ratecodes) + ',') > 0 or rtrim(rsv_plan_check.ratecodes) = null)
//										and (charindex(rtrim(a.type) + ',',rtrim(rsv_plan_check.rmtypes) + ',') > 0 or rtrim(rsv_plan_check.rmtypes) = null) and (b.groupno <> '' or b.class <> 'F')
//										group by a.saccnt ),0)
//							where class = 'G' and pc_id = @pc_id
	update rsv_plan_check set leftn = quan - used - @rmnum , used = used + @rmnum where class = 'G' and pc_id = @pc_id
	update rsv_plan_check set flag = '' where flag = 'F' and class = 'G' and pc_id = @pc_id
	update rsv_plan_check set leftn = - @rmnum where (convert(char(20),dateadd(dd, - lmt,date),111) < convert(char(20),getdate(),111) and lmt > 0) and class = 'G' and pc_id = @pc_id
	update rsv_plan_check set leftn = - used where flag = 'T'  and class = 'G' and pc_id = @pc_id
	update rsv_plan_check set leftn = quan - used where class = 'F' and pc_id = @pc_id
	update rsv_plan_check set flag = '' where flag = 'F' and class = 'F' and pc_id = @pc_id
	update rsv_plan_check set leftn = - used where flag = 'T'  and class = 'F' and pc_id = @pc_id
	end
else if @class = 'A'
	begin
	insert #snum select c.pc_id,c.id,c.date,sum(a.quantity)/count(a.accnt) from rsvsrc_detail a,master b,rsv_plan_check c where a.accnt = b.accnt and a.date_ = c.date 
										and (b.cusno = c.no or b.agent = c.no or b.source = c.no) and b.sta <> 'X'
										and (charindex(rtrim(a.ratecode) + ',',rtrim(c.ratecodes) + ',') > 0 or rtrim(c.ratecodes) = null)
										and (charindex(rtrim(a.type) + ',',rtrim(c.rmtypes) + ',') > 0 or rtrim(c.rmtypes) = null) and (b.groupno <> '' or b.class <> 'F')
										and c.class = 'G' and c.pc_id = @pc_id
										group by c.pc_id,c.id,c.date,a.saccnt
	insert #snum select c.pc_id,c.id,c.date,sum(a.quantity)/count(a.accnt) from rsvsrc_detail a,master b,rsv_plan_check c where a.accnt = b.accnt and a.date_ = c.date 
										and (b.cusno = c.no or b.agent = c.no or b.source = c.no) and b.sta <> 'X'
										and (charindex(rtrim(a.ratecode) + ',',rtrim(c.ratecodes) + ',') > 0 or rtrim(c.ratecodes) = null)
										and (charindex(rtrim(a.type) + ',',rtrim(c.rmtypes) + ',') > 0 or rtrim(c.rmtypes) = null) and (b.groupno = '' and b.class = 'F')
										and c.class = 'F' and c.pc_id = @pc_id
										group by c.pc_id,c.id,c.date,a.saccnt
	update rsv_plan_check set used = isnull((select sum(num) from #snum a where rsv_plan_check.id = a.id and a.pc_id = rsv_plan_check.pc_id 
												and a.date = rsv_plan_check.date),0) where pc_id = @pc_id


//	update rsv_plan_check set used = isnull((select sum(a.quantity)/count(a.accnt) from rsvsrc_detail a,master b where a.accnt = b.accnt and a.date_ = rsv_plan_check.date 
//										and (b.cusno = rsv_plan_check.no or b.agent = rsv_plan_check.no or b.source = rsv_plan_check.no)
//										and (charindex(rtrim(a.ratecode) + ',',rtrim(rsv_plan_check.ratecodes) + ',') > 0 or rtrim(rsv_plan_check.ratecodes) = null)
//										and (charindex(rtrim(a.type) + ',',rtrim(rsv_plan_check.rmtypes) + ',') > 0 or rtrim(rsv_plan_check.rmtypes) = null) and (b.groupno <> '' or b.class <> 'F')
//										group by a.saccnt ),0)
//							where class = 'G'	 and pc_id = @pc_id							
//	update rsv_plan_check set used = isnull((select sum(a.quantity)/count(a.accnt) from rsvsrc_detail a,master b where a.accnt = b.accnt and a.date_ = rsv_plan_check.date 
//										and (b.cusno = rsv_plan_check.no or b.agent = rsv_plan_check.no or b.source = rsv_plan_check.no)
//										and (charindex(rtrim(a.ratecode) + ',',rtrim(rsv_plan_check.ratecodes) + ',') > 0 or rtrim(rsv_plan_check.ratecodes) = null)
//										and (charindex(rtrim(a.type) + ',',rtrim(rsv_plan_check.rmtypes) + ',') > 0 or rtrim(rsv_plan_check.rmtypes) = null) and b.groupno = '' and b.class = 'F'
//										group by a.saccnt ),0)
//							where class = 'F' and pc_id = @pc_id
	update rsv_plan_check set leftn = quan - used - @rmnum , used = used + @rmnum where pc_id = @pc_id
	update rsv_plan_check set flag = '' where flag = 'F' and pc_id = @pc_id
	update rsv_plan_check set leftn = - @rmnum where (convert(char(20),dateadd(dd, - lmt,date),111) < convert(char(20),getdate(),111) and lmt > 0) and pc_id = @pc_id
	update rsv_plan_check set leftn = - used where flag = 'T' and pc_id = @pc_id
//select * from #snum where pc_id = @pc_id
//select * from rsv_plan_check where pc_id = @pc_id
	end

 


if @retmode = 'S'
	select a.date,a.flag,a.no,b.name,a.class,substring(a.ratecodes,1,100),substring(a.rmtypes,1,100),a.quan,a.lmt,a.used,a.leftn,a.leaf from  rsv_plan_check a,guest b 
			where a.no = b.no and pc_id = @pc_id order by no,date,ratecodes,rmtypes


return 0


;




