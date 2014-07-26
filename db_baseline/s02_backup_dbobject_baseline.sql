/****** Object:  StoredProcedure [dbo].[backup_dbobject_baseline]    Script Date: 06/01/2010 12:06:22 ******/
SET ANSI_NULLS OFF
GO
SET QUOTED_IDENTIFIER ON
GO

ALTER PROCEDURE [dbo].[backup_dbobject_baseline] 	
AS
/*
========================================================
Backup Objects - Silvio Hirashiki 2010

This stored procedure saves in a table DBobject_baseline
a copy of a databse object code, so you can later query
the table and get the code which was active in a certain date.

Example of uses
---------------

-- run this to generate a baseline
exec backup_dbobject_baseline

-- get existing baselines
select distinct baseline_date from DBobject_baseline


-- get last version code for view vw_master_invoice_summary
select * from DBobject_baseline
where object_name = 'fn_split'
and baseline_date = (select MAX(baseline_date) from DBobject_baseline)


-- get a version in a specific date
select * from DBobject_baseline
where object_name = 'vw_master_invoice_summary'
and baseline_date = '2010-06-03 12:05:59.737'

-- object types being saved
select distinct xtype_description from DBobject_baseline



*/
BEGIN
	SET NOCOUNT ON;

	
	Declare @current_date as datetime
	set @current_date = getdate()
	
	-- gets a list of objects in the database
	declare @obj_name as varchar(200)
	declare @obj_id as varchar(50)
	declare @obj_xtype as varchar(50)
	
	Declare c_objectlist cursor for
      Select name, id, xtype 
		from sysobjects where xtype in ('P', 'V', 'X', 'TF')
		/*
		Xtype decodification
		--------------------
		C : CHECK constraint
		D : Default or DEFAULT constraint
		F : FOREIGN KEY constraint
		L : Log
		P : Stored procedure
		PK : PRIMARY KEY constraint (type is K)
		RF : Replication filter stored procedure
		S : System tables
		TR : Triggers
		U : User table
		UQ : UNIQUE constraint (type is K)
		V : Views
		X : Extended stored procedure
		TF : Functions
		*/
		
	Open c_objectlist
	
	Fetch next from c_objectlist into 
		@obj_name 
		, @obj_id 
		, @obj_xtype 

	/* 
	for each object, we retrieve the code and 
	insert in a table
	*/
	
	declare @code_text varchar(8000)
	declare @line_number int
	WHILE @@FETCH_STATUS = 0  
		BEGIN
	
			Create Table #temp
			(	code_content varchar(8000)	)

			Insert into #temp
				Exec dbo.sp_helptext @objname = @obj_name
	
	
			declare c_objectcode cursor for
				select code_content from #temp
				
			Open c_objectcode 
			set @line_number = 0
			Fetch next from c_objectcode into @code_text
		
			while @@FETCH_STATUS = 0  
				begin
					set @line_number = @line_number + 1
					insert into DBobject_baseline 
					(	baseline_date
						, xtype
						, xtype_description
						, object_name
						, line_number
						, line_content
					) values 
					( 	@current_date 
						, @obj_xtype 
						, 	( case 	when @obj_xtype = 'P' then 'Stored procedure'
									when @obj_xtype = 'V' then 'View'
									when @obj_xtype = 'X' then 'Extended stored procedure'
									when @obj_xtype = 'TF' then 'Function'
									
								else ''
							end )
						, @obj_name 
						, @line_number
						, @code_text
					)	
				
					Fetch next from c_objectcode into @code_text
				end
	
			close c_objectcode		
			deallocate c_objectcode
			drop table #temp

					
			Fetch next from c_objectlist into 
				@obj_name 
				, @obj_id 
				, @obj_xtype 	
	
	END
				
	close c_objectlist		
	deallocate c_objectlist


	-- deletes from the baseline entries older than 1 month
	delete from DBobject_baseline 
		where baseline_date < dateadd(m,-1,GETDATE())
	
	/* End of script */	
END


