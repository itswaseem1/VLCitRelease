public with sharing class EmployeeMattterViewController {
    @AuraEnabled   
    public static List<Employee_Matter__c> fetchEmployeeMatter( string caseIds )  {  
        set<id> empId=new set<id>();
        List<case> caseList =new List<case>([SELECT Employee__c 
                                             FROM Case 
                                             WHERE Id=:caseIds WITH SECURITY_ENFORCED]);
        for(case c:caseList){
            empId.add(c.Employee__c); 
        }
        List<Employee_Matter__c> matterList = new List<Employee_Matter__c>([SELECT id,Name,FirstName__c,Gender__c,Other_E__c,Site__c 
                                                                            FROM Employee_Matter__c 
                                                                            WHERE Employee__c IN:empId WITH SECURITY_ENFORCED limit 1]);
       
        return matterList;
        
    }
    public List<Employee_Matter__c> matterList {get;set;}
    public EmployeeMattterViewController(){
        this.matterList = new List<Employee_Matter__c>();
    }
    @AuraEnabled   
    public static Map<String,String> mapEmpfetchEmployee( String caseIds ){  
        Map<String,String> mapEmp=new Map<String,String>();
        Case caseitems=[SELECT Employee__c,Employee__r.Name__c FROM Case WHERE Id=:caseIds WITH SECURITY_ENFORCED limit 1];
        //List<Employee__c> emplist = new List<Employee__c>([SELECT Id FROM Employee__c WHERE id =: empId WITH SECURITY_ENFORCED limit 1]);
        List<Employee_Matter__c> empMatterlist= [SELECT id,Name,FirstName__c,Gender__c,Other_E__c,Site__c FROM Employee_Matter__c 
                                                WHERE Employee__c =:caseitems.Employee__c WITH SECURITY_ENFORCED limit 1];
        mapEmp.put('empId',caseitems.Employee__c);
        mapEmp.put('empName',caseitems.Employee__r.Name__c);
        mapEmp.put('empMatterId',empMatterlist[0].Id);
        return mapEmp;
    }
     @AuraEnabled(cacheable=true)
    public static Employee_Matter__c getEmployeeMatter( Id caseId )  {  
        
        Id empId =[SELECT Employee__c FROM Case 
                   WHERE Id=:caseId  WITH SECURITY_ENFORCED LIMIT 1].Employee__c ;
        
        
        return [SELECT id,Name,FirstName__c,Gender__c,Other_E__c,Site__c FROM Employee_Matter__c 
                WHERE Employee__c =:empId WITH SECURITY_ENFORCED limit 1];
    }
    
    
}