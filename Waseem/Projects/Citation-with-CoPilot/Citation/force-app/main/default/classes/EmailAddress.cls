/**
 * @File Name          : EmailAddress.cls
 * @Description        : Fields required for specifying Email Address of Receipients of the Teams meeting 
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 06/10/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     06/10/2021               Priyanka                 Initial Version
 **/
public without sharing class EmailAddress {
    public String address{get; set;}
    public String name{get; set;}
    
    public EmailAddress(String addr, String name){
        this.address = addr;
        this.name = name;
    }
}