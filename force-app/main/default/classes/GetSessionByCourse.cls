global with sharing class GetSessionByCourse {

// a1xS0000001FOxOIAW
    @InvocableMethod(label='Get Session List by Course' description='Get Session List by Course')
    public static List<Result> process(List<Request> request) {
        List<TREX1__Course_Session__c> sessions = new List<TREX1__Course_Session__c>();
        if(request[0].recChoiceCourse != null){
            sessions = [SELECT TREX1__Session__c, TREX1__Session__r.Id, TREX1__Session__r.Name FROM TREX1__Course_Session__c WHERE TREX1__Course__c = :request[0].recChoiceCourse];
        } else {
            sessions = [SELECT TREX1__Session__c, TREX1__Session__r.Id, TREX1__Session__r.Name FROM TREX1__Course_Session__c];
        }

        Map<Id, TREX1__Session__c> tempMap = new Map<Id,TREX1__Session__c>();

        for(TREX1__Course_Session__c session : sessions){
            tempMap.put(session.TREX1__Session__c, session.TREX1__Session__r);
        }
        Result result = new Result();
        result.Sessions = tempMap.values();

        return new List<Result>{result};
    }


    public class Request {
        @InvocableVariable(required=false description='Course Selected')
        public String recChoiceCourse;
    }


    global class Result {
        @InvocableVariable(description='Sessions')
        public List<TREX1__Session__c> Sessions;

    }
}