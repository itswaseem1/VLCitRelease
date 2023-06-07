public class CaseWrapperSort implements Comparable {
  @AuraEnabled
  public Case caseObj { get; set; }
  @AuraEnabled
  public Integer annyYear {get; set;}
  @AuraEnabled
  public List<WorkOrder> workList { get; set; }
  public List<Product2> productList { get; set; }
  @AuraEnabled
  public Set<String> accSiteName {get; set;}
   
  public CaseWrapperSort() {
    caseObj = new Case();
    workList = new List<WorkOrder>();
    annyYear = 0000;
    accSiteName = new Set<String>(); 
  } 

  public Integer compareTo(Object objToCompare) {
    CaseWrapperSort aaObj = (CaseWrapperSort) objToCompare;
    if (caseObj.Anniversary_Date__c == aaObj.caseObj.Anniversary_Date__c) {
      return 0;
    } else if (caseObj.Anniversary_Date__c > aaObj.caseObj.Anniversary_Date__c) {
      return 1;
    } else {
      return -1;
    }
  }
    
}