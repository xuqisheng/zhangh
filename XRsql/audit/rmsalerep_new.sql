
// ע�⣺ ����÷��겻��¥�ţ���������ԭ���ĳ��� ������


//-------------------------------------------------------------------------------------
//���ڿͷ���Ӫҵͳ�� ----> ���Ӷ�¥�ŵļ���
//						¥�ŵı����¥����
//-------------------------------------------------------------------------------------

//-------------------------------------------------------------------------------------
// �ͷ�Ӫҵ���� ---> ��ԭ���Ļ��������� gkey �ֶΣ��Ա�ʾ��ͬ��ͳ�Ʒ�����
//-------------------------------------------------------------------------------------
//if exists (select * from sysobjects where name ='rmsalerep_new' and type ='U')
//   drop table rmsalerep_new;
//create table rmsalerep_new
//(
//   date      datetime				not null,
//	gkey 		 char(1) 				not null,     // f_loor, t_ype, h_all...   --- !!!!! �����־
//	hall		  char(1) 				not null,   
//   code      char(5) 				not null,
//   descript  char(16) 				not null,
//   ttl       money 		default 0 not null,  --  �ܷ��� 
//   mnt       money 		default 0 not null,  --  ά�޷� 
//	  os			 money	 	DEFAULT 0 NOT NULL,	--	 ����
//   htl       money 		default 0 not null,  --  ���÷� 
//   avl       money 		default 0 not null,  --  ���۷� 
//   vac       money 		default 0 not null,  --  �շ�   
//   soldf     money 		default 0 not null,  --  ɢ��   
//   soldg     money 		default 0 not null,  --  �Ŷ�   
//   soldc     money 		default 0 not null,  --  ����   
//   soldl     money 		default 0 not null,  --  ��ס   
//   ent       money 		default 0 not null,  --  ������ѷ��� 
//   ext       money 		default 0 not null,  --  �Ӵ�   
//   incomef   money  		default 0 not null,          --  ɢ������ 
//   incomeg   money  		default 0 not null,          --  �Ŷ����� 
//   incomec   money  		default 0 not null,          --  �������� 
//   incomel   money  		default 0 not null,          --  ��ס���� 
//   gstf      int    		default 0 not null,          --  ɢ������ 
//   gstg      int    		default 0 not null,          --  �Ŷ����� 
//   gstc      int    		default 0 not null,          --  �������� 
//   gstl      int    		default 0 not null,          --  ��ס���� 
//
//-- gaoliang add in scjj 
//   soldf_r     money 		default 0 not null,  --  ɢ��   
//   soldf_w     money 		default 0 not null,  --  ɢ��   
//   soldg_r     money 		default 0 not null,  --  �Ŷ�   
//   soldg_w     money 		default 0 not null,  --  �Ŷ�   
//   soldc_r     money 		default 0 not null,  --  ����   
//   soldc_w     money 		default 0 not null,  --  ����   
//
//   arrf     money 		default 0 not null,  --  ɢ��   
//   arrg     money 		default 0 not null,  --  �Ŷ�   
//   arrc     money 		default 0 not null,  --  ����   
//   arrl     money 		default 0 not null,  --  ��ס   
//
//   arrf_r     money 		default 0 not null,  --  ɢ��   
//   arrf_w     money 		default 0 not null,  --  ɢ��   
//   arrg_r     money 		default 0 not null,  --  �Ŷ�   
//   arrg_w     money 		default 0 not null,  --  �Ŷ�   
//   arrc_r     money 		default 0 not null,  --  ����   
//   arrc_w     money 		default 0 not null  --  ����   
//)
//exec sp_primarykey rmsalerep_new,gkey, hall, code
//create unique index index1 on rmsalerep_new(gkey, hall, code)
//;
//

//-------------------------------------------------------------------------------------
//	��ʷ��¼
//-------------------------------------------------------------------------------------
//if exists (select * from sysobjects where name ='yrmsalerep_new' and type ='U')
//   drop table yrmsalerep_new;
//create table yrmsalerep_new
//(
//   date      datetime,
//	gkey 		 char(1) 				not null,     // f_loor, t_ype, h_all...   --- !!!!! �����־
//	hall		  char(1) 				not null,   
//   code      char(5) 				not null,
//   descript  char(16) 				not null,
//   ttl       money 		default 0 not null,  --  �ܷ��� 
//   mnt       money 		default 0 not null,  --  ά�޷� 
//	  os			 money	 	DEFAULT 0 NOT NULL,	--	 ����
//   htl       money 		default 0 not null,  --  ���÷� 
//   avl       money 		default 0 not null,  --  ���۷� 
//   vac       money 		default 0 not null,  --  �շ�   
//   soldf     money 		default 0 not null,  --  ɢ��   
//   soldg     money 		default 0 not null,  --  �Ŷ�   
//   soldc     money 		default 0 not null,  --  ����   
//   soldl     money 		default 0 not null,  --  ��ס   
//   ent       money 		default 0 not null,  --  ������ѷ��� 
//   ext       money 		default 0 not null,  --  �Ӵ�   
//   incomef   money  		default 0 not null,          --  ɢ������ 
//   incomeg   money  		default 0 not null,          --  �Ŷ����� 
//   incomec   money  		default 0 not null,          --  �������� 
//   incomel   money  		default 0 not null,          --  ��ס���� 
//   gstf      int    		default 0 not null,          --  ɢ������ 
//   gstg      int    		default 0 not null,          --  �Ŷ����� 
//   gstc      int    		default 0 not null,          --  �������� 
//   gstl      int    		default 0 not null,          --  ��ס���� 
//
//   soldf_r     money 		default 0 not null,  --  ɢ��   
//   soldf_w     money 		default 0 not null,  --  ɢ��   
//   soldg_r     money 		default 0 not null,  --  �Ŷ�   
//   soldg_w     money 		default 0 not null,  --  �Ŷ�   
//   soldc_r     money 		default 0 not null,  --  ����   
//   soldc_w     money 		default 0 not null,  --  ����   
//
//   arrf     money 		default 0 not null,  --  ɢ��   
//   arrg     money 		default 0 not null,  --  �Ŷ�   
//   arrc     money 		default 0 not null,  --  ����   
//   arrl     money 		default 0 not null,  --  ��ס   
//
//   arrf_r     money 		default 0 not null,  --  ɢ��   
//   arrf_w     money 		default 0 not null,  --  ɢ��   
//   arrg_r     money 		default 0 not null,  --  �Ŷ�   
//   arrg_w     money 		default 0 not null,  --  �Ŷ�   
//   arrc_r     money 		default 0 not null,  --  ����   
//   arrc_w     money 		default 0 not null  --  ����   
//)
//exec sp_primarykey yrmsalerep_new,date, gkey, hall, code
//create unique index index1 on yrmsalerep_new(date, gkey, hall, code)
//create index index2 on yrmsalerep_new(gkey, hall, code, date)
//;
//

