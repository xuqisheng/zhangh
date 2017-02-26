if exists (select * from sysobjects where name ='p_gds_nar_reb_from_apply' and type ='P')
	drop proc p_gds_nar_reb_from_apply;
create proc p_gds_nar_reb_from_apply
	@accnt			varchar(10)
as
------------------------------------------------------
-- ��ʼ������ = p_gds_nar_zip_mnt 

-- ���� ��AR ����ѹ���������������  simon 2008.3.15 
-- Ŀǰ���ֺ���������û�й��� 
-- ����������ar_apply �ؽ� ����� charge9, credit9 
--       ����ײ�ĺ�����һֱ���µ������棻�������϶��� 
--
-- Ŀǰ����Ե����ʻ����� 
-- modi 2008.12.31 
------------------------------------------------------
declare
	@pccode			char(10),
	@maccnt			char(10),
	@number			int,  
	@inumber			int,  
	@pnumber			int,  
	@amount			money,  
	@charge			money,  
	@credit			money,  
	@charge9			money,  
	@credit9			money,
	@loop				int 

--
delete gdsmsg 

-- 
if rtrim(@accnt) is null or rtrim(@accnt)='' or rtrim(@accnt)='%'
begin
	select '�����봦����ʺ�'
	return 
end

-- 
update ar_detail set charge9=0, credit9=0 where accnt=@accnt 
update har_detail set charge9=0, credit9=0 where accnt=@accnt 
update ar_account set charge9=0, credit9=0 where ar_accnt=@accnt 
update har_account set charge9=0, credit9=0 where ar_accnt=@accnt 

-- �跽 
declare c_d_apply cursor for select d_number, d_inumber, amount from ar_apply where d_accnt = @accnt and d_number>0 
open c_d_apply 
fetch c_d_apply into @number, @inumber, @amount  
while @@sqlstatus = 0 
begin 
	select @loop = 0, @pccode='', @charge=0, @credit=0 
	while @number > 0 
	begin
-- insert gdsmsg select convert(char(10),@number)+convert(char(10),@inumber)+convert(char(10),@loop)   -- ��¼���ٹ켣 
		select @loop = @loop + 1 
		if exists(select 1 from ar_detail where accnt=@accnt and number=@number)	
		begin
			update ar_detail set charge9 = charge9 + @amount where accnt=@accnt and number=@number 
			if exists(select 1 from ar_account where ar_accnt=@accnt and ar_number=@inumber and ar_inumber=@number) 
				update ar_account set charge9 = charge9 + @amount where ar_accnt=@accnt and ar_number=@inumber and ar_inumber=@number 
			else 
				insert gdsmsg select 'Error-d1: Num=' + convert(char(10),@inumber)+' iNum='+convert(char(10),@number)+' Amount='+convert(char(12),@amount)+' Loop='+convert(char(12),@loop)
			select @number = 0 -- ׷�ٵ���ǰ��¼���϶�������㣬����ֱ���˳��� 
		end 	
		else if exists(select 1 from har_detail where accnt=@accnt and number=@number)	
		begin			
			update har_detail set charge9 = charge9 + @amount where accnt=@accnt and number=@number 
			if exists(select 1 from har_account where ar_accnt=@accnt and ar_number=@inumber and ar_inumber=@number)
				update har_account set charge9 = charge9 + @amount where ar_accnt=@accnt and ar_number=@inumber and ar_inumber=@number 
			else 
				insert gdsmsg select 'Error-d2: Num=' + convert(char(10),@inumber)+' iNum='+convert(char(10),@number)+' Amount='+convert(char(12),@amount)+' Loop='+convert(char(12),@loop)

			-- �������� 
			select @pccode=pccode, @charge=charge, @credit=credit from har_account where ar_accnt=@accnt and ar_number=@inumber and ar_inumber=@number 
			select @number = pnumber from har_detail where accnt=@accnt and number=@number
			if exists(select 1 from har_detail where accnt=@accnt and number=@number)
			begin
				select @inumber=isnull((select min(ar_number) from har_account where ar_accnt=@accnt and ar_inumber=@number and pccode=@pccode and charge=@charge and credit=@credit), 0) 
				if @inumber = 0 
					select @inumber=isnull((select min(ar_number) from har_account where ar_accnt=@accnt and ar_inumber=@number and pccode=@pccode), 0) 
				if @inumber = 0 
				begin 	
					insert gdsmsg select 'Error-d3: Num=' + convert(char(10),@inumber)+' iNum='+convert(char(10),@number)+' Amount='+convert(char(12),@amount)+' Loop='+convert(char(12),@loop)
					select @number=0 
				end 	
			end 
			else if exists(select 1 from ar_detail where accnt=@accnt and number=@number)
			begin
				select @inumber=isnull((select min(ar_number) from ar_account where ar_accnt=@accnt and ar_inumber=@number and pccode=@pccode and charge=@charge and credit=@credit), 0) 
				if @inumber = 0 
					select @inumber=isnull((select min(ar_number) from ar_account where ar_accnt=@accnt and ar_inumber=@number and pccode=@pccode), 0) 
				if @inumber = 0 
				begin 	
					insert gdsmsg select 'Error-d4: Num=' + convert(char(10),@inumber)+' iNum='+convert(char(10),@number)+' Amount='+convert(char(12),@amount)+' Loop='+convert(char(12),@loop)
					select @number=0 
				end 	
			end 
			else
				select @number=0 
		end 	
		else
			select @number = 0 -- ׷�ٵ�ͷ�� 
	end 	

	fetch c_d_apply into @number, @inumber, @amount  
