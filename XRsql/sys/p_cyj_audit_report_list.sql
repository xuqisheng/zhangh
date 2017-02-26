if exists(select 1 from sysobjects where name = 'p_cyj_audit_report_list' and type = 'P')
	drop proc p_cyj_audit_report_list;
create proc p_cyj_audit_report_list
	@empno		char(10),
	@printhis	varchar(10),
	@appid		char(1)
as
----------------------------------------------------------------------------------------
--
--		ҹ�󱨱�鿴Ȩ��
--	
----------------------------------------------------------------------------------------
declare 	@reptag 		char(1),
			@deptno		char(3),
			@langid		int

select @reptag  = reptag, @deptno = deptno from sys_empno where empno = @empno

if	@reptag = 'T'    --	 ͬ����Ȩ��һ��
	begin
	select a.prtno,
				a.descript,
				a.descript1,
				a.prtno1,
				a.callform,
				a.parms,
				a.wpaper,
				a.order_
		 FROM adtrep  a
		 Where charindex(@appid,a.allowmodus)>0 and a.needinst = 'T' and a.instready = 'T'
				 and ( charindex(@printhis,'T') =0 or withhis = 'T')
				and exists(select 1 from sys_rep_link b where b.code=@deptno and b.class='a'
								and (b.funccode='%' or b.funccode='Adtrep!'+rtrim(convert(char(10), a.order_)))
							)
	ORDER BY a.order_ ASC
	end
else					--  ͬ����Ȩ�޲�һ��
	begin
	select a.prtno,
				a.descript,
				a.descript1,
				a.prtno1,
				a.callform,
				a.parms,
				a.wpaper,
				a.order_
		 FROM adtrep  a
		 Where charindex(@appid,a.allowmodus)>0 and a.needinst = 'T' and a.instready = 'T'
				 and ( charindex(@printhis,'T') =0 or withhis = 'T')
				and exists(select 1 from sys_rep_link b where b.code=@empno and b.class='a'
								and (b.funccode='%' or b.funccode='Adtrep!'+rtrim(convert(char(10), a.order_)))
							)
	ORDER BY a.order_ ASC
	end

return 0
;