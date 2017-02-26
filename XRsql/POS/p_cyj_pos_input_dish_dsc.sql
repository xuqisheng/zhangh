/*-----------------------------------------------------------------------------*/
//
//	餐饮明细输入: 特要码折扣 code = 999901, sta ='X'; 结帐前打折 
//     不必关联菜谱 
//  
//
/*-----------------------------------------------------------------------------*/


if object_id('p_cyj_pos_input_dish_dsc') is not null
	drop proc p_cyj_pos_input_dish_dsc
;
create proc p_cyj_pos_input_dish_dsc
	@menu			char(10),
	@empno		char(10),
	@amount   	money,      		   //   折扣额
	@reason		char(3),             //   折扣理由
	@pc_id		char(8) 
 as
declare
	@ret			integer  ,
	@msg			char(60) ,
	@bdate		datetime,
	@mdate		datetime,
	@mshift		char(1),
	@deptno		char(2)	,
	@pccode		char(10)	,
	@mode			char(3),
	@code			char(6),
	@sort			char(4),
	@code1		char(10),
	@plucode		char(2),
	@inumber		integer	,


	@special				char(1),
	@sta					char(1),
 	@line 			int,
	@mx_id 			integer


select @bdate  = bdate1 from sysdata
select @plucode ='99', @sort='9999',@code='999901'

begin tran
save  tran p_hry_pos_input_dish_s1
update pos_menu set pc_id = @pc_id where menu = @menu
select @mdate = bdate,@mshift = shift,@deptno = deptno,@pccode = pccode,@inumber = lastnum + 1,@sta = sta
  from pos_menu where menu = @menu

if @@rowcount = 0
	select @ret = 1,@msg = "菜单“" + @menu + "”已不存在或已销单"
else if @sta ='3'
	select @ret = 1,@msg = "菜单“" + @menu + "”已被其他收银员结帐"
else if @sta ='7'
	select @ret = 1,@msg = "菜单“" + @menu + "”已被删除"

else
	begin
	
	 	insert pos_dish(menu,inumber,plucode,sort,code,id,printid,name1,name2,unit,number,amount,dsc,srv,tax,empno,bdate,remark,id_cancel,id_master,reason,empno1,sta,special)
		select @menu,@inumber,@plucode,@sort,@code,0,0,'折扣','折扣', '份',1,0,@amount,0,0,@empno,@bdate,'',0,0,@reason,'','0','X'

	select @mx_id = @inumber

	update pos_menu set amount = amount - @amount,dsc = dsc + amount,lastnum = @mx_id
	 where menu = @menu
	select @ret = 0,@msg = "成功"
	end

gout:
if @ret <> 0 
	rollback tran p_hry_pos_input_dish_s1
else
commit tran

select @ret,@msg 
return 0

;
