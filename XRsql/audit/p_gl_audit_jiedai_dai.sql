if exists (select * from sysobjects where name ='p_gl_audit_jiedai_dai' and type ='P')
	drop proc p_gl_audit_jiedai_dai;
create proc p_gl_audit_jiedai_dai
	@toseek			varchar(90) out, 
	@tail				char(2), 
	@credit			money
as
	
update dairep set sumcre = sumcre + @credit where class = substring(@toseek, 1, 8)
if @tail ='01'
	update dairep set credit01 = credit01 + @credit where class = substring(@toseek, 1, 8)
else if @tail ='02'
	update dairep set credit02 = credit02 + @credit where class = substring(@toseek, 1, 8)
else if @tail ='03'
	update dairep set credit03 = credit03 + @credit where class = substring(@toseek, 1, 8)
else if @tail ='04'
	update dairep set credit04 = credit04 + @credit where class = substring(@toseek, 1, 8)
else if @tail ='05'
	update dairep set credit05 = credit05 + @credit where class = substring(@toseek, 1, 8)
else if @tail ='06'
	update dairep set credit06 = credit06 + @credit where class = substring(@toseek, 1, 8)
else
	update dairep set credit07 = credit07 + @credit where class = substring(@toseek, 1, 8)
select @toseek = stuff(@toseek, 1, 9, null)
return 0
;
