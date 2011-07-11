if OBJECT_ID(N'Proc_QueryCPAllBizTransReport', N'P') is not null
begin
	drop procedure Proc_QueryCPAllBizTransReport;
end
go

create procedure Proc_QueryCPAllBizTransReport
	@StartDate datetime = '2011-06-01',
	@PeriodUnit nchar(5) = N'��'
as
begin

--1. Check input
if (@StartDate is null or ISNULL(@PeriodUnit, N'') = N'')
begin
	raiserror(N'Input params cannot be empty in Proc_QueryCPAllBizTransReport', 16, 1);
end

--2. Prepare StartDate and EndDate
declare @CurrStartDate datetime;
declare @CurrEndDate datetime;
declare @PrevStartDate datetime;
declare @PrevEndDate datetime;
declare @LastYearStartDate datetime;
declare @LastYearEndDate datetime;
declare @ThisYearRunningStartDate datetime;
declare @ThisYearRunningEndDate datetime;

if(@PeriodUnit = N'��')
begin
    set @CurrStartDate = @StartDate;
    set @CurrEndDate = DATEADD(week, 1, @StartDate);
    set @PrevStartDate = DATEADD(week, -1, @CurrStartDate);
    set @PrevEndDate = @CurrStartDate;
    set @LastYearStartDate = DATEADD(year, -1, @CurrStartDate); 
    set @LastYearEndDate = DATEADD(year, -1, @CurrEndDate);
end
else if(@PeriodUnit = N'��')
begin
    set @CurrStartDate = @StartDate;
    set @CurrEndDate = DATEADD(MONTH, 1, @StartDate);
    set @PrevStartDate = DATEADD(MONTH, -1, @CurrStartDate);
    set @PrevEndDate = @CurrStartDate;
    set @LastYearStartDate = DATEADD(year, -1, @CurrStartDate); 
    set @LastYearEndDate = DATEADD(year, -1, @CurrEndDate);
end
else if(@PeriodUnit = N'����')
begin
    set @CurrStartDate = @StartDate;
    set @CurrEndDate = DATEADD(QUARTER, 1, @StartDate);
    set @PrevStartDate = DATEADD(QUARTER, -1, @CurrStartDate);
    set @PrevEndDate = @CurrStartDate;
    set @LastYearStartDate = DATEADD(year, -1, @CurrStartDate); 
    set @LastYearEndDate = DATEADD(year, -1, @CurrEndDate);
end
else if(@PeriodUnit = N'����')
begin
    set @CurrStartDate = @StartDate;
    set @CurrEndDate = DATEADD(QUARTER, 2, @StartDate);
    set @PrevStartDate = DATEADD(QUARTER, -2, @CurrStartDate);
    set @PrevEndDate = @CurrStartDate;
    set @LastYearStartDate = DATEADD(year, -1, @CurrStartDate); 
    set @LastYearEndDate = DATEADD(year, -1, @CurrEndDate);
end
else if(@PeriodUnit = N'��')
begin
    set @CurrStartDate = @StartDate;
    set @CurrEndDate = DATEADD(YEAR, 1, @StartDate);
    set @PrevStartDate = DATEADD(YEAR, -1, @CurrStartDate);
    set @PrevEndDate = @CurrStartDate;
    set @LastYearStartDate = DATEADD(year, -1, @CurrStartDate); 
    set @LastYearEndDate = DATEADD(year, -1, @CurrEndDate);
end

set @ThisYearRunningStartDate = CONVERT(char(4), YEAR(@CurrStartDate)) + '-01-01';
set @ThisYearRunningEndDate = @CurrEndDate;

--3. Create BizCategory Table
Create Table #BizCategoryTable
(
	GroupName char(20),
	ItemID int,
	BizCategory char(40),
	GateCategory1 char(40)
);
insert into #BizCategoryTable(GroupName,ItemID,BizCategory,GateCategory1) values
(N'ͨ���ͽ���',101,N'ֱ������(B2C)',N'B2C'),
(N'ͨ���ͽ���',102,N'��ҵ����(B2B)',N'B2B'),
(N'ͨ���ͽ���',103,N'CUPSecure����',N'CUPSecure'),
(N'ͨ���ͽ���',104,N'UPOP����',N'UPOP'),
(N'ͨ���ͽ���',105,N'�⿨����',N'�⿨'),
(N'ͨ���ͽ���',106,N'��ҵ������',N'��ҵ��'),
(N'ͨ���ͽ���',107,N'���ÿ�MOTO����',N'MOTO'),
(N'ͨ���ͽ���',108,N'��ǿ��޴���������',N''),
--(N'�����˻�����',20,N'�Ϻ��׺���',N'5901'),
--(N'�����˻�����',21,N'����������',N'5902'),
--(N'�����˻�����',22,N'���������˻�����',N'7060'),
--(N'�����˻�����',23,N'���������˻�����(����)',N'7061'),
--(N'�����˻�����',24,N'������',N'5602'),
--(N'�����˻�����',25,N'������',N'5603'),
(N'�������㽻��',301,N'���մ���',N'����'),
(N'�������㽻��',302,N'��������',N'ORA'),
(N'�������㽻��',303,N'���˽���',N''),
(N'�������㽻��',304,N'������',N'EPOS'),
(N'�������㽻��',305,N'B2B�ֽ�֧��',N''),
(N'�������㽻��',306,N'���ÿ�����',N''),
(N'�������㽻��',307,N'����ɷ�',N'����'),
(N'�������㽻��',308,N'�����ն��˵�',N''),
(N'�������㽻��',309,N'�յ�����ί�н���',N''),
(N'�������㽻��',310,N'���������',N''),
(N'�������㽻��',311,N'�����յ�����',N'�����յ�'),
(N'���������㽻��',401,N'���п�����ת��',N'ת��'),
(N'���������㽻��',402,N'����ֱ������',N'����'),
(N'���������㽻��',403,N'ת�ӷֹ�˾����',N'ת��');

