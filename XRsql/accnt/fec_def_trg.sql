
create trigger t_gds_fec_def_insert
   on fec_def for insert 
	as
-- ------------------------------------------------------------------------------------
--		fec_def ���봥����
--    ��������������ù������� log��ɾ�����ټ�����룬��ʱ�� logmark Ҫע��� log ����ȡ���ֵ��
--          ������ɾ�� log �еĸĴ����������� 
-- ------------------------------------------------------------------------------------
begin
if exists(select 1 from inserted) 
	begin 
	delete fec_def_log from inserted a where fec_def_log.code=a.code 
	insert fec_def_log select * from inserted 
	end 
end
;

create trigger t_gds_fec_def_update
   on fec_def for update
	as
-- ------------------------------------------------------------------------------------
--		fec_def ���´�����
-- ------------------------------------------------------------------------------------
begin
if update(logmark) and  exists(select 1 from inserted)  -- ע�⣬���������� inserted 
	insert fec_def_log select * from inserted 
end
;

create trigger t_gds_fec_def_delete
   on fec_def for delete 
	as
-- ------------------------------------------------------------------------------------
--		fec_def ɾ��������
-- ------------------------------------------------------------------------------------
begin
if exists(select 1 from deleted) 
	begin
	declare @pc_id char(4), @empno char(10), @shift char(1), @appid varchar(5), @ret int 
	exec @ret = p_gds_get_login_info 'R', @empno output,@shift output, @pc_id output, @appid output  	
	if @ret = 0 
		insert fec_def_log 
			select code,descript,descript1,disc,base,price_in,price_out,price_cash,@empno,getdate(),logmark+1
				from deleted  
	end 
end
;