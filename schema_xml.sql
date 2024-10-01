WITH
	_tables(tbl_name, tbl_xml) AS (
		SELECT
			tbl_name, PRINTF('<table name="%s">%%s<sql><![CDATA[%s]]></sql></table>', "tbl_name", "sql")
		FROM sqlite_schema
		WHERE type='table' ORDER BY tbl_name),
	_cols(tbl_name, col_xml) AS (
		SELECT
			tbl_name, 
			GROUP_CONCAT(
				PRINTF('<column cid="%d" name="%s" type="%s" notnull="%d" dflt_value="%s" pk="%d"/>',
					"cid", "name", "type", "notnull","dflt_value", "pk"),
				CHAR(10)||CHAR(9))
		FROM pragma_table_info(tbl_name)
		JOIN _tables
		GROUP BY tbl_name),
	_forest(tbl_name, xml) AS (
		SELECT
			tbl_name,
			PRINTF(tbl_xml, 
			CHAR(10)||CHAR(09)||(
				SELECT col_xml||CHAR(10)
				FROM _cols AS c WHERE c.tbl_name=t.tbl_name)
			)
		FROM _tables AS t)
SELECT
	'<tables>' || CHAR(10) ||
	GROUP_CONCAT(xml, CHAR(10)) ||
	CHAR(10)||'</tables>' || CHAR(10) AS xml
FROM _forest;