--4. Get Gate FactDailyTrans Data
--4.1 Get Current Data
--4.1.1 Filter FactDailyTrans Data
select
	GateCategory.GateCategory1,
	Trans.MerchantNo,
	Trans.SucceedTransAmount,
	Trans.SucceedTransCount
into
	#TransWithCategory
from
	dbo.Table_GateCategory GateCategory
	inner join
	dbo.FactDailyTrans Trans
	on
		GateCategory.GateNo = Trans.GateNo
where
	Trans.DailyTransDate >= @CurrStartDate
	and
	Trans.DailyTransDate < @CurrEndDate
	and
	GateCategory.GateCategory1 <> N'#N/A';

--4.1.2 The result take Off Merchant from EPOS
select
	TransWithCategory.GateCategory1,
	SUM(TransWithCategory.SucceedTransCount)
	- case when TransWithCategory.GateCategory1 = N'EPOS'
		then (select 
				 SUM(Trans2.SucceedTransCount)
			from 
				#TransWithCategory Trans2 
			where 
				Trans2.GateCategory1 = N'EPOS' 
				and 
				Trans2.MerchantNo in (select MerchantNo from Table_EposTakeoffMerchant)
				)
		else 0
		end SucceedTransCount,
	SUM(TransWithCategory.SucceedTransAmount)
	- case when TransWithCategory.GateCategory1 = N'EPOS'
		then (select 
				 SUM(Trans2.SucceedTransAmount)
			from 
				#TransWithCategory Trans2 
			where 
				Trans2.GateCategory1 = N'EPOS' 
				and 
				Trans2.MerchantNo in (select MerchantNo from Table_EposTakeoffMerchant)
				)
		else 0
		end SucceedTransAmount
into
	#GateCategoryAmount
from
	#TransWithCategory TransWithCategory
group by
	TransWithCategory.GateCategory1;
	
--4.2 Get Previous Data
--4.2.1 Filter FactDailyTrans Data
select
	GateCategory.GateCategory1,
	Trans.MerchantNo,
	Trans.SucceedTransAmount,
	Trans.SucceedTransCount
into
	#PrevTransWithCategory
from
	dbo.Table_GateCategory GateCategory
	inner join
	dbo.FactDailyTrans Trans
	on
		GateCategory.GateNo = Trans.GateNo
where
	Trans.DailyTransDate >= @PrevStartDate
	and
	Trans.DailyTransDate < @PrevEndDate
	and
	GateCategory.GateCategory1 <> N'#N/A';

--4.2.2 The result take Off Merchant from EPOS
select
	TransWithCategory.GateCategory1,
	SUM(TransWithCategory.SucceedTransCount)
	- case when TransWithCategory.GateCategory1 = N'EPOS'
		then (select 
				 SUM(Trans2.SucceedTransCount)
			from 
				#TransWithCategory Trans2 
			where 
				Trans2.GateCategory1 = N'EPOS' 
				and 
				Trans2.MerchantNo in (select MerchantNo from Table_EposTakeoffMerchant)
				)
		else 0
		end SucceedTransCount,
	SUM(TransWithCategory.SucceedTransAmount)
	- case when TransWithCategory.GateCategory1 = N'EPOS'
		then (select 
				 SUM(Trans2.SucceedTransAmount)
			from 
				#TransWithCategory Trans2 
			where 
				Trans2.GateCategory1 = N'EPOS' 
				and 
				Trans2.MerchantNo in (select MerchantNo from Table_EposTakeoffMerchant)
				)
		else 0
		end SucceedTransAmount
into
	#PrevGateCategoryAmount
from
	#PrevTransWithCategory TransWithCategory
group by
	TransWithCategory.GateCategory1;
	
--4.3 Get Last Year Data
--4.3.1 Filter FactDailyTrans Data
select
	GateCategory.GateCategory1,
	Trans.MerchantNo,
	Trans.SucceedTransAmount,
	Trans.SucceedTransCount
into
	#LastYearTransWithCategory
from
	dbo.Table_GateCategory GateCategory
	inner join
	dbo.FactDailyTrans Trans
	on
		GateCategory.GateNo = Trans.GateNo
where
	Trans.DailyTransDate >= @LastYearStartDate
	and
	Trans.DailyTransDate < @LastYearEndDate
	and
	GateCategory.GateCategory1 <> N'#N/A';

