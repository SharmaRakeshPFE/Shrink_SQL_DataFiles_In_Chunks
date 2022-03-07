/*
Description:			- This script will help shrink database in chunks.
                        - Note : Shriking a database is a last choice as it may result into fregmentation
						-Good Reads
                        - http://www.sqlskills.com/blogs/paul/why-you-should-not-shrink-your-data-files/
                        - https://www.brentozar.com/archive/2009/08/stop-shrinking-your-database-files-seriously-now/
*/  

declare @DataBaseFileName sysname
declare @TargetFreeMB int
declare @ShrinkIncrementMB int

-- Define Database file to shrink
--<CHANGE FILE NAME HERE - Example here SQL2022>
set @DataBaseFileName = 'SQL2022'  

-- <Define File free space in MB after shrink operation>
-- <CHANGE VALUE HERE FROM 50 TO 500 OR ANY DESIRED VALUE>
set @TargetFreeMB = 50			

-- Set Increment to shrink file by in MB
--CHANGE SHRINK INCREMENT 
set @ShrinkIncrementMB = 50			

-- Show Size, Space Used, Unused Space, and Name of all database files
select
        [FileSizeMB]    =
                convert(numeric(10,2),round(a.size/128.,2)),
        [UsedSpaceMB]   =
                convert(numeric(10,2),round(fileproperty( a.name,'SpaceUsed')/128.,2)) ,
        [UnusedSpaceMB] =
                convert(numeric(10,2),round((a.size-fileproperty( a.name,'SpaceUsed'))/128.,2)) ,
        [DBFileName]    = a.name
from
        sysfiles a

declare @sql varchar(8000)
declare @SizeMB int
declare @UsedMB int

-- Get current file size in MB
select @SizeMB = size/128. from sysfiles where name = @DataBaseFileName

-- Get current space used in MB
select @UsedMB = fileproperty( @DataBaseFileName,'SpaceUsed')/128.

select [StartFileSize] = @SizeMB, [StartUsedSpace] = @UsedMB, [DBFileName] = @DataBaseFileName

-- Loop until file at desired size
while  @SizeMB > @UsedMB+@TargetFreeMB+@ShrinkIncrementMB
        begin

        set @sql =
        'dbcc shrinkfile ( '+@DataBaseFileName+', '+
        convert(varchar(20),@SizeMB-@ShrinkIncrementMB)+' ) '

        print 'Start ' + @sql
        print 'at '+convert(varchar(30),getdate(),121)

        exec ( @sql )

        print 'Done ' + @sql
        print 'at '+convert(varchar(30),getdate(),121)

        -- Get current file size in MB
        select @SizeMB = size/128. from sysfiles where name = @DataBaseFileName
        
        -- Get current space used in MB
        select @UsedMB = fileproperty( @DataBaseFileName,'SpaceUsed')/128.

        select [FileSize] = @SizeMB, [UsedSpace] = @UsedMB, [DBFileName] = @DataBaseFileName

        end

select [EndFileSize] = @SizeMB, [EndUsedSpace] = @UsedMB, [DBFileName] = @DataBaseFileName

-- Show Size, Space Used, Unused Space, and Name of all database files
select
        [FileSizeMB]    =
                convert(numeric(10,2),round(a.size/128.,2)),
        [UsedSpaceMB]   =
                convert(numeric(10,2),round(fileproperty( a.name,'SpaceUsed')/128.,2)) ,
        [UnusedSpaceMB] =
                convert(numeric(10,2),round((a.size-fileproperty( a.name,'SpaceUsed'))/128.,2)) ,
        [DBFileName]    = a.name
from
        sysfiles a