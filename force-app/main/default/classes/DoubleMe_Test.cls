/*
 * DoubleMe: Handler for Cloning the details.
 * 
 * 
 * 
 * Created By: 			Revision Date	
 * Sagarika Rout 		28th Sep		Updated: Added system.assert
 * Sagarika Rout 		28th Sep		Updated: Added negative test method
 */
@isTest
private class DoubleMe_Test {

    @TestSetup
    static void makeData(){

        TREX1__Program__c program = new TREX1__Program__c(
            Name = 'Test', 
            TREX1__Available__c = true, 
            TREX1__Available_Online__c = true
        );
        insert program;

        TREX1__Course__c course = new TREX1__Course__c(
            Name = 'Test Course', 
            TREX1__Available__c = true, 
            TREX1__Available_Online__c = true, 
            TREX1__Program__c = program.Id
        );
        insert course;

        List<TREX1__Session__c> lstSessions = new List<TREX1__Session__c>();

        TREX1__Session__c oldSession = new TREX1__Session__c(
            Name = 'Spring 22',
            TREX1__Available__c = true,
            TREX1__Available_Online__c = true,
            TREX1__Available_Online_From__c = Date.today().addDays(-60),
            TREX1__Available_Online_To__c = Date.today().addDays(-30),
            TREX1__Register_From_Date__c = Date.today().addDays(-60),
            TREX1__Register_To_Date__c = Date.today().addDays(-30),
            TREX1__Register_Online_From_Date__c = Date.today().addDays(-60),
            TREX1__Register_Online_To_Date__c = Date.today().addDays(-30),
            TREX1__Start_Date__c = Date.today().addDays(-60),
            TREX1__End_Date__c = Date.today().addDays(-30),
            TREX1__Status__c = 'Available'
        );
        lstSessions.add(oldSession);

        TREX1__Session__c newSession = new TREX1__Session__c(
            Name = 'Summer 22',
            TREX1__Available__c = true,
            TREX1__Available_Online__c = true,
            TREX1__Available_Online_From__c = Date.today().addDays(30),
            TREX1__Available_Online_To__c = Date.today().addDays(60),
            TREX1__Register_From_Date__c = Date.today().addDays(30),
            TREX1__Register_To_Date__c = Date.today().addDays(60),
            TREX1__Register_Online_From_Date__c = Date.today().addDays(30),
            TREX1__Register_Online_To_Date__c = Date.today().addDays(60),
            TREX1__Start_Date__c = Date.today().addDays(30),
            TREX1__End_Date__c = Date.today().addDays(60),
            TREX1__Status__c = 'Available'
        );
        lstSessions.add(newSession);

        insert lstSessions;

        TREX1__Course_Session__c cs = new TREX1__Course_Session__c(
            Name = 'Spring 22 Test S22',
            TREX1__Session__c = oldSession.Id,
            TREX1__Course__c = course.Id,
            TREX1__Status__c = 'Approved'
        );
        insert cs;

        TREX1__Course_Option__c co = new TREX1__Course_Option__c(
            Name = 'Spring 22 Test S22',
            TREX1__Type__c = 'Standard Course Option',
            TREX1__Status__c = 'Approved',
            TREX1__Age_as_of_date__c = Date.today().addDays(-60),
            TREX1__Start_Date__c = Date.today().addDays(-60),
            TREX1__End_Date__c = Date.today().addDays(-30),
            TREX1__Available__c = true,
            TREX1__Register_From_Date__c = Date.today().addDays(-60),
            TREX1__Register_From_Time__c = '9:00 AM',
            TREX1__Register_To_Date__c = Date.today().addDays(-30),
            TREX1__Register_To_Time__c = '11:00 AM',
            TREX1__Available_Online__c = true,
            TREX1__Register_Online_From_Date__c = Date.today().addDays(-60),
            TREX1__Register_Online_From_Time__c = '9:00 AM',
            TREX1__Register_Online_To_Date__c = Date.today().addDays(-30),
            TREX1__Register_Online_To_Time__c = '11:00 AM',
            TREX1__Setup_Time_Required__c = 0,
            TREX1__Tear_Down_Time_Required__c = 0
        );
        insert co;

        TREX1__Course_Session_Option__c cso = new TREX1__Course_Session_Option__c(
            TREX1__Course_Option__c = co.Id,
            TREX1__Course_Session__c = cs.Id,
            TREX1__Option_Available__c = true,
            TREX1__Available_Online__c = true
        );
        insert cso;

    }

