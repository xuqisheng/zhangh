if exists(select * from sysobjects where name = "p_gds_guest_del_flag_list")
	drop proc p_gds_guest_del_flag_list;
create proc p_gds_guest_del_flag_list
as
----------------------------------------------------------------------------------
--  ��Ҫɾ�������б�. ���� n ���Ҫɾ�� 
----------------------------------------------------------------------------------
declare		@parms		varchar(255),
				@bdate		datetime,
				@delay		int

-- parms
select @parms=null, @bdate=bdate1 from sysdata 
select @parms=rtrim(value) from sysoption where catalog='profile' and item='temp_delay'   -- ��Ҫɾ���ĵ�����ʱ�������� 
select @delay=convert(int, @parms)
if @delay is null or @delay<=0 
	select @delay = 0 

-- output 
if @delay > 0 
	select a.no,a.name,a.name2,a.class,a.keep,a.vip,a.ident,a.central,a.latency,a.street,a.street1,a.saleid,
				a.araccnt1,a.araccnt2,a.lv_date,a.crttime,a.i_times,a.i_days,a.rm,a.tl,a.changed,
				days=@delay-datediff(dd,b.bdate,@bdate) 
			from guest a, guest_del_flag b 
		where a.no=b.no order by days 
else  -- delay=0 ��ʾ��ɾ��
	select a.no,a.name,a.name2,a.class,a.keep,a.vip,a.ident,a.central,a.latency,a.street,a.street1,a.saleid,
				a.araccnt1,a.araccnt2,a.lv_date,a.crttime,a.i_times,a.i_days,a.rm,a.tl,a.changed,
				days=99999
			from guest a, guest_del_flag b 
		where a.no=b.no order by days 

;
