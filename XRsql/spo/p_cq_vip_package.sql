drop proc p_cq_vip_package;
create proc p_cq_vip_package
		@pc_id			char(4),
		@shift			char(1),
		@empno			char(10)
		
as
declare
		@no				char(20),
		@packcode		char(10),
		@inumber			integer,
		@class			char(1),
		@rate				money,
		@amount			money,
		@amount0			money,
		@posted			money,
		@arr				datetime,
		@dep				datetime,
		@bdate			datetime,
		@today			datetime,
		@menu				char(11),
		@remark			char(50),

		@accnt			char(10),
		@pccode			char(5),

		@ret				integer,
		@msg				char(50),
		@set				char(11),

		@empno1			char(10),
		@paycode			char(5)

select @bdate = bdate from sysdata 
select @today = getdate() from sysdata
begin tran
save tran p_package_s
declare c_package cursor for 
		select no,packcode,inumber,class,rate,amount,posted,arr,dep,accnt,pccode,empno,paycode from sp_viptax where halt <> 'T'
open c_package
fetch c_package into @no,@packcode,@inumber,@class,@rate,@amount,@posted,@arr,@dep,@accnt,@pccode,@empno1,@paycode
while @@sqlstatus = 0
	begin
	--总费用先入账
	if not exists(select 1 from sp_tax where no = @no and packcode = @packcode and inumber = @inumber and audit = 'T')
		begin
		select @set = 'A' + @no,@msg = @no
		exec @ret = p_gl_accnt_posting @set, '02', @pc_id,3, @shift, @empno1, @accnt,0, @paycode, '98',1, @amount,0,0,0,0,0,@no,@no, @today, '', '', 'IR', 0, '', @msg out
		if @ret = 0 
			insert sp_tax select @no,@packcode,@inumber,@accnt,@paycode,'T',getdate(),@empno
		end
-------------
	fetch c_package into @no,@packcode,@inumber,@class,@rate,@amount,@posted,@arr,@dep,@accnt,@pccode,@empno1,@paycode
	end

close c_package
deallocate cursor c_package

if @ret <> 0
   rollback tran p_package_s
commit tran

select @ret ,@msg

;