--4.3.2 The result take Off Merchant from EPOS
select
	TransWithCategory.GateCategory1,
	SUM(TransWithCategory.SucceedTransCount)
	- case when TransWithCategory.GateCategory1 = N'EPOS'
		then (select 
				 SUM(Trans2.SucceedTransCount)
			from 
				#TransWithCategory Trans2 
			where 
				Trans2.GateCategory1 = N'EPOS' 
				and 
				Trans2.MerchantNo in (select MerchantNo from Table_EposTakeoffMerchant)
				)
		else 0
		end SucceedTransCount,
	SUM(TransWithCategory.SucceedTransAmount)
	- case when TransWithCategory.GateCategory1 = N'EPOS'
		then (select 
				 SUM(Trans2.SucceedTransAmount)
			from 
				#TransWithCategory Trans2 
			where 
				Trans2.GateCategory1 = N'EPOS' 
				and 
				Trans2.MerchantNo in (select MerchantNo from Table_EposTakeoffMerchant)
				)
		else 0
		end SucceedTransAmount
into
	#LastYearGateCategoryAmount
from
	#LastYearTransWithCategory TransWithCategory
group by
	TransWithCategory.GateCategory1;

--4.4 Get This Year Running Data
--4.4.1 Filter FactDailyTrans Data
select
	GateCategory.GateCategory1,
	Trans.MerchantNo,
	Trans.SucceedTransAmount
into
	#ThisYearTransWithCategory
from
	dbo.Table_GateCategory GateCategory
	inner join
	dbo.FactDailyTrans Trans
	on
		GateCategory.GateNo = Trans.GateNo
where
	Trans.DailyTransDate >= @ThisYearRunningStartDate
	and
	Trans.DailyTransDate < @ThisYearRunningEndDate
	and
	GateCategory.GateCategory1 <> N'#N/A';

--4.4.2 The result take Off Merchant from EPOS
select
	TransWithCategory.GateCategory1,
	SUM(TransWithCategory.SucceedTransAmount)
	- case when TransWithCategory.GateCategory1 = N'EPOS'
		then (select 
				 SUM(Trans2.SucceedTransAmount)
			from 
				#TransWithCategory Trans2 
			where 
				Trans2.GateCategory1 = N'EPOS' 
				and 
				Trans2.MerchantNo in (select MerchantNo from Table_EposTakeoffMerchant)
				)
		else 0
		end SucceedTransAmount
into
	#ThisYearGateCategoryAmount
from
	#ThisYearTransWithCategory TransWithCategory
group by
	TransWithCategory.GateCategory1;

--
	
--5. Get the ORA Data
--5.1 Get Current Data
select
	N'ORA' as GateCategory1,
	SUM(TransAmount) SucceedTransAmount,
	SUM(TransCount) SucceedTransCount
into
	#ORATransAmount
from
	Table_OraTransSum
where
	CPDate >= @CurrStartDate
	and
	CPDate < @CurrEndDate;

--5.2 Get Previous Data
select
	N'ORA' as GateCategory1,
	SUM(TransAmount) SucceedTransAmount,
	SUM(TransCount) SucceedTransCount
into
	#PrevORATransAmount
from
	Table_OraTransSum
where
	CPDate >= @PrevStartDate
	and
	CPDate < @PrevEndDate;
	
--5.3 Get Last Year Data
select
	N'ORA' as GateCategory1,
	SUM(TransAmount) SucceedTransAmount,
	SUM(TransCount) SucceedTransCount
into
	#LastYearORATransAmount
from
	Table_OraTransSum
where
	CPDate >= @LastYearStartDate
	and
	CPDate < @LastYearEndDate;
	
--5.4 Get This Year Data
select
	N'ORA' as GateCategory1,
	SUM(TransAmount) SucceedTransAmount
into
	#ThisYearORATransAmount
from
	Table_OraTransSum
where
	CPDate >= @ThisYearRunningStartDate
	and
	CPDate < @ThisYearRunningEndDate;
	
--6. Get Convenience Data
--6.1 Get Current Data
select
	N'����' as GateCategory1,
	SUM(SucceedTransAmount) SucceedTransAmount,
	SUM(SucceedTransCount) SucceedTransCount
into
	#ConveTransAmount
from
	FactDailyTrans
where
	DailyTransDate >= @CurrStartDate
	and
	DailyTransDate < @CurrEndDate
	and
	MerchantNo in (select MerchantNo from dbo.Table_InstuMerInfo where InstuNo = '000020100816001');

--6.2 Get Previous Data
select
	N'����' as GateCategory1,
	SUM(SucceedTransAmount) SucceedTransAmount,
	SUM(SucceedTransCount) SucceedTransCount
into
	#PrevConveTransAmount
from
	FactDailyTrans
where
	DailyTransDate >= @PrevStartDate
	and
	DailyTransDate < @PrevEndDate
	and
	MerchantNo in (select MerchantNo from dbo.Table_InstuMerInfo where InstuNo = '000020100816001');

--6.3 Get Last Year Data
select
	N'����' as GateCategory1,
	SUM(SucceedTransAmount) SucceedTransAmount,
	SUM(SucceedTransCount) SucceedTransCount
into
	#LastYearConveTransAmount
from
	FactDailyTrans
