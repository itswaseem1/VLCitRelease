/**
 * @File Name          : Attendee.cls
 * @Description        : Fields required for Receipients of the Teams meeting 
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 06/10/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     06/10/2021               Priyanka                 Initial Version
 **/
public without sharing class Attendee {
    public EmailAddress emailAddress{get; set;}
    public String type{get; set;}
    
    public Attendee(EmailAddress emailAddr){
        this.emailAddress = emailAddr;
        this.type = 'required';
    }
}