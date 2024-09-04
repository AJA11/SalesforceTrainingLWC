/********************************************************************************************************
* Class Name  : DUFileDowloadandUploadController 
* Created By    : Infosys
* Description   : this class is used to perform Upload Event Attendee and E-ermission record Insert.

**********************************************************************************************************/

public class DUFileDowloadandUploadController {

/*************************************************************************************
* Method Name : getRelatedFilesByRecordId
* Created By  : Infosys
* Description : used to download file formate for Data Download
**************************************************************************************/
    @AuraEnabled(cacheable=true)
        public static Map<ID, String> getRelatedFilesByRecordId(String objectLabel) {

            String recordId=getExcelRecordId(objectLabel);
            // Get record file IDs        
            List<ContentDocumentLink> files = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId = :recordId];
            List<ID> fileIDs = new List<ID>();
            for (ContentDocumentLink docLink : files) {
                fileIDs.add(docLink.ContentDocumentId);
            }
     
            List<ContentVersion> docs = [SELECT ContentDocumentId, FileExtension, Title 
                FROM ContentVersion WHERE ContentDocumentId IN : fileIDs];
            Map<ID, String> mapIdTitle = new Map<ID, String>();
            for (ContentVersion docLink : docs) {
                mapIdTitle.put(docLink.ContentDocumentId, docLink.Title);
            }
            return mapIdTitle;
   }

/*************************************************************************************
* Method Name : getFileContent
* Created By  : Infosys
* Description : used to Read the column of Uplaoded filed during data upload
**************************************************************************************/    
    @AuraEnabled
    public static String getFileContent(Id documentId) {
        ContentVersion contentVersion = [
            SELECT VersionData
            FROM ContentVersion
            WHERE ContentDocumentId = :documentId
            LIMIT 1
        ];
        Blob contentBlob = contentVersion.VersionData;
        return contentBlob.toString();
    }
