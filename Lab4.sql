--ZAD 1A
CREATE TABLE figury (
	id NUMBER (1),
	ksztalt sdo_geometry
);

--ZAD 1B
INSERT INTO figury
		VALUES(1, sdo_geometry (2003, NULL, NULL, sdo_elem_info_array (1, 1003, 4), sdo_ordinate_array (3, 5, 5, 3, 7, 5)));

INSERT INTO figury
		VALUES(2, sdo_geometry (2003, NULL, NULL, sdo_elem_info_array (1, 1003, 3), sdo_ordinate_array (1, 1, 5, 5)));

INSERT INTO figury
		VALUES(3, sdo_geometry (2002, NULL, NULL, sdo_elem_info_array (1, 4, 2, 1, 2, 1, 5, 2, 2), sdo_ordinate_array (3, 2, 6, 2, 7, 3, 8, 2 7, 1)));

--ZAD 1C
INSERT INTO figury
		VALUES(4, sdo_geometry (2003, NULL, NULL, sdo_elem_info_array (1, 1003, 1), sdo_ordinate_array (1, 6, 1, 8, 4, 8)));

--ZAD 1D
SELECT
	id,
	sdo_geom.validate_geometry_with_context (ksztalt, 0.001) AS val
FROM
	figury;

--ZAD 1E
DELETE FROM figury
WHERE sdo_geom.validate_geometry_with_context (ksztalt, 0.001) != 'TRUE';

--ZAD 1F 
COMMIT;