--ZAD 1A
INSERT INTO user_sdo_geom_metadata VALUES (
    'FIGURY',
    'KSZTALT',
    mdsys.sdo_dim_array(
        mdsys.sdo_dim_element(
            'X', 0, 10, 0.01
        ), mdsys.sdo_dim_element(
            'Y', 0, 10, 0.01
        )
    ),
    NULL
);

--ZAD 1B
SELECT
    sdo_tune.estimate_rtree_index_size(
        3000000, 8192, 10, 2, 0
    )
FROM
    figury
WHERE
    ROWNUM = 1;

--ZAD 1C
CREATE INDEX figury_idx ON
    figury (
        ksztalt
    )
        INDEXTYPE IS mdsys.spatial_index_v2;

--ZAD 1D
SELECT
    id
FROM
    figury
WHERE
    sdo_filter(
        ksztalt, sdo_geometry(
            2001, NULL, sdo_point_type(
                3, 3, NULL
            ), NULL, NULL
        )
    ) = 'TRUE';

-- Odp: Wynik nie odpowiada rzeczywistości. 
-- Dla operatora SDO_FILTER wykorzystywana jest jedynia pierwsza faza przetwarzania
-- zapytań bazująca na podstawie aproksymacji opartej na utworzonym wcześniej indeksie.

--ZAD 1E
SELECT
    id
FROM
    figury
WHERE
    sdo_relate(
        ksztalt, sdo_geometry(
            2001, NULL, sdo_point_type(
                3, 3, NULL
            ), NULL, NULL
        ), 'mask=ANYINTERACT'
    ) = 'TRUE';

--Odp: Teraz wynik odpowiada rzeczywistości.

--ZAD 2A
SELECT
    a.city_name AS miasto,
    sdo_nn_distance(
        1
    )           AS odl
FROM
    major_cities a,
    major_cities b
WHERE
    sdo_nn(
        a.geom, b.geom, 'sdo_num_res=10 unit=km', 1
    ) = 'TRUE'
    AND b.city_name = 'Warsaw'
    AND a.city_name != 'Warsaw';

--ZAD 2B
SELECT
    a.city_name AS miasto
FROM
    major_cities a,
    major_cities b
WHERE
    sdo_within_distance(
        a.geom, b.geom, 'distance=100 unit=km'
    ) = 'TRUE'
    AND b.city_name = 'Warsaw'
    AND a.city_name != 'Warsaw';

--ZAD 2C
SELECT
    a.cntry_name AS kraj,
    a.city_name  AS miasto
FROM
    major_cities       a,
    country_boundaries b
WHERE
    sdo_relate(
        a.geom, b.geom, 'mask=INSIDE'
    ) = 'TRUE'
    AND b.cntry_name = 'Slovakia';

--ZAD 2D
SELECT
    b.cntry_name AS panstwo,
    sdo_geom.sdo_distance(
        a.geom, b.geom, 1, 'unit=km'
    )            AS odl
FROM
    country_boundaries a,
    country_boundaries b
WHERE
    sdo_relate(
        a.geom, b.geom, 'mask=ANYINTERACT'
    ) != 'TRUE'
    AND a.cntry_name = 'Poland';

--ZAD 3A
SELECT
    b.cntry_name AS kraj,
    sdo_geom.sdo_length(
        sdo_geom.sdo_intersection(
            a.geom, b.geom, 1
        ), 1, 'unit=km'
    )            AS odleglosc
FROM
    country_boundaries a,
    country_boundaries b
WHERE
    sdo_filter(
        a.geom, b.geom
    ) = 'TRUE'
    AND a.cntry_name = 'Poland'
    AND b.cntry_name != 'Poland';

--ZAD 3B
SELECT
    cntry_name
FROM
    country_boundaries
WHERE
    sdo_geom.sdo_area(
        geom, 1, 'unit=SQ_KM'
    ) = (
        SELECT
            MAX(sdo_geom.sdo_area(
                geom, 1, 'unit=SQ_KM'
            ))
        FROM
            country_boundaries
    );

--ZAD 3C
SELECT
    sdo_geom.sdo_area(
        sdo_geom.sdo_mbr(
            sdo_geom.sdo_union(
                a.geom, b.geom, 1
            )
        ), 1, 'unit=SQ_KM'
    ) AS sq_km
FROM
    major_cities a,
    major_cities b
WHERE
    a.city_name = 'Warsaw'
    AND b.city_name = 'Lodz';

--ZAD 3D
SELECT
    sdo_geom.sdo_union(
                      a.geom,
                      b.geom,
                      1
    ).get_gtype() AS gtype
FROM
    country_boundaries a,
    major_cities       b
WHERE
    a.cntry_name = 'Poland'
    AND b.city_name = 'Prague';

--ZAD 3E
SELECT
    a.city_name,
    a.cntry_name
FROM
    major_cities       a,
    country_boundaries b
WHERE
    a.cntry_name = b.cntry_name
    AND sdo_geom.sdo_distance(
        a.geom, sdo_geom.sdo_centroid(
            b.geom, 1
        ), 1
    ) = (
        SELECT
            MIN(sdo_geom.sdo_distance(
                a.geom, sdo_geom.sdo_centroid(
                    b.geom, 1
                ), 1
            ))
        FROM
            major_cities       a,
            country_boundaries b
        WHERE
            a.cntry_name = b.cntry_name
    );

--ZAD 3F
SELECT
    a.name,
    SUM(sdo_geom.sdo_length(
        sdo_geom.sdo_intersection(
            a.geom, b.geom, 1
        ), 1, 'unit=km'
    )) AS dlugosc
FROM
    rivers             a,
    country_boundaries b
WHERE
    b.cntry_name = 'Poland'
    AND sdo_relate(
        a.geom, b.geom, 'mask=ANYINTERACT'
    ) = 'TRUE'
GROUP BY
    a.name;