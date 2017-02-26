// ---------------------------------------------------
// 维护最常用的sql  
// ---------------------------------------------------
select b.accnt, b.bdate, b.pccode, b.charge, b.log_date from sysdata a, account b where a.bdate1=b.bdate; 
select * from sys_empno where empno='FOX';

// ---------------------------------------------------
// 同时存在 descript, descript1 两个列的表；
// ---------------------------------------------------
select * from sysobjects a where a.type='U' 
	and exists(select 1 from syscolumns b where a.id=b.id and b.name='descript')
	and exists(select 1 from syscolumns c where a.id=c.id and c.name='descript1')
order by a.name
;
 -- 只包含 descript
select * from sysobjects a where a.type='U' 
	and exists(select 1 from syscolumns b where a.id=b.id and b.name='descript')
	and not exists(select 1 from syscolumns c where a.id=c.id and c.name='descript1')
order by a.name
;


// ---------------------------------------------------
// 包含 text 列的表；
// ---------------------------------------------------
select a.name,b.name,b.type from sysobjects a , syscolumns b 
	where a.id=b.id and b.type=35 and a.type='U' order by a.name;


// ---------------------------------------------------
//	校验 limit, accredit, deposit 
// ---------------------------------------------------
 select a.accnt, a.limit, a.accredit, pp=(select sum(b.amount) from accredit b where a.accnt=b.accnt and b.tag='0') 
	from master a 
	where a.limit=a.accredit or a.limit <> (select sum(b.amount) from accredit b where a.accnt=b.accnt and b.tag='0') 
	order by a.accnt;


// ---------------------------------------------------
//	校验 account--> pccode & argcode 的一致性
// ---------------------------------------------------
select * from account 
	where pccode+argcode not in (select pccode+argcode from pccode)
		and modu_id<>'02';

// ---------------------------------------------------
//	check rsvsrc -- market, src 
// ---------------------------------------------------
-- 1
update rsvsrc set market=a.market from master a where rsvsrc.accnt=a.accnt and a.market<>'';
update rsvsrc set src=a.src from master a where rsvsrc.accnt=a.accnt and a.src<>'';
-- 2
update rsvsrc_till set market=a.market from master_till a where rsvsrc_till.accnt=a.accnt and a.market<>'';
update rsvsrc_till set src=a.src from master_till a where rsvsrc_till.accnt=a.accnt and a.src<>'';
-- 3
update rsvsrc_last set market=a.market from master_last a where rsvsrc_last.accnt=a.accnt and a.market<>'';
update rsvsrc_last set src=a.src from master_last a where rsvsrc_last.accnt=a.accnt and a.src<>'';


// ---------------------------------------------------
//	纠正 master locksta 允许记账的设置
// ---------------------------------------------------
update master set extra=stuff(extra,10,1,'1') 
	where accnt in (select accnt from subaccnt where type='0' and tag='0' and pccodes='*');
update master set extra=stuff(extra,10,1,'0') 
	where accnt in (select accnt from subaccnt where type='0' and tag='0' and (pccodes='' or pccodes='.'));
update master set extra=stuff(extra,10,1,'2') 
	where accnt in (select accnt from subaccnt where type='0' and tag='0' and pccodes<>'*' and pccodes<>'.' and pccodes<>'');

// ---------------------------------------------------
//	检查资源纪录错误 -- saccnt 
// ---------------------------------------------------
select * from rsvsrc where saccnt not in (select saccnt from rsvsaccnt);
select * from rsvsaccnt where saccnt not in (select saccnt from rsvsrc);
select * from rsvdtl where accnt not in (select saccnt from rsvsaccnt);


// ---------------------------------------------------
//	纠正 rsvsrc 的准确到达离开时间
// ---------------------------------------------------
update rsvsrc set arr=a.arr from master a 
	where rsvsrc.accnt=a.accnt and datediff(dd,a.arr,rsvsrc.arr)=0 and a.arr<>rsvsrc.arr;
update rsvsrc set dep=a.dep from master a 
	where rsvsrc.accnt=a.accnt and datediff(dd,a.dep,rsvsrc.dep)=0 and a.dep<>rsvsrc.dep;


// ---------------------------------------------------
//	基本系统代码
// ---------------------------------------------------
//select a.descript,a.descript1, b.code,b.descript,b.descript1,b.grp from basecode_cat a, basecode b 
//    where a.cat=b.cat
//    order by a.cat, b.sequence;
// select * from mktcode order by sequence;
// select * from srccode order by sequence;
//select * from restype order by sequence;
// select * from reason order by sequence;
//select * from typim ;
//select * from rmratecode;
//select * from package;
//select * from pccode;
//select * from countrycode;


