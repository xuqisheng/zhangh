IF OBJECT_ID('p_zk_cms_update') IS NOT NULL
    DROP PROCEDURE p_zk_cms_update;

create proc p_zk_cms_update
	@bdate   datetime,
	@pc_id	char(4)
as
declare		@ret		int,
				@msg		varchar(60),
				@des		varchar(150),
				@id		decimal,
				@type		char(10),
				@roomno	char(10),
				@accnt	char(10),
				@ratecode	char(10),
				@packages	char(50),
				@error		int ,
				@gstno		int,
				@children	int,
				@rmrate		money

---------------------------------------------
-- 分拆佣金记录中的房费项目-服务费，包价等 
---------------------------------------------				
select @ret=0, @error=0 
declare c_1 cursor for select id,type,roomno,accnt,rmrate from cms_rec where bdate=@bdate and isaudit='F' 
open c_1
fetch c_1 into @id,@type,@roomno,@accnt,@rmrate
while @@sqlstatus=0
	begin
	select @ratecode = ratecode,@packages=packages,@gstno=gstno,@children=children from master where roomno = @roomno and accnt=@accnt
   //exec @ret = p_yjw_rmratecode_check '',@pc_id,0,@bdate,@ratecode,@type,@packages,@gstno,@children
	exec @ret = p_yjw_daily_rate_change '',@pc_id,0,@bdate,@ratecode,@type,@packages,@rmrate,@gstno,@children
	select @error = @error + @ret 
	if @ret=0
		begin
		if (select count(1) from cms_rec where @roomno=roomno and bdate=@bdate)>0
			update cms_rec set netrate=rmrate -w_or_h*(isnull((select sum(amount) from rmratecode_check where pc_id=@pc_id and mdi_id=0 and number>1 and code not in ('RMRA','QRAT') and substring(rule_calc,2,1)='0' ),0)),
					packrate=w_or_h*(isnull((select sum(amount) from rmratecode_check where pc_id=@pc_id and mdi_id=0 and number>1 and code not in (select code from package where type in (select code from basecode where rtrim(cat) = 'package_type' and rtrim(grp)='SVR')) ),0)) ,
					rmsur= w_or_h*(isnull((select sum(amount) from rmratecode_check where pc_id=@pc_id and mdi_id=0 and number>1 and code in (select code from package where type in (select code from basecode where rtrim(cat) = 'package_type' and rtrim(grp)='SVR')) ),0))  where bdate=@bdate and id=@id
//		else
//			update cms_rec set netrate=w_or_h*((select isnull(amount,0) from rmratecode_check where pc_id=@pc_id and mdi_id=0 and code='QRAT' and substring(rule_calc,2,1)='0')),
//					packrate=w_or_h*(isnull((select sum(amount) from rmratecode_check where pc_id=@pc_id and mdi_id=0 and number>1),0)) where bdate=@bdate and id=@id
		end
	fetch c_1 into @id,@type,@roomno,@accnt,@rmrate
	end

return @error   --  表示分拆错误的记录个数
;

 