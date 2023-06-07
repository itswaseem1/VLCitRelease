@isTest
public class GetTerritorySubject_Test {
    //positive test scenario
    @isTest static void whenTerritoryRecognised_thenReturnSubjects(){
        list<string> HSterritory=new list<string>();
        HSterritory.add('H&S Territory');
        list<string> PELterritory=new list<string>();
        PELterritory.add('EL / HR Territory');
        Test.startTest();
        list<list<string>> subjHSList=GetTerritorySubject.getSubjectsTerritory(HSterritory);
        list<list<string>> subjPELList=GetTerritorySubject.getSubjectsTerritory(PELterritory);
        Test.stopTest();
                system.assert(subjHSList.size()>0, 'H&S Territory will have subjects');
                system.assert(subjPELList.size()>0,'EL&HR Territory will have subjects');
        
    }
        //negative test scenario
 @isTest static void whenTerritoryNotRecognised_thenReturnNoSubjects(){
     list<string> HSterritory=new list<string>();
        HSterritory.add('H&S Territory2');
        list<string> PELterritory=new list<string>();
        PELterritory.add('EL/HR Territory2');
        Test.startTest();
        list<list<string>> subjHSList=GetTerritorySubject.getSubjectsTerritory(HSterritory);
        list<list<string>> subjPELList=GetTerritorySubject.getSubjectsTerritory(PELterritory);
        Test.stopTest();
                system.assert(subjHSList.size()==0, 'H&S Territory will not have subjects');
                system.assert(subjPELList.size()==0,'EL&HR Territory will not have subjects');
 }
}