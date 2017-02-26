if exists(select 1 from sysobjects where name='p_cyj_guest_income_list' and type = 'P')	
	drop  proc p_cyj_guest_income_list;
create proc p_cyj_guest_income_list
	@no			char(7)
	
as
-- ---------------------------------------------------------
--  宾客餐饮消费明细：
--		
-- ---------------------------------------------------------
declare	@mno			char(7),
			@date			datetime,
			@accnt		char(10)

--

select  a.menu, a.sta, a.bdate, a.tableno, a.tables, a.guest, a.setmodes, a.empno3, a.shift, a.cusno, a.haccnt, 
	a.mode, c.descript, a.foliono ,a.pcrec,a.resno,a.amount
from pos_hmenu a, pos_pccode c
where charindex(a.sta, '7') = 0  and  (a.pccode = c.pccode) and (rtrim(a.haccnt) = @no or a.cusno = @no)
order by a.bdate,a.pcrec, a.menu

;