where
	DailyTransDate >= @LastYearStartDate
	and
	DailyTransDate < @LastYearEndDate
	and
	MerchantNo in (select MerchantNo from dbo.Table_InstuMerInfo where InstuNo = '000020100816001');
	
--6.4 Get This Year Data
select
	N'����' as GateCategory1,
	SUM(SucceedTransAmount) SucceedTransAmount
into
	#ThisYearConveTransAmount
from
	FactDailyTrans
where
	DailyTransDate >= @ThisYearRunningStartDate
	and
	DailyTransDate < @ThisYearRunningEndDate
	and
	MerchantNo in (select MerchantNo from dbo.Table_InstuMerInfo where InstuNo = '000020100816001');
	
--7.Get Transfer Data
--7.1 Get Current Data 
select
	N'ת��' as GateCategory1,
	SUM(TransAmt) SucceedTransAmount,
	COUNT(TransAmt) SucceedTransCount
into
	#TransferAmount
from
	Table_TrfTransLog
where
	TransDate >= @CurrStartDate
	and
	TransDate < @CurrEndDate
	and
	TransType = '2070';
	
--7.2 Get Previous Data 
select
	N'ת��' as GateCategory1,
	SUM(TransAmt) SucceedTransAmount,
	COUNT(TransAmt) SucceedTransCount
into
	#PrevTransferAmount
from
	Table_TrfTransLog
where
	TransDate >= @PrevStartDate
	and
	TransDate < @PrevEndDate
	and
	TransType = '2070';

--7.3 Get Last Year Data 
select
	N'ת��' as GateCategory1,
	SUM(TransAmt) SucceedTransAmount,
	COUNT(TransAmt) SucceedTransCount
into
	#LastYearTransferAmount
from
	Table_TrfTransLog
where
	TransDate >= @LastYearStartDate
	and
	TransDate < @LastYearEndDate
	and
	TransType = '2070';
	
--7.4 Get This Year Data 
select
	N'ת��' as GateCategory1,
	SUM(TransAmt) SucceedTransAmount
into
	#ThisYearTransferAmount
from
	Table_TrfTransLog
where
	TransDate >= @ThisYearRunningStartDate
	and
	TransDate < @ThisYearRunningEndDate
	and
	TransType = '2070';
	
--8. Get Fund Data
--8.1 Get Current Data
select
	N'����' as GateCategory1,
	SUM(TransAmt) SucceedTransAmount,
	COUNT(TransAmt) SucceedTransCount
into
	#FundTransAmount
from
	Table_TrfTransLog
where
	TransDate >= @CurrStartDate
	and
	TransDate < @CurrEndDate
	and
	TransType in ('3010','3020','3030','3040','3050');

--8.2 Get Previous Data
select
	N'����' as GateCategory1,
	SUM(TransAmt) SucceedTransAmount,
	COUNT(TransAmt) SucceedTransCount
into
	#PrevFundTransAmount
from
	Table_TrfTransLog
where
	TransDate >= @PrevStartDate
	and
	TransDate < @PrevEndDate
	and
	TransType in ('3010','3020','3030','3040','3050');

--8.3 Get Last Year Data
select
	N'����' as GateCategory1,
	SUM(TransAmt) SucceedTransAmount,
	COUNT(TransAmt) SucceedTransCount
into
	#LastYearFundTransAmount
from
	Table_TrfTransLog
where
	TransDate >= @LastYearStartDate
	and
	TransDate < @LastYearEndDate
	and
	TransType in ('3010','3020','3030','3040','3050');
	
--8.4 Get This Year Data
select
	N'����' as GateCategory1,
	SUM(TransAmt) SucceedTransAmount
into
	#ThisYearFundTransAmount
from
	Table_TrfTransLog
where
	TransDate >= @ThisYearRunningStartDate
	and
	TransDate < @ThisYearRunningEndDate
	and
	TransType in ('3010','3020','3030','3040','3050');
	
--9. Get Switch Data
--9.1 Get Current Data
select
	N'ת��' as GateCategory1,
	SUM(SucceedTransAmount) SucceedTransAmount,
	SUM(SucceedTransCount) SucceedTransCount
into
	#SwitchTransAmount
from
	FactDailyTrans
where
	DailyTransDate >= @CurrStartDate
	and
	DailyTransDate < @CurrEndDate
	and
	MerchantNo = '808080310004680';

--9.2 Get Previous Data
select
	N'ת��' as GateCategory1,
	SUM(SucceedTransAmount) SucceedTransAmount,
	SUM(SucceedTransCount) SucceedTransCount
into
	#PrevSwitchTransAmount
from
	FactDailyTrans
where
	DailyTransDate >= @PrevStartDate
	and
	DailyTransDate < @PrevEndDate
	and
	MerchantNo = '808080310004680';

--9.3 Get Last Year Data
select
	N'ת��' as GateCategory1,
	SUM(SucceedTransAmount) SucceedTransAmount,
	SUM(SucceedTransCount) SucceedTransCount
into
	#LastYearSwitchTransAmount
from
	FactDailyTrans
where
	DailyTransDate >= @LastYearStartDate
	and
	DailyTransDate < @LastYearEndDate
	and
	MerchantNo = '808080310004680';
	
