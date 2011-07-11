
--1. Create BizCategory Table
Create Table #BizCategoryTable
(
	GroupName char(20),
	ItemID int,
	BizCategory char(20),
	GateCategory1 char(40)
);
insert into #BizCategoryTable(GroupName,ItemID,BizCategory,GateCategory1) values
(N'ͨ���ͽ���',1,N'ֱ������(B2C)',N'B2C'),
(N'ͨ���ͽ���',2,N'��ҵ����(B2B)',N'B2B'),
(N'ͨ���ͽ���',3,N'CUPSecure����',N'CUPSecure'),
(N'ͨ���ͽ���',4,N'UPOP����',N'UPOP'),
(N'ͨ���ͽ���',5,N'�⿨����',N'�⿨'),
(N'ͨ���ͽ���',6,N'Ԥ���ѿ�����',N''),
(N'ͨ���ͽ���',7,N'���ÿ�MOTO����',N'MOTO'),
(N'ͨ���ͽ���',8,N'��ǿ�IVR����',N''),
(N'�����˻�����',9,N'����������',N'������'),
(N'�������㽻��',10,N'���մ���',N'����'),
(N'�������㽻��',11,N'��������',N'ORA'),
(N'�������㽻��',12,N'���˽���',N''),
(N'�������㽻��',13,N'������',N'EPOS'),
(N'�������㽻��',14,N'B2B�ֽ�֧��',N''),
(N'�������㽻��',15,N'���ÿ�����',N''),
(N'�������㽻��',16,N'����ɷ�',N'����'),
(N'�������㽻��',17,N'�����ն��˵�',N''),
(N'�������㽻��',18,N'�յ�����ί�н���',N''),
(N'�������㽻��',19,N'���������',N''),
(N'�������㽻��',20,N'�����յ�����',N''),
(N'���������㽻��',21,N'���п�����ת��',N'ת��'),
(N'���������㽻��',22,N'����ֱ������',N'����'),
(N'���������㽻��',23,N'ת�ӷֹ�˾����',N'ת��');

--2. Get the FactDailyTrans Data
--2.1 Filter FactDailyTrans Data
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
	Trans.DailyTransDate >= '2011-04-01'
	and
	Trans.DailyTransDate < '2011-05-01'
	and
	GateCategory.GateCategory1 <> N'#N/A';

--2.2 The result take Off Merchant from EPOS
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

--2. Get the ORA Data
select
	N'ORA' as GateCategory1,
	SUM(TransAmount) SucceedTransAmount,
	SUM(TransCount) SucceedTransCount
into
	#ORATransAmount
from
	Table_OraTransSum
where
	CPDate >= '2011-04-01'
	and
	CPDate < '2011-05-01'
	
--3. Get Convenience Data
select
	N'����' as GateCategory1,
	SUM(SucceedTransAmount) SucceedTransAmount,
	SUM(SucceedTransCount) SucceedTransCount
into
	#ConveTransAmount
from
	FactDailyTrans
where
	DailyTransDate >= '2011-04-01'
	and
	DailyTransDate < '2011-05-01'
	and
	MerchantNo in (select MerchantNo from dbo.Table_InstuMerInfo where InstuNo = '000020100816001');
	
--4.Get Transfer Data
select
	N'ת��' as GateCategory1,
	SUM(TransAmt) SucceedTransAmount,
	COUNT(TransAmt) SucceedTransCount
into
	#TransferAmount
from
	Table_TrfTransLog
where
	TransDate >= '2011-04-01'
	and
	TransDate < '2011-05-01'
	and
	TransType = '2070'
	
--5. Get Fund Data
select
	N'����' as GateCategory1,
	SUM(TransAmt) SucceedTransAmount,
	COUNT(TransAmt) SucceedTransCount
into
	#FundTransAmount
from
	Table_TrfTransLog
where
	TransDate >= '2011-04-01'
	and
	TransDate < '2011-05-01'
	and
	TransType in ('3010','3020','3030','3040','3050')
	
--6. Get Switch Data
select
	N'ת��' as GateCategory1,
	SUM(SucceedTransAmount) SucceedTransAmount,
	SUM(SucceedTransCount) SucceedTransCount
into
	#SwitchTransAmount
from
	FactDailyTrans
where
	DailyTransDate >= '2011-04-01'
	and
	DailyTransDate < '2011-05-01'
	and
	MerchantNo = '808080310004680';
	
select 
	BizCategoryTable.GroupName,
	BizCategoryTable.ItemID,
	BizCategoryTable.BizCategory,
	coalesce(GateCategoryAmount.SucceedTransAmount,ORATransAmount.SucceedTransAmount,ConveTransAmount.SucceedTransAmount,TransferAmount.SucceedTransAmount,FundTransAmount.SucceedTransAmount,SwitchTransAmount.SucceedTransAmount) SucceedTransAmount,
	coalesce(GateCategoryAmount.SucceedTransCount,ORATransAmount.SucceedTransCount,ConveTransAmount.SucceedTransCount,TransferAmount.SucceedTransCount,FundTransAmount.SucceedTransCount,SwitchTransAmount.SucceedTransCount) SucceedTransCount
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
		BizCategoryTable.GateCategory1 = SwitchTransAmount.GateCategory1;
		
		
drop table #BizCategoryTable;
drop table #TransWithCategory;
drop table #GateCategoryAmount;
drop table #ORATransAmount;
drop table #ConveTransAmount;
drop table #TransferAmount;
drop table #FundTransAmount;
drop table #SwitchTransAmount;