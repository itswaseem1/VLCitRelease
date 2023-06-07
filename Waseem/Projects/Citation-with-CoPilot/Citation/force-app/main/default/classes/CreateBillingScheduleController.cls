/*
    * FinancialForce.com, inc. claims copyright in this software, its screen display designs and
    * supporting documentation. FinancialForce and FinancialForce.com are trademarks of FinancialForce.com, inc.
    * Any unauthorized use, copying or sale of the above may constitute an infringement of copyright and may
    * result in criminal or other legal proceedings.
    *
    * Copyright FinancialForce.com, inc. All rights reserved.
    * Uves Ravat
*/

public class CreateBillingScheduleController 
{
	public Integer columnNumber { get; set; } 
	public Integer rowNumber { get; set; } 
	public static Boolean initOK { get; set; } 

	public CreateBillingScheduleController() 
	{
		this.columnNumber = 0;
		this.rowNumber = 1;
		initOK = true;
	}

	@RemoteAction
	public static String createSchedules(List<id> contractIds)
	{
		try
		{
			system.debug(contractIds);
			if(batchIsRunning(new List<String>{'CreateBillingScheduleBatch'}) > 1)
			{
				return 'CreateBillingScheduleBatch Batch Job is already running. Please try again later';		
			}
			else
			{
				initOK = false;
				Database.executeBatch(new CreateBillingScheduleBatch(contractIds), 1);
	        	return 'Contracts are being processed - Please check Apex jobs for more detail';
			}
		}
		catch(Exception ex)
		{
			return ex.getMessage();
		}
	}

	private static Integer batchIsRunning(List<String> batchClassNames)
	{
        List<String> batchStatus = new List<String>{'Queued', 'Holding', 'Preparing', 'Processing'};
       	Integer noOfJobs = [Select count() from AsyncApexJob where ApexClass.Name IN :batchClassNames AND Status IN :batchStatus];
		
		return noOfJobs;
	}
}