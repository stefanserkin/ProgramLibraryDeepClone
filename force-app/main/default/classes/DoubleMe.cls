/*
 * DoubleMe: Handler for Cloning the details.
 * 
 * 
 * 
 * Created By: 			Revision Date	
 * Sagarika Rout 		27th Sep		Updated: Added Null Check and try Catch
 */ 
public with sharing class DoubleMe {

    /**
     * Static variables
     */

    // Coming and going session information
    private static Id originalSessionId;
    private static String originalSessionName;
    private static String originalSessionCode;
    private static Id targetSessionId;
    private static String targetSessionName;
    private static String targetSessionCode;

    // Configuration options from flow input
    private static Integer daysToAdd;
    private static Date fixedStartDate;
    private static Date fixedEndDate;
    private static Boolean fixedDateMode = false;
    private static Boolean updateSessionNameMode = false;
    
    private static string exceptionString = 'The following exception has occurred: ';
    private static String contactAdminError = ' kindly Contact to Admin';

    /**
     * Invocable Method
     */

    @InvocableMethod(label='Double Me' description='Provide a collection of Course Session Options to clone')
    public static List<Result> doubleThisCollection(List<Request> lstRequests) {
        try {
            List<Result> lstResults = new List<Result>();
            List<TREX1__Course_Session_Option__c> lstCSOs;
    
            if(lstRequests.size() > 0){
                lstCSOs = lstRequests.get(0).lstCSOs;
                originalSessionId = lstRequests.get(0).originalSessionId;
                targetSessionId = lstRequests.get(0).targetSessionId;
                fixedDateMode = lstRequests.get(0).fixedDateMode != null ? lstRequests.get(0).fixedDateMode : false;
                daysToAdd = lstRequests.get(0).daysToAdd != null ? lstRequests.get(0).daysToAdd : 0;
                fixedStartDate = lstRequests.get(0).fixedStartDate != null ? lstRequests.get(0).fixedStartDate : Date.today();
                fixedEndDate = lstRequests.get(0).fixedEndDate != null ? lstRequests.get(0).fixedEndDate : Date.today();
                updateSessionNameMode = lstRequests.get(0).updateSessionNameMode != null ? lstRequests.get(0).updateSessionNameMode : false;
            }
            else{
                return null;
            }
            if (updateSessionNameMode) {
                setSessionDetails();
            }
            
            Set<Id> setCourseOptionIds = new Set<Id>();
            Set<Id> setCourseSessionIds = new Set<Id>();
            // Create sets of ids for queries
            for (TREX1__Course_Session_Option__c cso : lstCSOs) {
                if(cso.TREX1__Course_Option__c != null){
                    setCourseOptionIds.add(cso.TREX1__Course_Option__c);
                }
                if(cso.TREX1__Course_Session__c != null){
                	setCourseSessionIds.add(cso.TREX1__Course_Session__c);
                }
            }
            
            // Get map of records with only fields to clone
            Map<Id, TREX1__Course_Session__c> mapCourseSessions = getCourseSessionMap(setCourseSessionIds);
            Map<Id, TREX1__Course_Option__c> mapCourseOptions = getCourseOptionMap(setCourseOptionIds);
            // Create maps of cloned records and insert them
            Map<Id, TREX1__Course_Session__c> mapOldCourseSessionIdToClone = cloneCourseSessions(mapCourseSessions);
            
            
            if (!mapOldCourseSessionIdToClone.isEmpty()) {
                insert mapOldCourseSessionIdToClone.values();
                
            }
            Map<Id, TREX1__Course_Option__c> mapOldCourseOptionIdToClone = cloneCourseOptions(mapCourseOptions);
            if (!mapOldCourseOptionIdToClone.isEmpty()) {
                insert mapOldCourseOptionIdToClone.values();
            }
            
            // Create CSOs for each in request, pointing to cloned parent records
            List<TREX1__Course_Session_Option__c> lstClonedCSOs = new List<TREX1__Course_Session_Option__c>();
            for (TREX1__Course_Session_Option__c cso : lstCSOs) {
                lstClonedCSOs.add(
                    new TREX1__Course_Session_Option__c(
                        TREX1__Course_Session__c   = mapOldCourseSessionIdToClone.get(cso.TREX1__Course_Session__c).Id,
                        TREX1__Course_Option__c    = mapOldCourseOptionIdToClone.get(cso.TREX1__Course_Option__c).Id,
                        TREX1__Option_Available__c = cso.TREX1__Option_Available__c,
                        TREX1__Available_Online__c = cso.TREX1__Available_Online__c
                    )
                );
            }
            if (!lstClonedCSOs.isEmpty()) {
                insert lstClonedCSOs;
            }
            
            Result result = new Result();
            result.lstClonedCSOs = lstClonedCSOs;
            result.lstClonedCourseSessions = mapOldCourseSessionIdToClone.values();
            result.lstClonedCourseOptions = mapOldCourseOptionIdToClone.values();
            lstResults.add(result);
            return lstResults;
            
            

        }catch (QueryException e) {
            System.debug('Query Exception hit' + e.getStackTraceString());
            throw new AuraHandledException( exceptionString +  e.getStackTraceString() + contactAdminError);


        }catch(DmlException e){
                //If a DML exception occurs it will go to this statement
                System.debug('DmlException hit' + e.getStackTraceString());
            	throw new AuraHandledException( exceptionString +  e.getStackTraceString() + contactAdminError);

        }catch (Exception e) {
                //Any other exceptions that occur will go here
                System.debug('Exception hit' + e.getStackTraceString());
                throw new AuraHandledException( exceptionString +  e.getStackTraceString() + contactAdminError);    
        } finally {
                // for future use
        }

    }

    /**
     * Clone records and modify clones to configuration input
     */

    private static Map<Id, TREX1__Course_Session__c> cloneCourseSessions(
        Map<Id, TREX1__Course_Session__c> mapCourseSessions
    ) {
        Map<Id, TREX1__Course_Session__c> mapOldCourseSessionIdToClone = new Map<Id, TREX1__Course_Session__c>();
        for (TREX1__Course_Session__c cs : mapCourseSessions.values()) {
            TREX1__Course_Session__c clonedCourseSession = cs.clone(false, false, false, false);
            if (fixedDateMode) {
                updateCourseSessionDatesInFixedMode(clonedCourseSession, fixedStartDate, fixedEndDate);
            } else {
                updateCourseSessionDates(clonedCourseSession, daysToAdd);
            }
            if (updateSessionNameMode) {
                updateCourseSessionName(clonedCourseSession);
            }
            clonedCourseSession.TREX1__Session__c = targetSessionId;
            mapOldCourseSessionIdToClone.put(cs.Id, clonedCourseSession);
        }
        return mapOldCourseSessionIdToClone;
    }

    private static Map<Id, TREX1__Course_Option__c> cloneCourseOptions(
        Map<Id, TREX1__Course_Option__c> mapCourseOptions
    ) {
        Map<Id, TREX1__Course_Option__c> mapOldCourseOptionIdToClone = new Map<Id, TREX1__Course_Option__c>();
        for (TREX1__Course_Option__c co : mapCourseOptions.values()) {
            TREX1__Course_Option__c clonedCourseOption = co.clone(false, false, false, false);
            if (fixedDateMode) {
                updateCourseOptionDatesInFixedMode(clonedCourseOption, fixedStartDate, fixedEndDate);
            } else {
                updateCourseOptionDates(clonedCourseOption, daysToAdd);
            }
            if (updateSessionNameMode) {
                updateCourseOptionName(clonedCourseOption);
            }
            mapOldCourseOptionIdToClone.put(co.Id, clonedCourseOption);
        }
        return mapOldCourseOptionIdToClone;
    }

    /**
     * Helpers replace instances of Session Name or Session Code in record names
     * e.g. Baseball Spring 2022 Tournament => Baseball Summer 2022 Tournament
     */

    private static void updateCourseSessionName(
        TREX1__Course_Session__c cs
    ) {
        if (cs.Name.contains(originalSessionName)) {
            cs.Name = cs.Name.replace(originalSessionName, targetSessionName);
        }
        if (cs.Name.contains(originalSessionCode)) {
            cs.Name = cs.Name.replace(originalSessionCode, targetSessionCode);
        }
    }

    private static void updateCourseOptionName(
        TREX1__Course_Option__c co
    ) {
        if (co.Name.contains(originalSessionName)) {
            co.Name = co.Name.replace(originalSessionName, targetSessionName);
        }
        if (co.Name.contains(originalSessionCode)) {
            co.Name = co.Name.replace(originalSessionCode, targetSessionCode);
        }
    }

    /**
     * Date update helpers
     */

    // Add days to all dates
    
    private static void updateCourseSessionDates(
        TREX1__Course_Session__c cs, 
        Integer daysToAdd
    ) {
        cs.TREX1__Available_Online_From__c = cs.TREX1__Available_Online_From__c != null ? cs.TREX1__Available_Online_From__c + daysToAdd : null;
        cs.TREX1__Available_Online_To__c = cs.TREX1__Available_Online_To__c != null ? cs.TREX1__Available_Online_To__c + daysToAdd : null;
    } 

    private static void updateCourseOptionDates(
        TREX1__Course_Option__c co, 
        Integer daysToAdd
    ) {
        co.TREX1__Start_Date__c = co.TREX1__Start_Date__c != null ? co.TREX1__Start_Date__c + daysToAdd : null;
        co.TREX1__End_Date__c = co.TREX1__End_Date__c != null ? co.TREX1__End_Date__c + daysToAdd : null;
        co.TREX1__Register_From_Date__c = co.TREX1__Register_From_Date__c != null ? co.TREX1__Register_From_Date__c + daysToAdd : null;
        co.TREX1__Register_To_Date__c = co.TREX1__Register_From_Date__c != null ? co.TREX1__Register_From_Date__c + daysToAdd : null;
        co.TREX1__Register_Online_From_Date__c = co.TREX1__Register_Online_From_Date__c != null ? co.TREX1__Register_Online_From_Date__c + daysToAdd : null;
        co.TREX1__Register_Online_To_Date__c = co.TREX1__Register_Online_To_Date__c != null ? co.TREX1__Register_Online_To_Date__c + daysToAdd : null;
        co.TREX1__Early_Register_From_Date__c = co.TREX1__Early_Register_From_Date__c != null ? co.TREX1__Early_Register_From_Date__c + daysToAdd : null;
        co.TREX1__Early_Register_To_Date__c = co.TREX1__Early_Register_To_Date__c != null ? co.TREX1__Early_Register_To_Date__c + daysToAdd : null;
        co.TREX1__Early_Register_Online_From_Date__c = co.TREX1__Early_Register_Online_From_Date__c != null ? co.TREX1__Early_Register_Online_From_Date__c + daysToAdd : null;
        co.TREX1__Early_Register_Online_To_Date__c = co.TREX1__Early_Register_Online_To_Date__c != null ? co.TREX1__Early_Register_Online_To_Date__c + daysToAdd : null;
        co.TREX1__Age_as_of_date__c = co.TREX1__Age_as_of_date__c != null ? co.TREX1__Age_as_of_date__c + daysToAdd : null;
    } 

    // Update dates to configuration start and end dates

    private static void updateCourseSessionDatesInFixedMode(
        TREX1__Course_Session__c cs, 
        Date startDate, 
        Date endDate
    ) {
        cs.TREX1__Available_Online_From__c = startDate;
        cs.TREX1__Available_Online_To__c = endDate;
    } 

    private static void updateCourseOptionDatesInFixedMode(
        TREX1__Course_Option__c co, 
        Date startDate, 
        Date endDate
    ) {
        co.TREX1__Start_Date__c = startDate;
        co.TREX1__End_Date__c = endDate;
        co.TREX1__Register_From_Date__c = startDate;
        co.TREX1__Register_To_Date__c = endDate;
        co.TREX1__Register_Online_From_Date__c = startDate;
        co.TREX1__Register_Online_To_Date__c = endDate;
        co.TREX1__Early_Register_From_Date__c = startDate;
        co.TREX1__Early_Register_To_Date__c = endDate;
        co.TREX1__Early_Register_Online_From_Date__c = startDate;
        co.TREX1__Early_Register_Online_To_Date__c = endDate;
        co.TREX1__Age_as_of_date__c = co.TREX1__Age_as_of_date__c != null ? startDate : null;
    } 

    /**
     * Set name and session code for original and target sessions
     */

    private static void setSessionDetails() {
        Map<Id, TREX1__Session__c> mapSessions = getSessionMap();
        if(mapSessions != null && !mapSessions.isEmpty()){
            TREX1__Session__c originalSession = mapSessions.get(originalSessionId);
            TREX1__Session__c targetSession = mapSessions.get(targetSessionId);
            if(originalSession != null){
            	originalSessionName = originalSession.Name;
            	originalSessionCode = originalSession.Session_Code__c != null ? originalSession.Session_Code__c : null;    
            }
            if(targetSession != null){
                targetSessionName = targetSession.Name;
                targetSessionCode = targetSession.Session_Code__c != null ? targetSession.Session_Code__c : null;
            }
        }
        
    }


    /**
     * Queries
     */

    private static Map<Id, TREX1__Course_Session__c> getCourseSessionMap(
        Set<Id> setCourseSessionIds
    ) {
        return new Map<Id, TREX1__Course_Session__c>([
            SELECT Id, Name, TREX1__Available__c, TREX1__Available_Online__c, TREX1__Available_Online_From__c, 
                   TREX1__Available_Online_To__c, TREX1__Code__c, TREX1__Course__c, TREX1__Description__c, TREX1__Expiry_Extension_Seconds__c,
                   TREX1__External_Alert__c, TREX1__Free_Membership_End_Date__c, TREX1__Free_Membership_Start_Date__c, TREX1__Free_Membership_Type__c, 
                   TREX1__Initial_Seconds_To_Expiry__c, TREX1__Internal_Alert__c, TREX1__Max_Expiry_Seconds__c, TREX1__Num_Classroom_Assignments__c,
                   TREX1__Num_Option_Entitlements__c, TREX1__Product__c, TREX1__Required_of_Employees_10_Registrants__c, TREX1__Reservation_Expiry_Seconds__c,
                   TREX1__Rich_Description__c, TREX1__Session__c, TREX1__Status__c, TREX1__Supervisor__c, TREX1__Supervisor_Email__c,
                   TREX1__Transfer_Fee__c, TREX1__Transfer_GL_Account__c, TREX1__Transfer_in_within_Program__c, TREX1__Transfer_out_within_Program__c, 
                   TREX1__Waitlist_Message__c, TREX1__Withdrawal_Days__c, TREX1__Withdrawal_Fee__c, TREX1__Withdrawal_GL_Account__c, TREX1__Withdrawal_Policy__c
              FROM TREX1__Course_Session__c 
             WHERE Id IN :setCourseSessionIds
              WITH SECURITY_ENFORCED
             LIMIT 10000
        ]);
    }

    private static Map<Id, TREX1__Course_Option__c> getCourseOptionMap(
        Set<Id> setCourseOptionIds
    ) {
        return new Map<Id, TREX1__Course_Option__c>([
            SELECT Id, Name, Day_of_Week_Code__c, TREX1__Age_as_of_date__c, TREX1__Age_Max__c, TREX1__Age_Min__c, 
                   TREX1__Attendance_Group__c, TREX1__Available__c, TREX1__Available_Online__c, TREX1__Capacity__c, 
                   TREX1__Code__c, TREX1__Day_of_Week__c, TREX1__Description__c, TREX1__Scanning_Location__c, 
                   TREX1__Display_Number_of_Classes__c, TREX1__Early_Register__c, TREX1__Early_Register_From_Date__c,
                   TREX1__Early_Register_From_Time__c, TREX1__Early_Register_Online__c, TREX1__Early_Register_Online_From_Date__c,
                   TREX1__Early_Register_Online_From_Time__c, TREX1__Early_Register_Online_To_Date__c, 
                   TREX1__Early_Register_Online_To_Time__c, TREX1__Early_Register_To_Date__c, TREX1__Early_Register_To_Time__c,
                   TREX1__Enable_Automated_Waitlist__c, TREX1__Enable_Calendar_Booking_Download__c, TREX1__Enable_Reservation__c,
                   TREX1__End_Date__c, TREX1__End_Time__c, TREX1__Grade_Range__c, TREX1__Instructor__c, TREX1__Location__c,
                   TREX1__Number_of_Classes__c, TREX1__Overbooking_Capacity__c, TREX1__Product__c, TREX1__Register_From_Date__c,
                   TREX1__Register_From_Time__c, TREX1__Register_Online_From_Date__c, TREX1__Register_Online_From_Time__c,
                   TREX1__Register_Online_To_Date__c, TREX1__Register_Online_To_Time__c, TREX1__Register_To_Date__c, 
                   TREX1__Register_To_Time__c, TREX1__Setup_Notes__c, TREX1__Setup_Time_Required__c, TREX1__Show_Age_Range__c,
                   TREX1__Show_Capacity_Online__c, TREX1__Show_Cost__c, TREX1__Show_Days__c, TREX1__Show_Grade_Range__c, 
                   TREX1__Show_Instructor__c, TREX1__Show_Location__c, TREX1__Show_Time_Window__c, TREX1__Show_Watlist_Capacity__c,
                   TREX1__Special_Instructions__c, TREX1__Start_Date__c, TREX1__Start_Time__c, TREX1__Status__c, 
                   TREX1__Tear_Down_Notes__c, TREX1__Tear_Down_Time_Required__c, TREX1__Transfer_in_within_Program__c,
                   TREX1__Transfer_out_within_Program__c, TREX1__Type__c, TREX1__Unlimited_Capacity__c, 
                   TREX1__Unlimited_Overbooking_Capacity__c, TREX1__Unlimited_Waitlist_Capacity__c, 
                   TREX1__Unnamed_Group_Reg_Max_Tickets__c, TREX1__Unnamed_Group_Reg_Min_Tickets__c,
                   TREX1__Unnamed_Group_Registration__c, TREX1__Waitlist_Capacity__c, TREX1__Waitlist_Message__c,
                   TREX1__Waitlist_Pending_Confirmation_Total__c, TREX1__Waitlist_Total__c
              FROM TREX1__Course_Option__c 
             WHERE Id IN :setCourseOptionIds
              WITH SECURITY_ENFORCED
             LIMIT 10000
        ]);
    }

    private static Map<Id, TREX1__Session__c> getSessionMap() {
        return new Map<Id, TREX1__Session__c>([
            SELECT Id, Name, Session_Code__c FROM TREX1__Session__c WHERE Id = :originalSessionId OR Id = :targetSessionId WITH SECURITY_ENFORCED LIMIT 2 
        ]);
    }

    /**
     * Wrappers
     */

    public class Request {
        @InvocableVariable(required=true description='Original Course Session Options')
        public List<TREX1__Course_Session_Option__c> lstCSOs;
        @InvocableVariable(required=true description='Original Session')
        public Id originalSessionId;
        @InvocableVariable(required=true description='Target Session')
        public Id targetSessionId;
        @InvocableVariable(description='Fixed Date Mode')
        public Boolean fixedDateMode;
        @InvocableVariable(description='Days to Add')
        public Integer daysToAdd;
        @InvocableVariable(description='Fixed Start Date')
        public Date fixedStartDate;
        @InvocableVariable(description='Fixed End Date')
        public Date fixedEndDate;
        @InvocableVariable(description='Update Session Names in Record Names')
        public Boolean updateSessionNameMode;
    }

    public class Result {
        @InvocableVariable(description='Cloned Course Sessions')
        public List<TREX1__Course_Session__c> lstClonedCourseSessions;
        @InvocableVariable(description='Cloned Course Options')
        public List<TREX1__Course_Option__c> lstClonedCourseOptions;
        @InvocableVariable(description='Cloned Course Session Options')
        public List<TREX1__Course_Session_Option__c> lstClonedCSOs;
    }

}