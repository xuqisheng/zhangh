IF OBJECT_ID('dbo.p_gds_audit_package_hs') IS NOT NULL
    DROP PROCEDURE dbo.p_gds_audit_package_hs
;
create proc p_gds_audit_package_hs
	@pc_id				char(4),
	@shift				char(1),
	@empno				char(10),
	@retmode				char(1) = 'S',
	@msg					varchar(60) output
as
-----------------------------------------------------------------------------------
--	ҹ���������ʻ��еİ��ۣ��Զ����� profit, loss, Ȼ���Զ�ƽ��
--	yjw ���� 20070824
-----------------------------------------------------------------------------------
declare
			@ret			integer,
			@bdate		datetime,
			@code			char(4),
			@amount		money,
			@credit		money,
			@profit		char(5),
			@loss			char(5),
			@accnt		char(10),
			@roomno		char(5),
			@flag			varchar(10),
			@profit_amt	money,
			@loss_amt	money,
			@ref2			varchar(50),
			@mtmp			money,
         @quan       money,
         @pnumber    money,
         @charge     money,
			@copy 		money, 	-- package. quantity
			@price		money,
            @rule       char(10)

create table #package_tmp
(
	accnt			char(10)	not null,
	code       char(4)	not null,
   amount     money	default 0,		-- �ɱ�
   charge     money	default 0,		-- �ۼƳ���
   charge_td  money	default 0,		-- ���ճ���
   credit     money	default 0,		-- ��������
   posted_number money	default 0,
   tag        money	default 0,
   profit     money	default 0,
   loss       money	default 0
)

select @bdate=bdate1, @ret=0, @msg='' from sysdata

begin tran
save tran package_hs
--- by yjw 2008-11-6  ����ͬ�İ�����ȡ��ʽ����  rule_calc
declare c_package cursor for select code, amount, credit, accnt, profit, loss, quantity,rule_calc
		from package where type<'5' and accnt<>'' and profit<>'' and loss<>''     -- type<'5' Ŀǰֻ��Բ���
open c_package
fetch c_package into @code, @amount, @credit, @accnt, @profit, @loss, @copy,@rule
while @@sqlstatus = 0
begin
	-- part 1 �������֣��緿�ѣ�
	select @flag = '{' + rtrim(@code) + '>}%'
	if exists(select 1 from package_detail where bdate=@bdate and code=@code and tag<>'9' and flag='F')
	begin
		select @roomno = roomno from master where accnt=@accnt
		-- �Զ� Posting Profit -- ����ֻ�� Profit, û�� Loss
      -- ��package_detail������package������
      --- by yjw 2008-11-6  ����ͬ�İ�����ȡ��ʽ����  rule_calc
        if substring(@rule,4,1)='0'
    		select @quan=isnull((select count(quantity) from package_detail where code=@code and bdate=@bdate and tag<>'9' and flag='F'), 0)
        else
        	select @quan=isnull((select sum(quantity) from package_detail where code=@code and bdate=@bdate and tag<>'9' and flag='F'), 0)
--		select @quan=isnull((select count(quantity) from package_detail where code=@code and bdate=@bdate and tag<>'9' and flag='F' and quantity<>0), 0)
		update package_detail set flag='T' where code=@code and bdate=@bdate and tag<>'9' and flag='F'
		select @profit_amt=@quan*isnull(@amount,0)
		if @profit_amt <> 0
		begin
			select @ref2 = '{' + rtrim(@code) + '>} Package Profit'
			exec @ret = p_gl_accnt_posting 'A', '02', '9999', 0, @shift, @empno, @accnt, 0, @profit, '',
				1, @profit_amt, 0, 0, 0, 0, 0, @code, @ref2, @bdate, '', ' pkg_c', 'ARYY', 0, null, @msg out
			if @ret = 1
				goto gout
		end
		-- �ж���� �� ƽ��
		select @mtmp=sum(charge) from account where accnt=@accnt and mode like ' pkg_c%' and ref2 like @flag and billno='' and bdate=@bdate
        if @mtmp <> 0
		begin
			select @ret=1, @msg='1Package(%1) �����ʲ�ƽ�������Ի���ϵ EDP^' + @code
         goto gout
		end
		else
		begin
			delete account_temp where accnt=@accnt and pc_id=@pc_id and mdi_id=0
			insert account_temp (pc_id,mdi_id,accnt,number,mode1,billno,selected,charge,credit)
				select @pc_id,0,@accnt,number,mode1,billno,1,0,0
					from account where accnt=@accnt and mode like ' pkg_c%' and ref2 like @flag and billno='' and bdate=@bdate
			exec @ret=p_gds_accnt_checkout @pc_id,0,@roomno,@accnt,0,'SELECTED',@shift,@empno,'R',@msg output
			if @ret<>0
				goto gout
		end
	end

	-- part 2 ��ֲ��֣���ͷѣ�
	-- �Զ� Posting Profit & Loss  �������110Ԫ���ɱ���50Ԫ����ô�Զ���� Profit -50, Loss -60
	select @flag = '{' + rtrim(@code) + '<}%'
	if exists(select 1 from package_detail where bdate=@bdate and code=@code and tag='9' and flag='F')
	begin
		select @roomno = roomno from master where accnt=@accnt

		delete #package_tmp
		insert #package_tmp(accnt,code, posted_number, charge_td)
			select accnt, code, posted_number, isnull(sum(charge), 0)
			from package_detail
			where code=@code and bdate=@bdate and tag='9' and flag='F'
			group by accnt, code, posted_number
		update package_detail set flag='T' where code=@code and bdate=@bdate and tag='9' and flag='F'

		update #package_tmp set amount=@amount, charge=a.charge, credit=a.credit
			from package_detail a
			where #package_tmp.accnt=a.accnt and #package_tmp.code=a.code and #package_tmp.posted_number=a.number

      -- ���㵥�ֵóɱ���

--		-- �����Ǽ��� profit, loss �ı�׼�㷨
--		-- profile, loss
--      update #package_tmp set profit = charge_td -( charge - amount) where charge > amount and (charge_td -( charge - amount)) >0
--      update #package_tmp set loss   = charge_td - profit where charge > amount and (charge_td -( charge - amount)) >0
--
--      update #package_tmp set profit = 0 where charge > amount and (charge_td -( charge - amount)) <=0
--      update #package_tmp set loss   = charge_td where charge > amount and (charge_td -( charge - amount)) <=0
--
--      update #package_tmp set profit = charge_td where charge <= amount
--      update #package_tmp set loss   = 0 where charge <= amount
--
--      select @profit_amt=isnull((select sum(profit) from #package_tmp),0)
--      select @loss_amt=isnull((select sum(loss) from #package_tmp),0)

		-- ��������Զ�����������룬��ʱ��д�Ĵ��롣��Ҫԭ���ǲ�������û���������
		select @price = round(@credit/@copy, 2)				-- ������۵���
		select @copy = sum(charge_td) from #package_tmp 	-- �����ܳ���
select @loss_amt = sum(charge) from account where accnt=@accnt and mode like ' pkg_d%' and ref2 like @flag and billno like 'T%' and tofrom='TO'
select @copy=@copy + @loss_amt
		select @profit_amt = round(@copy / @price * @amount, 2)  -- ���������Ȼ��ó���ת���
		select @loss_amt = @copy - @profit_amt

--select @price, @copy, @profit_amt, @loss_amt  -- debug
		-- Profit
   	if @profit_amt <> 0
		begin
			select @profit_amt = -1*@profit_amt, @ref2 = '{' + rtrim(@code) + '<} Package Profit'
			exec @ret = p_gl_accnt_posting 'A', '02', '9999', 0, @shift, @empno, @accnt, 0, @profit, '',
				1, @profit_amt, 0, 0, 0, 0, 0, @code, @ref2, @bdate, '', ' pkg_d', 'ARYY', 0, null, @msg out
			if @ret = 1
				goto gout
		end
		-- Loss
		if @loss_amt <> 0
		begin
			select @loss_amt = -1*@loss_amt, @ref2 = '{' + rtrim(@code) + '<} Package Loss'
			exec @ret = p_gl_accnt_posting 'A', '02', '9999', 0, @shift, @empno, @accnt, 0, @loss, '',
				1, @loss_amt, 0, 0, 0, 0, 0, @code, @ref2, @bdate, '', ' pkg_d', 'ARYY', 0, null, @msg out
			if @ret = 1
				goto gout
		end

		-- �ж����  �� ƽ��
		select @mtmp = isnull(sum(charge),0) from account where accnt=@accnt and mode like ' pkg_d%' and ref2 like @flag and billno=''
		if @mtmp <> 0
		begin
			select @ret=1, @msg='P2ackage(%1) �����ʲ�ƽ�������Ի���ϵ EDP^' + @code
			goto gout
		end
		else
		begin
			delete account_temp where accnt=@accnt and pc_id=@pc_id and mdi_id=0
			insert account_temp (pc_id,mdi_id,accnt,number,mode1,billno,selected,charge,credit)
				select @pc_id,0,@accnt,number,mode1,billno,1,0,0
					from account
					where accnt=@accnt and mode like ' pkg_d%' and ref2 like @flag and billno=''
			exec @ret=p_gds_accnt_checkout @pc_id,0,@roomno,@accnt,0,'SELECTED',@shift,@empno,'R',@msg output
			if @ret<>0
				goto gout
		end
	end

	fetch c_package into @code, @amount, @credit, @accnt, @profit, @loss, @copy,@rule
end
close c_package
deallocate cursor c_package

gout:
if @ret <> 0
	rollback tran package_hs
commit tran

if @retmode = 'S'
	select @ret, @msg

return @ret

;