--9.4 Get This Year Data
select
	N'ת��' as GateCategory1,
	SUM(SucceedTransAmount) SucceedTransAmount
into
	#ThisYearSwitchTransAmount
from
	FactDailyTrans
where
	DailyTransDate >= @ThisYearRunningStartDate
	and
	DailyTransDate < @ThisYearRunningEndDate
	and
	MerchantNo = '808080310004680';

--10.Get Foreign Merchants Data
--10.1 Get Current Data 
With CurrPayment as
(
	select
		N'�����յ�' as GateCategory1,
		SUM(Trans.SucceedTransAmount) SucceedTransAmount,
		SUM(Trans.SucceedTransCount) SucceedTransCount
	from
		Table_ForeignMerchants FM
		inner join
		FactDailyTrans Trans
		on
			FM.MerchantNo = Trans.MerchantNo
	where
		Trans.DailyTransDate >= @CurrStartDate
		and
		Trans.DailyTransDate < @CurrEndDate
),
CurrORA as
(
	select
		N'�����յ�' as GateCategory1,
		SUM(ORASum.TransAmount) SucceedTransAmount,
		SUM(ORASum.TransCount) SucceedTransCount
	from
		Table_ForeignMerchants FM
		inner join
		Table_OraTransSum ORASum
		on
			FM.MerchantNo = ORASum.MerchantNo
	where
		ORASum.CPDate >= @CurrStartDate
		and
		ORASum.CPDate < @CurrEndDate
)
select
	coalesce(CurrPayment.GateCategory1, CurrORA.GateCategory1) GateCategory1,
	ISNULL(CurrPayment.SucceedTransAmount, 0) + ISNULL(CurrORA.SucceedTransAmount, 0) SucceedTransAmount,
	ISNULL(CurrPayment.SucceedTransCount, 0) + ISNULL(CurrORA.SucceedTransCount, 0) SucceedTransCount
into
	#CurrForeignAmount
from
	CurrPayment
	full outer join
	CurrORA
	on
		CurrPayment.GateCategory1 = CurrORA.GateCategory1;

--10.2 Get Previous Data 
With CurrPayment as
(
	select
		N'�����յ�' as GateCategory1,
		SUM(Trans.SucceedTransAmount) SucceedTransAmount,
		SUM(Trans.SucceedTransCount) SucceedTransCount
	from
		Table_ForeignMerchants FM
		inner join
		FactDailyTrans Trans
		on
			FM.MerchantNo = Trans.MerchantNo
	where
		Trans.DailyTransDate >= @PrevStartDate
		and
		Trans.DailyTransDate < @PrevEndDate
),
CurrORA as
(
	select
		N'�����յ�' as GateCategory1,
		SUM(ORASum.TransAmount) SucceedTransAmount,
		SUM(ORASum.TransCount) SucceedTransCount
	from
		Table_ForeignMerchants FM
		inner join
		Table_OraTransSum ORASum
		on
			FM.MerchantNo = ORASum.MerchantNo
	where
		ORASum.CPDate >= @PrevStartDate
		and
		ORASum.CPDate < @PrevEndDate
)
select
	coalesce(CurrPayment.GateCategory1, CurrORA.GateCategory1) GateCategory1,
	ISNULL(CurrPayment.SucceedTransAmount, 0) + ISNULL(CurrORA.SucceedTransAmount, 0) SucceedTransAmount,
	ISNULL(CurrPayment.SucceedTransCount, 0) + ISNULL(CurrORA.SucceedTransCount, 0) SucceedTransCount
into
	#PrevForeignAmount
from
	CurrPayment
	full outer join
	CurrORA
	on
		CurrPayment.GateCategory1 = CurrORA.GateCategory1;

--10.3 Get Last Year Data 
With CurrPayment as
(
	select
		N'�����յ�' as GateCategory1,
		SUM(Trans.SucceedTransAmount) SucceedTransAmount,
		SUM(Trans.SucceedTransCount) SucceedTransCount
	from
		Table_ForeignMerchants FM
		inner join
		FactDailyTrans Trans
		on
			FM.MerchantNo = Trans.MerchantNo
	where
		Trans.DailyTransDate >= @LastYearStartDate
		and
		Trans.DailyTransDate < @LastYearEndDate
),
CurrORA as
(
	select
		N'�����յ�' as GateCategory1,
		SUM(ORASum.TransAmount) SucceedTransAmount,
		SUM(ORASum.TransCount) SucceedTransCount
	from
		Table_ForeignMerchants FM
		inner join
		Table_OraTransSum ORASum
		on
			FM.MerchantNo = ORASum.MerchantNo
	where
		ORASum.CPDate >= @LastYearStartDate
		and
		ORASum.CPDate < @LastYearEndDate
)
select
	coalesce(CurrPayment.GateCategory1, CurrORA.GateCategory1) GateCategory1,
	ISNULL(CurrPayment.SucceedTransAmount, 0) + ISNULL(CurrORA.SucceedTransAmount, 0) SucceedTransAmount,
	ISNULL(CurrPayment.SucceedTransCount, 0) + ISNULL(CurrORA.SucceedTransCount, 0) SucceedTransCount
into
	#LastYearForeignAmount
