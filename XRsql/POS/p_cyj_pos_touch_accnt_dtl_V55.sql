if exists ( select * from sysobjects where name = "p_cyj_pos_touch_accnt_dtl" and type ="P")
   drop proc p_cyj_pos_touch_accnt_dtl;
create proc p_cyj_pos_touch_accnt_dtl
	@accnt		char(10)					-- �ʺ�
as
-----------------------------------------------------------------------------------------------
--
--	������: ���˲�ѯ�ʺŴ���--�ʺ���ϸ����
--
-----------------------------------------------------------------------------------------------
declare 
	@roomno			char(6),
	@name1			char(30),
	@name2			char(30),
	@haccnt			char(10),
	@cusno			char(10),
	@cus				char(30),
	@paycode			char(10),
	@package			char(30),
	@ref				varchar(100),
	@arr				datetime,
	@dep				datetime,
	@limit			money,
	@charge			money,
	@credit			money,
	@accredit		money,
	@locksta			char(1),
	@lockref			char(12)

select @roomno = roomno,@cusno=cusno,@arr=arr,@dep=dep,@paycode=paycode,@limit=limit,@charge=rmb_db,@credit= depr_cr + addrmb, @ref=ref,@locksta =locksta from master where accnt =@accnt
if @@rowcount = 0 
	begin
	select @roomno = '',@cusno='',@arr=arr,@dep=dep,@paycode='',@limit=limit,@charge=rmb_db,@credit= depr_cr + addrmb, @ref=name,@locksta=locksta from grpmst where accnt =@accnt
	if @@rowcount = 0 
		select @roomno = '',@cusno='',@arr=arr,@dep=dep,@paycode='',@limit=limit,@charge=rmb_db,@credit= depr_cr + addrmb, @ref=name,@locksta=locksta from armst where accnt =@accnt
	end
select @name1=@ref
select @cusno=name from cusinf where no=@cusno
if @locksta = '0' 
	select @lockref ='���������'
else if @locksta = '1' 
	select @lockref ='�������'
else if @locksta = '2' 
	select @lockref ='�����������'
else
	select @lockref ='���������'



select ref1 = substring('����:  ' + @name1 + space(30), 1, 30) + space(2)
	+   substring('       '   + @name2 + space(30), 1, 30) + space(2)
	+ 	 substring('����:  ' + @roomno + space(30), 1, 30) + space(2)
	+ 	 substring('��λ:  ' + @cus + space(30), 1, 30) + space(2)
	+ 	 substring('����:  ' + @paycode + space(30), 1, 30) + space(2)
	+ 	 substring('����:  ' + convert(char(8), @arr, 11) + space(30), 1, 30) + space(2)
	+ 	 substring('����:  ' + convert(char(8), @dep, 11) + space(30), 1, 30) + space(2)
	+ 	 substring('���:  ' + convert(char(12), @credit-@charge) + space(30), 1, 30) + space(2),
		 ref2 = substring('Pack:  ' + @package + space(30), 1, 30) + space(2)
	+ 	 substring('����:  ' + @lockref + space(30), 1, 30) + space(2)
	+	 @ref

	
;



