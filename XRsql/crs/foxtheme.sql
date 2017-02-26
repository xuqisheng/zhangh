if exists (select 1
            from  sysobjects
            where  id = object_id('foxtheme')
            and    type = 'U')
   drop table foxtheme
;

/* ============================================================ */
/*   Table: foxtheme                                            */
/* ============================================================ */
create table foxtheme
(
    themeid				    varchar(10)					not null,
    descript			    varchar(30)					not null,
    descript1			    varchar(30)					not null,
    datawindow_color     integer	default 31907036  not null,
    header_background    integer	default 15780518  not null,
    header_color     	 integer	default 8388608   not null,
    detail_background    integer	default 33222896  not null,
    detail_color     	 integer	default 0  			not null,
    summary_background   integer	default 33222896  not null,
    summary_color     	 integer	default 0  			not null,
    footer_background    integer	default 33222896  not null,
    footer_color     	 integer	default 0  			not null 
)
exec sp_primarykey foxtheme,themeid
create unique index index1 on foxtheme(themeid)
;

INSERT INTO foxtheme ( themeid, descript, descript1, datawindow_color, header_background, header_color, detail_background, detail_color, summary_background, summary_color, footer_background, footer_color ) VALUES ( 'default', '»± °', 'Default', 31907036, 15780518, 8388608, 33222896, 0, 33222896, 0, 33222896, 0 ) 
INSERT INTO foxtheme ( themeid, descript, descript1, datawindow_color, header_background, header_color, detail_background, detail_color, summary_background, summary_color, footer_background, footer_color ) VALUES ( 'training', '≈‡—µ', 'Training', 32768, 8421504, 16776960, 8421504, 32768, 8421504, 16711680, 8421504, 65535 ) 
INSERT INTO foxtheme ( themeid, descript, descript1, datawindow_color, header_background, header_color, detail_background, detail_color, summary_background, summary_color, footer_background, footer_color ) VALUES ( 'crs', 'CRS', 'CRS', 16762111, 16760831, 8388608, 16765183, 0, 33222896, 0, 33222896, 0 ) 
INSERT INTO foxtheme ( themeid, descript, descript1, datawindow_color, header_background, header_color, detail_background, detail_color, summary_background, summary_color, footer_background, footer_color ) VALUES ( 'crsm', 'CRS Member', 'CRS Member', 12713921, 13303754, 8388608, 12713921, 0, 33222896, 0, 33222896, 0 ) 
;
