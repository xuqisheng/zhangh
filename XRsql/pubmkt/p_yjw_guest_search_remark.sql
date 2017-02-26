IF OBJECT_ID('p_yjw_guest_search_remark') IS NOT NULL
    DROP PROCEDURE p_yjw_guest_search_remark
;
create procedure p_yjw_guest_search_remark
              @no        varchar(10),
              @appid 	 varchar(20) ,
	           @langid	int
as
	create table #tips
	(
		title    varchar(20) not null,
      tips		text 		not null,
		color		decimal      default 13947080 		not null
	)
declare
     @len      int


if @langid=0
   insert #tips(title,tips) select "�ͷ�ƫ��:",rmpref from guest where no=@no and rmpref<>'' and rmpref is not null
else
	insert #tips(title,tips) select "Room Prefer:",rmpref from guest where no=@no and rmpref<>'' and rmpref is not null

if @langid=0
   insert #tips(title,tips) select "�ŷ�Ҫ��:",feature from guest where no=@no and feature<>'' and feature is not null
else
	insert #tips(title,tips) select "Feature:",feature from guest where no=@no and feature<>'' and feature is not null

if @langid=0 
   insert #tips(title,tips) select "����Ҫ��:",srqs from guest where no=@no and srqs<>'' and srqs is not null
else
	insert #tips(title,tips) select "Special Require:",srqs from guest where no=@no and srqs<>'' and srqs is not null

if @langid=0 
   insert #tips(title,tips) select "ǰ̨ϲ��:",refer1 from guest where no=@no and refer1<>'' and refer1 is not null
else
	insert #tips(title,tips) select "FO Prefer:",refer1 from guest where no=@no and refer1<>'' and refer1 is not null

if @langid=0 
   insert #tips(title,tips) select "˵��:", comment from guest where no=@no and comment<>'' and comment is not null
else
	insert #tips(title,tips) select "Comment:",comment from guest where no=@no and comment<>'' and comment is not null

select @len=datalength(remark) from guest where no=@no
   if @len>1
      begin
			if @langid=0
				insert #tips(title,tips) select "��ע:", remark from guest where no=@no
			else
				insert #tips(title,tips) select "Remark:",remark from guest where no=@no
      end

if @langid=0
   insert #tips(title,tips) select "����ϲ��:", refer2 from guest where no=@no and refer2<>'' and refer2 is not null
else
	insert #tips(title,tips) select "F&B Prefer:",refer2 from guest where no=@no and refer2<>'' and refer2 is not null


select title,tips,color from #tips
;