/*************************************************************************************
* Method Name : getFileContent
* Created By  : Infosys
* Description : used to Read the column of Uplaoded filed during data upload
**************************************************************************************/     
      @AuraEnabled
    //public static void updateAccounts(String accountData) { //List<Map<String, String>> csvData
    public static void createEventAttendee(List<Map<String, String>> csvData) {
      List<Event_Attendee_vod__c> EventAttendeeList = new List<Event_Attendee_vod__c>();
       
        for (Map<String, String> row : csvData) {

            if (row.containsKey('Medical_Event_number') && row.containsKey('Account _Local_Data_Provider_id')) {
                String localdataproviderId = row.get('Account_Local_Data_Provider_id');
                String attendeetype = row.get('Attendance_Type');
                String status = row.get('Status');
                String medicaleventnumber = row.get('Medical_Event_number');

                // Validate that the fields are not empty
                if (!String.isBlank(localdataproviderId) && !String.isBlank(attendeetype) && !String.isBlank(status) && !String.isBlank(medicaleventnumber)) {
                    Event_Attendee_vod__c eventattendee = new Event_Attendee_vod__c(Account_vod__c = localdataproviderId, Medical_Event_vod__c = medicaleventnumber,Status_vod__c = status,CMS_Attendance_Type__c = attendeetype );
                    EventAttendeeList.add(eventattendee);
                } else {
                    System.debug('Skipping row due to empty Event Attendee: ' + row);
                }
            } else {
                System.debug('Skipping row due to empty Event Attendee: ' + row);
            }
            
        }

        try {
            if (!EventAttendeeList.isEmpty()) {
            insert EventAttendeeList;
            System.debug('Event Attendee Inserted successfully');
            }
        } catch (DmlException e) {
            System.debug('Error updating Event Attendee: ' + e.getMessage());
            throw new AuraHandledException('Error updating Event Attendee: ' + e.getMessage());
        }
    }
    
      /**
     * This method reads an Excel file by its document ID, processes the content, 
     * converts it to JSON format, and then inserts the data into a custom object.
     *
     * @param documentId The ID of the document containing the Excel file.
     * @return A string response from the insert operation.
     */
    @AuraEnabled
    public static String readExcelThenInsertData(String documentId, String objectName, String objectLabel) {
        // Fetch the file content as a string.
        String fileDataString = getFileContent(documentId);
        
        // Remove any non-ASCII characters to avoid processing errors.
        fileDataString = fileDataString.replaceAll('[^\\x00-\\x7F]', '');
        
        // Convert the cleaned CSV data to JSON format.
       convertCSVtoJSON(fileDataString,objectName,objectLabel);
        
        // Process the JSON data asynchronously
        
        // Return success message
        return 'Success';
    }
    /**
     * This method converts CSV data into JSON format.
     * It processes each line of the CSV, maps header columns to field values, 
     * and handles specific lookups for related objects.
     *
     * @param csv The CSV data as a string.
     * @return A map containing the processed JSON data and the original CSV data as JSON.
     */
    @future
    public static void convertCSVtoJSON(String csv,String objectName, String objectLabel) {
        List<Map<String, String>> jsonList = new List<Map<String, String>>();
        List<Map<String, String>> originalJsonList = new List<Map<String, String>>();
        
        List<String> lines = csv.split('\n');
        List<String> headers = parseCSVLine(lines[0]);
        
        // Prepare sets to collect unique values for lookup
        Set<String> accountIds = new Set<String>();
        Set<String> medicalEventNumbers = new Set<String>();
        
        for (Integer i = 1; i < lines.size(); i++) {
            List<String> record = parseCSVLine(lines[i]);
            for (Integer j = 0; j < headers.size(); j++) {
                String header = headers[j];
                String fieldValue = record[j];
                
                if (header == 'Account _Local_Data_Provider_id') {
                    accountIds.add(fieldValue);
                } else if (header == 'Medical_Event_number') {
                    medicalEventNumbers.add(fieldValue);
                }
            }
        }
        
        // Perform the lookup queries in batch
        Map<String, Id> accountIdMap = getLookupIds('Account', 'Cegedim_ID__c', accountIds);
        Map<String, Id> medicalEventMap = getLookupIds('Medical_Event_vod__c', 'CMS_Event_Number__c', medicalEventNumbers);
        
        // Re-process the lines to build the JSON list
        for (Integer i = 1; i < lines.size(); i++) {
            Map<String, String> recordMap = new Map<String, String>();
            Map<String, String> originalRecordMap = new Map<String, String>();
            
            List<String> record = parseCSVLine(lines[i]);
            
            for (Integer j = 0; j < headers.size(); j++) {
                String header = headers[j];
                String fieldValue = record[j];
                
                if (header == 'Account _Local_Data_Provider_id') {
                    recordMap.put(header, accountIdMap.get(fieldValue));
                } else if (header == 'Medical_Event_number') {
                    recordMap.put(header, medicalEventMap.get(fieldValue));
                } else {
                    recordMap.put(header, fieldValue);
                }
                
                originalRecordMap.put(header, fieldValue);
            }
            
            jsonList.add(recordMap);
            originalJsonList.add(originalRecordMap);
        }
        
        Map<String, List<Map<String, String>>> result = new Map<String, List<Map<String, String>>>();
        result.put('jsonList', jsonList);
        result.put('originalJsonList', originalJsonList);
        
        EnqueueJobController.enqueueJobForProcessing(result, objectLabel, objectName);

        // return result;
    }
    /**
     * This method parses a single line of CSV data into individual fields.
     * It handles cases where fields may contain commas enclosed in quotes.
     *
     * @param line A single line from the CSV.
     * @return A list of parsed fields from the line.
     */
    private static List<String> parseCSVLine(String line) {
        // Regular expression to split CSV fields, considering quoted fields.
        Pattern csvPattern = Pattern.compile(',(?=([^"]*"[^"]*")*[^"]*$)');
        List<String> fields = new List<String>(csvPattern.split(line));
    
        // Remove surrounding quotes and carriage return from each field.
        for (Integer i = 0; i < fields.size(); i++) {
            String field = fields[i];
            if (field.startsWith('"') && field.endsWith('"')) {
                field = field.substring(1, field.length() - 1);
            }
            field = field.replace('\r', '');  // Remove carriage return character.
            fields[i] = field;
        }
    
        return fields;
    }

    /**
     * This method performs a lookup query on a specified object and field to retrieve the record ID.
     *
     * @param objectName The name of the Salesforce object (e.g., Account, Medical_Event_vod__C).
     * @param fieldName The API name of the field to query against (e.g., Cegedim_ID__c).
     * @param fieldValue The value to search for in the specified field.
     * @return The ID of the found record, or the original field value if no match is found.
     */
   // Helper method to perform bulk lookups
   private static Map<String, Id> getLookupIds(String objectName, String fieldName, Set<String> fieldValues) {
    Map<String, Id> lookupMap = new Map<String, Id>();

    if (fieldValues.isEmpty()) {
        return lookupMap;
    }

    // Query the database for records matching the field values
    String query = 'SELECT ' + fieldName + ', Id FROM ' + objectName + ' WHERE ' + fieldName + ' IN :fieldValues';
    for (SObject record : Database.query(query)) {
        lookupMap.put((String)record.get(fieldName), (Id)record.get('Id'));
    }

    // Add null entries for any field values that did not have a matching record
    for (String fieldValue : fieldValues) {
        if (!lookupMap.containsKey(fieldValue)) {
            lookupMap.put(fieldValue, null);
        }
    }

    return lookupMap;
}

    
    
    public static string getExcelRecordId (String objectLabel)
    
    {
        String recordTypeId=InsertDateEmailController.getRecordTypeId('Master Template Download');
        List<Data_Upload__c> getRecordId=[SELECT Id FROM Data_Upload__c WHERE List_of_Object__c=:objectLabel AND RecordTypeId=:recordTypeId LIMIT 1];

        if(!getRecordId.isEmpty())
        {
            return getRecordId[0].Id;

        }
        else
        {
            return 'File Not Found';
        }
    }
}

