
// 综合扫描临时记录 
if exists(select * from sysobjects where name = "foxhis_sign")
	drop table foxhis_sign;
CREATE TABLE foxhis_sign 
(
    signid     int          NOT NULL,		// ID 流水 
    name1      varchar(100) NULL,			// 名称 
    ref1       varchar(60)  NULL,			// 备注 
    sign       image        NULL,			// 图像 
    linkno     char(10)     NULL,			// 档案号 
    empno      char(5)      NOT NULL,		// 建立人
    addtime    datetime     NOT NULL,		// 建立时间
    addpcid    char(4)      NOT NULL,		// 建立站点 
    scan_class char(1)      NOT NULL,		// N=仅创建者使用 
    flag       char(1)      NOT NULL,
    linkempno  char(5)      NOT NULL,		// 关联人
    linktime   datetime     NULL,			// 关联时间 
    type1      char(1)      NOT NULL		// 保存的类别：S=签名 P=相片 
);

