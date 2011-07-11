With TransWithCardNo as
(
	select
		TransDate,
		MerchantNo,
		TransType,
		TransAmt,
		FeeAmt,
		FundType,
		case when
			TransType in ('1010','3010')
		then
			CardID
		else
			CardTwo
		end CardNo
	from
		dbo.Table_TrfTransLog
	where
		TransType in ('1010','3010','3020','3030','3040','3050')
)
select
	TransWithCardNo.MerchantNo,
	FundCardBin.BankNo,
	Left(Right(TransWithCardNo.CardNo,LEN(TransWithCardNo.CardNo)-LEN(FundCardBin.CardBin)),2) as BranchNo,
	TransWithCardNo.TransType,
	TransWithCardNo.FundType,
	Sum(TransWithCardNo.TransAmt) as TransAmount,
	COUNT(TransWithCardNo.TransAmt) as TransCount,
	SUM(TransWithCardNo.FeeAmt) as FeeAmount
into
	#ResultTable
from
	TransWithCardNo
	left join
	dbo.Table_FundCardBin FundCardBin
	on
		TransWithCardNo.CardNo like (RTrim(FundCardBin.CardBin)+'%')
	left join
	dbo.Table_FundBankBranch FundBankBranch
	on
		FundCardBin.BankNo = FundBankBranch.BankNo
		and
		Left(Right(TransWithCardNo.CardNo,LEN(TransWithCardNo.CardNo)-LEN(FundCardBin.CardBin)),2) like RTrim(FundBankBranch.BankBranchNo)
where
	FundCardBin.CardBin is not null
group by
	TransWithCardNo.MerchantNo,
	FundCardBin.BankNo,
	Left(Right(TransWithCardNo.CardNo,LEN(TransWithCardNo.CardNo)-LEN(FundCardBin.CardBin)),2),
	TransWithCardNo.FundType,
	TransWithCardNo.TransType
order by
	TransWithCardNo.MerchantNo,
	FundCardBin.BankNo;
	
select 
	RT.MerchantNo,
	RT.BankNo,
	RT.BranchNo,	
--����
	case when
		RT.TransType = '1010'
	then
		N'������֤'
--�깺		
	when
		RT.TransType = '3010' and RT.FundType = '0'
	then
		N'�깺��Ʊ��'
	when
		RT.TransType = '3010' and RT.FundType = '1'
	then
		N'�깺������'
	when
		RT.TransType = '3010' and RT.FundType = '2'
	then
		N'�깺ծȯ��'		
	when
		RT.TransType = '3010' and RT.FundType not in ('0','1','2')
	then
		N'�깺������'
--����		
	when
		RT.TransType = '3020'
	then
		N'����'
--���
	when
		RT.TransType = '3030' and RT.FundType = '0'
	then
		N'��ع�Ʊ��'
	when
		RT.TransType = '3030' and RT.FundType = '1'
	then
		N'��ػ�����'
	when
		RT.TransType = '3030' and RT.FundType = '2'
	then
		N'���ծȯ��'		
	when
		RT.TransType = '3030' and RT.FundType not in ('0','1','2')
	then
		N'���������'
--�ֺ�	
	when
		RT.TransType = '3040'
	then
		N'�ֺ�'
--��Ͷ
	when
		RT.TransType = '3050'
	then
		N'��Ͷ'			
	end ColName,
	RT.TransAmount,
	RT.TransCount
into
	#ResultTable2
from
	#ResultTable RT;
	

select
	RT.MerchantNo,
	RT.BankNo,
	RT.BranchNo,
	SUM(case when
		ColName = N'����'
	then
		TransCount
	else
		0
	end) as RegisterCount,
	
	SUM(case when
		ColName = N'�깺������'
	then
		TransCount
	else
		0
	end) as PurchaseCurrencyCount,
	SUM(case when
		ColName = N'�깺������'
	then
		TransAmount
	else
		0
	end) as PurchaseCurrencyAmount,
	
	SUM(case when
		ColName = N'�깺��Ʊ��'
	then
		TransCount
	else
		0
	end) as PurchaseStockCount,
	SUM(case when
		ColName = N'�깺��Ʊ��'
	then
		TransAmount
	else
		0
	end) as PurchaseStockAmount,
	
	SUM(case when
		ColName = N'�깺ծȯ��'
	then
		TransCount
	else
		0
	end) as PurchaseBondCount,
	SUM(case when
		ColName = N'�깺ծȯ��'
	then
		TransAmount
	else
		0
	end) as PurchaseBondAmount,
	
	SUM(case when
		ColName = N'�깺������'
	then
		TransCount
	else
		0
	end) as PurchaseOtherCount,
	SUM(case when
		ColName = N'�깺������'
	then
		TransAmount
	else
		0
	end) as PurchaseOtherAmount,
	
	SUM(case when
		ColName = N'����'
	then
		TransCount
	else
		0
	end) as RetractCount,
	SUM(case when
		ColName = N'����'
	then
		TransAmount
	else
		0
	end) as RetractAmount,
	
	SUM(case when
		ColName = N'��ػ�����'
	then
		TransCount
	else
		0
	end) as RedemptoryCurrencyCount,
	SUM(case when
		ColName = N'��ػ�����'
	then
		TransAmount
	else
		0
	end) as RedemptoryCurrencyAmount,
	
	SUM(case when
		ColName = N'��ع�Ʊ��'
	then
		TransCount
	else
		0
	end) as RedemptoryStockCount,
	SUM(case when
		ColName = N'��ع�Ʊ��'
	then
		TransAmount
	else
		0
	end) as RedemptoryStockAmount,
	
	SUM(case when
		ColName = N'���ծȯ��'
	then
		TransCount
	else
		0
	end) as RedemptoryBondCount,
	SUM(case when
		ColName = N'���ծȯ��'
	then
		TransAmount
	else
		0
	end) as RedemptoryBondAmount,
	
	SUM(case when
		ColName = N'���������'
	then
		TransCount
	else
		0
	end) as RedemptoryOtherCount,
	SUM(case when
		ColName = N'���������'
	then
		TransAmount
	else
		0
	end) as RedemptoryOtherAmount,
	
	SUM(case when
		ColName = N'�ֺ�'
	then
		TransCount
	else
		0
	end) as DividendCount,
	SUM(case when
		ColName = N'�ֺ�'
	then
		TransAmount
	else
		0
	end) as DividendAmount,	
	
	SUM(case when
		ColName = N'��Ͷ'
	then
		TransCount
	else
		0
	end) as ScheduleCount,
	SUM(case when
		ColName = N'��Ͷ'
	then
		TransAmount
	else
		0
	end) as ScheduleAmount
into
	#ResultTable3
from
	#ResultTable2 RT
group by
	MerchantNo,
	BankNo,
	BranchNo;


select
	BankID.BankName,
	ISNULL(FundBankBranch.BankBranchName, N'����') BankBranchName,
	MerInfo.MerchantName,
	Result.*
from
	#ResultTable3 Result
	left join
	Table_BankID BankID
	on
		Result.BankNo = BankID.BankNo
	left join
	Table_FundBankBranch FundBankBranch
	on
		Result.BranchNo = FundBankBranch.BankBranchNo
	left join
	Table_MerInfo MerInfo
	on
		Result.MerchantNo = MerInfo.MerchantNo;
		
		
		
drop table #ResultTable;
drop table #ResultTable2;
drop table #ResultTable3;