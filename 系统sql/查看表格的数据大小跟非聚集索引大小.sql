--查看表格的数据大小跟非聚集索引大小
WITH DATA AS (
SELECT
 
      O.name tb_name,
      reservedpages = SUM (reserved_page_count),
      usedpages = SUM (used_page_count),
      pages = SUM (CASE WHEN (index_id < 2) THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count) ELSE 0 END ),
      rowCounts = SUM (CASE WHEN (index_id < 2) THEN row_count ELSE 0 END )
FROM sys.dm_db_partition_stats S
JOIN sys.objects o on s.object_id=o.object_id
WHERE O.type='U'
GROUP BY O.name
)
SELECT
 
         tb_name,
         rowCounts,
         reservedpages*8/1024 reserved_Mb,
         pages*8/1024 data_Mb,
         index_Mb=(usedpages-pages)*8/1024,
         unused_Mb=case when usedpages>reservedpages then 0 else (reservedpages-usedpages)*8/1024 end
FROM DATA
--WHERE tb_name = 'tb_composite'
ORDER BY reserved_Mb DESC
GO

