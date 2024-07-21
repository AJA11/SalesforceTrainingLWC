@isTest
private class DynamicQueryControllerTest {

@isTest
static void testGetDynamicFieldAndQuery() {
    // Create a test case record
    Hotel__c insertHotel=new Hotel__c(Street_Address__c='Test',City__c='Moradabad',State__c='Uttar Pradesh');
    insert  insertHotel;
    Room__c testCase = new Room__c(
        Hotel__c = insertHotel.Id,
        Room_Cost__c=240
    );
    insert testCase;

    // Call the method to be tested
    Test.startTest();
    DynamicQueryController.getDynamicFieldAndQuery();
    Test.stopTest();

    // Verify the results
    List<Room__c> testCases = [SELECT Id, Name, Hotel__r.Name FROM Room__c];
        System.assertEquals(testCases.Size(), 1);
    
}}