// --------------------------------------------------------------------------------
// ���ű�־��ȡ���� 
// --------------------------------------------------------------------------------
if exists(select * from sysobjects where name = "p_gds_get_rm_code")
   drop proc p_gds_get_rm_code
;
create proc    p_gds_get_rm_code	
	@roomno	   char(5),	
	@gkey	      char(1),	      --  ��ȡ��ʽ: ¥�㣺f(loor), ���ࣺt(ype), ¥�ţ�h(all) �������� 
	@ghall		char(1)  out, --  hall code 
	@gcode	   char(5)  out,  --  ¥�㣺floor, ���ࣺtype, ¥�ţ�hall ��������
	@gdescript	char(16) out,  --  ���� 
	@ret			int 		out,
	@msg			varchar(70) out
as

declare 	@oroomno			char(5),
			@type 			char(5),
			@flr				char(3)

select @gcode = '', @gdescript = '', @ret = 0, @msg = 'ok!'

select @ghall=hall, @oroomno = oroomno, @type = type, @flr=flr from rmsta where roomno = @roomno
if @@error <> 0 or @@rowcount = 0 
	select @ret = 1, @msg = @roomno + '  ���Ų����� !'
else if @ghall is null or not exists(select 1 from basecode where cat='hall' and code = @ghall)
	select @ret = 1, @msg = @roomno + ' --- ¥�Ŵ��� !' 
else if @flr is null or not exists(select 1 from flrcode where code = @flr)
	select @ret = 1, @msg = @roomno + ' --- ¥����� !'
else if charindex(@gkey,'fF,tT,hH') <= 0
	select @ret = 1, @msg = '���ű�־��ڴ��� !!! '

if @ret <> 0 
	 return @ret

if charindex(@gkey, 'fF') > 0   --  ¥�� 
	begin
   select @gcode = @flr
	select @gdescript = descript from flrcode where code=@flr
   end 

else if charindex(@gkey, 'tT') > 0 --  ���� 
	begin
	select @gcode = @type
	select @gdescript = descript from typim where type = @gcode
	end

else   --  ¥�� 
	begin
	select @gcode = hall from rmsta where oroomno = @oroomno
	select @gdescript = descript from basecode where cat='hall' and code = @gcode
	end
 
return @ret
;


//-------------------------------------------------------------------------------------
// �µ�ͳ�ƹ��� 
//-------------------------------------------------------------------------------------
IF OBJECT_ID('dbo.p_gds_audit_rmsale_new') IS NOT NULL
    DROP PROCEDURE dbo.p_gds_audit_rmsale_new
;
create proc p_gds_audit_rmsale_new
	@gkey 			char(1), 			-- floor, type, hall, ...
	@exclcodes 		varchar(10)
as

declare
	@bdate			datetime,
	@bfdate			datetime,
	@oroomno			char(5),
	@type				char(5),
	@code				char(5),
	@name				char(16),
	@ttl				money,
	@mnt				money,
	@htl				money,
	@avl				money,
	@vac				money,
	@ent				money,
	@incomef			money,
	@incomeg			money,
	@incomec			money,
	@incomel			money,
	@mode				char(10),
	@charge			money,
	@tag				char(3),
	@maccnt			char(10),
	@roomno			char(5),
	@sta				char(1),
	@number			integer,
	@class			char(1),
	@isfstday		char(1),
	@isyfstday		char(1),
	@hall				char(1),

	@accnt			char(10),
	@quantity		money,
	@reserved		money,
	@walk_in			money,
	@arr				datetime,
	@pccode			char(5),
	@groupno			char(10),
	@extra			char(15),
	@market			char(3),
	@ret				integer,
	@msg			 	varchar(70),
	@rmposted		char(1),
	@nights_option	char(20),	 -- �������ѡ�JjBbNPDd����Ӧaccount.mode�ĵ�һλ��������㣬û�����㣻Dd��ӦDay Use��
										-- parms --> sysoption / audit / addrm_night / ???  def=JjDd
	@pcaddbed		char(5),		-- �Ӵ�������
	@gst_calmode	char(1),		-- ����ͳ�Ƶķ��� - 0=���� 1=������
	@gstno			int,
	@master        char(10),
	@day_use_in		char(1),
	@pccodeallow	char(100),
	@addquantity		money,
	@tmp				money,
	@tmp_quantity	money,
	@tmp_quantity2	money,
	@sum				money,
	@saccnt			char(10),
	@dep				datetime,
	@accntof			char(10)

select @tmp = 0,@sum=0

if exists ( select 1 from gate where audit = 'T')
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead
select @bfdate = dateadd(day, -1, @bdate)
delete rmsalerep_new where gkey = @gkey

select @nights_option = value from sysoption where catalog='audit' and item='addrm_night'
if @@rowcount = 0 or rtrim(@nights_option) is null
	select @nights_option = 'JjBbNPDd'

select @pcaddbed = value from sysoption where catalog='audit' and item='room_charge_pccode_extra'
if @@rowcount = 0 or @pcaddbed is null
	select @pcaddbed = '1005 '

select @pccodeallow = value from sysoption where catalog='audit' and item='room_charge_pccodes_nt'
if @@rowcount = 0 or @pccodeallow is null
	select @pccodeallow = '1000 '

select @gst_calmode = value from sysoption where catalog='audit' and item='gst_calmode'
if @@rowcount = 0 or @gst_calmode is null or charindex(@gst_calmode,'01')=0
	select @gst_calmode = '0'

select @day_use_in = value from sysoption where catalog='reserve' and item='day_use_in'
if @@rowcount = 0 or @day_use_in is null or charindex(@day_use_in,'TF')=0
	select @day_use_in = 'F'

