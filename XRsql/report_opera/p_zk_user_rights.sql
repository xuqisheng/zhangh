if exists(select * from sysobjects where name = "p_zk_user_rights" and type ='P')
	drop proc p_zk_user_rights
;


create proc p_zk_user_rights
  
as
declare
   @permission   char(30),
   @dept  char(20),
   @rights     char(1),
   @code    char(10),
   @funcsort   char(2),
   @funccode   char(4),
   @descript  char(20)
   
   
 
create table #bob
(
	permission   char(30) null,
   dept      char(20) null,
   deptno    char(8)  null,
   rights     char(1) null
)
--CREATE UNIQUE NONCLUSTERED INDEX index1
  -- ON #bob(permission,dept,rights)


insert #bob select distinct '',rtrim(descript),code,'' from basecode where cat='dept'
--select a.code,a.descript from basecode a,#bob b where rtrim(a.descript)=rtrim(b.dept)
--return
declare d_cms cursor for select deptno,dept from #bob
declare c_cms cursor for select funcsort,funccode from sys_function_dtl where rtrim(sys_function_dtl.code)=rtrim(@code)
open d_cms
fetch d_cms into @code,@descript
while @@sqlstatus = 0
   begin
  --  return convert(integer,@code)
   open c_cms
   fetch c_cms into @funcsort,@funccode
   while @@sqlstatus = 0
      begin
     -- return convert(integer,@code)
      if rtrim(@funcsort)='%'
         begin
         insert #bob select distinct descript,@descript,'','T' from sys_function
         end
      if rtrim(@funcsort)<>'%' and rtrim(@funccode)='%'
         begin
         insert #bob select distinct descript,@descript,'','T' from sys_function where rtrim(sys_function.class)=rtrim(@funcsort)
         end 
      if rtrim(@funcsort)<>'%' and rtrim(@funccode)<>'%'
         begin
         insert #bob select distinct descript,@descript,'','T' from sys_function where rtrim(sys_function.code)=rtrim(@funccode)
         end
      fetch c_cms into @funcsort,@funccode
      end
   close c_cms
   fetch d_cms into @code,@descript
   end
deallocate cursor c_cms
close d_cms
deallocate cursor d_cms


select distinct permission,dept,rights from #bob order by dept,permission
;

--exec p_zk_user_rights;