@isTest

private class GetSessionByCourseTest {

    @isTest
    static void TestSessionFilter() {


        GetSessionByCourse.Request req = new GetSessionByCourse.Request();
        req.recChoiceCourse = [SELECT Id FROM TREX1__Course__c Limit 1].Id;


        GetSessionByCourse.process(new List<GetSessionByCourse.Request>{req});

    }


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

        TREX1__Global_Billing_Group__c billingGroup = new TREX1__Global_Billing_Group__c(
            Name = 'Test Billing Group',
            TREX1__Community_Bill_To_Account__c = 'Enabled',
            TREX1__Monthly_Billing_Day__c = 1,
            TREX1__Public_Name__c = 'Test Billing Group'
        );
        insert billingGroup;
        
        TREX1__Product__c productDiscount = new TREX1__Product__c(
            Name = 'Test Product',
            TREX1__Billing_Cancellation_Credit_Setting__c = 'No Credit',
            TREX1__Global_Billing_Group__c = billingGroup.Id
        );

        insert productDiscount;

        cs.TREX1__Product__c = productDiscount.Id;
        update cs;

        TREX1__Price_Level__c priceLevel = new TREX1__Price_Level__c();
        priceLevel.TREX1__Product__c = productDiscount.Id;
        insert priceLevel;

        TREX1__Planned_Billing_Schedule__c plannedBS = new TREX1__Planned_Billing_Schedule__c();
        plannedBS.TREX1__Price_Level__c = priceLevel.Id;
        plannedBS.TREX1__End_Date_Setting__c = 'Fixed End Date';
        plannedBS.TREX1__Start_Date__c = Date.newInstance(2023, 1, 1);
        plannedBS.TREX1__Number_Of_Terms__c = 1;
        insert plannedBS;


        TREX1__Available_Discounts__c availableDiscounts = new TREX1__Available_Discounts__c(
            Name = 'Discount Test',
            TREX1__Discount__c = productDiscount.Id,
            TREX1__Course_Session__c = cs.Id,
            TREX1__Course_Option__c = co.Id
        );
        insert availableDiscounts;

        TREX1__Question_Group__c questionGroup = new TREX1__Question_Group__c();
        questionGroup.Name = 'Test QuestionGroup';
        insert questionGroup;

        TREX1__Assigned_Question_Group__c assignQuestionGroups = new TREX1__Assigned_Question_Group__c(
            TREX1__Question_Group__c = questionGroup.Id,
            TREX1__Course_Session__c = cs.Id,
            TREX1__Program__c = program.Id,
            TREX1__Sort_Priority__c = 1
        );
        insert assignQuestionGroups;


    }
}