from
	CurrPayment
	full outer join
	CurrORA
	on
		CurrPayment.GateCategory1 = CurrORA.GateCategory1;
	
--10.4 Get This Year Data 
With CurrPayment as
(
	select
		N'�����յ�' as GateCategory1,
		SUM(Trans.SucceedTransAmount) SucceedTransAmount,
		SUM(Trans.SucceedTransCount) SucceedTransCount
	from
		Table_ForeignMerchants FM
		inner join
		FactDailyTrans Trans
		on
			FM.MerchantNo = Trans.MerchantNo
	where
		Trans.DailyTransDate >= @ThisYearRunningStartDate
		and
		Trans.DailyTransDate < @ThisYearRunningEndDate
),
CurrORA as
(
	select
		N'�����յ�' as GateCategory1,
		SUM(ORASum.TransAmount) SucceedTransAmount,
		SUM(ORASum.TransCount) SucceedTransCount
	from
		Table_ForeignMerchants FM
		inner join
		Table_OraTransSum ORASum
		on
			FM.MerchantNo = ORASum.MerchantNo
	where
		ORASum.CPDate >= @ThisYearRunningStartDate
		and
		ORASum.CPDate < @ThisYearRunningEndDate
)
select
	coalesce(CurrPayment.GateCategory1, CurrORA.GateCategory1) GateCategory1,
	ISNULL(CurrPayment.SucceedTransAmount, 0) + ISNULL(CurrORA.SucceedTransAmount, 0) SucceedTransAmount,
	ISNULL(CurrPayment.SucceedTransCount, 0) + ISNULL(CurrORA.SucceedTransCount, 0) SucceedTransCount
into
	#ThisYearForeignAmount
from
	CurrPayment
	full outer join
	CurrORA
	on
		CurrPayment.GateCategory1 = CurrORA.GateCategory1;
		
--11. Get Owned Account Data
--11.1 Get Current Data
select
	Gate.GateNo,
	SUM(Trans.SucceedTransAmount) SucceedTransAmount,
	SUM(Trans.SucceedTransCount) SucceedTransCount
into
	#CurrOwnedAccountTransAmount
from
	Table_GateCategory Gate
	left join
	FactDailyTrans Trans
	on
		Gate.GateNo = Trans.GateNo
where
	Gate.GateCategory1 = N'�����˻�'
	and
	Trans.DailyTransDate >= @CurrStartDate
	and
	Trans.DailyTransDate < @CurrEndDate
group by
	Gate.GateNo;

--11.2 Get Previous Data
select
	Gate.GateNo,
	SUM(Trans.SucceedTransAmount) SucceedTransAmount,
	SUM(Trans.SucceedTransCount) SucceedTransCount
into
	#PrevOwnedAccountTransAmount
from
	Table_GateCategory Gate
	left join
	FactDailyTrans Trans
	on
		Gate.GateNo = Trans.GateNo
where
	Gate.GateCategory1 = N'�����˻�'
	and
	Trans.DailyTransDate >= @PrevStartDate
	and
	Trans.DailyTransDate < @PrevEndDate
group by
	Gate.GateNo;

--11.3 Get Last Year Data
select
	Gate.GateNo,
	SUM(Trans.SucceedTransAmount) SucceedTransAmount,
	SUM(Trans.SucceedTransCount) SucceedTransCount
into
	#LastYearOwnedAccountTransAmount
from
	Table_GateCategory Gate
	left join
	FactDailyTrans Trans
	on
		Gate.GateNo = Trans.GateNo
where
	Gate.GateCategory1 = N'�����˻�'
	and
	Trans.DailyTransDate >= @LastYearStartDate
	and
	Trans.DailyTransDate < @LastYearEndDate
group by
	Gate.GateNo;
	
--11.4 Get This Year Data
select
	Gate.GateNo,
	SUM(Trans.SucceedTransAmount) SucceedTransAmount,
	SUM(Trans.SucceedTransCount) SucceedTransCount
into
	#ThisYearOwnedAccountTransAmount
from
	Table_GateCategory Gate
	left join
	FactDailyTrans Trans
	on
		Gate.GateNo = Trans.GateNo
where
	Gate.GateCategory1 = N'�����˻�'
	and
	Trans.DailyTransDate >= @ThisYearRunningStartDate
	and
	Trans.DailyTransDate < @ThisYearRunningEndDate
group by
	Gate.GateNo;
	
--11.5 Get the Final Owned Account Data
select 
	N'�����˻�����' as GroupName,
	200+ROW_NUMBER() Over(order by Gate.GateNo) as ItemID,
	GateRoute.GateDesc as BizCategory,
	Convert(decimal,isnull(Curr.SucceedTransAmount,0))/100 SucceedTransAmount,
	isnull(Curr.SucceedTransCount,0) SucceedTransCount,
	CONVERT(decimal,isnull(Prev.SucceedTransAmount,0))/100 PrevSucceedTransAmount,
	ISNULL(Prev.SucceedTransCount,0) PrevSucceedTransCount,
	CONVERT(decimal,isnull(LastYear.SucceedTransAmount,0))/100 LastYearSucceedTransAmount,
	ISNULL(LastYear.SucceedTransCount,0) LastYearSucceedTransCount,
	CONVERT(decimal,ISNULL(ThisYear.SucceedTransAmount,0))/100 ThisYearSucceedTransAmount
