public with sharing class GetRecordDataController 

{
  
    @AuraEnabled(Cacheable=true)
    public static List<Reservation__c> getReservationData()
    {
        List<Reservation__c> getRecord=[SELECT  Id,Start_Date__c,Name,End_Date__c ,Contact__r.Id FROM Reservation__c LIMIT 10];


        return getRecord;

    }



    @AuraEnabled(Cacheable=true)
    public static List<Account> getAccountData()
    {
        List<Account> getRecord=[SELECT  Id,Name,Phone FROM Account];


        return getRecord;

    }


    
    @AuraEnabled
    public static void insertAccountData(WrapperClass getData)
    {

        try
        {
        Account getField=new Account();

        getField.Name=getData.accountName;
        getField.Phone=getData.phoneNumber;
            insert getField;
    }
    catch(Exception ex)
    {
        throw new AuraHandledException(ex.getMessage());
    }


    }


     
    @AuraEnabled
    public static void updateAccountData(WrapperClass getData)
    {

        // List<Account> getAccount=[Select Id, Name,Phone From Account WHERE Id=:getData.accountId];
        try
        {
        // Account getField=new Account();

        getAccount[0].Name=getData.accountName;
        getAccount[0].Phone=getData.phoneNumber;
        
        update getField;
    }
    catch(Exception ex)
    {
        throw new AuraHandledException(ex.getMessage());
    }


    }

    public class WrapperClass
    {

        @AuraEnabled
        public string accountId {get;set;}
        @AuraEnabled
        public string accountName {get;set;}

        @AuraEnabled
        public string phoneNumber{get;set;}


    }
}