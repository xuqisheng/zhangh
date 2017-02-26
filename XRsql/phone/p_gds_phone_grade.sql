drop proc p_gds_phone_grade;
create proc p_gds_phone_grade
	@roomno			char(5),
	@type				char(4),  -- ckin, ckou, grad, ......
	@grade			char(1),
	@accnt			char(10) = '',
	@oroomno			char(5) = ''   -- 换房前的房号
as
-----------------------------------------------------------------------
--	维护电话 PMS : phteleclos 
-----------------------------------------------------------------------

if not exists(select 1 from sysoption where catalog='hotel' and item='ename' and value='xhdjd')
begin
-- 插入分机号
	delete phteleclos where roomno in (select extno from phextroom where roomno=@roomno) and type=@type
	insert phteleclos(roomno,type,tag,wktime,changed,settime,chgtime,accnt) 
		select extno, @type, @grade,null, 'F', getdate(), null, @accnt from phextroom 
			where roomno=@roomno
end
else
begin
-- 直接插入房号 （西湖大酒店）
	delete phteleclos where roomno =@roomno and type=@type
	insert phteleclos(roomno,type,tag,wktime,changed,settime,chgtime,accnt) 
		select @roomno, @type, @grade,null, 'F', getdate(), null, @accnt 
end

return 
;
