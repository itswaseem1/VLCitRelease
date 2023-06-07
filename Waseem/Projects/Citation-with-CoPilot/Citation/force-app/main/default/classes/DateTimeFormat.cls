/**
 * @File Name          : DateTimeFormat.cls
 * @Description        : Fields required for mentioning start and end date time of the Teams meeting 
 * @Author             : Priyanka -Cognizant
 * @Last Modified By   :
 * @Last Modified On   : 06/10/2021.
 * @Modification Log   :
 *==============================================================================
 * Ver         Date                     Author                 Modification
 *==============================================================================
 * 1.0     06/10/2021               Priyanka                 Initial Version
 **/
public without sharing class DateTimeFormat {
    public DateTime scheduledDate{get; set;}
    public String timeZone{get; set;}
    
    public DateTimeFormat(DateTime dt,String tz){
        this.scheduledDate = dt;
        this.timeZone = (tz != null ? tz : 'Europe/London');
    }
}