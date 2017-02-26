/*---------------------------------------------------------------------------------------------*/
//
//	触摸屏: 收银员窗口--开单列表
//
/*---------------------------------------------------------------------------------------------*/

if exists ( select * from sysobjects where name = "p_cyj_pos_touch_accnt_menulist" and type ="P")
   drop proc p_cyj_pos_touch_accnt_menulist;
create proc p_cyj_pos_touch_accnt_menulist
	@pc_id		char(4),					/*站点*/
	@shift		char(9),					/*班别*/
	@sta			char(10),				/*状态*/
	@pccode		char(3) = ''         /*餐厅*/
as


select *,tbldes = space(11) into #menu from pos_menu where 1=2

insert into #menu select *,'' from pos_menu where ( charindex(shift, @shift) > 0 and charindex(sta, @sta) >0 and charindex(pccode, (select pccodes from pos_station where pc_id = @pc_id)) >0  and (@pccode ='' or pccode = @pccode) or sta ='4' )
insert into #menu select *,'' from pos_menu where menu not in(select menu from #menu) and pcrec <>'' and pcrec in (select pcrec from #menu)

update #menu set cardno = '★' from #menu a,pos_menu_bill b where (a.menu=b.menu or a.pcrec=b.menu) and (b.hline>0 or b.hpage>0)
update #menu set foliono = convert(char(10), (select count(1) from #menu b where b.pcrec = a.pcrec )) from #menu a where a.pcrec <>''
update #menu set tbldes = descript1 from pos_tblsta where #menu.tableno = pos_tblsta.tableno

-- 没联单
select ref =  menu + space(1) 
	+ substring(convert(char(30),convert(decimal(30,2), amount))+space(11), 1,11) 
	+ substring(empno3 + space(9), 1, 9)  + '*'+shift
	+ substring(setmodes + space(6), 1, 6) + ltrim(rtrim(cardno))
	+  remark, sta, menu,tableno,box =space(10),pcrec,tbldes from #menu  
	where rtrim(pcrec) is null
union all
-- 联单
select ref =  menu + space(1) 
	+ substring(convert(char(30),convert(decimal(30,2), amount))+space(11), 1,11) 
	+ substring(empno3 + space(9), 1, 9)  + '*'+shift 
	+ substring(setmodes + space(6), 1, 6)  + ltrim(rtrim(cardno))
	+ '▲' + substring(pcrec, 7, 4) +'-'+ ltrim(rtrim(foliono)) + '▲'
	+  remark, sta, menu,tableno,box =space(10),pcrec,tbldes from #menu  
	where rtrim(pcrec) > ''
order by pcrec,tableno
;
//

