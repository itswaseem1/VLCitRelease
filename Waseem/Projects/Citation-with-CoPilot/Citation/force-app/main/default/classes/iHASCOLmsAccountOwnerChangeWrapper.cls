public class iHASCOLmsAccountOwnerChangeWrapper {
        public String EventType;
        public String LmsId;
        public String AccountId;
        public SalesRepresentative SalesRepresentative;
        
        public iHASCOLmsAccountOwnerChangeWrapper(Account Ac, String EvType){
            this.EventType = EvType;
            this.LmsId = Ac.LMS_ID__c;
            this.AccountId = Ac.id;
            this.SalesRepresentative = new SalesRepresentative(ac);
        }
        
        private class SalesRepresentative{
            public String FirstName;
            public String LastName;
            public String Email;
            
            public SalesRepresentative(Account ac){
                this.FirstName =  ac.iHASCO_Account_Manager__r.FirstName;
                this.LastName =  ac.iHASCO_Account_Manager__r.LastName;
                this.Email =  ac.iHASCO_Account_Manager__r.Email;
            }
        }
    }