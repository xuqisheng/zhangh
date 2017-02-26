
if  exists(select * from sysobjects where name = "p_cq_audit_create_cms")
	drop  proc p_cq_audit_create_cms;
create proc p_cq_audit_create_cms

	@pc_id			char(4)
as
---------------------------------------------------------
-- Ӷ����� = ���� cms_rec
--
-- ����ʱ����ҹ������У������Ҫ���Ͽۼ����ѣ���Ҫ����ҹ��ǰ
--
---------------------------------------------------------
declare
	@bdate			datetime,
	@bfdate			datetime,
	@duringaudit	char(1),
	@accnt			char(10),
	@cmscode			char(10),
	@cms_code		char(10),
	@upmode			char(1),
	@rmtype_s		char(1),
	@pri				integer,
	@cmscode_detail char(10),
	@unit				 char(1),
	@type				 char(1),
	@rm_type			 char(5),
	@rmtype			 varchar(255),   --  varchar(30)  xia 
	@amount			 money,
	@dayuse			 char(2),
	@uproom1			 money, 		@upamount1      money,
	@uproom2			 money, 		@upamount2      money,
	@uproom3			 money, 		@upamount3      money,
	@uproom4			 money, 		@upamount4     money,
	@uproom5			 money, 		@upamount5      money,
	@uproom6			 money, 		@upamount6      money,
	@uproom7			 money, 		@upamount7      money,
	@upamount       money,
	@week           varchar(30),
	@weeknow    	 char(1),
	@rmmode         char(8),
	@nights		    integer,
	@datecond		 varchar(80),
	@ret        	 integer,
	@id				 int

select @ret = 0
select @duringaudit = audit from gate
if exists(select 1 from gate where audit = 'T')
	select @bdate = bdate from sysdata
else
	select @bdate = bdate from accthead

-- cms_rec.type
-- update cms_rec set type = a.type from rmsta a where cms_rec.bdate = @bdate and cms_rec.roomno=a.roomno
update cms_rec set type = a.type from rmsta a 
	where cms_rec.sta='I' and cms_rec.roomno=a.roomno and cms_rec.type='' and cms_rec.isaudit='F' 
update cms_rec set sta='U' where type='' and isaudit='F' and sta='I'  -- ����Ϊ��Ч

-- cms_rec.belong
update cms_rec set belong=source where belong='' and source<>'' and sta='I' and isaudit='F' 
update cms_rec set belong=agent where belong='' and agent<>'' and sta='I'  and isaudit='F' 
update cms_rec set belong=cusno where belong='' and cusno<>'' and sta='I'  and isaudit='F' 
update cms_rec set sta='U' where belong=''  and isaudit='F' and sta='I' -- ����Ϊ��Ч

exec p_zk_audit_cms_combine @pc_id --�ϲ�ͬ���䡢ͬ��Ӷ��λ��ͬӶ����Ŀ��˽��Խ����Ӷ�׼�����
exec p_zk_cms_update @bdate,@pc_id --���㾻�ۡ����ۡ������

update cms_rec set sta='U', cmsdetail='----------' 
			where sta = 'I' and (cmsdetail='' or cmsdetail is null) and bdate < @bdate
				 and isaudit='F'		--�������մ��������Ч��¼

-- ��ʼ���� cmsdetail='' ��ʾ��û�п�ʼ����.  �����ر�ȥ�� bdate ����������
declare c_cms_rec cursor for select id,belong,cmscode,type 
	from cms_rec where sta = 'I' and (cmsdetail='' or cmsdetail is null)	and isaudit='F' order by id
open c_cms_rec
fetch c_cms_rec into @id,@accnt,@cmscode,@rm_type
while @@sqlstatus = 0
begin
	--upmodeΪ����ʱ�����ƣ�Y-�꣬M-�£�J-����A-���ޡ�rmtype_sΪ�����Ƿ�ַ���
	select @upmode = upmode , @rmtype_s = rmtype_s from cmscode where code = @cmscode
	select @weeknow = convert(char(1), datepart(weekday, @bdate)-1)
	if @weeknow = '0'
		select @weeknow = '7'
	exec p_cq_cmscode_judge	@rm_type,@cmscode,@weeknow,@bdate,@cms_code out

	if @cms_code <> ''
	begin
		select @unit = unit,@type=type,@rmtype=rmtype,@amount=amount,@dayuse=dayuse,
					@uproom1=uproom1,@upamount1=upamount1,@uproom2=uproom2,@upamount2=upamount2,
					@uproom3=uproom3,@upamount3=upamount3,@uproom4=uproom4,@upamount4=upamount4,
					@uproom5=uproom5,@upamount5=upamount5,@uproom6=uproom6,@upamount6=upamount6,
					@uproom7=uproom7,@datecond = datecond 
			from cms_defitem where no=@cms_code

			if @uproom1=0		--�޽��ݽ���
				exec @ret = p_cq_cmscode_get_none @accnt,@cmscode,@cms_code,@bdate
			else 					--�н��ݽ���
				exec @ret = p_cq_cmscode_get_add	@upmode,	@rmtype_s,@accnt,@cmscode,@cms_code,@rm_type,@bdate,@id
	end
	else
		update cms_rec set sta='U', cmsdetail='----------' 
			where sta = 'I' and (cmsdetail='' or cmsdetail is null) and belong=@accnt and cmscode=@cmscode and type=@rm_type
				 and isaudit='F'

	fetch c_cms_rec into @id,@accnt,@cmscode,@rm_type
end
close c_cms_rec
deallocate cursor c_cms_rec

select @ret
return 0;
