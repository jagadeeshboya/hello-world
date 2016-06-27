@isTest(SeeAllData=false)
private class Invoice2ControllerTest 
{
	public static testMethod void test_Invoice2Controller()
	{
        User objUser = H_Utility_Test.createUserRecords();
        system.runAs(objUser)
        {
            
            Tax_Rate__c tax = new Tax_Rate__c(Name ='test', Rate__c = 10, Taxable_Amount__c = 'Total', Applied_To__c = 'Closing Report');
            insert tax;
        
            Account objAccount = H_Utility_Test.accountRecords();  
            objAccount.Tax_Rate__c = tax.Id;
            update objAccount;
            Credit_Check__c objCreditCheck = new Credit_Check__c(Status__c = 'Passed', Client__c = objAccount.Id);
            insert objCreditCheck;
            Contact conApp = new Contact(LastName='Approv Calif Contact Test',Email='anshul@satrangtech.com',AccountId=objAccount.Id);
            insert conApp;
            objAccount.Credit_Check__c = objCreditCheck.Id;
            update objAccount;
    
            Contact con = H_Utility_Test.contactRecords('Test', 'Contact', objAccount.Id, '', null, false,'test1@test.com');
            con.TR1__Birthdate__c = system.today().addyears(-20);
            con.Sex__c = 'Male';
            con.NI_Number__c = 'test';
            con.No_of_Non_Workable__c = 0;
            con.Pay_Type__c = 'PAYE';
            update con;
            
            //User u1 = createTestUser('Recr', con.Id, objAccount.Id);

            //Custom setting broadbean
            List<Broadbean_Settings__c>  objBroadBeanCSlist  = new List<Broadbean_Settings__c>();
            objBroadBeanCSlist = [Select Id,Display_Menu__c, Secret_Key__c, Stylesheet_URL__c from Broadbean_Settings__c limit 1 FOR UPDATE ];
            Broadbean_Settings__c objBroadBeanCS = new Broadbean_Settings__c();
            if(objBroadBeanCSlist.size() > 0 ){
                objBroadBeanCS = objBroadBeanCSlist[0] ;
            }
            else {
                objBroadBeanCS = Broadbean_Settings__c.getOrgDefaults();
                objBroadBeanCS.Display_Menu__c = False;
                objBroadBeanCS.Secret_Key__c = '74be05bec946a11bf50e0a06d1981db8875b5682e6fd17e40fc167ebfe2c1db9';
                objBroadBeanCS.Stylesheet_URL__c = 'http://v4.adcourier.com/css/adapt-v4.css';
            }
            Database.insert(objBroadBeanCS , false);

            //invoicing custom setting
            Invoice_2_Utility__c testInvoice2UtilityRecord = new Invoice_2_Utility__c(Name = 'Draft_Invoices_List_View_URL', Value__c = 'www.google.com');
            insert testInvoice2UtilityRecord;

            
            TR1__Job__c job = H_Utility_Test.createJobRecords(objAccount.Id, con.Id);
            job.Job_Code__c = '157654112';
            job.Purchase_Order_Number__c = '7812683123';
            update job;
            Id JobId = job.Id;
            H_Utility_Test.createApplication(con.Id, 'Accepted', JobId);


            //Rate card and Timetype
            Time_Type__c testTimeType1 = new Time_Type__c(Name = 'Holiday (Unpaid)', Entry_Type__c = 'Hours');
            insert testTimeType1;
            Time_Type__c testTimeType2 = new Time_Type__c(Name = 'Base', Entry_Type__c = 'Start/Finish');
            insert testTimeType2;
            Billing_Profile__c testBillingProfile = new Billing_Profile__c(Account__c = objAccount.id,Billing_Account__c =objAccount.id , Invoice_Contact__c = con.id, Bill_Frequency__c = 'Weekly',Invoice_Split_Type__c='Invoice per Client per Week');
            insert testBillingProfile;
            objAccount.Billing_Profile__c = testBillingProfile.id;
            update objAccount;
            
            Test.startTest();
            TR1__Closing_Report__c TempCR = createClosingReportsTemp(objAccount.Id, con.Id, objUser.Id, JobId);
            TR1__Closing_Report__c PermCR = createClosingReportsPerm(objAccount.Id, con.Id, objUser.Id, JobId);
            
            Rate_Card_Detail__c testRateCardDetail = new Rate_Card_Detail__c(Rate_Card__c = TempCR.Placement_Rate_Card__c, Time_Type__c = testTimeType1.id, Regular_Pay_Rate__c = 0.0, Regular_Bill_Rate__c=0.0);
            insert testRateCardDetail;
            Rate_Card_Detail__c testRateCardDetail1 = new Rate_Card_Detail__c(Rate_Card__c = TempCR.Placement_Rate_Card__c, Time_Type__c = testTimeType2.id, Regular_Pay_Rate__c = 10.0, Regular_Bill_Rate__c=10.0);
            insert testRateCardDetail1;
            
            TR1__Timesheet__c ts = new TR1__Timesheet__c();
            ts.TR1__Status__c='Approved';
            ts.TR1__Closing_Report__c =TempCR.Id;
            ts.TR1__Consultant__c=TempCR.TR1__Person_Placed__c; 
            ts.TR1__Job_Order__c = TempCR.TR1__Job__c;
            //ts.TR1__Approver__c=TempCR.Timesheet_Approver_2__c;
            ts.TR1__Client__c=TempCR.TR1__Account__c;
            ts.TR1__Week_Ending__c = Date.today().toStartOfWeek().addDays(7);
            ts.TR1__Pay_Week_Ending__c = Date.today().toStartOfWeek().addDays(7);
            insert ts;
            
            test.stoptest();
            
            List<TR1__Timesheet_Detail__c> timesheetdetails = new List<TR1__Timesheet_Detail__c>(); 
            TR1__Timesheet_Detail__c td = new TR1__Timesheet_Detail__c();
            td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(1),TR1__Day__c='Monday');
            timesheetdetails.add(td);
            td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(2),TR1__Day__c='Tuesday');
            timesheetdetails.add(td);
            td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(3),TR1__Day__c='Wednesday');
            timesheetdetails.add(td);
            insert timesheetdetails;
            List<Shift_Work__c> swList = new List<Shift_Work__c> ();
            List<Shift_Work__c> swList2 = new List<Shift_Work__c> ();
            
            for(TR1__Timesheet_Detail__c td1 : timesheetdetails){
                Shift_Work__c sw = new Shift_Work__c(Timesheet_Detail__c = td1.Id,Timesheet__c = td1.TR1__Timesheet__c,
                                   Finish_Hours__c='02',Finish_Minutes__c='00',Start_Hours__c='01',Start_Minutes__c='00'
                                   ,Bill_Rate_Card_Detail__c=testRateCardDetail.Id,Rate_Card_Detail__c=testRateCardDetail.Id);

                swList2.add(sw);
            }
         
            //insert swList2;
            //RecordType objRecordType = [Select Id from RecordType where DeveloperName = 'Meals & Entertainment' AND SobjectType = 'TR1__Expense_Report_Detail__c' limit 1];
            Id RecordTypeEXPDMM = Schema.SObjectType.TR1__Expense_Report_Detail__c.getRecordTypeInfosByName().get('Meals & Entertainment').getRecordTypeId();
            Id expRecordTypeMM = Schema.SObjectType.TR1__Expense_Report__c.getRecordTypeInfosByName().get('Internal Expense').getRecordTypeId();
            TR1__Expense_Report__c expPerm  =   new TR1__Expense_Report__c(TR1__Expense_Period_Start__c = Date.today().addDays(1), TR1__Expense_Period_End__c= Date.today().addDays(5), TR1__Status__c = 'Unsubmitted'
                                                ,TR1__Account__c= PermCR.TR1__Account__c ,TR1__Closing_Report__c = PermCR.Id,RecordTypeId = expRecordTypeMM);

            TR1__Expense_Report__c expTemp  =   new TR1__Expense_Report__c(TR1__Expense_Period_Start__c = Date.today().addDays(1), TR1__Expense_Period_End__c= Date.today().addDays(5), TR1__Status__c = 'Unsubmitted'
                                                ,TR1__Account__c= TempCR.TR1__Account__c ,TR1__Closing_Report__c = TempCR.Id, RecordTypeId = expRecordTypeMM);
            insert  expPerm;
            insert  expTemp;
            TR1__Expense_Report_Detail__c expdPerm = new TR1__Expense_Report_Detail__c(TR1__Date__c = Date.today().addDays(2), TR1__Vendor__c='MAcdonald' ,Billable_to_Client__c= True , TR1__Expense_Report__c = expPerm.Id, TR1__Amount__c = 55, RecordTypeId = RecordTypeEXPDMM);
            TR1__Expense_Report_Detail__c expdTemp = new TR1__Expense_Report_Detail__c(TR1__Date__c = Date.today().addDays(2), TR1__Vendor__c='MAcdonald' ,Billable_to_Client__c= True , TR1__Expense_Report__c = expTemp.Id, TR1__Amount__c = 55, RecordTypeId = RecordTypeEXPDMM);
            insert  expdTemp;
            insert  expdPerm;

            expPerm.TR1__Status__c = 'Approved';
            expTemp.TR1__Status__c = 'Approved';
            update  expPerm;
            update  expTemp;
            Set<Id> erRTIDset= new Set<Id>();
            Set<Id> crRTIDset= new Set<Id>();
            Set<String> billingFrequencyset= new Set<String>();

            Id permanentRecordTypeClosingReport = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            Id tempRecordTypeClosingReport = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();

            crRTIDset.add(permanentRecordTypeClosingReport);
            crRTIDset.add(tempRecordTypeClosingReport);
            erRTIDset.add(expRecordTypeMM);
            billingFrequencyset.add('Weekly');
            
            Test.setCurrentPage(Page.Invoice2);
            Invoice2Controller testInvoiceController = new Invoice2Controller();
            Invoice2Controller.NonBillableItemWrapper wrapp = new Invoice2Controller.NonBillableItemWrapper(TempCR, ts, expTemp, 'test');
            wrapp.cr = TempCR;
            wrapp.ts = ts;
            wrapp.er = expTemp;
            wrapp.reason = 'test';
            
            testInvoiceController.invoiceableMapSize = 0;
            Invoice2Controller.FailureWrapper objWrap = new Invoice2Controller.FailureWrapper('Test', 'testId', expPerm.Id);

            testInvoiceController.hasBillableItems = True;
            testInvoiceController.closingReportRecordTypeSelectedValues = '[]';
            testInvoiceController.billingProfileFrequencySelectedValues = '[]';
            testInvoiceController.InvoicePreviewButton();
            testInvoiceController.InvoiceCreateButton();
            Boolean isPreview = false;
            //testInvoiceController.fetchClosingReport(crRTIDset, erRTIDset, billingFrequencyset, isPreview);
            testInvoiceController.closingReportRecordTypeSelectedValues = '['+tempRecordTypeClosingReport+']';
            testInvoiceController.expenseReportRecordTypeSelectedValues = '['+expRecordTypeMM+']';
            testInvoiceController.billingProfileFrequencySelectedValues = '[Weekly]';
            testInvoiceController.InvoicePreviewButton();
            testInvoiceController.closingReportRecordTypeSelectedValues = '['+tempRecordTypeClosingReport+','+permanentRecordTypeClosingReport+']';
            testInvoiceController.expenseReportRecordTypeSelectedValues = '['+expRecordTypeMM+']';
            testInvoiceController.billingProfileFrequencySelectedValues = '[Weekly]';
            testInvoiceController.InvoiceCreateButton();
            Invoice2Controller testInvoiceController2 = new Invoice2Controller();
            testBillingProfile.Invoice_Split_Type__c= 'Invoice Per Job Code';
            update testBillingProfile;
            //testInvoiceController.fetchClosingReport(crRTIDset, erRTIDset, billingFrequencyset, True);
            
            testInvoiceController.InvoicePreviewButton();
            testInvoiceController.closingReportRecordTypeSelectedValues = '['+permanentRecordTypeClosingReport+']';
            testInvoiceController.expenseReportRecordTypeSelectedValues = '['+expRecordTypeMM+']';
            testInvoiceController.billingProfileFrequencySelectedValues = '[Weekly]';
           // testInvoiceController.timesheetListToBeUpdated.add( new TR1__Timesheet__c() );
            testInvoiceController.InvoiceCreateButton();
        }
    }
    
    public static testMethod void test_Invoice2Controller2()
	{
        User objUser = H_Utility_Test.createUserRecords();
        system.runAs(objUser)
        {
            
            Tax_Rate__c tax = new Tax_Rate__c(Name ='test', Rate__c = 10, Taxable_Amount__c = 'Total', Applied_To__c = 'Closing Report');
            insert tax;
        
            Account objAccount = H_Utility_Test.accountRecords();
            objAccount.Tax_Rate__c = tax.Id;
            update objAccount;
            Credit_Check__c objCreditCheck = new Credit_Check__c(Status__c = 'Passed', Client__c = objAccount.Id);
            insert objCreditCheck;
            Contact conApp = new Contact(LastName='Approv Calif Contact Test',Email='anshul@satrangtech.com',AccountId=objAccount.Id);
            insert conApp;
            objAccount.Credit_Check__c = objCreditCheck.Id;
            update objAccount;
    
            Contact con = H_Utility_Test.contactRecords('Test', 'Contact', objAccount.Id, '', null, false,'test1@test.com');
            con.TR1__Birthdate__c = system.today().addyears(-20);
            con.Sex__c = 'Male';
            con.NI_Number__c = 'test';
            con.No_of_Non_Workable__c = 0;
            con.Pay_Type__c = 'PAYE';
            update con;

            //Custom setting broadbean
            List<Broadbean_Settings__c>  objBroadBeanCSlist  = new List<Broadbean_Settings__c>();
            objBroadBeanCSlist = [Select Id,Display_Menu__c, Secret_Key__c, Stylesheet_URL__c from Broadbean_Settings__c limit 1 FOR UPDATE ];
            Broadbean_Settings__c objBroadBeanCS = new Broadbean_Settings__c();
            if(objBroadBeanCSlist.size() > 0 ){
                objBroadBeanCS = objBroadBeanCSlist[0] ;
            }
            else {
                objBroadBeanCS = Broadbean_Settings__c.getOrgDefaults();
                objBroadBeanCS.Display_Menu__c = False;
                objBroadBeanCS.Secret_Key__c = '74be05bec946a11bf50e0a06d1981db8875b5682e6fd17e40fc167ebfe2c1db9';
                objBroadBeanCS.Stylesheet_URL__c = 'http://v4.adcourier.com/css/adapt-v4.css';
            }
            Database.insert(objBroadBeanCS , false);

            //invoicing custom setting
            Invoice_2_Utility__c testInvoice2UtilityRecord = new Invoice_2_Utility__c(Name = 'Draft_Invoices_List_View_URL', Value__c = 'www.google.com');
            insert testInvoice2UtilityRecord;

            
            TR1__Job__c job = H_Utility_Test.createJobRecords(objAccount.Id, con.Id);
            job.Job_Code__c = '157654112';
            job.Purchase_Order_Number__c = '7812683123';
            update job;
            Id JobId = job.Id;
            H_Utility_Test.createApplication(con.Id, 'Accepted', JobId);


            //Rate card and Timetype
            Time_Type__c testTimeType1 = new Time_Type__c(Name = 'Holiday (Unpaid)', Entry_Type__c = 'Hours');
            insert testTimeType1;
            Time_Type__c testTimeType2 = new Time_Type__c(Name = 'Base', Entry_Type__c = 'Start/Finish');
            insert testTimeType2;
            Billing_Profile__c testBillingProfile = new Billing_Profile__c(Account__c = objAccount.id,Billing_Account__c =objAccount.id , Invoice_Contact__c = con.id, Bill_Frequency__c = 'Weekly',Invoice_Split_Type__c='Invoice Per Candidate per Client');
            insert testBillingProfile;
            objAccount.Billing_Profile__c = testBillingProfile.id;
            update objAccount;
            
            Test.startTest();
            TR1__Closing_Report__c TempCR = createClosingReportsTemp(objAccount.Id, con.Id, objUser.Id, JobId);
            TR1__Closing_Report__c PermCR = createClosingReportsPerm(objAccount.Id, con.Id, objUser.Id, JobId);
            
            Rate_Card_Detail__c testRateCardDetail = new Rate_Card_Detail__c(Rate_Card__c = TempCR.Placement_Rate_Card__c, Time_Type__c = testTimeType1.id, Regular_Pay_Rate__c = 0.0, Regular_Bill_Rate__c=0.0);
            insert testRateCardDetail;
            Rate_Card_Detail__c testRateCardDetail1 = new Rate_Card_Detail__c(Rate_Card__c = TempCR.Placement_Rate_Card__c, Time_Type__c = testTimeType2.id, Regular_Pay_Rate__c = 10.0, Regular_Bill_Rate__c=10.0);
            insert testRateCardDetail1;
            
            TR1__Timesheet__c ts = new TR1__Timesheet__c();
            ts.TR1__Status__c='Approved';
            ts.TR1__Closing_Report__c =TempCR.Id;
            ts.TR1__Consultant__c=TempCR.TR1__Person_Placed__c; 
            ts.TR1__Job_Order__c = TempCR.TR1__Job__c;
            //ts.TR1__Approver__c=TempCR.Timesheet_Approver_2__c;
            ts.TR1__Client__c=TempCR.TR1__Account__c;
            ts.TR1__Week_Ending__c = Date.today().toStartOfWeek().addDays(7);
            ts.TR1__Pay_Week_Ending__c = Date.today().toStartOfWeek().addDays(7);
            insert ts;
            
            Invoice_2__c testInvoice1 = new Invoice_2__c(Status__c = 'Printed');
            insert testInvoice1;
             system.debug('===testInvoice1  11111==='+testInvoice1.id);
             /*testInvoice1.Status__c = 'Emailed';
            update testInvoice1;
            system.debug('===testInvoice1 2222==='+testInvoice1.id); */
             TR1__Timesheet__c testTimesheet = new TR1__Timesheet__c(TR1__Job_Order__c = job.id, TR1__Closing_Report__c = TempCR.id, TR1__Week_Ending__c =  System.today().addDays(-7), TR1__Status__c = 'Approved');
            insert testTimesheet;
            TR1__Expense_Report__c testExpenseReport2 = new TR1__Expense_Report__c(TR1__Closing_Report__c = TempCR.id,TR1__Expense_Period_End__c = System.today().addDays(-1), TR1__Status__c = 'Approved');
            insert testExpenseReport2;
            List<Invoice_Line_Item__c> lstILI = new List<Invoice_Line_Item__c>{new Invoice_Line_Item__c(Invoice_2__c = testInvoice1.id, Unit__c = 'Timesheet', Timesheet__c = testTimesheet.id, Generate_Detail__c = true),
                                                                               new Invoice_Line_Item__c(Invoice_2__c = testInvoice1.id, Unit__c = 'Expense Report', Expense_Report__c = testExpenseReport2.id, Generate_Detail__c = true),
                                                                               new Invoice_Line_Item__c(Invoice_2__c = testInvoice1.id, Unit__c = 'Closing Report', Closing_Report__c = PermCR.id, Generate_Detail__c = true)};
            insert lstILI;
            /*//Invoice2TriggerHandler.isExecuted = true;
            testInvoice1.Status__c = 'Printed';
            update testInvoice1;*/
            Invoice_Line_Item__c objILItem = new Invoice_Line_Item__c(Timesheet__c = testTimesheet.id);
            test.stoptest();
            
            List<TR1__Timesheet_Detail__c> timesheetdetails = new List<TR1__Timesheet_Detail__c>(); 
            TR1__Timesheet_Detail__c td = new TR1__Timesheet_Detail__c();
            td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(1),TR1__Day__c='Monday');
            timesheetdetails.add(td);
            td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(2),TR1__Day__c='Tuesday');
            timesheetdetails.add(td);
            td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(3),TR1__Day__c='Wednesday');
            timesheetdetails.add(td);
            insert timesheetdetails;
            List<Shift_Work__c> swList = new List<Shift_Work__c> ();
            List<Shift_Work__c> swList2 = new List<Shift_Work__c> ();
            
            for(TR1__Timesheet_Detail__c td1 : timesheetdetails){
                Shift_Work__c sw = new Shift_Work__c(Timesheet_Detail__c = td1.Id,Timesheet__c = td1.TR1__Timesheet__c,
                                   Finish_Hours__c='02',Finish_Minutes__c='00',Start_Hours__c='01',Start_Minutes__c='00'
                                   ,Bill_Rate_Card_Detail__c=testRateCardDetail.Id,Rate_Card_Detail__c=testRateCardDetail.Id);

                swList2.add(sw);
            }
         
            //insert swList2;
            //RecordType objRecordType = [Select Id from RecordType where DeveloperName = 'Meals & Entertainment' AND SobjectType = 'TR1__Expense_Report_Detail__c' limit 1];
            Id RecordTypeEXPDMM = Schema.SObjectType.TR1__Expense_Report_Detail__c.getRecordTypeInfosByName().get('Meals & Entertainment').getRecordTypeId();
            Id expRecordTypeMM = Schema.SObjectType.TR1__Expense_Report__c.getRecordTypeInfosByName().get('Internal Expense').getRecordTypeId();
            TR1__Expense_Report__c expPerm  =   new TR1__Expense_Report__c(TR1__Expense_Period_Start__c = Date.today().addDays(1), TR1__Expense_Period_End__c= Date.today().addDays(5), TR1__Status__c = 'Unsubmitted'
                                                ,TR1__Account__c= PermCR.TR1__Account__c ,TR1__Closing_Report__c = PermCR.Id,RecordTypeId = expRecordTypeMM);

            TR1__Expense_Report__c expTemp  =   new TR1__Expense_Report__c(TR1__Expense_Period_Start__c = Date.today().addDays(1), TR1__Expense_Period_End__c= Date.today().addDays(5), TR1__Status__c = 'Unsubmitted'
                                                ,TR1__Account__c= TempCR.TR1__Account__c ,TR1__Closing_Report__c = TempCR.Id, RecordTypeId = expRecordTypeMM);
            insert  expPerm;
            insert  expTemp;
            TR1__Expense_Report_Detail__c expdPerm = new TR1__Expense_Report_Detail__c(TR1__Date__c = Date.today().addDays(2), TR1__Vendor__c='MAcdonald' ,Billable_to_Client__c= True , TR1__Expense_Report__c = expPerm.Id, TR1__Amount__c = 55, RecordTypeId = RecordTypeEXPDMM);
            TR1__Expense_Report_Detail__c expdTemp = new TR1__Expense_Report_Detail__c(TR1__Date__c = Date.today().addDays(2), TR1__Vendor__c='MAcdonald' ,Billable_to_Client__c= True , TR1__Expense_Report__c = expTemp.Id, TR1__Amount__c = 55, RecordTypeId = RecordTypeEXPDMM);
            insert  expdTemp;
            insert  expdPerm;

            expPerm.TR1__Status__c = 'Approved';
            expTemp.TR1__Status__c = 'Approved';
            update  expPerm;
            update  expTemp;
            Set<Id> erRTIDset= new Set<Id>();
            Set<Id> crRTIDset= new Set<Id>();
            Set<String> billingFrequencyset= new Set<String>();

            Id permanentRecordTypeClosingReport = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            Id tempRecordTypeClosingReport = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();

            crRTIDset.add(permanentRecordTypeClosingReport);
            crRTIDset.add(tempRecordTypeClosingReport);
            erRTIDset.add(expRecordTypeMM);
            billingFrequencyset.add('Weekly');
            
            Test.setCurrentPage(Page.Invoice2);
            Invoice2Controller testInvoiceController = new Invoice2Controller();
            
            //testInvoiceController.ILI = lstILI[0];
            
            Invoice2Controller.NonBillableItemWrapper wrapp = new Invoice2Controller.NonBillableItemWrapper(TempCR, ts, expTemp, 'test');
            wrapp.cr = TempCR;
            wrapp.ts = ts;
            wrapp.er = expTemp;
            wrapp.reason = 'test';
            
            testInvoiceController.invoiceableMapSize = 0;
            Invoice2Controller.FailureWrapper objWrap = new Invoice2Controller.FailureWrapper('Test', 'testId', expPerm.Id);

            testInvoiceController.hasBillableItems = True;
            testInvoiceController.closingReportRecordTypeSelectedValues = '[]';
            testInvoiceController.billingProfileFrequencySelectedValues = '[]';
            testInvoiceController.InvoicePreviewButton();
            testInvoiceController.InvoiceCreateButton();
            //testInvoiceController.fetchClosingReport(crRTIDset, erRTIDset, billingFrequencyset, isPreview);
            testInvoiceController.closingReportRecordTypeSelectedValues = '['+tempRecordTypeClosingReport+']';
            testInvoiceController.expenseReportRecordTypeSelectedValues = '['+expRecordTypeMM+']';
            testInvoiceController.billingProfileFrequencySelectedValues = '[Weekly]';
            testInvoiceController.InvoicePreviewButton();
            testInvoiceController.closingReportRecordTypeSelectedValues = '['+tempRecordTypeClosingReport+','+permanentRecordTypeClosingReport+']';
            testInvoiceController.expenseReportRecordTypeSelectedValues = '['+expRecordTypeMM+']';
            testInvoiceController.billingProfileFrequencySelectedValues = '[Weekly]';
            testInvoiceController.InvoiceCreateButton();
            testInvoiceController.InvoicePreviewButton();
            
            delete testInvoice1;
            undelete testInvoice1;
        }
    }
    public static testMethod void test_Invoice2TriggerHandler()
    {   
        User testUser = H_Utility_Test.createUserRecords();
        system.runAs(testUser)
        {
            //Where there are Invoice as well as Invoice Line Items
            Id consultingRecordTypeJob = Schema.SObjectType.TR1__Job__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            Id consultingRecordTypeClosingReport = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();
            
            Broadbean_Settings__c objBroadBeanCS = Broadbean_Settings__c.getOrgDefaults();
            objBroadBeanCS.Display_Menu__c = False;
            objBroadBeanCS.Secret_Key__c = '74be05bec946a11bf50e0a06d1981db8875b5682e6fd17e40fc167ebfe2c1db9';
            objBroadBeanCS.Stylesheet_URL__c = 'http://v4.adcourier.com/css/adapt-v4.css';
            upsert objBroadBeanCS;
            
            Account acc = H_Utility_Test.accountRecords();
    
            Credit_Check__c testCreditCheck = new Credit_Check__c(Client__c = acc.id, Status__c = 'Passed');
            insert testCreditCheck;
    
            acc.Credit_Check__c = testCreditCheck.id;
            update acc;
            
            Contact con = new Contact(LastName = 'test', Email = 'test@test.com',AccountId = acc.Id, No_of_Non_Workable__c = 0, Pay_Type__c = 'PAYE', TR1__Birthdate__c = Date.newInstance(1988, 02, 29), Sex__c = 'Male', NI_Number__c = '123456');
            insert con;
    
            Contact con1 = new Contact(LastName = 'test1', Email = 'test1@test1.com',AccountId = acc.Id, No_of_Non_Workable__c = 0, Pay_Type__c = 'PAYE', TR1__Birthdate__c = Date.newInstance(1988, 02, 29), Sex__c = 'Male', NI_Number__c = '123456');
            insert con1;
            
            Profile testProfile = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    
            TR1__Branch__c testBranch = new TR1__Branch__c(Name = 'Test');
            insert testBranch;
            
            Division__c testDivision = new Division__c(Name = 'A & F', hExternal_Id__c = 'AF');
            insert testDivision;
            
            TR1__Job__c testConsultingJob = new TR1__Job__c(RecordTypeId = consultingRecordTypeJob, Name = 'Test Consulting Job');
            insert testConsultingJob;
            
            TR1__Closing_Report__c testConsultingCR = new TR1__Closing_Report__c(TR1__Account__c = acc.id,
                                                                                TR1__Person_Placed__c = con1.Id,
                                                                                TR1__Start_Date__c = Date.today().addDays(-5),
                                                                                TR1__Salary__c = 1000,
                                                                                TR1__Billing_Street__c = 'Test Street',
                                                                                TR1__Billing_City__c = 'Test City',
                                                                                TR1__Billing_Zip_Code__c = '626001',
                                                                                TR1__Job_Credit__c = testUser.id,
                                                                                TR1__Job_Percentage__c = 20,
                                                                                TR1__Candidate_Percentage__c = 20,
                                                                                TR1__Marketing_Percentage__c = 20,
                                                                                TR1__Other_Percentage__c = 20,
                                                                                TR1__Other2_Percentage__c = 20,
                                                                                TR1__Candidate_Credit__c = testUser.id,
                                                                                Marketing_Credit_Branch__c = testBranch.id,
                                                                                Candidate_Credit_Branch__c = testBranch.id,
                                                                                Job_Credit_Branch__c = testBranch.id,
                                                                                Other_Credit_Branch__c = testBranch.id,
                                                                                Other2_Credit_Branch__c = testBranch.id,
                                                                                Job_Credit_Division__c = testDivision.id,
                                                                                Marketing_Credit_Division__c = testDivision.Id,
                                                                                Other_Credit_Division__c = testDivision.Id,
                                                                                Candidate_Credit_Division__c = testDivision.Id,
                                                                                Other2_Credit_Division__c = testDivision.Id,
                                                                                TR1__Other_Credit__c = testUser.id,
                                                                                TR1__Other2_Credit__c = testUser.id,
                                                                                TR1__Marketing_Credit__c  = testUser.id,
                                                                                RecordTypeId = consultingRecordTypeClosingReport,
                                                                                TR1__Job__c = testConsultingJob.Id,
                                                                                TR1__End_Date__c = Date.today().addDays(6),
                                                                                hSell_to_Contact__c = con1.Id,
                                                                                TR1__Generate_Timesheet__c = true,
                                                                                TR1__Timesheet_Approver__c = con.Id,
                                                                                Sales_Commission_1_Team__c = createTeam().Id,
                                                                                Sales_Commission_2_Team__c = createTeam().Id,
                                                                                Sales_Commission_3_Team__c = createTeam().Id,
                                                                                Flat_Fee_Amount__c = 123,TR1__Fee_Percentage__c=1);
                    
            insert testConsultingCR;
    
            TR1__Timesheet__c testTimesheet = new TR1__Timesheet__c(TR1__Job_Order__c = testConsultingJob.id, TR1__Closing_Report__c = testConsultingCR.id, TR1__Week_Ending__c =  System.today().addDays(-7), TR1__Status__c = 'Approved');
            insert testTimesheet;
            system.debug('======inserted timesheet====='+testTimesheet +'-------id---'+testTimesheet.id );
            TR1__Expense_Report__c testExpenseReport2 = new TR1__Expense_Report__c(TR1__Closing_Report__c = testConsultingCR.id,TR1__Expense_Period_End__c = System.today().addDays(-1), TR1__Status__c = 'Approved');
            insert testExpenseReport2;
            system.debug('===testExpenseReport2===='+testExpenseReport2 +'========'+testExpenseReport2.id);
            
            Test.starttest();
             Invoice_2__c testInvoice3 = new Invoice_2__c(Status__c = 'Printed',/* Create_Margin_Line__c = True,*/ Closing_Report__c = testConsultingCR.Id);
            insert testInvoice3;
            system.debug('====testInvoice3==111='+testInvoice3);
            Invoice_2__c testInvoice2 = new Invoice_2__c(Status__c = 'Draft',/* Create_Margin_Line__c = True,*/ Closing_Report__c = testConsultingCR.Id);
            insert testInvoice2;
            system.debug('====testInvoice2=222=='+testInvoice2);
            List<Invoice_Line_Item__c> lstILI = new List<Invoice_Line_Item__c>{new Invoice_Line_Item__c(Invoice_2__c = testInvoice2.id, Unit__c = 'Timesheet', Timesheet__c = testTimesheet.id, Generate_Detail__c = true),
                                                                               new Invoice_Line_Item__c(Invoice_2__c = testInvoice2.id, Unit__c = 'Expense Report', Expense_Report__c = testExpenseReport2.id, Generate_Detail__c = true),
                                                                               new Invoice_Line_Item__c(Invoice_2__c = testInvoice2.id, Unit__c = 'Closing Report', Closing_Report__c = testConsultingCR.id, Generate_Detail__c = true)};
            insert lstILI;
            system.debug('=====lstILI===='+lstILI);
           Invoice2TriggerHandler.isExecuted = false;
            
            testInvoice2.Status__c = 'Printed';
            update testInvoice2;  
            system.debug('======updated ====222==='+testInvoice2);
            testInvoice2.Status__c = 'Emailed';
            update testInvoice2; 
             system.debug('====testInvoice2==4444='+testInvoice3);
            testInvoice3.Status__c = 'Emailed';
            update testInvoice3;
             system.debug('====testInvoice3==333='+testInvoice3);
            test.stoptest();
            
            delete testInvoice2;
            undelete testInvoice2;
        }
    }

    
   /* public static testMethod void test_Invoice2Controller1()
	{
        User objUser = H_Utility_Test.createUserRecords();
        system.runAs(objUser)
        {
            
            Tax_Rate__c tax = new Tax_Rate__c(Name ='test', Rate__c = 10, Taxable_Amount__c = 'Total', Applied_To__c = 'Closing Report');
            insert tax;
        
            Account objAccount = H_Utility_Test.accountRecords();
            objAccount.Tax_Rate__c = tax.Id;
            update objAccount;
            Credit_Check__c objCreditCheck = new Credit_Check__c(Status__c = 'Passed', Client__c = objAccount.Id);
            insert objCreditCheck;
            Contact conApp = new Contact(LastName='Approv Calif Contact Test',Email='anshul@satrangtech.com',AccountId=objAccount.Id);
            insert conApp;
            objAccount.Credit_Check__c = objCreditCheck.Id;
            update objAccount;
    
            Contact con = H_Utility_Test.contactRecords('Test', 'Contact', objAccount.Id, '', null, false,'test1@test.com');
            con.TR1__Birthdate__c = system.today().addyears(-20);
            con.Sex__c = 'Male';
            con.NI_Number__c = 'test';
            con.No_of_Non_Workable__c = 0;
            con.Pay_Type__c = 'PAYE';
            update con;

            //Custom setting broadbean
            List<Broadbean_Settings__c>  objBroadBeanCSlist  = new List<Broadbean_Settings__c>();
            objBroadBeanCSlist = [Select Id,Display_Menu__c, Secret_Key__c, Stylesheet_URL__c from Broadbean_Settings__c limit 1 FOR UPDATE ];
            Broadbean_Settings__c objBroadBeanCS = new Broadbean_Settings__c();
            if(objBroadBeanCSlist.size() > 0 ){
                objBroadBeanCS = objBroadBeanCSlist[0] ;
            }
            else {
                objBroadBeanCS = Broadbean_Settings__c.getOrgDefaults();
                objBroadBeanCS.Display_Menu__c = False;
                objBroadBeanCS.Secret_Key__c = '74be05bec946a11bf50e0a06d1981db8875b5682e6fd17e40fc167ebfe2c1db9';
                objBroadBeanCS.Stylesheet_URL__c = 'http://v4.adcourier.com/css/adapt-v4.css';
            }
            Database.insert(objBroadBeanCS , false);

            //invoicing custom setting
            Invoice_2_Utility__c testInvoice2UtilityRecord = new Invoice_2_Utility__c(Name = 'Draft_Invoices_List_View_URL', Value__c = 'www.google.com');
            insert testInvoice2UtilityRecord;

            
            TR1__Job__c job = H_Utility_Test.createJobRecords(objAccount.Id, con.Id);
            job.Job_Code__c = '157654112';
            job.Purchase_Order_Number__c = '7812683123';
            update job;
            Id JobId = job.Id;
            H_Utility_Test.createApplication(con.Id, 'Accepted', JobId);


            //Rate card and Timetype
            Time_Type__c testTimeType1 = new Time_Type__c(Name = 'Holiday (Unpaid)', Entry_Type__c = 'Hours');
            insert testTimeType1;
            Time_Type__c testTimeType2 = new Time_Type__c(Name = 'Base', Entry_Type__c = 'Start/Finish');
            insert testTimeType2;
            Billing_Profile__c testBillingProfile = new Billing_Profile__c(Account__c = objAccount.id,Billing_Account__c =objAccount.id , Invoice_Contact__c = con.id, Bill_Frequency__c = 'Weekly',Invoice_Split_Type__c='Invoice Per Processing Week');
            insert testBillingProfile;
            objAccount.Billing_Profile__c = testBillingProfile.id;
            update objAccount;
            
            Test.startTest();
            TR1__Closing_Report__c TempCR = createClosingReportsTemp(objAccount.Id, con.Id, objUser.Id, JobId);
            TR1__Closing_Report__c PermCR = createClosingReportsPerm(objAccount.Id, con.Id, objUser.Id, JobId);
            
            Rate_Card_Detail__c testRateCardDetail = new Rate_Card_Detail__c(Rate_Card__c = TempCR.Placement_Rate_Card__c, Time_Type__c = testTimeType1.id, Regular_Pay_Rate__c = 0.0, Regular_Bill_Rate__c=0.0);
            insert testRateCardDetail;
            Rate_Card_Detail__c testRateCardDetail1 = new Rate_Card_Detail__c(Rate_Card__c = TempCR.Placement_Rate_Card__c, Time_Type__c = testTimeType2.id, Regular_Pay_Rate__c = 10.0, Regular_Bill_Rate__c=10.0);
            insert testRateCardDetail1;
            
            TR1__Timesheet__c ts = new TR1__Timesheet__c();
            ts.TR1__Status__c='Approved';
            ts.TR1__Closing_Report__c =TempCR.Id;
            ts.TR1__Consultant__c=TempCR.TR1__Person_Placed__c; 
            ts.TR1__Job_Order__c = TempCR.TR1__Job__c;
            //ts.TR1__Approver__c=TempCR.Timesheet_Approver_2__c;
            ts.TR1__Client__c=TempCR.TR1__Account__c;
            ts.TR1__Week_Ending__c = Date.today().toStartOfWeek().addDays(7);
            ts.TR1__Pay_Week_Ending__c = Date.today().toStartOfWeek().addDays(7);
            insert ts;
            
            test.stoptest();
            
            List<TR1__Timesheet_Detail__c> timesheetdetails = new List<TR1__Timesheet_Detail__c>(); 
            TR1__Timesheet_Detail__c td = new TR1__Timesheet_Detail__c();
            td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(1),TR1__Day__c='Monday');
            timesheetdetails.add(td);
            td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(2),TR1__Day__c='Tuesday');
            timesheetdetails.add(td);
            td = new TR1__Timesheet_Detail__c(TR1__Timesheet__c=ts.id, TR1__Date__c=Date.today().toStartOfWeek().addDays(3),TR1__Day__c='Wednesday');
            timesheetdetails.add(td);
            insert timesheetdetails;
            List<Shift_Work__c> swList = new List<Shift_Work__c> ();
            List<Shift_Work__c> swList2 = new List<Shift_Work__c> ();
            
            for(TR1__Timesheet_Detail__c td1 : timesheetdetails){
                Shift_Work__c sw = new Shift_Work__c(Timesheet_Detail__c = td1.Id,Timesheet__c = td1.TR1__Timesheet__c,
                                   Finish_Hours__c='02',Finish_Minutes__c='00',Start_Hours__c='01',Start_Minutes__c='00'
                                   ,Bill_Rate_Card_Detail__c=testRateCardDetail.Id,Rate_Card_Detail__c=testRateCardDetail.Id);

                swList2.add(sw);
            }
         
            Id RecordTypeEXPDMM = Schema.SObjectType.TR1__Expense_Report_Detail__c.getRecordTypeInfosByName().get('Meals & Entertainment').getRecordTypeId();
            Id expRecordTypeMM = Schema.SObjectType.TR1__Expense_Report__c.getRecordTypeInfosByName().get('Internal Expense').getRecordTypeId();
            TR1__Expense_Report__c expPerm  =   new TR1__Expense_Report__c(TR1__Expense_Period_Start__c = Date.today().addDays(1), TR1__Expense_Period_End__c= Date.today().addDays(5), TR1__Status__c = 'Unsubmitted'
                                                ,TR1__Account__c= PermCR.TR1__Account__c ,TR1__Closing_Report__c = PermCR.Id,RecordTypeId = expRecordTypeMM);

            TR1__Expense_Report__c expTemp  =   new TR1__Expense_Report__c(TR1__Expense_Period_Start__c = Date.today().addDays(1), TR1__Expense_Period_End__c= Date.today().addDays(5), TR1__Status__c = 'Unsubmitted'
                                                ,TR1__Account__c= TempCR.TR1__Account__c ,TR1__Closing_Report__c = TempCR.Id, RecordTypeId = expRecordTypeMM);
            insert  expPerm;
            insert  expTemp;
            TR1__Expense_Report_Detail__c expdPerm = new TR1__Expense_Report_Detail__c(TR1__Date__c = Date.today().addDays(2), TR1__Vendor__c='MAcdonald' ,Billable_to_Client__c= True , TR1__Expense_Report__c = expPerm.Id, TR1__Amount__c = 55, RecordTypeId = RecordTypeEXPDMM);
            TR1__Expense_Report_Detail__c expdTemp = new TR1__Expense_Report_Detail__c(TR1__Date__c = Date.today().addDays(2), TR1__Vendor__c='MAcdonald' ,Billable_to_Client__c= True , TR1__Expense_Report__c = expTemp.Id, TR1__Amount__c = 55, RecordTypeId = RecordTypeEXPDMM);
            insert  expdTemp;
            insert  expdPerm;

            expPerm.TR1__Status__c = 'Approved';
            expTemp.TR1__Status__c = 'Approved';
            update  expPerm;
            update  expTemp;
            Set<Id> erRTIDset= new Set<Id>();
            Set<Id> crRTIDset= new Set<Id>();
            Set<String> billingFrequencyset= new Set<String>();

            Id permanentRecordTypeClosingReport = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Permanent').getRecordTypeId();
            Id tempRecordTypeClosingReport = Schema.SObjectType.TR1__Closing_Report__c.getRecordTypeInfosByName().get('Consulting').getRecordTypeId();

            crRTIDset.add(permanentRecordTypeClosingReport);
            crRTIDset.add(tempRecordTypeClosingReport);
            erRTIDset.add(expRecordTypeMM);
            billingFrequencyset.add('Weekly');
            
            Test.setCurrentPage(Page.Invoice);
            Invoice2Controller testInvoiceController = new Invoice2Controller();
            Invoice2Controller.NonBillableItemWrapper wrapp = new Invoice2Controller.NonBillableItemWrapper(TempCR, ts, expTemp, 'test');
            wrapp.cr = TempCR;
            wrapp.ts = ts;
            wrapp.er = expTemp;
            wrapp.reason = 'test';
            
            testInvoiceController.invoiceableMapSize = 0;
            Invoice2Controller.FailureWrapper objWrap = new Invoice2Controller.FailureWrapper('Test', 'testId', expPerm.Id);
            
            testInvoiceController.hasBillableItems = True;
            testInvoiceController.closingReportRecordTypeSelectedValues = '[]';
            testInvoiceController.billingProfileFrequencySelectedValues = '[]';
            testInvoiceController.InvoicePreviewButton();
            testInvoiceController.InvoiceCreateButton();
            testInvoiceController.closingReportRecordTypeSelectedValues = '['+tempRecordTypeClosingReport+']';
            testInvoiceController.expenseReportRecordTypeSelectedValues = '['+expRecordTypeMM+']';
            testInvoiceController.billingProfileFrequencySelectedValues = '[Weekly]';
            testInvoiceController.InvoicePreviewButton();
            delete ts;
            testInvoiceController.closingReportRecordTypeSelectedValues = '['+tempRecordTypeClosingReport+','+permanentRecordTypeClosingReport+']';
            testInvoiceController.expenseReportRecordTypeSelectedValues = '['+expRecordTypeMM+']';
            testInvoiceController.billingProfileFrequencySelectedValues = '[Weekly]';
            testInvoiceController.InvoiceCreateButton();
            testInvoiceController.InvoicePreviewButton(); 
            
            Invoice_2__c testInvoice1 = new Invoice_2__c(Status__c = 'Draft');
            insert testInvoice1;
            delete testInvoice1;
            undelete testInvoice1;
        }
    }*/
    
    
    public static TR1__Closing_Report__c createClosingReportsTemp(Id AccountId, Id contactId, Id userId, Id JobId){
    
        TR1__Account_Address__c address = new TR1__Account_Address__c(TR1__Account__c = AccountId,Health_and_Safety_Officer__c = contactId, TR1__Street_Address__c = 'asdasdaffa' );
        insert address;
        Id placementRateCardType = Schema.SObjectType.Rate__c.getRecordTypeInfosByName().get('Placement Rate Card').getRecordTypeId();
        Rate__c rate_Card = new Rate__c(RecordTypeId = placementRateCardType, Contract_Type__c = 'W2',SVS_Holiday_Pay__c = 'Yes');
        insert rate_Card;
        RecordType objRecordType = [Select Id from RecordType where
                                        DeveloperName = 'Consulting' AND
                                        SobjectType = 'TR1__Closing_Report__c' limit 1];

        TR1__Closing_Report__c objClosingReport = new TR1__Closing_Report__c(
                                                    Client_Site__c = address.Id,
                                                    TR1__Account__c = AccountId,
                                                    TR1__Person_Placed__c = contactId,
                                                    TR1__Start_Date__c = Date.today(),
                                                    TR1__Salary__c = 1000,
                                                    TR1__Billing_Street__c = 'Test Street',
                                                    TR1__Billing_City__c = 'Test City',
                                                    TR1__Billing_Zip_Code__c = '626001',
                                                    TR1__Job_Credit__c = userId,
                                                    TR1__Job_Percentage__c = 20,
                                                    TR1__Candidate_Percentage__c = 20,
                                                    TR1__Marketing_Percentage__c = 20,
                                                    TR1__Other_Percentage__c = 20,
                                                    TR1__Other2_Percentage__c = 20,
                                                    Sales_Commission_1_Team__c = createTeam().Id,
                                                    Sales_Commission_2_Team__c = createTeam().Id,
                                                    Sales_Commission_3_Team__c = createTeam().Id,
                                                    Placement_Rate_Card__c = rate_Card.Id,
                                                    TR1__Candidate_Credit__c = userId,
                                                    Marketing_Credit_Branch__c = H_Utility_Test.createBranch().Id,
                                                    Candidate_Credit_Branch__c = H_Utility_Test.createBranch().Id,
                                                    Job_Credit_Branch__c = H_Utility_Test.createBranch().Id,
                                                    Other_Credit_Branch__c = H_Utility_Test.createBranch().Id,
                                                    Other2_Credit_Branch__c = H_Utility_Test.createBranch().Id,
                                                    Job_Credit_Division__c = H_Utility_Test.createDivision().Id,
                                                    Marketing_Credit_Division__c = H_Utility_Test.createDivision().Id,
                                                    Other_Credit_Division__c = H_Utility_Test.createDivision().Id,
                                                    Candidate_Credit_Division__c = H_Utility_Test.createDivision().Id,
                                                    Other2_Credit_Division__c = H_Utility_Test.createDivision().Id,
                                                    TR1__Other_Credit__c = userId,
                                                    TR1__Other2_Credit__c = userId,
                                                    TR1__Marketing_Credit__c  = userId,
                                                    RecordTypeId = objRecordType.Id,
                                                    TR1__Job__c = JobId,
                                                    TR1__End_Date__c = Date.today().addDays(5),
                                                    hSell_to_Contact__c = contactId,
                                                    Successful_Start__c = 'yes',
                                                    Flat_Fee_Amount__c = 123,TR1__Fee_Percentage__c=1);
        insert objClosingReport;
        return objClosingReport;
        
    }
    public static TR1__Closing_Report__c createClosingReportsPerm(Id AccountId, Id contactId, Id userId, Id JobId){
    
        Id placementRateCardType = Schema.SObjectType.Rate__c.getRecordTypeInfosByName().get('Placement Rate Card').getRecordTypeId();
        Rate__c rate_Card = new Rate__c(RecordTypeId = placementRateCardType, Contract_Type__c = 'W2',SVS_Holiday_Pay__c = 'Yes');
        insert rate_Card;
         RecordType objRecordType = [Select Id from RecordType where
                                        DeveloperName = 'Permanent' AND
                                        SobjectType = 'TR1__Closing_Report__c' limit 1];

        TR1__Closing_Report__c objClosingReport = new TR1__Closing_Report__c(
                                                    TR1__Account__c = AccountId,
                                                    TR1__Person_Placed__c = contactId,
                                                    TR1__Start_Date__c = Date.today(),
                                                    TR1__Salary__c = 1000,
                                                    TR1__Billing_Street__c = 'Test Street',
                                                    TR1__Billing_City__c = 'Test City',
                                                    TR1__Billing_Zip_Code__c = '626001',
                                                    Placement_Rate_Card__c = rate_Card.Id,
                                                    TR1__Job_Credit__c = userId,
                                                    TR1__Job_Percentage__c = 20,
                                                    TR1__Candidate_Percentage__c = 20,
                                                    TR1__Marketing_Percentage__c = 20,
                                                    TR1__Other_Percentage__c = 20,
                                                    TR1__Other2_Percentage__c = 20,
                                                    TR1__Candidate_Credit__c = userId,
                                                    Sales_Commission_1_Team__c = createTeam().Id,
                                                    Sales_Commission_2_Team__c = createTeam().Id,
                                                    Sales_Commission_3_Team__c = createTeam().Id,
                                                    Marketing_Credit_Branch__c = H_Utility_Test.createBranch().Id,
                                                    Candidate_Credit_Branch__c = H_Utility_Test.createBranch().Id,
                                                    Job_Credit_Branch__c = H_Utility_Test.createBranch().Id,
                                                    Other_Credit_Branch__c = H_Utility_Test.createBranch().Id,
                                                    Other2_Credit_Branch__c = H_Utility_Test.createBranch().Id,
                                                    Job_Credit_Division__c = H_Utility_Test.createDivision().Id,
                                                    Marketing_Credit_Division__c = H_Utility_Test.createDivision().Id,
                                                    Other_Credit_Division__c = H_Utility_Test.createDivision().Id,
                                                    Candidate_Credit_Division__c = H_Utility_Test.createDivision().Id,
                                                    Other2_Credit_Division__c = H_Utility_Test.createDivision().Id,
                                                    TR1__Other_Credit__c = userId,
                                                    TR1__Other2_Credit__c = userId,
                                                    TR1__Marketing_Credit__c  = userId,
                                                    RecordTypeId = objRecordType.Id,
                                                    TR1__Job__c = JobId,
                                                    Successful_Start__c = 'yes',
                                                    //TR1__End_Date__c = Date.today().addDays(5),
                                                    hSell_to_Contact__c = contactId,
                                                    Flat_Fee_Amount__c = 123,TR1__Fee_Percentage__c=1
                                                    );
                                                    //Timesheet_Approver_2__c = conApp.Id;
        insert objClosingReport;
       
        return objClosingReport;
        
    }

    public static Team__c createTeam() {

        Team__c objTeam = new Team__c(Division__c = createDivision().Id, Branch__c = createBranch().Id);
        insert objTeam;
        return objTeam;
    }

    public static Division__c createDivision() {

        Division__c objDivision = new Division__c(Name = 'A & F', hExternal_Id__c = 'AF');
        insert objDivision;
        return objDivision;
    }

   public static TR1__Branch__c createBranch() {

       TR1__Branch__c objBranch = new TR1__Branch__c(Name = 'Test');
       insert objBranch;
       return objBranch;
   }

}