    @isTest
    static void cloneStuffInFixedDateMode() {

        List<TREX1__Course_Session_Option__c> lstOldCSOs = [
            SELECT Id, Name, TREX1__Course_Option__r.TREX1__Type__c, TREX1__Course_Option__r.TREX1__Status__c,
                   TREX1__Course_Option__r.TREX1__Age_as_of_date__c, TREX1__Course_Option__r.TREX1__Start_Date__c,
                   TREX1__Course_Option__r.TREX1__End_Date__c, TREX1__Course_Option__r.TREX1__Available__c,
                   TREX1__Course_Option__r.TREX1__Register_From_Time__c, TREX1__Course_Option__r.TREX1__Register_To_Time__c,
                   TREX1__Course_Option__r.TREX1__Register_From_Date__c, TREX1__Course_Option__r.TREX1__Register_To_Date__c,
                   TREX1__Course_Option__r.TREX1__Available_Online__c, TREX1__Course_Option__r.TREX1__Register_Online_From_Date__c,
                   TREX1__Course_Option__r.TREX1__Register_Online_From_Time__c, TREX1__Course_Option__r.TREX1__Register_Online_To_Time__c,
                   TREX1__Course_Option__r.TREX1__Register_Online_To_Date__c, TREX1__Course_Option__r.TREX1__Setup_Time_Required__c,
                   TREX1__Course_Option__r.TREX1__Tear_Down_Time_Required__c, TREX1__Course_Session__r.Name, 
                   TREX1__Course_Session__r.TREX1__Session__c, TREX1__Course_Session__r.TREX1__Course__c, 
                   TREX1__Course_Session__r.TREX1__Status__c, TREX1__Course_Option__c, TREX1__Course_Session__c, 
                   TREX1__Option_Available__c, TREX1__Available_Online__c, TREX1__Course_Option__r.Name
              FROM TREX1__Course_Session_Option__c
             WHERE TREX1__Course_Session__r.Name = 'Spring 22 Test S22'
             LIMIT 1
        ];
        
        TREX1__Session__c oldSession;
        TREX1__Session__c newSession;

        List<TREX1__Session__c> lstSessions = [
            SELECT Id, Name, TREX1__Available__c, TREX1__Available_Online__c,
                   TREX1__Available_Online_From__c, TREX1__Available_Online_To__c,
                   TREX1__Start_Date__c, TREX1__End_Date__c, TREX1__Status__c
              FROM TREX1__Session__c
             LIMIT 2
        ];

        for (TREX1__Session__c session : lstSessions) {
            if (session.Name == 'Spring 22') {
                oldSession = session;
            } else if (session.Name == 'Summer 22') {
                newSession = session;
            }
        }

        List<TREX1__Course_Session_Option__c> lstCSOs = lstOldCSOs;
        Id originalSessionId = oldSession.Id;
        Id targetSessionId = newSession.Id;
        Boolean fixedDateMode = true;
        Date fixedStartDate = Date.today().addDays(30);
        Date fixedEndDate = Date.today().addDays(60);
        Boolean updateSessionNameMode = true;

        List<DoubleMe.Result> lstResult;

        Test.startTest();
        DoubleMe.Request request;
        request = new DoubleMe.Request();
        request.lstCSOs = lstCSOs;
        request.originalSessionId = originalSessionId;
        request.targetSessionId = targetSessionId;
        request.fixedDateMode = true;
        request.fixedStartDate = fixedStartDate;
        request.fixedEndDate = fixedEndDate;
        request.updateSessionNameMode = updateSessionNameMode;

        lstResult = DoubleMe.doubleThisCollection(
            new List<DoubleMe.Request>{ request }
        );
        Test.stopTest();
        
    }

