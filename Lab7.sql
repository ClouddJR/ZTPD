-- ZAD1A
CREATE TABLE a6_lrs (
    geom SDO_GEOMETRY
);

-- ZAD1B
INSERT INTO a6_lrs
    SELECT
        a.geom
    FROM
        streets_and_railroads a,
        major_cities          b
    WHERE
        sdo_relate(
            a.geom, sdo_geom.sdo_buffer(
                b.geom, 10, 1, 'unit=km'
            ), 'mask=ANYINTERACT'
        ) = 'TRUE'
        AND b.city_name = 'Koszalin';
        
-- ZAD1C
SELECT
    sdo_geom.sdo_length(
        geom, 1, 'unit=km'
    )                                  AS distance,
    st_linestring(geom).st_numpoints() AS st_numpoints
FROM
    a6_lrs;
    
-- ZAD1D
UPDATE a6_lrs
SET
    geom = sdo_lrs.convert_to_lrs_geom(
        geom, 0, sdo_geom.sdo_length(
            geom, 1, 'unit=km'
        )
    );
    
-- ZAD1E
INSERT INTO user_sdo_geom_metadata VALUES (
    'A6_LRS',
    'GEOM',
    mdsys.sdo_dim_array(
        mdsys.sdo_dim_element(
            'X', 12.603676, 26.369824, 1
        ), mdsys.sdo_dim_element(
            'Y', 45.8464, 58.0213, 1
        ), mdsys.sdo_dim_element(
            'M', 0, 300, 1
        )
    ),
    8307
);

-- ZAD1F
CREATE INDEX a6_lrs_idx ON
    a6_lrs (
        geom
    )
        INDEXTYPE IS mdsys.spatial_index_v2;
        
-- ZAD2A
SELECT
    sdo_lrs.valid_measure(
        geom, 500
    ) AS valid_500
FROM
    a6_lrs;
    
-- ZAD2B
SELECT
    sdo_lrs.geom_segment_end_pt(geom) AS end_pt
FROM
    a6_lrs;
    
-- ZAD2C
SELECT
    sdo_lrs.locate_pt(
        geom, 150, 0
    ) km150
FROM
    a6_lrs;
    
-- ZAD2D
SELECT
    sdo_lrs.clip_geom_segment(
        geom, 120, 160
    ) cliped
FROM
    a6_lrs;
    
-- ZAD2E
SELECT
    sdo_lrs.get_next_shape_pt(
        a6.geom, sdo_lrs.project_pt(
            a6.geom, c.geom
        )
    ) wjazd_na_a6
FROM
    a6_lrs       a6,
    major_cities c
WHERE
    c.city_name = 'Slupsk';
    
-- ZAD2F
SELECT
    sdo_geom.sdo_length(
        sdo_lrs.offset_geom_segment(
            a6.geom, m.diminfo, 50, 200, 50, 'unit=m'
        ), 1, 'unit=km'
    ) AS koszt
FROM
    a6_lrs                 a6,
    user_sdo_geom_metadata m
WHERE
    m.table_name = 'A6_LRS'
    AND m.column_name = 'GEOM';