end 
close c_d_apply
deallocate cursor c_d_apply 

-- ���� 
declare c_c_apply cursor for select c_number, c_inumber, amount from ar_apply where c_accnt = @accnt and c_number>0 
open c_c_apply 
fetch c_c_apply into @number, @inumber, @amount  
while @@sqlstatus = 0 
begin 
	select @loop = 0, @pccode='', @charge=0, @credit=0 
	while @number > 0 
	begin
		select @loop = @loop + 1 
		if exists(select 1 from ar_detail where accnt=@accnt and number=@number)	
		begin
			update ar_detail set credit9 = credit9 + @amount where accnt=@accnt and number=@number 
			if exists(select 1 from ar_account where ar_accnt=@accnt and ar_number=@inumber and ar_inumber=@number) 
				update ar_account set credit9 = credit9 + @amount where ar_accnt=@accnt and ar_number=@inumber and ar_inumber=@number 
			else 
				insert gdsmsg select 'Error-c1: Num=' + convert(char(10),@inumber)+' iNum='+convert(char(10),@number)+' Amount='+convert(char(12),@amount)+' Loop='+convert(char(12),@loop)
			select @number = 0 -- ׷�ٵ���ǰ��¼���϶�������㣬����ֱ���˳��� 
		end 	
		else if exists(select 1 from har_detail where accnt=@accnt and number=@number)	
		begin			
			update har_detail set credit9 = credit9 + @amount where accnt=@accnt and number=@number 
			if exists(select 1 from har_account where ar_accnt=@accnt and ar_number=@inumber and ar_inumber=@number)
				update har_account set credit9 = credit9 + @amount where ar_accnt=@accnt and ar_number=@inumber and ar_inumber=@number 
			else 
				insert gdsmsg select 'Error-c2: Num=' + convert(char(10),@inumber)+' iNum='+convert(char(10),@number)+' Amount='+convert(char(12),@amount)+' Loop='+convert(char(12),@loop)

			-- �������� 
			select @pccode=pccode, @charge=charge, @credit=credit from har_account where ar_accnt=@accnt and ar_number=@inumber and ar_inumber=@number 
			select @number = pnumber from har_detail where accnt=@accnt and number=@number
			if exists(select 1 from har_detail where accnt=@accnt and number=@number)
			begin
				select @inumber=isnull((select min(ar_number) from har_account where ar_accnt=@accnt and ar_inumber=@number and pccode=@pccode and charge=@charge and credit=@credit), 0) 
				if @inumber = 0 
					select @inumber=isnull((select min(ar_number) from har_account where ar_accnt=@accnt and ar_inumber=@number and pccode=@pccode), 0) 
				if @inumber = 0 
				begin 	
					insert gdsmsg select 'Error-c3: Num=' + convert(char(10),@inumber)+' iNum='+convert(char(10),@number)+' Amount='+convert(char(12),@amount)+' Loop='+convert(char(12),@loop)
					select @number=0 
				end 	
			end 
			else if exists(select 1 from ar_detail where accnt=@accnt and number=@number)
			begin
				select @inumber=isnull((select min(ar_number) from ar_account where ar_accnt=@accnt and ar_inumber=@number and pccode=@pccode and charge=@charge and credit=@credit), 0) 
				if @inumber = 0 
					select @inumber=isnull((select min(ar_number) from ar_account where ar_accnt=@accnt and ar_inumber=@number and pccode=@pccode), 0) 
				if @inumber = 0 
				begin 	
					insert gdsmsg select 'Error-c4: Num=' + convert(char(10),@inumber)+' iNum='+convert(char(10),@number)+' Amount='+convert(char(12),@amount)+' Loop='+convert(char(12),@loop)
					select @number=0 
				end 	
			end 
			else
				select @number=0 
		end 	
		else
			select @number = 0 -- ׷�ٵ�ͷ�� 
	end 	

	fetch c_c_apply into @number, @inumber, @amount  
end 
close c_c_apply
deallocate cursor c_c_apply 

select * from gdsmsg 

return 0;