// ---------------------------------------------------
//	客房资源维护
// ---------------------------------------------------
select type,descript,quantity,overquan,quantity+overquan,(select sum(quantity+overquan) from typim a where a.sequence<=typim.sequence ) from typim order by sequence;
//select * from sysoption where catalog='reserve';


// ---------------------------------------------------
//	清除房态临时表内容
// ---------------------------------------------------
truncate table    hsmap 			;
truncate table    hsmap_new 		;
truncate table    hsmap_bu 		;
truncate table    hsmap_bu_cond 	;
truncate table    hsmap_des 		;
truncate table    hsmap_flr 		;
truncate table    hsmapsel 		;


// ---------------------------------------------------
//	date format 
// ---------------------------------------------------
select 'yyyy/mm/dd'=convert(char(10), getdate(), 111) from sysdata;
select 'yyyymmdd'=convert(char(8), getdate(), 112) from sysdata;
select 'yy/mm/dd'=convert(char(10), getdate(), 11) from sysdata;
select 'yymmdd'=convert(char(8), getdate(), 12) from sysdata;
select 'hh:mm:ss'=convert(char(8), getdate(), 8) from sysdata;


// ---------------------------------------------------
//	为了翻译，检查可能引起翻译的错误
// ---------------------------------------------------
//select * from mktcode 
//select * from srccode 
//select * from pccode
//select * from basecode
select * from guest_card_type
	where charindex('/', descript)>0	or charindex('/', descript1)>0
		or charindex("'", descript)>0	or charindex("'", descript1)>0
		or charindex('"', descript)>0	or charindex('"', descript1)>0
;


// ---------------------------------------------------
//	判断 新 ar 
// ---------------------------------------------------
declare	@lic_buy_1 varchar(255), @lic_buy_2 varchar(255)
select @lic_buy_1 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.1'), '')
select @lic_buy_2 = isnull((select value from sysoption where catalog='hotel' and item='lic_buy.2'), '')
if (charindex(',nar,', @lic_buy_1) > 0 or charindex(',nar,', @lic_buy_2) > 0)
begin
end


// ---------------------------------------------------
//	初始化 
// ---------------------------------------------------
exec p_gds_maint_main;
exec p_foxhis_sys_init 'ARB1';
exec p_foxhis_sys_init 'ARB1';



--------------------------------------------------------------------------------
-- 察看字符 ascii
-- char() 返回空值，用 X 表示。
--
-- 由该过程可以看出，char(0) 返回的不是空值，但是该值会自动截断字符串后面的内容 
--------------------------------------------------------------------------------
drop proc p_111;
create proc p_111
as
delete gdsmsg
declare @i int, @row int, @char  char(1), @value varchar(255) 
select @i = 0, @row = 0, @value='['
while @i < 1000
begin
	select @value = @value + convert(char(5), @i) + '--' + isnull(char(@i),'X') + ' ]      ['
	select @i=@i+1, @row=@row+1
	if @row = 10 
	begin
		insert gdsmsg select @value
		select @row=0, @value='['
	end
end
if @value<>''
	insert gdsmsg select @value
select * from gdsmsg
return ;
exec p_111; 

--------------------------------------------------------------------------------
-- 检查修正 guest.name 4 
--------------------------------------------------------------------------------
select * from guest where name4=''; 
exec p_gds_guest_name4_bu ;
select * from guest where name4=''; 


--------------------------------------------------------------------------------
-- 系统工作表
--------------------------------------------------------------------------------
select * from workselect where window like 'w_gds_sc_saleid_list%'; 
select * from worksheet where window like 'w_gds_sc_saleid_list%'; 
select * from worksta where window like 'w_gds_sc_saleid_list%'; 
select * from worksta_name where window like 'w_gds_sc_saleid_list%'; 
select * from workbutton where window like 'w_gds_sc_saleid_list%'; 
select * from workbutton_name where window like 'w_gds_sc_saleid_list%'; 


--------------------------------------------------------------------------------
-- 删除翻译资料中的 非英语语种内容  
--------------------------------------------------------------------------------
select * from foxlangobj where langid<>0 and langid<>2; 
delete foxlangobj where langid<>0 and langid<>2; 
select * from foxlangobj where langid<>0 and langid<>2; 

select * from foxlangmsg where langid<>0 and langid<>2; 
delete foxlangmsg where langid<>0 and langid<>2; 
select * from foxlangmsg where langid<>0 and langid<>2; 


