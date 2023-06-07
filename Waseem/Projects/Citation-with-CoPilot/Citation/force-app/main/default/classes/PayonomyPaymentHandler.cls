/*
    * FinancialForce.com, inc. claims copyright in this software, its screen display designs and
    * supporting documentation. FinancialForce and FinancialForce.com are trademarks of FinancialForce.com, inc.
    * Any unauthorized use, copying or sale of the above may constitute an infringement of copyright and may
    * result in criminal or other legal proceedings.
    *
    * Copyright FinancialForce.com, inc. All rights reserved.
    * Created by Uves Ravat
*/
public class PayonomyPaymentHandler 
{
	private static string ns;
	private static string ns2;

	/**
		* For every Payonomy Payment Generated, a Cash Entry will be created at the time of Payonomy Payment Collection Process
		* Cash Entry will be linked to a Payonomy Payment Agreement 
		* Payonomy Payment can be linked back to a Cash Entry based on Payonomy Payment Agreement and Net Value
	**/
	public static void beforeInsertHandler()
	{	
		//Correct Namespace selected
        ns = 'PAYBASE2__';
        ns2 ='PAYREC2__'; 
        
        Set<id> payonomyPaymentAgreementIds = new Set<id>();

       	//Generate Set of Payment Agreement Ids
		for(sObject payment :Trigger.new)
		{
			if(payment.get(ns2 + 'Payment_Agreement__c') != null) payonomyPaymentAgreementIds.add((id)payment.get(ns2 + 'Payment_Agreement__c'));
		}

		//Find all Cash Entries which are not linked to a Payonomy Payment Record
		if(!payonomyPaymentAgreementIds.isEmpty())
		{
			Map<id, List<CashEntry>> cashEntries = getCashEntries(payonomyPaymentAgreementIds);
			List<c2g__codaCashEntry__c> cashEntriesToUpdate = new List<c2g__codaCashEntry__c>();

			//Loop through Payonomy Payments again
			for(sObject payment :Trigger.new)
			{
				if(payment.get(ns2 + 'Payment_Agreement__c') != null && cashEntries.containsKey((id)payment.get(ns2 + 'Payment_Agreement__c')) )
				{
					for(CashEntry wr :cashEntries.get((id)payment.get(ns2 + 'Payment_Agreement__c')) )
					{
						//if wrapper record has already been processed we can ignore it
						if(wr.processed) continue;

						//Find a Cash Entry with the following values
						//Update Payonomy Payment and Cash Entry Records
						if((Decimal)payment.get(ns + 'Amount__c') == wr.csh.c2g__NetValue__c)
						{
							payment.put('CashEntry__c', wr.csh.id);
							wr.processed = true;
							wr.csh.ffps_cita__LinkedToPayonomyPayment__c = true;
							cashEntriesToUpdate.add(wr.csh);

							continue;
						}
					}
				}
			}
			//Update Cash Entries 
			if(!cashEntriesToUpdate.isEmpty()) update cashEntriesToUpdate;
		}
	}

	private static Map<id, List<CashEntry>> getCashEntries(Set<id> payonomyPaymentAgreementIds)
	{
        Date lstModifiedDate = system.today().addmonths(-2);
        
		Map<id, List<CashEntry>> rtnMap = new Map<id, List<CashEntry>>();

		List<c2g__codaCashEntry__c> cashEntries =
			[SELECT 
				id, 
				name,
				c2g__NetValue__c, 
				ffps_cita__PayonomyPaymentAgreementId__c,
				ffps_cita__LinkedToPayonomyPayment__c
			FROM 
				c2g__codaCashEntry__c
			WHERE 
				ffps_cita__PayonomyPaymentAgreementId__c IN :payonomyPaymentAgreementIds
			AND 
				ffps_cita__LinkedToPayonomyPayment__c = false
            AND 
            	LastModifiedDate >= :lstModifiedDate];

		for(c2g__codaCashEntry__c csh :cashEntries)
		{
			if(!rtnMap.containsKey(csh.ffps_cita__PayonomyPaymentAgreementId__c))
			{
				rtnMap.put(csh.ffps_cita__PayonomyPaymentAgreementId__c, new List<CashEntry>());
			}
			rtnMap.get(csh.ffps_cita__PayonomyPaymentAgreementId__c).add(new CashEntry(csh));
		}

		return rtnMap;
	}

	public class CashEntry
	{
		public c2g__codaCashEntry__c csh {get; set;}
		public Boolean processed {get; set;}

		public CashEntry(c2g__codaCashEntry__c csh)
		{
			this.csh = csh;
			this.processed = false;
		}
	}
}