into
	#OwnedAccountTransData
from
	Table_GateCategory Gate
	inner join
	Table_GateRoute GateRoute
	on
		Gate.GateNo = GateRoute.GateNo
	left join
	#CurrOwnedAccountTransAmount Curr
	on
		Gate.GateNo = Curr.GateNo
	left join
	#PrevOwnedAccountTransAmount Prev
	on
		Gate.GateNo = Prev.GateNo
	left join
	#LastYearOwnedAccountTransAmount LastYear
	on
		Gate.GateNo = LastYear.GateNo
	left join
	#ThisYearOwnedAccountTransAmount ThisYear
	on
		Gate.GateNo = ThisYear.GateNo
where
	Gate.GateCategory1 = N'�����˻�';
		
--12. Get Final Result	
select 
	BizCategoryTable.GroupName,
	BizCategoryTable.ItemID,
	BizCategoryTable.BizCategory,
	Convert(Decimal,coalesce(GateCategoryAmount.SucceedTransAmount,ORATransAmount.SucceedTransAmount,ConveTransAmount.SucceedTransAmount,TransferAmount.SucceedTransAmount,FundTransAmount.SucceedTransAmount,SwitchTransAmount.SucceedTransAmount,CurrForeignAmount.SucceedTransAmount,0))/100 SucceedTransAmount,
	coalesce(GateCategoryAmount.SucceedTransCount,ORATransAmount.SucceedTransCount,ConveTransAmount.SucceedTransCount,TransferAmount.SucceedTransCount,FundTransAmount.SucceedTransCount,SwitchTransAmount.SucceedTransCount,CurrForeignAmount.SucceedTransCount,0) SucceedTransCount,
	Convert(Decimal,coalesce(PrevGateCategoryAmount.SucceedTransAmount,PrevORATransAmount.SucceedTransAmount,PrevConveTransAmount.SucceedTransAmount,PrevTransferAmount.SucceedTransAmount,PrevFundTransAmount.SucceedTransAmount,PrevSwitchTransAmount.SucceedTransAmount,PrevForeignAmount.SucceedTransAmount,0))/100 PrevSucceedTransAmount,
	coalesce(PrevGateCategoryAmount.SucceedTransCount,PrevORATransAmount.SucceedTransCount,PrevConveTransAmount.SucceedTransCount,PrevTransferAmount.SucceedTransCount,PrevFundTransAmount.SucceedTransCount,PrevSwitchTransAmount.SucceedTransCount,PrevForeignAmount.SucceedTransCount,0) PrevSucceedTransCount,
	Convert(Decimal,coalesce(LastYearGateCategoryAmount.SucceedTransAmount,LastYearORATransAmount.SucceedTransAmount,LastYearConveTransAmount.SucceedTransAmount,LastYearTransferAmount.SucceedTransAmount,LastYearFundTransAmount.SucceedTransAmount,LastYearSwitchTransAmount.SucceedTransAmount,LastYearForeignAmount.SucceedTransAmount,0))/100 LastYearSucceedTransAmount,
	coalesce(LastYearGateCategoryAmount.SucceedTransCount,LastYearORATransAmount.SucceedTransCount,LastYearConveTransAmount.SucceedTransCount,LastYearTransferAmount.SucceedTransCount,LastYearFundTransAmount.SucceedTransCount,LastYearSwitchTransAmount.SucceedTransCount,LastYearForeignAmount.SucceedTransCount,0) LastYearSucceedTransCount,
	Convert(Decimal,coalesce(ThisYearGateCategoryAmount.SucceedTransAmount,ThisYearORATransAmount.SucceedTransAmount,ThisYearConveTransAmount.SucceedTransAmount,ThisYearTransferAmount.SucceedTransAmount,ThisYearFundTransAmount.SucceedTransAmount,ThisYearSwitchTransAmount.SucceedTransAmount,ThisYearForeignAmount.SucceedTransAmount,0))/100 ThisYearSucceedTransAmount