----------------------------------------
--  �����ͷ���Ϣ	scan till_rmsta
----------------------------------------
declare c_rmsta cursor for select roomno, sta, number from rmsta_till where tag<>'P' order by type
open  c_rmsta
fetch c_rmsta into @roomno, @sta, @number
while @@sqlstatus = 0
	begin
	exec p_gds_get_rm_code @roomno, @gkey, @hall out, @code out, @name out, @ret out, @msg out
	if @ret <> 0
		begin
		close c_rmsta
		deallocate cursor c_rmsta
		return 1
		end
	if not exists (select 1 from rmsalerep_new where gkey = @gkey and code = @code and hall = @hall)
		insert rmsalerep_new (date, gkey, hall, code, descript) values (@bfdate, @gkey, @hall, @code, @name)
	--if not exists (select accnt from master_till a, mktcode b where a.sta = 'I' and a.roomno = @roomno and a.market = b.code and b.flag = 'HSE')
	update rmsalerep_new set ttl = ttl + 1, descript = @name where code = @code and gkey = @gkey and hall = @hall
	--if @number > 0		-- ����ס
		--begin
		--if exists (select accnt from master_till a, mktcode b where a.sta = 'I' and a.roomno = @roomno and a.market = b.code and b.flag = 'HSE')
			--update rmsalerep_new set htl = htl + 1 where code = @code and gkey = @gkey and hall = @hall
		--end
	if exists (select 1 from rmstalist where sta = @sta and maintnmark = 'T') --zk �޸� ����os�� ��ά����=ά�޷�+����
		begin
		if @sta = 'O'
			update rmsalerep_new set mnt = mnt + 1 where code = @code and gkey = @gkey and hall = @hall
		else if @sta = 'S'
			update rmsalerep_new set os = os + 1 where code = @code and gkey = @gkey and hall = @hall
		end
	else if @number = 0
		update rmsalerep_new set vac = vac + 1 where code = @code and gkey = @gkey and hall = @hall

	fetch c_rmsta into @roomno, @sta, @number
	end
close c_rmsta
deallocate cursor c_rmsta

-------------------------------------------
--  ������Ϣ scan gltemp, ���ˡ�ת�˲�����
-------------------------------------------
create table #roomno (roomno  char(5)  not null,
							 accnt   char(10)  not null,
							 arr		datetime  null,
							 dep		datetime	 null,
							 rm		money		 not null)

//declare c_gltemp cursor for select a.pccode, a.charge, a.tag, a.mode, a.roomno, a.accnt, a.quantity, b.flag, c.rmposted ,c.master
//	from gltemp a, mktcode b, master_till c
//	where a.pccode < '20'  and rtrim(accntof) = null //and charindex(rtrim(substring(a.mode, 1, 1)), rtrim(@nights_option)) > 0
//		and a.tag *= b.code and a.accnt=c.accnt and charindex(rtrim(a.pccode),rtrim(@pccodeallow)) > 0 union all
//select a.pccode, a.charge, a.tag, a.mode, a.roomno, a.accntof, a.quantity, b.flag, c.rmposted ,c.master
//	from gltemp a, mktcode b, master_till c
//	where a.pccode < '20'  and accntof <> '' 
//		and a.tag *= b.code and a.accntof=c.accnt //and charindex(rtrim(substring(a.mode, 1, 1)), rtrim(@nights_option)) > 0
//		and charindex(rtrim(a.pccode),rtrim(@pccodeallow)) > 0 
//order by a.roomno
declare c_gltemp cursor for
	select a.pccode,a.charge,a.tag,a.mode,'',a.accnt, a.quantity, b.market, b.rmposted ,b.master,a.accntof
	from  gltemp a, master_till b
	where a.accnt = b.accnt and a.pccode < '9' and (a.crradjt in ('AD', '') or (a.crradjt in ('LT', 'LA') and a.tofrom= ''))
union all
	select a.pccode,a.charge,a.tag,a.mode,'',a.accnt, a.quantity, a.tag, b.rmposted ,b.master,a.accntof
	from  gltemp a, ar_master b
	where a.accnt = b.accnt and a.pccode < '9' and (a.crradjt in ('AD', '') or (a.crradjt in ('LT', 'LA') and a.tofrom= ''))
