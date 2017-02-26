
if exists(select 1 from sysobjects where type ='P' and name ='p_cyj_create_bar_no')
	drop proc  p_cyj_create_bar_no;
create proc  p_cyj_create_bar_no
	@no			char(10) output,
	@return		char(1)	= 'R'
as
------------------------------------------------------------------------------------
--
-- 吧台：产生 pos_store_mst 单号 
--
------------------------------------------------------------------------------------

declare 
	@no1 		char(10),
	@no2 		char(10),
	@bdate	datetime,
	@numb		int

select @bdate = bdate1 from sysdata
select @no = convert(char(8), @bdate, 2)
select @no = substring(@no, 1, 2) + substring(@no, 4, 2) + substring(@no, 7, 2) 
select @no1 = isnull(max(no), '0000000000') from pos_store_mst where no > @no
select @no2 = isnull(max(no), '0000000000') from pos_store_hmst where no > @no

if @no1 > @no2
	select @numb = convert(int, substring(@no1, 7, 4)) + 1
else
	select @numb = convert(int, substring(@no2, 7, 4)) + 1

select @no1 = '0000'+rtrim(convert(char(4), @numb))
select @no = rtrim(@no) + substring(rtrim(@no1), datalength(rtrim(@no1)) - 3, 4)

if @return = 'R'
	select @no	
;