from  
	#BizCategoryTable BizCategoryTable
	left join
	#GateCategoryAmount GateCategoryAmount
	on
		BizCategoryTable.GateCategory1 = GateCategoryAmount.GateCategory1
	left join
	#ORATransAmount ORATransAmount
	on
		BizCategoryTable.GateCategory1 = ORATransAmount.GateCategory1
	left join
	#ConveTransAmount ConveTransAmount
	on
		BizCategoryTable.GateCategory1 = ConveTransAmount.GateCategory1
	left join
	#TransferAmount TransferAmount
	on
		BizCategoryTable.GateCategory1 = TransferAmount.GateCategory1
	left join
	#FundTransAmount FundTransAmount
	on
		BizCategoryTable.GateCategory1 = FundTransAmount.GateCategory1
	left join
	#SwitchTransAmount SwitchTransAmount
	on
		BizCategoryTable.GateCategory1 = SwitchTransAmount.GateCategory1
	left join
	#CurrForeignAmount CurrForeignAmount
	on
		BizCategoryTable.GateCategory1 = CurrForeignAmount.GateCategory1
	left join
	#PrevGateCategoryAmount PrevGateCategoryAmount
	on
		BizCategoryTable.GateCategory1 = PrevGateCategoryAmount.GateCategory1
	left join
	#PrevORATransAmount PrevORATransAmount
	on
		BizCategoryTable.GateCategory1 = PrevORATransAmount.GateCategory1
	left join
	#PrevConveTransAmount PrevConveTransAmount
	on
		BizCategoryTable.GateCategory1 = PrevConveTransAmount.GateCategory1
	left join
	#PrevTransferAmount PrevTransferAmount
	on
		BizCategoryTable.GateCategory1 = PrevTransferAmount.GateCategory1
	left join
	#PrevFundTransAmount PrevFundTransAmount
	on
		BizCategoryTable.GateCategory1 = PrevFundTransAmount.GateCategory1
	left join
	#PrevSwitchTransAmount PrevSwitchTransAmount
	on
		BizCategoryTable.GateCategory1 = PrevSwitchTransAmount.GateCategory1
	left join
	#PrevForeignAmount PrevForeignAmount
	on
		BizCategoryTable.GateCategory1 = PrevForeignAmount.GateCategory1
	left join
	#LastYearGateCategoryAmount LastYearGateCategoryAmount
	on
		BizCategoryTable.GateCategory1 = LastYearGateCategoryAmount.GateCategory1
	left join
	#LastYearORATransAmount LastYearORATransAmount
	on
		BizCategoryTable.GateCategory1 = LastYearORATransAmount.GateCategory1
	left join
	#LastYearConveTransAmount LastYearConveTransAmount
	on
		BizCategoryTable.GateCategory1 = LastYearConveTransAmount.GateCategory1
	left join
	#LastYearTransferAmount LastYearTransferAmount
	on
		BizCategoryTable.GateCategory1 = LastYearTransferAmount.GateCategory1
	left join
	#LastYearFundTransAmount LastYearFundTransAmount
	on
		BizCategoryTable.GateCategory1 = LastYearFundTransAmount.GateCategory1
	left join
	#LastYearSwitchTransAmount LastYearSwitchTransAmount
	on
		BizCategoryTable.GateCategory1 = LastYearSwitchTransAmount.GateCategory1
	left join
	#LastYearForeignAmount LastYearForeignAmount
	on
		BizCategoryTable.GateCategory1 = LastYearForeignAmount.GateCategory1
	left join
	#ThisYearGateCategoryAmount ThisYearGateCategoryAmount
	on
		BizCategoryTable.GateCategory1 = ThisYearGateCategoryAmount.GateCategory1
	left join
	#ThisYearORATransAmount ThisYearORATransAmount
	on
		BizCategoryTable.GateCategory1 = ThisYearORATransAmount.GateCategory1
	left join
	#ThisYearConveTransAmount ThisYearConveTransAmount
	on
		BizCategoryTable.GateCategory1 = ThisYearConveTransAmount.GateCategory1
	left join
	#ThisYearTransferAmount ThisYearTransferAmount
	on
		BizCategoryTable.GateCategory1 = ThisYearTransferAmount.GateCategory1
	left join
	#ThisYearFundTransAmount ThisYearFundTransAmount
	on
		BizCategoryTable.GateCategory1 = ThisYearFundTransAmount.GateCategory1
	left join
	#ThisYearSwitchTransAmount ThisYearSwitchTransAmount
	on
		BizCategoryTable.GateCategory1 = ThisYearSwitchTransAmount.GateCategory1
	left join
	#ThisYearForeignAmount ThisYearForeignAmount
	on
		BizCategoryTable.GateCategory1 = ThisYearForeignAmount.GateCategory1
union all
select * from #OwnedAccountTransData;
		
--13. Drop Table	
drop table #BizCategoryTable;

drop table #TransWithCategory;
drop table #GateCategoryAmount;
drop table #ORATransAmount;
drop table #ConveTransAmount;
drop table #TransferAmount;
drop table #FundTransAmount;
drop table #SwitchTransAmount;
drop table #CurrForeignAmount;
drop table #CurrOwnedAccountTransAmount;

drop table #PrevTransWithCategory;
drop table #PrevGateCategoryAmount;
drop table #PrevORATransAmount;
drop table #PrevConveTransAmount;
drop table #PrevTransferAmount;
drop table #PrevFundTransAmount;
drop table #PrevSwitchTransAmount;
drop table #PrevForeignAmount;

drop table #LastYearTransWithCategory;
drop table #LastYearGateCategoryAmount;
drop table #LastYearORATransAmount;
drop table #LastYearConveTransAmount;
drop table #LastYearTransferAmount;
drop table #LastYearFundTransAmount;
drop table #LastYearSwitchTransAmount;
drop table #LastYearForeignAmount;

drop table #ThisYearTransWithCategory;
drop table #ThisYearGateCategoryAmount;
drop table #ThisYearORATransAmount;
drop table #ThisYearConveTransAmount;
drop table #ThisYearTransferAmount;
drop table #ThisYearFundTransAmount;
drop table #ThisYearSwitchTransAmount;
drop table #ThisYearForeignAmount;

drop table #OwnedAccountTransData;
End