--------------------------------------------------------------------------------
-- 房价检查 
--------------------------------------------------------------------------------
drop proc p_111;
create proc p_111
as
declare @ret int, @msg varchar(60), @charge1 money, @charge2 money, @charge3 money, @charge4 money, @charge5 money
declare @accnt char(10), @w_or_h int, @rmrate money, @qtrate money, @setrate money, @pc_id char(4), @mdi_id int, @package_c money 
declare @rmpostdate datetime , @coperation char(3), @amount money 

//select @accnt='F702100007' // xr
select @accnt='F705080001'  // jjh
select @pc_id='0.39', @mdi_id=0, @w_or_h=1, @coperation='SN1' 
select @rmpostdate = dateadd(dd, 1, rmpostdate) from sysdata  

	exec @ret = p_gl_audit_rmpost_calculate @rmpostdate, @accnt, @w_or_h, @rmrate out, @qtrate out, @setrate out, 
		@charge1 out, @charge2 out, @charge3 out, @charge4 out, @charge5 out, @coperation, @pc_id, @mdi_id
	select @package_c = isnull((select sum(amount) from rmpostpackage
		where pc_id = @pc_id and mdi_id = @mdi_id and accnt = @accnt and rule_calc like '1%'), 0)
	select @amount = @charge1 - @charge2 + @charge3 + @charge4 + @charge5

select @charge1,@charge2,@charge3,@charge4,@charge5,@package_c
return ; 


exec p_111; 
select * from rmpostpackage; 
select * from package_detail where accnt='F705080001'; 



--------------------------------------------------------------------------------
// 把某个表的列插入到可选列中  X50204 
--------------------------------------------------------------------------------
// 1 插入全部记录 
//insert sys_column_show(window,column,sequence,ctype,defselected)
//	select 'w_gds_rep_act_detail1', b.name,1000,'char','T' from sysobjects a, syscolumns b where a.id=b.id and a.name='account'; 
// 2 手工输入中文描述，删除不必要项目
// 3 更新某些内容 
//update sys_column_show set descript1=descript where window='w_gds_rep_act_detail1';
//update sys_column_show set syntax=column+':'+descript+'=10=[general]=alignment="2"' where window='w_gds_rep_act_detail1' and ctype='char';
//update sys_column_show set syntax=column+':'+descript+'=5=0=alignment="2"' where window='w_gds_rep_act_detail1' and ctype='numb';
//update sys_column_show set syntax=column+':'+descript+'=8=0.00=alignment="1"' where window='w_gds_rep_act_detail1' and ctype='mone';
//update sys_column_show set syntax=column+':'+descript+'=8=yy/mm/dd=alignment="2"' where window='w_gds_rep_act_detail1' and ctype='date';
// 4 在做微调-长度，格式等 


--------------------------------------------------------------------------------
-- 检查 account, haccount 重复 
--------------------------------------------------------------------------------
select b.accnt, b.number  from master a, account b, haccount c 
where a.accnt=b.accnt and b.accnt=c.accnt and b.number=c.number ; 


--------------------------------------------------------------------------------
-- 报表简缩宏 
--------------------------------------------------------------------------------
#rpt_pages#
#rpt_hotel!1#
#rpt_title!2#
#rpt_printer!3#
#rpt_rptid!REPID#
#rpt_filter!Date #date1##


//------------------------------------------------
// cus_xf 数据纠错 - 合并结帐引起 
//------------------------------------------------
// 检查 
select accnt, name, lastbl + dtl - ctl - tillbl from ycus_xf where lastbl + dtl - ctl - tillbl<>0 ; 
select accnt, name,  t_dtl - t_ctl - tillbl from ycus_xf where t_dtl - t_ctl - tillbl<>0 ; 
select accnt, name, lastbl + dtl - ctl - tillbl from cus_xf  where lastbl + dtl - ctl - tillbl<>0 ; 
select accnt, name,  t_dtl - t_ctl - tillbl from cus_xf  where t_dtl - t_ctl - tillbl<>0; 

// 纠正 
//update cus_xf set cot=cot+(lastbl+dtl-ctl-tillbl), ctl=ctl+(lastbl+dtl-ctl-tillbl) ; 
//update ycus_xf set cot=cot+(lastbl+dtl-ctl-tillbl), ctl=ctl+(lastbl+dtl-ctl-tillbl) ; 
//
//update cus_xf set t_cot=t_cot+(t_dtl-t_ctl-tillbl), t_ctl=t_ctl+(t_dtl-t_ctl-tillbl) ; 
//update ycus_xf set t_cot=t_cot+(t_dtl-t_ctl-tillbl), t_ctl=t_ctl+(t_dtl-t_ctl-tillbl) ; 



