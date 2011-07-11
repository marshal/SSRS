select
	Trans.MerchantNo,
	case when
		Trans.DailyTransDate >= '2010-01-01' and Trans.DailyTransDate < '2011-01-01'
	then
		N'2011��ǰ������'
	when
		Trans.DailyTransDate >= '2011-01-01' and Trans.DailyTransDate < '2011-02-01'
	then
		N'2011��1�½�����'
	when
		Trans.DailyTransDate >= '2011-02-01' and Trans.DailyTransDate < '2011-03-01'
	then
		N'2011��2�½�����'
	when
		Trans.DailyTransDate >= '2011-03-01' and Trans.DailyTransDate < '2011-04-01'
	then
		N'2011��3�½�����'
	when
		Trans.DailyTransDate >= '2011-04-01' and Trans.DailyTransDate < '2011-05-01'
	then
		N'2011��4�½�����'
	when
		Trans.DailyTransDate >= '2011-05-01' and Trans.DailyTransDate < '2011-06-01'
	then
		N'2011��5�½�����'
	end as TradeDuration,
	SucceedTransCount,
	SucceedTransAmount
into
	#Trans
from
	FactDailyTrans Trans
where
	Trans.DailyTransDate < '2011-06-01';

		
select
	Trans.MerchantNo,
	Trans.TradeDuration,
	SUM(Trans.SucceedTransCount) SumCount,
	convert(decimal, SUM(Trans.SucceedTransAmount))/100 SumAmount
into
	#SumValue
from
	#Trans Trans
group by
	Trans.MerchantNo,
	Trans.TradeDuration;
	
select
	MerchantNo,
	
	SUM(case when TradeDuration = N'2011��ǰ������' then SumCount else 0 end) as N'2011��ǰ���ױ���',
	SUM(case when TradeDuration = N'2011��ǰ������' then SumAmount else 0 end) as N'2011��ǰ���׽��',
	
	SUM(case when TradeDuration = N'2011��1�½�����' then SumCount else 0 end) as N'2011��1�½��ױ���',
	SUM(case when TradeDuration = N'2011��1�½�����' then SumAmount else 0 end) as N'2011��1�½��׽��',
	
	SUM(case when TradeDuration = N'2011��2�½�����' then SumCount else 0 end) as N'2011��2�½��ױ���',
	SUM(case when TradeDuration = N'2011��2�½�����' then SumAmount else 0 end) as N'2011��2�½��׽��',

	SUM(case when TradeDuration = N'2011��3�½�����' then SumCount else 0 end) as N'2011��3�½��ױ���',
	SUM(case when TradeDuration = N'2011��3�½�����' then SumAmount else 0 end) as N'2011��3�½��׽��',

	SUM(case when TradeDuration = N'2011��4�½�����' then SumCount else 0 end) as N'2011��4�½��ױ���',
	SUM(case when TradeDuration = N'2011��4�½�����' then SumAmount else 0 end) as N'2011��4�½��׽��',

	SUM(case when TradeDuration = N'2011��5�½�����' then SumCount else 0 end) as N'2011��5�½��ױ���',
	SUM(case when TradeDuration = N'2011��5�½�����' then SumAmount else 0 end) as N'2011��5�½��׽��'
into
	#PivotSum
from
	#SumValue
group by
	MerchantNo;
	

select
	MerInfo.MerchantName,
	MerInfo.MerchantNo,
	case when 
		Config.Channel in (N'����',N'����') 
	then 
		N'����'+ isnull(Config.Area, N'') + N'�ֹ�˾'
	else
		N'ChinaPay'
	end as BranchName,
	
	case when
		Config.SigningYear is null or Config.SigningYear = 'History'
	then
		N'-'
	else
		Config.SigningYear
	end as OnlineYear,
	
	case when
		Config.MerchantType = N'�����̻�'
	then
		N'����'
	else
		N'����֧��'
	end as BizType,		
	isnull([2011��ǰ���ױ���],0) as [2011��ǰ���ױ���],
	isnull([2011��ǰ���׽��],0) as [2011��ǰ���׽��],
	
	isnull([2011��1�½��ױ���],0) as [2011��1�½��ױ���],
	isnull([2011��1�½��׽��],0) as [2011��1�½��׽��],
	
	isnull([2011��2�½��ױ���],0) as [2011��2�½��ױ���],
	isnull([2011��2�½��׽��],0) as [2011��2�½��׽��],

	isnull([2011��3�½��ױ���],0) as [2011��3�½��ױ���],
	isnull([2011��3�½��׽��],0) as [2011��3�½��׽��],

	isnull([2011��4�½��ױ���],0) as [2011��4�½��ױ���],
	isnull([2011��4�½��׽��],0) as [2011��4�½��׽��],

	isnull([2011��5�½��ױ���],0) as [2011��5�½��ױ���],
	isnull([2011��5�½��׽��],0) as [2011��5�½��׽��]
into
	#Result1
from
	#PivotSum PivotSum
	inner join
	Table_MerInfo MerInfo
	on
		PivotSum.MerchantNo = MerInfo.MerchantNo
	left join
	Table_SalesDeptConfiguration Config
	on
		PivotSum.MerchantNo = Config.MerchantNo;
		
select
	R1.*,
	R1.[2011��1�½��ױ���] + R1.[2011��2�½��ױ���] + R1.[2011��3�½��ױ���] + R1.[2011��4�½��ױ���] + R1.[2011��5�½��ױ���] as [2011��1-5�½��ױ���],
	R1.[2011��1�½��׽��] + R1.[2011��2�½��׽��] + R1.[2011��3�½��׽��] + R1.[2011��4�½��׽��] + R1.[2011��5�½��׽��] as [2011��1-5�½��׽��]
from
	#Result1 R1
	
	
drop table #Result1;
drop table #PivotSum;
drop table #SumValue;
drop table #Trans;