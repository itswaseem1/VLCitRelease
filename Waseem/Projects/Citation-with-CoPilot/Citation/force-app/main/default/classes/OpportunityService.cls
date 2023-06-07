public inherited sharing class OpportunityService extends DefaultService
{
    private static final String REGION_NORTH = 'North';
    private static final String REGION_SOUTH = 'South';
    private static final String BDM_SOUTH = 'BDM South';
    private static final String BDM_NORTH = 'BDM North';
    private static final String IHASCO_PRICEBOOK_NAME = 'iHasco';
    private static final String IHASCO_OPP_TYPE = 'IHASCO';
    private static final String IHASCO_CONTRACT_TYPE = 'iHASCO_Contract';
    private static final String RENEWAL = 'Renewal';
    private static final String NEW_BUSINESS = 'New Business';

    /*
    *   This implementation of the service will require a selector to handle loading
    *   records that it will need to perform its job.
    */
    public interface ISelector
    {
        /*
        *   User role names mapped by user Ids, but only for those whose role
        *   is 'BDM North or BDM South'.
        */
        Map<Id, String> getNorthSouthBDMS();

        /*
        *   get a record type Id.
        */
        Id getRecordTypeId(SObjectType objType, String devName);

        /*
        *   Find the price book 'Ihasco'
        */
        Id getIHascoPriceBook();

        /*
        *   get accounts related to the opportunities.
        */
        Map<Id, Account> getAccounts(List<Opportunity> opps);

        /*
        *   Get the contracts related to the opportunities.
        */
        Map<Id, Contract> getContracts(List<Opportunity> opps);
    }

    /*
    *   Our selector that we were provided by what ever created us.
    */
    private ISelector selector;

    public OpportunityService(ISelector selector) 
    {
        this.selector = selector;
    }

    /*
    *   see IDomainService
    */
    public override void setDefaults(List<SObject> newRecords)
    {
        super.setDefaults(newRecords);

        List<Opportunity> opps = (List<Opportunity>)newRecords;

        setIHascoDefaults(opps);
        setNorthSouth(opps);
        setPayroll(opps);
        setFMDate(opps);
        setIsCore(opps, null);
    }

    /*
    *   see IDomainService
    */
    public override void processChangedValues(List<SObject> newRecords, Map<Id, SObject> oldRecords)
    {
        super.processChangedValues(newRecords, oldRecords);

        List<Opportunity> opps = (List<Opportunity>)newRecords;
        Map<Id, Opportunity> oldOpps = (Map<Id, Opportunity>)oldRecords;

        setNorthSouth(opps);
        setIsCore(opps,oldOpps);
    }

    private void setIHascoDefaults(List<Opportunity> opps)
    {
        new IHascoDefaults(opps, selector).process();
    }

    private void setNorthSouth(List<Opportunity> opps)
    {
        new NorthSouth(opps, selector).process();
    }

    private void setPayroll(List<Opportunity> opps)
    {
        new Payroll(opps, selector).process();
    }

    private void setFMDate(List<Opportunity> opps)
    {
        new FMDate(opps).process();
    }
    
    private void setIsCore(List<Opportunity> opps, Map<Id, Opportunity> oldOpps)
    {
        new IsCoreOpp(opps, oldOpps).process();
    }

    /*
    *   Our default selector.
    */
    public class DefaultSelector extends RecordTypeSelector implements ISelector
    {
        public Map<Id, String> getNorthSouthBDMS()
        {
            List<User> users = [SELECT Name, UserRole.Name 
                                FROM User 
                                WHERE UserRole.Name = :BDM_NORTH 
                                    OR UserRole.Name = :BDM_SOUTH];

            Map<Id, String> roles = new Map<Id, String>();
            for(User user :users)
            {
                roles.put(user.Id, user.UserRole.Name);
            }

            return roles;
        }

        public Id getIHascoPriceBook()
        {
            List<SObject> pb = [SELECT Id 
                                FROM PriceBook2 
                                WHERE Name = :IHASCO_PRICEBOOK_NAME
                                LIMIT 1];

            if(pb != null && pb.size() > 0)
                return pb[0].Id;

            return null;
        }

        public Map<Id, Account> getAccounts(List<Opportunity> opps)
        {
            // TODO:  consider caching the results.  There 'may' be 
            // multiple queries per set of records. The query is fast so
            // performance may not be better with a cache, but if SOQL becomes
            // an issue it may be useful.
            
            if(opps == null || opps.isEmpty())
                return new Map<Id, Account>();

            Set<Id> actIds = new Set<Id>();
            for(Opportunity opp: opps)
            {
                actIds.add(opp.AccountId);
            }
            actIds.remove(null);

            if(actIds.isEmpty())
                return new Map<Id, Account>();

            List<Account> accounts = [SELECT Id, 
                                            Name, 
                                            BillingCountry, 
                                            BillingPostalCode, 
                                            Payroll_Amt__c, 
                                            iHASCO_Account_Manager__c, 
                                            OwnerId
                                        FROM Account 
                                        WHERE Id IN :actIds];

            return new Map<Id, Account>(accounts);
        }

        public Map<Id, Contract> getContracts(List<Opportunity> opps)
        {
            if(opps == null || opps.isEmpty())
                return new Map<Id, Contract>();

            Set<Id> ids = new Set<Id>();
            for(Opportunity opp: opps)
            {
                ids.add(opp.SBQQ__RenewedContract__c);
                ids.add(opp.SBQQ__AmendedContract__c);
            }
            ids.remove(null);

            if(ids.isEmpty())
                return new Map<Id, Contract>();

            List<Contract> cons = [SELECT Id, RecordTypeId
                                        FROM Contract 
                                        WHERE Id IN :ids];

            return new Map<Id, Contract>(cons);
        }
    }

    class IHascoDefaults
    {
        private List<Opportunity> opps;
        private Id iHascoOppRecordType;
        private Id iHascoContractRecordType;
        private Id iHascoPriceBook;
        private ISelector selector;
        private Map<Id, Account> accounts;
        private Map<Id, Contract> contracts;

        public IHascoDefaults(List<Opportunity> opps, ISelector selector)
        {
            this.opps = opps;
            this.selector = selector;
            this.iHascoOppRecordType = selector.getRecordTypeId(Opportunity.SObjectType, IHASCO_OPP_TYPE);
            this.iHascoContractRecordType = selector.getRecordTypeId(Contract.SObjectType, IHASCO_CONTRACT_TYPE);
        }

        void process()
        {
            for(Opportunity opp: opps)
            {
                if(iHascoRecordType(opp) || isAmendedContract(opp))
                {
                    opp.RecordTypeID = iHascoOppRecordType;
                    opp.PriceBook2Id = getIHascoPriceBook();

                    if(opp.isConverted__c)
                    {
                        opp.Type = NEW_BUSINESS;
                    }
                }
                else if(isRenewalContract(opp))
                {
                    Account act = getAccount(opp);

                    opp.Type = RENEWAL;
                    opp.Name = opp.Name + '-' + act.Name;
                    opp.OwnerId = getOwnerId(act);
                }
            }
        }

        private Boolean isRenewalContract(Opportunity opp)
        {
            return opp.SBQQ__RenewedContract__c != null &&
                    getRenewalContract(opp)?.RecordTypeID == iHascoContractRecordType;
        }

        private Boolean isAmendedContract(Opportunity opp)
        {
            return opp.SBQQ__AmendedContract__c != null &&
                    getAmendedContract(opp)?.RecordTypeID == iHascoContractRecordType;
        }

        private Boolean iHascoRecordType(Opportunity opp)
        {
            return opp.RecordTypeId == iHascoOppRecordType &&
                    opp.SBQQ__AmendedContract__c == null &&
                    opp.SBQQ__RenewedContract__c == null;
        }

        private Account getAccount(Opportunity opp)
        {
            if(accounts == null)
            {
                accounts = selector.getAccounts(opps);
            }

            return accounts.get(opp.AccountId);
        }

        private Contract getAmendedContract(Opportunity opp)
        {
            if(contracts == null)
            {
                contracts = selector.getContracts(opps);
            }

            return contracts.get(opp.SBQQ__AmendedContract__c);
        }

        private Contract getRenewalContract(Opportunity opp)
        {
            if(contracts == null)
            {
                contracts = selector.getContracts(opps);
            }

            return contracts.get(opp.SBQQ__RenewedContract__c);
        }

        private Id getIHascoPriceBook()
        {
            if(iHascoPriceBook == null)
            {
                iHascoPriceBook = selector.getIHascoPriceBook();
            }

            return iHascoPriceBook;
        }

        private Id getOwnerId(Account act)
        {
            return act.iHASCO_Account_Manager__c != null ? act.iHASCO_Account_Manager__c : act.OwnerId;
        }
    }

    class NorthSouth
    {
        private Set<String> northernRegions = new Set<String>{
            'BT', 'NE', 'CA', 'DH', 'SR', 'DL', 'TS', 'BD', 'HG', 'YO', 'LA', 'PR', 'BB', 'HX', 'LS', 'HD', 'WF', 'HU', 'DN',
            'LN', 'WN', 'BL', 'OL', 'FY', 'LL', 'SK', 'CH', 'WA', 'CW', 'SY', 'TF', 'ST', 'WV', 'WS', 'DE', 'NG', 'LE', 'L', 'S', 'M'
        };

        private List<Opportunity> opps;
        private ISelector selector;
        private Map<Id, String> userRoles;
        private Map<Id, Account> accounts;

        NorthSouth(List<Opportunity> opps, ISelector selector)
        {
            this.opps = opps;
            this.selector = selector;
            this.userRoles = selector.getNorthSouthBDMS();
        }

        void process()
        {
            for(Opportunity opp: opps)
            {
                if(isSouthernBDM(opp))
                {
                    opp.North_South__c = REGION_SOUTH;
                }
                else if(isNorthernBDM(opp))
                {
                    opp.North_South__c = REGION_NORTH;
                }
                else
                {
                    opp.North_South__c = isNorthernRegion(opp) ? REGION_NORTH : REGION_SOUTH;
                }
            }
        }

        private boolean isSouthernBDM(Opportunity opp)
        {
            return userRoles.get(opp.OwnerId) == BDM_SOUTH;
        }

        private boolean isNorthernBDM(Opportunity opp)
        {
            return userRoles.get(opp.OwnerId) == BDM_NORTH;
        }

        private boolean isNorthernRegion(Opportunity opp)
        {
            Account account = getAccount(opp);

            if(account == null)
                return false;

            if(account.BillingCountry != null && account.BillingCountry == 'Scotland')
                return true;

            String postCodeArea = getPostCodeArea(account.BillingPostalCode);

            return northernRegions.contains(postCodeArea);
        }

        private Account getAccount(Opportunity opp)
        {
            if(accounts == null)
            {
                accounts = selector.getAccounts(opps);
            }

            return accounts.get(opp.AccountId);
        }

        private String getPostCodeArea(String postCode)
        {
            if(postCode == null)
                return null;

            List<String> parts = postCode.toUpperCase().splitByCharacterType();
            return parts[0];
        }
    }

    class Payroll
    {

        private List<Opportunity> opps;
        private ISelector selector;
        private Map<Id, Account> accounts;

        Payroll(List<Opportunity> opps, ISelector selector)
        {
            this.opps = opps;
            this.selector = selector;
        }

        void process()
        {
            for(Opportunity opp: opps)
            {
                if(opp.Payroll_Amt__c == 0)
                {
                    Account act = getAccount(opp);
                    opp.Payroll_Amt__c = act != null ? act.Payroll_Amt__c : 0;
                }
            }
        }

        private Account getAccount(Opportunity opp)
        {
            if(accounts == null)
            {
                accounts = selector.getAccounts(opps);
            }

            return accounts.get(opp.AccountId);
        }
    }

    class FMDate
    {
        private List<Opportunity> opps;
        
        FMDate(List<Opportunity> opps)
        {
            this.opps = opps;
        }
        
        void process()
        {
            DateTime now = System.now();
            for(Opportunity opp: opps)
            {
                opp.FMCreatedDate__c = now;
            }
        }
    }
    
    class IsCoreOpp
    {
        private List<Opportunity> opps;
        private Map<Id, Opportunity> oldOpps;
        private Set<String> appointmentTypeSet = new Set<String>{'Combined', 'H&S', 'PEL', 'Combined + ISO', 'H&S + ISO', 'PEL + ISO'};
            
        IsCoreOpp(List<Opportunity> opps, Map<Id, Opportunity> oldOpps)
        {
            this.opps = opps;
            this.oldOpps = oldOpps;
        }
        
        void process()
        {
            for(Opportunity opp: opps)
            {
                //Appointment Type for insert
                if(oldOpps==null && appointmentTypeSet.contains(opp.Appointment_Type__c)){
                    opp.Is_Core__c = true;
                    continue;
                }
                //When the Number of Core Products and Appointment Type are changed 
                if(oldOpps!=null){
                    opp.Is_Core__c = appointmentTypeSet.contains(opp.Appointment_Type__c) || opp.Number_of_Core_Products__c > 0;
                }
            }
        }
    }
}