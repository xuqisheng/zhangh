-------------------------------------------------------------------------
-- 
-- Docunets Management : 
--                     using ftp server
-- Designer: ZHJ    May,2003    GHH
-------------------------------------------------------------------------
--
-- Documents Class
--
if exists (select 1	
            from  sysobjects
            where  id = object_id('doc_class')
            and    type = 'U')
   drop table doc_class
;

create table doc_class
(
   classid	 char(4)	         default ''	    not null,
   parentcls char(4)	         default ''	    not null,
   clsgrade	 char(1)	         default 'C'	    not null, -- C:assign rights by class   
																		  -- D:assign rights by documents 
   descript	 char(30)	      default ''	    not null, 
   descript1 char(30)	      default ''	        null, 
   remark    varchar(254)     default ''          null, 
   prvdept   varchar(254)	   default ''	    not null,
   prvemp1   varchar(254)	   default ''	    not null, 
   prvemp2   varchar(254)	   default ''	    not null  
)
;
exec sp_primarykey doc_class,classid
create unique index index1 on doc_class(classid)
;
--
-- Documents Detail 
--
if exists (select 1
            from  sysobjects
            where  id = object_id('doc_detail')
            and    type = 'U')
   drop table doc_detail
;

create table doc_detail
(
   docid     varchar(38)	   default ''         not null,
   docname   varchar(120)	   default ''         not null,
   orgname   varchar(254)	   default ''         not null,
   classid	 char(4)  	      default ''         not null,
   sender	 char(10)  	      default ''         not null,
   senddate  datetime         default GetDate()  not null,
   filepath  varchar(254)     default ''         not null,
   descript  varchar(254)     default ''             null, 
   prvdept   varchar(254)	   default ''	     	 not null,
   prvemp1   varchar(254)	   default ''	       not null, 
   prvemp2   varchar(254)	   default ''	       not null  
)
;
exec sp_primarykey doc_detail,docid
create index index2 on doc_detail(docname)
;
--
-- Documents Read Log 
--
if exists (select 1
            from  sysobjects
            where  id = object_id('doc_readlog')
            and    type = 'U')
   drop table doc_readlog
;

create table doc_readlog
(
   docid     varchar(38)	default ''         not null,
   reader	 char(10)  	   default ''         not null,
   readdate  datetime      default GetDate()  not null,
   advice    varchar(254)  default ''             null 
)
;

if exists (select 1
            from  sysobjects
            where  id = object_id('tu_doc_class')
            and    type = 'TR')
   drop trigger tu_doc_class
;
--
--  Update trigger for doc_class
--
create trigger tu_doc_class on doc_class for update as
begin
   declare
      @maxcard  int,
      @numrows  int,
      @numnull  int,
      @errno    int,
      @errmsg   varchar(255)

      select  @numrows = @@rowcount
      if @numrows = 0
         return
      if (update(prvdept) or update(prvemp1) or update(prvemp1))
		begin 
			update doc_detail 
			set prvdept = a.prvdept,prvemp1 = a.prvemp1,prvemp2 = a.prvemp2 
			from doc_detail d,inserted a 
			where d.classid = a.classid 
		end 
      return
--  Errors handling  
error:
    raiserror @errno @errmsg
    rollback  transaction
end
;

--
-- Documents Maint Rights 
--
exec p_hry_manage_auth_function 0,'sys!doccls', '文档类型维护' ,'07#','S'
;
--
-- Docunets Management Parameter
--
if not exists (select 1 from  sysoption where  catalog = 'hotel' and item = 'docftpserver' )
   insert into sysoption (catalog, item, value) 
	values ('hotel', 'docftpserver', '192.168.0.200|foxdoc|foxdoc|c:\ver5\tmp\|/usr/foxdoc/|')
;

		