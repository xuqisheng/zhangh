
IF OBJECT_ID('p_gds_vipcard_calc') IS NOT NULL
    DROP PROCEDURE p_gds_vipcard_calc
;
create proc p_gds_vipcard_calc
   @mode  		char(1),				--  + / -
   @no  			char(20),
   @calc  		char(10),
	@m1			money,
	@m2			money,
	@m3			money,
	@m4			money,
	@m5			money,
	@retmode		char(1) = 'S',
	@msg			varchar(60)	output,
	@m9			money			output
as
--------------------------------------------------------------------
--	vipcard ���ּ���
--------------------------------------------------------------------
declare		@ret  int

select @ret=0, @msg=''
select @no = isnull(rtrim(@no), ''), @calc = isnull(rtrim(@calc), ''), @mode = isnull(rtrim(@mode), '+')
select @m1=isnull(@m1, 0), @m2=isnull(@m2, 0), @m3=isnull(@m3, 0), @m4=isnull(@m4, 0), @m5=isnull(@m5, 0)

if @m1=0 and @m2=0 and @m3=0 and @m4=0 and @m5=0
begin
	select @ret=1, @msg='���ݲ�ȫ������'
	goto gout
end

if @mode = '+'    --- ���ּ���-> m1-5 = ����/�ͷ�/������
begin
	if @calc = '' and @no <> ''
	begin
		select @calc=b.calc from vipcard a, vipcard_type b where a.no=@no and a.type=b.code 
		if @@rowcount = 0 
			select @calc = '0'
	end
	if @calc = ''
		select @calc = '0'

	select @m9 = (select round((@m1 / step),2) * rate from vipdef1 where code=@calc and pccode='RM' and step<>0)
    +(select round((@m2 / step),2) * rate from vipdef1 where code=@calc and pccode='FB' and step<>0)
    +(select round((@m3 / step),2) * rate from vipdef1 where code=@calc and pccode='OT' and step<>0)
--	select @m9 = @m1+@m2+@m3+@m4+@m5
--	if @calc = '0'									--       ��ʱ����Ѽ��㷽��д����
--		select @m9 = round(@m9*1.2048,0)
--	else
--		select @m9 = round(@m9*1.4458,0)

end

else if @mode = '-'        --- �������� m1=���ѽ�� m2=�ɱ��� m3=�һ�����  
begin
	if @m1=0
	begin
		select @ret=1, @msg='������������ѽ��'
		goto gout
	end
	if @m3 = 0 
	begin
		select @m3 = convert(money, value) from sysoption where catalog = "vipcard" and item = "exchange_rate"
		if @@rowcount=0 or @m3 is null or @m3<=0 
			select @m3 = 1
	end 
	select @m9 = round(@m1 * @m3, 0)
	
end

gout:

if @retmode = 'S'
	select @ret, @msg, @m9
return @ret
;

