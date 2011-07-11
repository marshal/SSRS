

if OBJECT_ID(N'xp_SplitStringToTable', N'P') is not null
begin
	drop procedure xp_SplitStringToTable;
end
go

create procedure xp_SplitStringToTable
	@inputString nvarchar(max)
as
begin

if isnull(@inputString, N'') = N''
begin
	select N'' as ColValue;
end
else
begin
	declare @sqlscript nvarchar(max);
	set @sqlscript = N'select N''' + REPLACE(@inputString, N',', N''' ColValue union select N''') + N'''';
	exec(@sqlscript);	
end

end