    @isTest
    static void cloneStuffNotInFixedDateMode() {

        List<TREX1__Course_Session_Option__c> lstOldCSOs = [
            SELECT Id, Name, TREX1__Course_Option__r.TREX1__Type__c, TREX1__Course_Option__r.TREX1__Status__c,
                   TREX1__Course_Option__r.TREX1__Age_as_of_date__c, TREX1__Course_Option__r.TREX1__Start_Date__c,
                   TREX1__Course_Option__r.TREX1__End_Date__c, TREX1__Course_Option__r.TREX1__Available__c,
                   TREX1__Course_Option__r.TREX1__Register_From_Time__c, TREX1__Course_Option__r.TREX1__Register_To_Time__c,
                   TREX1__Course_Option__r.TREX1__Register_From_Date__c, TREX1__Course_Option__r.TREX1__Register_To_Date__c,
                   TREX1__Course_Option__r.TREX1__Available_Online__c, TREX1__Course_Option__r.TREX1__Register_Online_From_Date__c,
                   TREX1__Course_Option__r.TREX1__Register_Online_From_Time__c, TREX1__Course_Option__r.TREX1__Register_Online_To_Time__c,
                   TREX1__Course_Option__r.TREX1__Register_Online_To_Date__c, TREX1__Course_Option__r.TREX1__Setup_Time_Required__c,
                   TREX1__Course_Option__r.TREX1__Tear_Down_Time_Required__c, TREX1__Course_Session__r.Name, 
                   TREX1__Course_Session__r.TREX1__Session__c, TREX1__Course_Session__r.TREX1__Course__c, 
                   TREX1__Course_Session__r.TREX1__Status__c, TREX1__Course_Option__c, TREX1__Course_Session__c, 
                   TREX1__Option_Available__c, TREX1__Available_Online__c, TREX1__Course_Option__r.Name
              FROM TREX1__Course_Session_Option__c
             WHERE TREX1__Course_Session__r.Name = 'Spring 22 Test S22'
             LIMIT 1
        ];
        
        TREX1__Session__c oldSession;
        TREX1__Session__c newSession;

        List<TREX1__Session__c> lstSessions = [
            SELECT Id, Name, TREX1__Available__c, TREX1__Available_Online__c,
                   TREX1__Available_Online_From__c, TREX1__Available_Online_To__c,
                   TREX1__Start_Date__c, TREX1__End_Date__c, TREX1__Status__c
              FROM TREX1__Session__c
             LIMIT 2
        ];

        for (TREX1__Session__c session : lstSessions) {
            if (session.Name == 'Spring 22') {
                oldSession = session;
            } else if (session.Name == 'Summer 22') {
                newSession = session;
            }
        }

        List<TREX1__Course_Session_Option__c> lstCSOs = lstOldCSOs;
        Id originalSessionId = oldSession.Id;
        Id targetSessionId = newSession.Id;
        Boolean fixedDateMode = false;
        Integer daysToAdd = 60;
        Boolean updateSessionNameMode = true;

        List<DoubleMe.Result> lstResult;

        Test.startTest();
            DoubleMe.Request request;
            request = new DoubleMe.Request();
            request.lstCSOs = lstCSOs;
            request.originalSessionId = originalSessionId;
            request.targetSessionId = targetSessionId;
            request.fixedDateMode = false;
            request.daysToAdd = daysToAdd;
            request.updateSessionNameMode = updateSessionNameMode;
    
            lstResult = DoubleMe.doubleThisCollection(
                new List<DoubleMe.Request>{ request }
            );
        Test.stopTest();
        

        System.assert(lstResult.size() > 0);
        System.assert(lstResult[0].lstClonedCSOs != null);
        System.assert(lstResult[0].lstClonedCourseOptions != null);
        
		List<TREX1__Course_Session_Option__c> csList = lstResult[0].lstClonedCSOs;
        System.assert(csList.size() > 0);
		System.assertEquals(csList[0].TREX1__Option_Available__c, true, 'unable to fetch Option Avaiable');
        System.assertNotEquals(csList[0].TREX1__Course_Session__c, Null, 'unable to fetch Course_Session');
        System.assertNotEquals(csList[0].TREX1__Course_Option__c, null, 'unable to fetch Course_Option');
        System.assertEquals(csList[0].TREX1__Available_Online__c, true, 'unable to fetch Available_Online');
        
        List<TREX1__Course_Option__c> coList = lstResult[0].lstClonedCourseOptions;
        System.assert(coList.size() > 0);
		System.assertEquals(coList[0].Name, 'Summer 22 Test U22', 'unable to fetch Name');
        System.assertEquals(coList[0].TREX1__Age_as_of_date__c, date.today(), 'unable to fetch Age_as_of_date');
        System.assertEquals(coList[0].TREX1__Display_Number_of_Classes__c, false, 'unable to fetch Display_Number_of_Classes');
        System.assertEquals(coList[0].TREX1__Available__c, true, 'unable to fetch Available');
        System.assertEquals(coList[0].TREX1__Available_Online__c, true, 'unable to fetch Available_Online');
         
    }
    
    @isTest
    static void cloneStuffNotInFixedDateModeNullTest() {
        Test.startTest();
            
        try{
            List<DoubleMe.Result> lstResult = DoubleMe.doubleThisCollection(
                new List<DoubleMe.Request>{ new DoubleMe.Request() }
            );
            System.assert(false, 'Expected an exception.');
        }
        catch(AuraHandledException e) {
            System.debug('AuraHandledException: ' + e.getMessage());
            System.assertEquals('Script-thrown exception', e.getMessage());
        }
        Test.stopTest();
        

    }


}