public with sharing class GetRecordDataController 

{
  
    @AuraEnabled(Cacheable=true)
    public static List<Reservation__c> getReservationData()
    {
        List<Reservation__c> getRecord=[SELECT  Id,Start_Date__c,Name,End_Date__c ,Contact__r.Id FROM Reservation__c LIMIT 10];


        return getRecord;

    }


}