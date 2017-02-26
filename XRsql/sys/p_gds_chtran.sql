IF OBJECT_ID('p_gds_chtran') IS NOT NULL
    DROP PROCEDURE p_gds_chtran
;
create proc p_gds_chtran
	@chinchar		varchar(10),
	@enghead			char(1) output
as
----------------------------------
-- 获取中文字符串的第一个大写字母
----------------------------------
declare		@a		int,
				@b		int,
				@c		int

select @a=ascii(substring(@chinchar,1,1))-160
select @b=ascii(substring(@chinchar,datalength(@chinchar),1))-160
select @c=@a*100+@b

if @c<1601 or @c >= 5601
      select @enghead='?'
else if @c < 1637
      select @enghead='A'
else if @c < 1833
      select @enghead='B'
else if @c < 2078
      select @enghead='C'
else if @c < 2274
      select @enghead='D'
else if @c < 2302
      select @enghead='E'
else if @c < 2433
      select @enghead='F'
else if @c < 2594
      select @enghead='G'
else if @c < 2787
      select @enghead='H'
else if @c < 3106
      select @enghead='J'
else if @c < 3212
      select @enghead='K'
else if @c < 3472
      select @enghead='L'
else if @c < 3635
      select @enghead='M'
else if @c < 3722
      select @enghead='N'
else if @c < 3730
      select @enghead='O'
else if @c < 3858
      select @enghead='P'
else if @c < 4027
      select @enghead='Q'
else if @c < 4086
      select @enghead='R'
else if @c < 4390
      select @enghead='S'
else if @c < 4558
      select @enghead='T'
else if @c < 4684
      select @enghead='W'
else if @c < 4925
      select @enghead='X'
else if @c < 5249
      select @enghead='Y'
else if @c < 5601
      select @enghead='Z'

return 0
;
