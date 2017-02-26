// ===================================================
// information_name : source --> text
// ===================================================
//exec sp_rename  information_name, a_information_name;
if exists(select * from sysobjects where name = 'information_name' and type ='U')
	drop table information_name
;
create table information_name (
		cat				varchar(10)	default '' not null,
		descript			char(20)					not null,
		descript1		char(20)					not null,
		bmp				char(60)					not null,
		source			text			default ''	null,
      havebmp    		char(1)  	default 'F' null
);
exec sp_primarykey information_name, descript
create unique index index1 on information_name(descript)
;
//insert information_name select * from a_information_name;
//select * from information_name;


// ===================================================
// information_def : Ôö¼ÓÁË code ×Ö¶Î
// ===================================================
//exec sp_rename information_def, a_information_def;
if exists(select * from sysobjects where name = 'information_def' and type ='U')
	drop table information_def
;
create table information_def (
		no 			numeric(10,0) 		identity,
		catalog		char(10)				not null,
		item			char(50)				not null,
		c1				varchar(255)		null,
		c2				varchar(255)		null,
		c3				varchar(255)		null,
		c4				varchar(255)		null,
		c5				varchar(255)		null,
		c6				varchar(255)		null,
		c7				varchar(255)		null,
		c8				varchar(255)		null,
		n1				money					default 0 not null,
		n2				money					default 0 not null,
		n3				money					default 0 not null,
		n4				money					default 0 not null,
		n5				money					default 0 not null,
		n6				money					default 0 not null,
      bmp         varchar(50)       default ''    null
);
exec sp_primarykey information_def, no
create unique index index1 on information_def(no)
;
//
//insert information_def(catalog,item,c1,c2,c3,c4,c5,c6,c7,c8,n1,n2,n3,n4,n5,n6)
// select catalog,item,c1,c2,c3,c4,c5,c6,c7,c8,n1,n2,n3,n4,n5,n6 from a_information_def;
//select * from information_def;
//