order by a.accnt
open  c_gltemp
fetch c_gltemp into @pccode, @charge, @tag, @mode, @oroomno, @accnt, @quantity, @market, @rmposted ,@master,@accntof
while @@sqlstatus = 0
	begin 
	if rtrim(@accntof) <> null
		select @accnt = @accntof
	select @code = 'ZZZ', @hall = '{' 
	select @class = class, @groupno = groupno, @extra = extra,@saccnt = saccnt,@arr = arr,@dep = dep from master_till where accnt = @accnt
	--�Ӵ�����
	if @pccode = @pcaddbed
		select @addquantity = @quantity
	--ʲô������㷿��
	if substring(@mode, 1, 1)='' or charindex(substring(@mode, 1, 1), @nights_option) = 0
		select @quantity = 0
	--ʲô������㷿��
	if charindex(rtrim(@pccode), @pccodeallow) = 0 -- and charindex(rtrim(@pccode), @pcaddbed) = 0
		select @charge = 0

	if substring(@mode, 2, 5) <> '' --or charindex(@pccode,@pccodeallow) > 0
		begin
		select @roomno = ltrim(rtrim(substring(@mode, 2, 5)))
		exec p_gds_get_rm_code @roomno, @gkey, @hall out, @code out, @name out, @ret out, @msg out
		if @ret = 1
			select @roomno = @oroomno, @mode = 'J' + rtrim(@oroomno) + substring(@mode, 10, 1)
			exec p_gds_get_rm_code @roomno, @gkey, @hall out, @code out, @name out, @ret out, @msg out
		end
	else
		select @quantity = 0

	if substring(@mode, 1, 1)='' or charindex(rtrim(substring(@mode, 1, 1)), rtrim(@nights_option)) = 0 or rtrim(@mode) = 'pkg_c A'
		begin
		select @quantity = 0
		end

	if not exists (select 1 from rmsalerep_new where code = @code and gkey = @gkey and hall = @hall) and rtrim(@code) <> null
		insert rmsalerep_new(date, gkey, hall, code, descript) values(@bfdate, @gkey, @hall, @code, @name)

	if @class = 'F' and @groupno = ''  -- ɢ��
		begin

		if exists(select 1 from mktcode where flag='LON' and code = @market)
			update rmsalerep_new set incomel = incomel + @charge where code = @code and gkey = @gkey and hall = @hall
		else
			update rmsalerep_new set incomef = incomef + @charge where code = @code and gkey = @gkey and hall = @hall
		end
	else if @class = 'M' or substring(@groupno, 1, 1) = 'M'
		update rmsalerep_new set incomec = incomec + @charge where code = @code and gkey = @gkey and hall = @hall
	else if @class = 'G' or substring(@groupno, 1, 1) = 'G'
		update rmsalerep_new set incomeg = incomeg + @charge where code = @code and gkey = @gkey and hall = @hall
	else
		update rmsalerep_new set incomef = incomef + @charge where code = @code and gkey = @gkey and hall = @hall

	-- DayUse��������
	if @rmposted = 'F' and @mode like 'N%'
		select @mode = 'D' + substring(@mode, 2, 9)
	else if @rmposted = 'F' and @mode like 'P%'
		select @mode = 'd' + substring(@mode, 2, 9)

	-- ����ֵ��˼�����Ƿ��� @mode, ���� substring(@mode,2,5) ?
	if @day_use_in='F'
		begin
		if substring(@mode,2,5) <> '' and @quantity !=  0 and @pccode<>@pcaddbed and @class<>'C' 
			begin
			if not exists(select 1 from #roomno where roomno = substring(@mode,2,5))
				insert #roomno select substring(@mode,2,5),'',null,null,0
			else
				select @quantity = 0
			end
		else if @pccode <> @pcaddbed
			select @quantity = 0
		end
	else
		begin
			if substring(@mode,2,5) <> '' and @quantity !=  0 and @pccode<>@pcaddbed
				begin
				if not exists(select 1 from #roomno where roomno = substring(@mode,2,5))
					begin
					--�÷����״γ���
					insert #roomno select substring(@mode,2,5),@accnt,@arr,@dep,@quantity
					end
				else if  not exists(select 1 from #roomno where roomno = substring(@mode,2,5) and ((@arr >= arr and @arr < dep) or (@dep > arr and @dep <= dep) or (@arr <= arr and @dep >= dep)))
					begin
					--�÷����ѳ���,ʱ��������ص�
					insert #roomno select substring(@mode,2,5),@accnt,@arr,@dep,@quantity
					end
				else 
					begin
					--�÷����ѳ���,ʱ����ص����Ҳ�ѳ���
					if  not exists(select 1 from #roomno where roomno = substring(@mode,2,5) and accnt = @accnt)
					--�÷�����@accnt�״γ���
					insert #roomno select substring(@mode,2,5),@accnt,@arr,@dep,@quantity
					else
					--�÷�����@accnt�ٴγ���
					update #roomno set rm = @quantity + rm where roomno = substring(@mode,2,5) and accnt = @accnt
					declare @tmp_quantity_hry1 money,@tmp_quantity_hry2 money
					select @tmp_quantity_hry1  = isnull(max(rm),0) from #roomno where roomno = substring(@mode,2,5) and ((@arr >= arr and @arr < dep) or (@dep > arr and @dep <= dep) or (@arr <= arr and @dep >= dep)) and accnt <> @accnt
					select @tmp_quantity_hry2  = rm - @quantity from #roomno where roomno = substring(@mode,2,5) and accnt = @accnt
					if @tmp_quantity_hry2 < @tmp_quantity_hry1
						begin
						select @quantity = @tmp_quantity_hry2  - @tmp_quantity_hry1 + @quantity
						if @quantity < 0
							 select @quantity = 0
						end
					end
//				if not exists(select 1 from #roomno where roomno = substring(@mode,2,5) and arr = @arr and dep = @dep and accnt = @accnt)
//					begin
//					select @tmp_quantity = @quantity , @tmp_quantity2 = @quantity
//					if exists (select 1 from #roomno where roomno = substring(@mode,2,5) )
//						select @quantity = 0 from #roomno where roomno = substring(@mode,2,5) and ((@arr >= arr and @arr < dep) or (@dep > arr and @dep <= dep))
//								 and @tmp_quantity <= (select max(rm) from #roomno where roomno = substring(@mode,2,5) ) //and master = @master and accnt <> @accnt
//					select @tmp_quantity = (@quantity
//												- isnull((select max(rm) from #roomno where roomno = substring(@mode,2,5) and accnt <> @accnt and ((@arr >= arr and @arr < dep) or (@dep > arr and @dep <= dep)) ),0))
//					if @quantity > 0 and @tmp_quantity < @quantity
//						select @quantity = @tmp_quantity
//					insert #roomno select substring(@mode,2,5),@accnt,@arr,@dep,@tmp_quantity2
//					end
//				else
//					begin
//					select @tmp_quantity = @quantity
//					update #roomno set rm = @tmp_quantity + rm where roomno = substring(@mode,2,5) and arr = @arr and dep = @dep and accnt = @accnt
//					select @quantity = 0 from #roomno where roomno = substring(@mode,2,5) and accnt = @accnt and 
//							rm <= (select max(rm) from #roomno where roomno = substring(@mode,2,5) and accnt <> @accnt and ((@arr >= arr and @arr < dep) or (@dep > arr and @dep <= dep)) )
//					select @tmp_quantity = (isnull((select max(rm) from #roomno where roomno = substring(@mode,2,5) and accnt = @accnt and arr = @arr and dep = @dep ),0)
//												- isnull((select max(rm) from #roomno where roomno = substring(@mode,2,5) and accnt <> @accnt and ((@arr >= arr and @arr < dep) or (@dep > arr and @dep <= dep)) ),0))
//					if @quantity > 0 and @tmp_quantity < @quantity
//						select @quantity = @tmp_quantity
//					end
				end
			else
				select @quantity = 0
		end


		
	-- ����ֵ��˼�����Ƿ��� @mode, ���� substring(@mode,2,5) ?  ���������ʵĲ�����
//	if @day_use_in='F'
//		begin
//		if substring(@mode,2,5) <> '' and @quantity !=  0 and @pccode<>@pcaddbed and @class<>'C'
//			begin
//			if not exists(select 1 from #roomno where rtrim(roomno) =  @roomno )//rtrim( substring(@mode,2,5) ) ) 
//				insert #roomno select  rtrim( substring(@mode,2,5) ) ,'','',0
//			else
//				begin
//				select @quantity = 0
//				end
//			end
//		else if @pccode <> @pcaddbed
//			select @quantity = 0
//		end
//	else
//		begin
//		if substring(@mode,2,5) <> '' and @quantity !=  0 and @pccode<>@pcaddbed and @class<>'C'
//			begin
//			if not exists(select 1 from #roomno where rtrim(roomno) =  rtrim( substring(@mode,2,5) )  and master = @master and accnt=@accnt)
//				begin
//				insert #roomno select  rtrim( substring(@mode,2,5) ) ,@accnt,@master,@quantity
//				select @quantity = 0 from #roomno where rtrim(roomno) =  rtrim( substring(@mode,2,5) )  and master = @master and accnt = @accnt and rm <= (select max(rm) from #roomno where rtrim(roomno) =  rtrim( substring(@mode,2,5) )  and master = @master and accnt <> @accnt)
//				end
//			else
//				begin
//				update #roomno set rm = @quantity + rm where rtrim(roomno) =  rtrim( substring(@mode,2,5) )  and master = @master and accnt = @accnt
//				select @quantity = 0 from #roomno where rtrim(roomno) =  rtrim( substring(@mode,2,5) )  and master = @master and accnt = @accnt and rm <= (select max(rm) from #roomno where rtrim(roomno) =  rtrim( substring(@mode,2,5) )  and master = @master and accnt <> @accnt)
//				end
//			end
//		else if @pccode <> @pcaddbed
//			select @quantity = 0
//		end



	select @reserved = 0, @walk_in = 0 
	if @quantity != 0 or @addquantity <> 0
		begin
		if exists (select 1 from master_till where accnt = @accnt and substring(extra, 9, 1) = '1')
			select @reserved = 0, @walk_in = @quantity
		else
			select @reserved = @quantity, @walk_in = 0

		if @pccode = @pcaddbed  -- �Ӵ�  @servcode = 'C'
			begin
			update rmsalerep_new set ext = ext + @addquantity where rtrim(code) = rtrim(@code) and gkey = @gkey and hall = @hall
			end
		else if exists(select 1 from mktcode where flag='COM' and code = @market)
			update rmsalerep_new set ent = ent + @quantity where code = @code and gkey = @gkey and hall = @hall
		else if exists(select 1 from mktcode where flag='HSE' and code = @market)
			update rmsalerep_new set htl = htl + @quantity where code = @code and gkey = @gkey and hall = @hall

		if @class = 'F' and @groupno = ''
			begin
			if exists(select 1 from mktcode where flag='LON' and code = @market)   -- ����
				update rmsalerep_new set soldl = soldl + @quantity where code = @code and gkey = @gkey and hall = @hall
			else if not exists(select 1 from mktcode where flag='HSE' and code = @market)	-- ������
				update rmsalerep_new set soldf = soldf + @quantity, soldf_r = soldf_r + @reserved, soldf_w = soldf_w + @walk_in
					where code = @code and gkey = @gkey and hall = @hall
			end
		else if (@class = 'M' or substring(@groupno, 1, 1) = 'M') and not exists(select 1 from mktcode where flag='HSE' and code = @market)
			update rmsalerep_new set soldc = soldc + @quantity, soldc_r = soldc_r + @reserved, soldc_w = soldc_w + @walk_in
				where code = @code and gkey = @gkey and hall = @hall
		else if (@class = 'G' or substring(@groupno, 1, 1) = 'G') and not exists(select 1 from mktcode where flag='HSE' and code = @market)
			update rmsalerep_new set soldg = soldg + @quantity, soldg_r = soldg_r + @reserved, soldg_w = soldg_w + @walk_in
				where code = @code and gkey = @gkey and hall = @hall
		else
				update rmsalerep_new set soldf = soldf + @quantity, soldf_r = soldf_r + @reserved, soldf_w = soldf_w + @walk_in
					where code = @code and gkey = @gkey and hall = @hall
		end

	fetch c_gltemp into @pccode, @charge, @tag, @mode, @oroomno, @accnt, @quantity, @market, @rmposted ,@master,@accntof
	end
close c_gltemp
deallocate cursor c_gltemp


----------------------------------------
--  ����ͳ����Ϣ	guest count
----------------------------------------
select @roomno = null
declare c_guest cursor for select a.accnt, a.roomno, a.bdate, a.extra, a.groupno, a.class, b.code, a.gstno
	from master_till a, mktcode b where a.sta = 'I' and a.class = 'F' and a.market *=  b.code
	order by a.roomno
open c_guest
fetch c_guest into @maccnt, @oroomno, @arr, @extra, @groupno, @class, @market, @gstno
while @@sqlstatus = 0
	begin
	select  @oroomno  = ltrim(rtrim(@oroomno))
	exec p_gds_get_rm_code @oroomno, @gkey, @hall out, @code out, @name out, @ret out, @msg out
	if @ret <> 0
		begin
		close c_guest
		deallocate cursor c_guest
		return 1
		end

	if @gst_calmode <> '0'
		select @gstno = 1

	if @class = 'F' and @groupno = ''
		begin
		if exists(select 1 from mktcode where flag='LON' and code = @market)
			update rmsalerep_new set gstl = gstl + @gstno where code = @code and gkey = @gkey and hall = @hall

		else if not exists(select 1 from mktcode where flag='HSE' and code = @market)
			update rmsalerep_new set gstf = gstf + @gstno where code = @code and gkey = @gkey and hall = @hall
		end
	else if @class = 'M' or substring(@groupno, 1, 1) = 'M'
		update rmsalerep_new set gstc = gstc + @gstno where code = @code and gkey = @gkey and hall = @hall
	else if @class = 'G' or substring(@groupno, 1, 1) = 'G'
		update rmsalerep_new set gstg = gstg + @gstno where code = @code and gkey = @gkey and hall = @hall
	else
		update rmsalerep_new set gstf = gstf + @gstno where code = @code and gkey = @gkey and hall = @hall

	if rtrim(@oroomno) !=  rtrim(@roomno)
		begin
		if @arr = @bdate
			begin
			if substring(@extra, 9, 1) = '1'
				select @reserved = 0, @walk_in = @gstno
			else
				select @reserved = @gstno, @walk_in = 0
			if @class = 'F' and @groupno = ''
				begin

				if exists(select 1 from mktcode where flag='LON' and code = @market)
					update rmsalerep_new set gstl = gstl + @gstno where code = @code and gkey = @gkey and hall = @hall

				else if not exists(select 1 from mktcode where flag='HSE' and code = @market)
					update rmsalerep_new set arrf = arrf + @gstno, arrf_r = arrf_r + @reserved, arrf_w = arrf_w + @walk_in
						where code = @code and gkey = @gkey and hall = @hall
				end
			else if @class = 'M' or substring(@groupno, 1, 1) = 'M'
				update rmsalerep_new set arrc = arrc + @gstno, arrc_r = arrc_r + @reserved, arrc_w = arrc_w + @walk_in
					where code = @code and gkey = @gkey and hall = @hall
			else if @class = 'G' or substring(@groupno, 1, 1) = 'G'
				update rmsalerep_new set arrg = arrg + @gstno, arrg_r = arrg_r + @reserved, arrg_w = arrg_w + @walk_in
					where code = @code and gkey = @gkey and hall = @hall
			else
				update rmsalerep_new set arrf = arrf + @gstno, arrf_r = arrf_r + @reserved, arrf_w = arrf_w + @walk_in
						where code = @code and gkey = @gkey and hall = @hall
			end
		select @roomno = @oroomno
		end
	fetch c_guest into @maccnt, @oroomno, @arr, @extra, @groupno, @class, @market, @gstno
	end
close c_guest
deallocate cursor c_guest

--------------------------------------------------------------------------------
--  insert summary value for quick and frequent retrieval
--------------------------------------------------------------------------------
insert rmsalerep_new
	select @bfdate, @gkey, '{', '{{{', '��  ��',
		isnull(sum(ttl),0), isnull(sum(mnt),0),isnull(sum(os),0), isnull(sum(htl),0), isnull(sum(avl),0), isnull(sum(vac),0),
		isnull(sum(soldf),0), isnull(sum(soldg),0), isnull(sum(soldc),0), isnull(sum(soldl),0), isnull(sum(ent),0), isnull(sum(ext),0),
		isnull(sum(incomef),0), isnull(sum(incomeg),0), isnull(sum(incomec),0), isnull(sum(incomel),0),
		isnull(sum(gstf),0), isnull(sum(gstg),0), isnull(sum(gstc),0), isnull(sum(gstl),0),
		isnull(sum(soldf_r),0), isnull(sum(soldf_w),0), isnull(sum(soldg_r),0), isnull(sum(soldg_w),0), isnull(sum(soldc_r),0), isnull(sum(soldc_w),0),
		isnull(sum(arrf),0), isnull(sum(arrg),0), isnull(sum(arrc),0), isnull(sum(arrl),0),
		isnull(sum(arrf_r),0), isnull(sum(arrf_w),0), isnull(sum(arrg_r),0), isnull(sum(arrg_w),0), isnull(sum(arrc_r),0), isnull(sum(arrc_w),0)
	from rmsalerep_new where gkey = @gkey

update rmsalerep_new set avl = ttl - htl - mnt where gkey = @gkey -- 
update rmsalerep_new set descript = '�ֹ�����' where code = 'ZZZ' and gkey = @gkey
update rmsalerep_new set date = @bdate where gkey = @gkey

begin tran
delete yrmsalerep_new where date = @bdate and gkey = @gkey
                                                                               
insert yrmsalerep_new select * from rmsalerep_new where gkey = @gkey
commit tran

return 0


;

// -----------------------------------------------------------------------------
// ��ӡ��ʱ�� 
// -----------------------------------------------------------------------------
if exists (select * from sysobjects where name ='rmsalerep_prn' and type ='U')
   drop table rmsalerep_prn;
create table rmsalerep_prn
(
   pc_id     char(4)									not null,
   modu_id   char(2)									not null,
   hall      char(1) 								null,
   code      char(5)  								not null,
	sequence	 int						default 0	not null,
   descript  char(30) 								not null,
   ttl       float                default 0 not null,  --  �ܷ��� 
   mnt       float                default 0 not null,  --  ά�޷� 
	os			 float					default 0 not null,  --   ���� 
   htl       float                default 0 not null,  --  ���÷� 
   avl       float                default 0 not null,  --  ���۷� 
   vac       float                default 0 not null,  --  �շ�   
   soldf     float                default 0 not null,  --  ɢ��   
   soldg     float                default 0 not null,  --  �Ŷ�   
   soldc     float                default 0 not null,  --  ����   
   soldl     float                default 0 not null,  --  ��ס   
   ent       float                default 0 not null,  --  ������ѷ��� 
   ext       float                default 0 not null,  --  �Ӵ�   
   incomef   money  		default 0 not null,          --  ɢ������ 
   incomeg   money  		default 0 not null,          --  �Ŷ����� 
   incomec   money  		default 0 not null,          --  �������� 
   incomel   money  		default 0 not null,          --  ��ס���� 
   gstf      int    		default 0 not null,          --  ɢ������ 
   gstg      int    		default 0 not null,          --  �Ŷ����� 
   gstc      int    		default 0 not null,          --  �������� 
   gstl      int    		default 0 not null,          --  ��ס���� 
)
exec sp_primarykey rmsalerep_prn,pc_id,modu_id,hall,code
create unique index index1 on rmsalerep_prn(pc_id,modu_id,hall,code)
;

//-------------------------------------------------------------------------------------
//		��ӡ����֮һ���������ݽ��
//-------------------------------------------------------------------------------------
if exists (select * from sysobjects where name ='p_gds_audit_prmsale_new' and type ='P')
   drop proc p_gds_audit_prmsale_new;
create proc p_gds_audit_prmsale_new
   @pc_id   char(4),
   @modu_id char(2),
   @pmode   char(1),  --  'L'��¥��,'T'������ 'H' ¥��  --------> ��Сд������ 
   @pmark   char(2),  --  'D',ĳ��,'M',ĳ�����ۼ� 
   @beg_    datetime, --  ���� 
   @end_    datetime, --  Ԥ�������䱨�� 
   @langid  integer   --  ����
as

declare
   @monthbeg  datetime,
   @isfstday  char(1),
   @isyfstday char(1)
delete rmsalerep_prn where pc_id=@pc_id
select @monthbeg = @beg_,@isfstday='F'
if @pmark='D'
   begin
   if @pmode = 'L'
      begin
      insert rmsalerep_prn (pc_id,modu_id,hall,code,descript,ttl,mnt,os,htl,avl,vac,soldf,soldg,soldc,soldl,ent,ext,incomef,incomeg,incomec,incomel,gstf,gstg,gstc,gstl)
      select @pc_id,@modu_id,hall,code,descript,ttl,mnt,os,htl,avl,vac,soldf,soldg,soldc,soldl,ent,ext,incomef,incomeg,incomec,incomel,gstf,gstg,gstc,gstl
             from yrmsalerep_new where date = @beg_ and code <> '{{{' and gkey = 'f'
      end
   else if @pmode = 'l'
      begin
      insert rmsalerep_prn (pc_id,modu_id,code,descript,ttl,mnt,os,htl,avl,vac,soldf,soldg,soldc,soldl,ent,ext,incomef,incomeg,incomec,incomel,gstf,gstg,gstc,gstl)
      select @pc_id,@modu_id,code,descript,sum(ttl),sum(mnt),sum(os),sum(htl),sum(avl),sum(vac),sum(soldf),sum(soldg),sum(soldc),
                        sum(soldl),sum(ent),sum(ext),sum(incomef),sum(incomeg),sum(incomec),sum(incomel),
                        sum(gstf),sum(gstg),sum(gstc),sum(gstl)
             from yrmsalerep_new where date = @beg_ and code <> '{{{' and gkey = 'f'
					group by code, descript
      end
   else if @pmode = 'T'
      begin
      insert rmsalerep_prn (pc_id,modu_id,hall,code,descript,ttl,mnt,os,htl,avl,vac,soldf,soldg,soldc,soldl,ent,ext,incomef,incomeg,incomec,incomel,gstf,gstg,gstc,gstl)
      select @pc_id,@modu_id,hall,code,descript,ttl,mnt,os,htl,avl,vac,soldf,soldg,soldc,soldl,ent,ext,incomef,incomeg,incomec,incomel,gstf,gstg,gstc,gstl
             from yrmsalerep_new where date = @beg_ and code <> '{{{'  and gkey = 't'
      end
   else if @pmode = 't'
      begin
      insert rmsalerep_prn (pc_id,modu_id,code,descript,ttl,mnt,os,htl,avl,vac,soldf,soldg,soldc,soldl,ent,ext,incomef,incomeg,incomec,incomel,gstf,gstg,gstc,gstl)
      select @pc_id,@modu_id,code,descript,sum(ttl),sum(mnt),sum(os),sum(htl),sum(avl),sum(vac),sum(soldf),sum(soldg),sum(soldc),
                        sum(soldl),sum(ent),sum(ext),sum(incomef),sum(incomeg),sum(incomec),sum(incomel),
                        sum(gstf),sum(gstg),sum(gstc),sum(gstl)
             from yrmsalerep_new where date = @beg_ and code <> '{{{'  and gkey = 't'
				group by code, descript
      end
   else
      begin
      insert rmsalerep_prn (pc_id,modu_id,code,descript,ttl,mnt,os,htl,avl,vac,soldf,soldg,soldc,soldl,ent,ext,incomef,incomeg,incomec,incomel,gstf,gstg,gstc,gstl)
      select @pc_id,@modu_id,code,descript,ttl,mnt,os,htl,avl,vac,soldf,soldg,soldc,soldl,ent,ext,incomef,incomeg,incomec,incomel,gstf,gstg,gstc,gstl
             from yrmsalerep_new where date = @beg_ and code <> '{{{'  and gkey = 'h'
      end
   end
else
   begin
   if @pmark='W'
      begin
      while datepart(dw,@monthbeg) <> 2
         select @monthbeg=dateadd(dd,-1,@monthbeg)
      end
   else if @pmark = 'M'
      begin
      exec p_hry_audit_fstday @monthbeg,@isfstday out,@isyfstday out
      while @isfstday = 'F'
         begin
         select @monthbeg=dateadd(dd,-1,@monthbeg)
         exec p_hry_audit_fstday @monthbeg,@isfstday out,@isyfstday out
         end
      end
	else if @pmark = 'S'
		begin
		select @monthbeg = @beg_
		select @beg_ = @end_
		end
	else
      begin
      exec p_hry_audit_fstday @monthbeg,@isfstday out,@isyfstday out
      while @isyfstday = 'F'
         begin
         select @monthbeg=dateadd(dd,-1,@monthbeg)
         exec p_hry_audit_fstday @monthbeg,@isfstday out,@isyfstday out
         end
      end

   if @pmode = 'L'
      begin
      insert rmsalerep_prn (pc_id,modu_id,hall,code,descript,ttl,mnt,os,htl,avl,vac,soldf,soldg,soldc,soldl,ent,ext,incomef,incomeg,incomec,incomel,gstf,gstg,gstc,gstl)
      select @pc_id,@modu_id,hall,code,descript,sum(ttl),sum(mnt),sum(os),sum(htl),sum(avl),sum(vac),sum(soldf),sum(soldg),sum(soldc),
                        sum(soldl),sum(ent),sum(ext),sum(incomef),sum(incomeg),sum(incomec),sum(incomel),
                        sum(gstf),sum(gstg),sum(gstc),sum(gstl)
             from yrmsalerep_new
             where date >= @monthbeg and date <= @beg_  and code <> '{{{' and gkey = 'f'
             group by hall,code,descript
      end
   else if @pmode = 'l'
      begin
      insert rmsalerep_prn (pc_id,modu_id,code,descript,ttl,mnt,os,htl,avl,vac,soldf,soldg,soldc,soldl,ent,ext,incomef,incomeg,incomec,incomel,gstf,gstg,gstc,gstl)
      select @pc_id,@modu_id,code,descript,sum(ttl),sum(mnt),sum(os),sum(htl),sum(avl),sum(vac),sum(soldf),sum(soldg),sum(soldc),
                        sum(soldl),sum(ent),sum(ext),sum(incomef),sum(incomeg),sum(incomec),sum(incomel),
                        sum(gstf),sum(gstg),sum(gstc),sum(gstl)
             from yrmsalerep_new
             where date >= @monthbeg and date <= @beg_  and code <> '{{{' and gkey = 'f'
             group by code,descript
      end
   else if @pmode = 'T'
      begin
      insert rmsalerep_prn (pc_id,modu_id,hall,code,descript,ttl,mnt,os,htl,avl,vac,soldf,soldg,soldc,soldl,ent,ext,incomef,incomeg,incomec,incomel,gstf,gstg,gstc,gstl)
      select @pc_id,@modu_id,hall,code,descript,sum(ttl),sum(mnt),sum(os),sum(htl),sum(avl),sum(vac),sum(soldf),sum(soldg),sum(soldc),
                        sum(soldl),sum(ent),sum(ext),sum(incomef),sum(incomeg),sum(incomec),sum(incomel),
                        sum(gstf),sum(gstg),sum(gstc),sum(gstl)
             from yrmsalerep_new
             where date >= @monthbeg and date <= @beg_ and code <> '{{{' and gkey = 't'
             group by hall,code,descript
      end
   else if @pmode = 't'
      begin
      insert rmsalerep_prn (pc_id,modu_id,code,descript,ttl,mnt,os,htl,avl,vac,soldf,soldg,soldc,soldl,ent,ext,incomef,incomeg,incomec,incomel,gstf,gstg,gstc,gstl)
      select @pc_id,@modu_id,code,descript,sum(ttl),sum(mnt),sum(os),sum(htl),sum(avl),sum(vac),sum(soldf),sum(soldg),sum(soldc),
                        sum(soldl),sum(ent),sum(ext),sum(incomef),sum(incomeg),sum(incomec),sum(incomel),
                        sum(gstf),sum(gstg),sum(gstc),sum(gstl)
             from yrmsalerep_new
             where date >= @monthbeg and date <= @beg_ and code <> '{{{' and gkey = 't'
             group by code,descript
      end
   else
      begin
      insert rmsalerep_prn (pc_id,modu_id,code,descript,ttl,mnt,os,htl,avl,vac,soldf,soldg,soldc,soldl,ent,ext,incomef,incomeg,incomec,incomel,gstf,gstg,gstc,gstl)
      select @pc_id,@modu_id,code,descript,sum(ttl),sum(mnt),sum(os),sum(htl),sum(avl),sum(vac),sum(soldf),sum(soldg),sum(soldc),
                        sum(soldl),sum(ent),sum(ext),sum(incomef),sum(incomeg),sum(incomec),sum(incomel),
                        sum(gstf),sum(gstg),sum(gstc),sum(gstl)
             from yrmsalerep_new
             where date >= @monthbeg and date <= @beg_ and code <> '{{{' and gkey = 'h'
             group by code,descript
      end
   end

-- ��������
if @langid <> 0
	 begin
      update rmsalerep_prn set descript =  a.descript1 from typim   a where a.type = rmsalerep_prn.code and rmsalerep_prn.code in (select type from typim )
      update rmsalerep_prn set descript =  a.descript1 from flrcode a where a.code = rmsalerep_prn.code and rmsalerep_prn.code in (select code from flrcode)
      update rmsalerep_prn set descript =  'Other'  where code='ZZZ'
	 end

-- ��������
if charindex(@pmode,'lL') > 0
	update rmsalerep_prn set sequence=a.sequence from flrcode a
		where rmsalerep_prn.code=a.code and rmsalerep_prn.modu_id=@modu_id and rmsalerep_prn.pc_id=@pc_id
else if charindex(@pmode,'tT') > 0
	update rmsalerep_prn set sequence=a.sequence from typim a
		where rmsalerep_prn.code=a.type and rmsalerep_prn.modu_id=@modu_id and rmsalerep_prn.pc_id=@pc_id
else
	update rmsalerep_prn set sequence=a.sequence from basecode a
		where rmsalerep_prn.code=a.code and a.cat='hall' and rmsalerep_prn.modu_id=@modu_id and rmsalerep_prn.pc_id=@pc_id

update rmsalerep_prn set sequence=9999 where modu_id=@modu_id and pc_id=@pc_id and code='ZZZ'

return 0
;
   

   


//-------------------------------------------------------------------------------------
//		��ӡ����֮����ֱ��������ݽ��
//-------------------------------------------------------------------------------------
if exists (select * from sysobjects where name ='p_gds_audit_prmsale_new1' and type ='P')
   drop proc p_gds_audit_prmsale_new1;
create proc p_gds_audit_prmsale_new1
   @pc_id   char(4),
   @modu_id char(2),
   @pmode   char(1),  --  'L'��¥��,'T'������ 'H' ¥��
   @pmark   char(2),  --  'D',ĳ��,'M',ĳ�����ۼ� 
   @beg_    datetime, --  ���� 
   @end_    datetime  --  Ԥ�������䱨�� 
as

exec p_gds_audit_prmsale_new @pc_id, @modu_id, @pmode, @pmark, @beg_, @end_
if charindex(@pmode, 'T,L') > 0 
	select hall,code,descript,ttl,mnt,htl,avl,vac,numb10_1  =  soldf+soldg+soldc+soldl,soldf,soldg,soldc,soldl,ent,ext,numb10_2  =  incomef+incomeg+incomec+incomel,incomef,incomeg,incomec,incomel,numb10_3  =  gstf+gstg+gstc+gstl,gstf,gstg,gstc,gstl
		from rmsalerep_prn where pc_id = @pc_id and modu_id = @modu_id order by pc_id,modu_id,sequence,hall,code
else
	select code,descript,ttl,mnt,htl,avl,vac,numb10_1  =  soldf+soldg+soldc+soldl,soldf,soldg,soldc,soldl,ent,ext,numb10_2  =  incomef+incomeg+incomec+incomel,incomef,incomeg,incomec,incomel,numb10_3  =  gstf+gstg+gstc+gstl,gstf,gstg,gstc,gstl
		from rmsalerep_prn where pc_id = @pc_id and modu_id = @modu_id order by pc_id,modu_id,sequence,code

return 0
;