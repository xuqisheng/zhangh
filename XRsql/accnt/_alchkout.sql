if exists (select * from sysobjects where name='alchkout' and type='U')
   drop table alchkout;
create table alchkout
(
   accnt        char(10),
   sta          char(1),
   stabacktoi   char(1),
   empno        char(10),
   date         datetime
)
exec sp_primarykey alchkout,accnt
create unique index index1 on alchkout(accnt)
;