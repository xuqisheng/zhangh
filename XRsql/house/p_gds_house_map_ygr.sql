//------------------------------------------------------------------------------
//		X5 客房部房态表 - 1
//		
//			-- 起源：苏州雅戈尔
//------------------------------------------------------------------------------
IF OBJECT_ID('dbo.p_gds_house_map_ygr') IS NOT NULL
 DROP PROCEDURE dbo.p_gds_house_map_ygr
;
//create proc  p_gds_house_map_ygr
//	@pc_id			char(4),
//	@modu_id			char(2),
//	@type				char(5) = '#####',
//	@hall				varchar(20) = '#',
//	@flr				char(3) = '###',
//	@sep				char(1) = 'T',
//	@accnt			char(7) = ''
//
//as
//declare
//	@day			int,
//	@flr_min		char(3),
//	@flr_max		char(3),
//	@floor		char(3),
//	@yu			int,
//	@num			int,
//	@column		int,
//	@rmno			char(5),
//	@needbu		char(1)
//
//
//
//if substring(@accnt,1,1)='B'
//	begin
//	select @needbu = 'T'
//	select @accnt = rtrim(substring(@accnt,2,6))
//	end
//else
//	select @needbu = 'F'
//
//delete hsmap_new where modu_id = @modu_id and pc_id = @pc_id
//
//insert hsmap_new(modu_id,pc_id,roomno,flr,ocsta,sta,type,dep,tmpsta) select @modu_id,@pc_id,a.roomno, a.flr, a.ocsta, a.sta, a.type,'2002/01/01',a.tmpsta
//	from rmsta a, hsmap_term_end b
//	where b.pc_id=@pc_id and b.modu_id=@modu_id and a.roomno=b.roomno
//		and (@type='#####' or @type=a.type) and (@hall ='#' or charindex(a.hall,@hall)>0) and (@flr='###' or a.flr=@flr)
//		order by a.flr,a.roomno
//
//update hsmap_new set groupno=a.groupno, extra=a.extra, dep=a.dep, gstno=a.gstno, addbed=a.addbed,rate = a.setrate,
//	limit =isnull((Select sum(d.charge-d.credit) From master d Where d.pcrec=a.pcrec),(a.charge-a.credit))
//           - isnull((Select sum(i.amount) From accredit i Where i.tag='0' and i.accnt
//		in (select e.accnt from master e where e.pcrec = a.pcrec) ),  0),phonesta = '0'
//	from master a where hsmap_new.roomno=a.roomno and a.sta='I' and a.class='F'
//		and  hsmap_new.modu_id = @modu_id and hsmap_new.pc_id = @pc_id
//
//update hsmap_new set ocsta='M' where ocsta='V' and sta in ('O', 'S') and modu_id = @modu_id and pc_id = @pc_id
//update hsmap_new set main='L' where substring(extra,2,1)='1' and modu_id = @modu_id and pc_id = @pc_id
//update hsmap_new set main='H' where substring(extra,1,1)='1' and modu_id = @modu_id and pc_id = @pc_id
//update hsmap_new set main='F' where groupno='' and ocsta='O' and modu_id = @modu_id and pc_id = @pc_id
//
//update hsmap_new set main='G' from master a, master b where hsmap_new.modu_id = @modu_id and hsmap_new.pc_id = @pc_id
//	and hsmap_new.roomno =a.roomno and a.groupno = b.accnt and b.class = 'G'
//	and hsmap_new.groupno<>'' and hsmap_new.ocsta='O'
//update hsmap_new set main='M' from master a, master b where hsmap_new.modu_id = @modu_id and hsmap_new.pc_id = @pc_id
//	and hsmap_new.roomno =a.roomno and a.groupno = b.accnt and b.class = 'M'
//	and hsmap_new.groupno<>'' and hsmap_new.ocsta='O'
//
//
//update hsmap_new set ed=1 where ocsta='O' and datediff(dd,getdate(),dep)<=0 and modu_id = @modu_id and pc_id = @pc_id
//update hsmap_new set ea=1 from master a where hsmap_new.roomno = a.roomno and charindex(a.sta,'RCG')>0 and datediff(dd,getdate(),a.arr)>0 and hsmap_new.modu_id = @modu_id and hsmap_new.pc_id = @pc_id
//update hsmap_new set ea=2 from master a where hsmap_new.roomno = a.roomno and charindex(a.sta,'RCG')>0 and datediff(dd,getdate(),a.arr)=0 and hsmap_new.modu_id = @modu_id and hsmap_new.pc_id = @pc_id
//
//update hsmap_new set flag=flag+'＋' where addbed > 0 and modu_id = @modu_id and pc_id = @pc_id
//update hsmap_new set flag=flag+'★' from master a,guest b where a.haccnt =b.no and hsmap_new.ocsta='O' and hsmap_new.roomno=a.roomno and b.vip>'0' and hsmap_new.modu_id = @modu_id and hsmap_new.pc_id = @pc_id
//update hsmap_new set flag=flag+'※' where ocsta='O' and substring(extra,4,1)='1'
//update hsmap_new set flag=flag+'▲' from master a,guest b where a.haccnt =b.no and hsmap_new.ocsta='O' and hsmap_new.roomno=a.roomno and b.country <>'CHN' and hsmap_new.modu_id = @modu_id and hsmap_new.pc_id = @pc_id
//update hsmap_new set flag=flag+'■' where ocsta='O' and rate =0 and main <> 'H'  and modu_id = @modu_id and pc_id = @pc_id
//update hsmap_new set flag=flag+'∽' from master a where hsmap_new.roomno=a.roomno and charindex(a.sta,'RCGI') > 0 and a.pcrec<>'' and hsmap_new.modu_id = @modu_id and hsmap_new.pc_id = @pc_id
//update hsmap_new set flag=flag+'＠' from master a where hsmap_new.roomno=a.roomno and charindex(a.sta,'RCGI') > 0
//	and exists(select 1 from message_leaveword where sort = 'LWD' and accnt = a.accnt ) and hsmap_new.modu_id = @modu_id and hsmap_new.pc_id = @pc_id
//update hsmap_new set flag=flag+'◆'  where tmpsta <>'' and rtrim(tmpsta) is not null and modu_id = @modu_id and pc_id = @pc_id
//
//update hsmap_new set flag=isnull(ltrim(flag),'') where modu_id = @modu_id and pc_id = @pc_id
//
//
//if @sep = 'T'
//begin
//	if @needbu = 'T'
//	exec p_wz_house_map5_bu @modu_id,@pc_id
//	insert hsmap_new(modu_id,pc_id,roomno,flr,type,ocsta,sta,dep,vsta) select @modu_id,@pc_id,oroomno,flr,'wz','w','z','2003.1.1',0 from hsmap_bu
//		where modu_id = @modu_id and pc_id = @pc_id order by oroomno
//end
//update hsmap_new set ar1='>>' where ea>0 and  modu_id = @modu_id and pc_id = @pc_id
//update hsmap_new set ar2='>>' where ed>0 and  modu_id = @modu_id and pc_id = @pc_id
//
//select roomno,type,ocsta,sta,main,ea,ed,flag,limit,gstno,bk='',ar1,ar2,box='0',phonesta,vsta
//	from hsmap_new where modu_id = @modu_id and pc_id = @pc_id order by convert(integer,flr),roomno
//
//
//return 0
//;
//