----------------------------------------------------------------------
--	智能楼宇接口数据产生 
--	Table : pms_building
----------------------------------------------------------------------
IF OBJECT_ID('p_gds_pms_building') IS NOT NULL
    DROP PROCEDURE p_gds_pms_building
;
create proc p_gds_pms_building
	@roomno			char(5),
	@type				char(4),  -- sta
	@grade			char(1),  -- 1 = c/i,   0 = c/o
	@accnt			char(10) = ''
as

delete pms_building where roomno=@roomno and type=@type
insert pms_building(roomno,type,tag,wktime,changed,settime,chgtime,accnt)
	select @roomno, @type, @grade,null, 'F', getdate(), null, @accnt

return
;
