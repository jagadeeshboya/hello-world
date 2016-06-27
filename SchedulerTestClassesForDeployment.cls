@isTest
public class SchedulerTestClassesForDeployment {
    public static testMethod void test_schedular(){
        
    	Vacancy_Scheduler_new schRef = new Vacancy_Scheduler_new();  
        SchedulerHelperClas schHlp = new SchedulerHelperClas();  
        Scheduler_CRTriggerHandler schCRT = new Scheduler_CRTriggerHandler();
       Scheduler_IncomingSMSTriggerHandler refsch2 = new Scheduler_IncomingSMSTriggerHandler();
        Scheduler_FilterJob refsch3 = new Scheduler_FilterJob();
        Scheduler_JobCalendar refsch4 = new Scheduler_JobCalendar();
        Scheduler_JSDHandler refsch5 = new Scheduler_JSDHandler();
        Scheduler_CandidateAvailability refSch6 = new Scheduler_CandidateAvailability();
        Scheduler_CSDHandler refSch7 = new Scheduler_CSDHandler();
        Scheduler_FilterCandidates refSch8 = new Scheduler_FilterCandidates();
        Scheduler_CandidateCalendar refSch9 = new Scheduler_CandidateCalendar();
        Scheduler_CRSHandler refSch10 = new Scheduler_CRSHandler();
        Scheduler_JobTriggerHandler refSch11 = new Scheduler_JobTriggerHandler();
        Scheduler_Utility refSch12 = new Scheduler_Utility();
        CandidateSchedulerExtension_new refSch13 = new CandidateSchedulerExtension_new();
        ClosingReportSchedule_Helper refSch14 = new ClosingReportSchedule_Helper();
    }
	
}