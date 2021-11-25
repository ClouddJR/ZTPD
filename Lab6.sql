-- ZAD1C
CREATE TABLE myst_major_cities (
    fips_cntry VARCHAR2(2),
    city_name  VARCHAR2(40),
    stgeom     st_point
);

-- ZAD1D
INSERT INTO myst_major_cities
    SELECT
        fips_cntry,
        city_name,
        TREAT(st_point.from_sdo_geom(geom) AS st_point) AS stgeom
    FROM
        major_cities;
        
-- ZAD2A
INSERT INTO myst_major_cities VALUES (
    'PL',
    'Szczyrk',
    TREAT(st_point.from_wkt(
        'POINT (19.036107 49.718655)'
    ) AS st_point)
);

-- ZAD2B
SELECT
    name,
    TREAT(st_point.from_sdo_geom(geom) AS st_geometry).get_wkt() AS wkt
FROM
    rivers;
    
-- ZAD2C
SELECT
    sdo_util.to_gmlgeometry(
        st_point.get_sdo_geom(stgeom)
    ) AS gml
FROM
    myst_major_cities
WHERE
    city_name = 'Szczyrk';
    
-- ZAD3A
CREATE TABLE myst_country_boundaries (
    fips_cntry VARCHAR2(2),
    cntry_name VARCHAR2(40),
    stgeom     st_multipolygon
);

-- ZAD3B
INSERT INTO myst_country_boundaries
    SELECT
        fips_cntry,
        cntry_name,
        st_multipolygon(geom)
    FROM
        country_boundaries;
        
-- ZAD3C
SELECT
    b.stgeom.st_geometrytype() AS typ_obiektu,
    COUNT(*)                   AS ile
FROM
    myst_country_boundaries b
GROUP BY
    b.stgeom.st_geometrytype();
    
-- ZAD3D
SELECT
    b.stgeom.st_issimple()
FROM
    myst_country_boundaries b;
    
-- ZAD4A
SELECT
    b.cntry_name,
    COUNT(*)
FROM
    myst_country_boundaries b,
    myst_major_cities       c
WHERE
    c.stgeom.st_within(
        b.stgeom
    ) = 1
GROUP BY
    b.cntry_name;
    
-- Powód błędu: Obiekty geometrii znajdują się w różnych systemach współrzędnych (wcześniej dodane miasto Szczyrk)

UPDATE myst_major_cities b
SET
    b.stgeom = st_point(
        b.stgeom.st_x(), b.stgeom.st_y(), 8307
    )
WHERE
    b.city_name = 'Szczyrk';

-- ZAD4B
SELECT
    a.cntry_name AS a_name,
    b.cntry_name AS b_name
FROM
    myst_country_boundaries a,
    myst_country_boundaries b
WHERE
    a.stgeom.st_touches(
        b.stgeom
    ) = 1
    AND b.cntry_name = 'Czech Republic';

-- ZAD4C
SELECT DISTINCT
    b.cntry_name,
    r.name
FROM
    myst_country_boundaries b,
    rivers                  r
WHERE
    st_linestring(r.geom).st_intersects(b.stgeom) = 1
    AND b.cntry_name = 'Czech Republic';
    
-- ZAD4D
SELECT
    round(
        TREAT(a.stgeom.st_union(
            b.stgeom
        ) AS st_polygon).st_area(), - 2
    ) AS powierzchnia
FROM
    myst_country_boundaries a,
    myst_country_boundaries b
WHERE
    a.cntry_name = 'Czech Republic'
    AND b.cntry_name = 'Slovakia';
    
-- ZAD4E
SELECT
    a.stgeom                                                      AS obiekt,
    a.stgeom.st_difference(st_geometry(b.geom)).st_geometrytype() AS wegry_bez
FROM
    myst_country_boundaries a,
    water_bodies            b
WHERE
    a.cntry_name = 'Hungary'
    AND b.name = 'Balaton';
    
-- ZAD5A
EXPLAIN PLAN
    FOR
SELECT
    b.cntry_name a_name,
    COUNT(*)
FROM
    myst_country_boundaries b,
    myst_major_cities       c
WHERE
    sdo_within_distance(
        c.stgeom, b.stgeom, 'distance=100 unit=km'
    ) = 'TRUE'
    AND b.cntry_name = 'Poland'
GROUP BY
    b.cntry_name;

SELECT
    plan_table_output
FROM
    TABLE ( dbms_xplan.display );
    
-- ZAD5B
INSERT INTO user_sdo_geom_metadata
    SELECT
        'MYST_MAJOR_CITIES',
        'STGEOM',
        t.diminfo,
        t.srid
    FROM
        all_sdo_geom_metadata t
    WHERE
        t.table_name = 'MAJOR_CITIES';

-- ZAD5C
CREATE INDEX myst_major_cities_idx ON
    myst_major_cities (
        stgeom
    )
        INDEXTYPE IS mdsys.spatial_index_v2;
        
EXPLAIN PLAN
    FOR
SELECT
    b.cntry_name a_name,
    COUNT(*)
FROM
    myst_country_boundaries b,
    myst_major_cities       c
WHERE
    sdo_within_distance(
        c.stgeom, b.stgeom, 'distance=100 unit=km'
    ) = 'TRUE'
    AND b.cntry_name = 'Poland'
GROUP BY
    b.cntry_name;

SELECT
    plan_table_output
FROM
    TABLE ( dbms_xplan.display );
    
-- Indeks został wykorzystany