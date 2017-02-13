declare @num int 
set @num=1 
while @num<=1236 
begin 
	UPDATE [TransferOrder] SET TransferStatus = cast( floor(rand()*5) as int) -2
	WHERE TransferId = (SELECT TransferId FROM(
								SELECT TransferId,TransferNumber,TransferStatus,UpdateTime,
		                            ROW_NUMBER() OVER (ORDER BY TransferId DESC) AS RowNumber
	                            FROM TransferOrder 
							) AS T WHERE RowNumber = @num)
	set @num=@num+1 
end

SELECT TransferStatus,COUNT(1) FROM TransferOrder GROUP BY TransferStatus



SELECT * FROM dbo.TransferOrder ORDER BY TransferId DESC

UPDATE TransferOrder SET TransferStatus = 1 WHERE TransferId = 2376