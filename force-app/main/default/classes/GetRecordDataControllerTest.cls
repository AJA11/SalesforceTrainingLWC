/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an org are executed whenever Apex code is deployed
 * to a production org to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production org. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the org size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class GetRecordDataControllerTest {

    
    @isTest
    // (SeeAllData=true)
    static void myUnitTest() {

        Hotel__c insertHot=new Hotel__c(Street_Address__c='Test',State__c='Uttar Pradesh',City__c='Moradabad');
        insert insertHot;
        Contact insertCon=new Contact(LastName='Sethi');
        insert insertCon;

        Room__c insertRom=new Room__c(Room_Cost__c=20,Hotel__c=insertHot.Id);
        insert insertRom;
        Reservation__c getReserved=new Reservation__c();
        getReserved.Room__c=insertRom.Id;
        getReserved.Contact__c=insertCon.Id;

        getReserved.Name='Test Reservation';
        insert getReserved;


        Test.startTest();
        List<Reservation__c> getData=GetRecordDataController.getReservationData();
        Test.stopTest();

        // System.assertEquals(1,getData.Size());
        // System.assertEquals('Test Reservation',getData[0].Name);



        // TO DO: implement unit test
    }

    @isTest
    // (SeeAllData=true)
    static void testTrigger() {

        GetRecordDataController.WrapperClass getWrap=new GetRecordDataController.WrapperClass();


        getWrap.accountName='Ajay';
        getWrap.phoneNumber='999-999-9999';

        Test.startTest();
        GetRecordDataController.insertAccountData(getWrap);
        Test.stopTest();

        List<Account> getAccount= [SELECT Id,Name,Phone FROM  Account];

        System.assertEquals(1,getAccount.Size());

        System.assertEquals('Ajay',getAccount[0].Name);

        getAccount[0].Name='Sethi';
        update getAccount;
        // System.assertEquals('Test Reservation',getData[0].Name);



        // TO DO: implement unit test
    }
}