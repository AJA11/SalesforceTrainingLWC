public with sharing class InsertDateEmailController {

    // Map of object names to their respective field label-to-API name mappings
    public static Map<String, Map<String, String>> objectFieldLabelToApiNameMap = new Map<String, Map<String, String>>{
        'Event_Attendee_vod__c' => new Map<String, String>{
            'Account _Local_Data_Provider_id' => 'Account_vod__c',
            'Attendance_Type' => 'CMS_Attendance_Type__c',
            'Status' => 'Status_vod__c',
            'Medical_Event_number' => 'Medical_Event_vod__c'
            // Add more mappings as needed
        }
        // Add more objects if needed
    };


        
        public static Id getRecordTypeId(String recordTypeName) {
            try {
                // Query for the RecordType Id based on the provided object and record type name
                RecordType rt = [SELECT Id FROM RecordType WHERE SObjectType = 'Data_Upload__c' AND Name = :recordTypeName LIMIT 1];
                return rt.Id;
            } catch (Exception e) {
                // Handle the case where the RecordType is not found or an error occurs
                System.debug('Error retrieving RecordTypeId: ' + e.getMessage());
                return null;
            }
        }
    
    
    /**
     * Inserts records into a custom object and sends a result summary email.
     *
     * @param objectName The API name of the Salesforce object to insert records into.
     * @param jsonMap A map containing the JSON data to be inserted.
     * @return A CSV string of the insertion results.
     */
    public static List<Map<String, Object>> insertIntoCustomObject(String objectName, Map<String, List<Map<String, String>>> jsonMap,String objectLabel) {
        List<SObject> recordsToInsert = new List<SObject>();
        List<SObject> recordsToSkip = new List<SObject>();
        List<Map<String, Object>> results = new List<Map<String, Object>>();

        List<Map<String, String>> jsonList = jsonMap.get('jsonList');
        List<Map<String, String>> originalJsonList = jsonMap.get('originalJsonList');
        List<Map<String, String>> originalRecordsToInsert = new List<Map<String, String>>();

        try {
            // Process each record in the JSON list
            for (Integer i = 0; i < jsonList.size(); i++) {
                Map<String, String> recordMap = jsonList[i];
                Map<String, String> originalRecordMap = originalJsonList[i];

                SObject record = Schema.getGlobalDescribe().get(objectName).newSObject();
                Map<String, Object> result = new Map<String, Object>();
                Boolean hasMissingField = false;

                // Map each field to its corresponding API name and check for missing required fields
                for (String key : recordMap.keySet()) {
                    String fieldName = key.replaceAll('[^\\x00-\\x7F]', '');
                    String apiName = getApiName(objectName, fieldName);
                    if (apiName != null) {
                        String value = recordMap.get(key);
                        if (String.isBlank(value)) {
                            hasMissingField = true;
                            result.put('Status', 'Fail');
                            result.put('Error', 'Required Field is Missing: ' + key);
                        }
                        record.put(apiName, value);
                    }
                }

                // Categorize records based on the presence of missing fields
                if (hasMissingField) {
                    result.put('record', originalRecordMap);
                    recordsToSkip.add(record);
                } else {
                    recordsToInsert.add(record);
                    originalRecordsToInsert.add(originalRecordMap);
                }

                if (!result.isEmpty()) {
                    results.add(result);
                }
            }

            // Insert valid records and log the results
            Database.SaveResult[] srList = Database.insert(recordsToInsert, false);
            for (Database.SaveResult sr : srList) {
                Map<String, Object> resultss = new Map<String, Object>();
                if (sr.isSuccess()) {
                    resultss.put('Status', 'Success');
                    resultss.put('record', originalRecordsToInsert[srList.indexOf(sr)]);
                } else {
                    for (Database.Error err : sr.getErrors()) {
                        resultss.put('Status', 'Fail');
                        resultss.put('Error', err.getMessage());
                        resultss.put('record', originalRecordsToInsert[srList.indexOf(sr)]);
                    }
                }
                if (!resultss.isEmpty()) {
                    results.add(resultss);
                }
            }

            return results;


        } catch (Exception ex) {
            System.debug('Error: ' + ex.getMessage());
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * Retrieves the API name of a field based on its label.
     *
     * @param objectName The API name of the Salesforce object.
     * @param fieldLabel The label of the field.
     * @return The API name of the field, or null if not found.
     */
    public static String getApiName(String objectName, String fieldLabel) {
        Map<String, String> fieldLabelToApiNameMap = objectFieldLabelToApiNameMap.get(objectName);
        if (fieldLabelToApiNameMap != null && fieldLabelToApiNameMap.containsKey(fieldLabel)) {
            return fieldLabelToApiNameMap.get(fieldLabel);
        }
        return null; // Return null if API name not found
    }

    @AuraEnabled
    public static Map<String, String> getFieldMappings(String objectName) {
        if (objectFieldLabelToApiNameMap.containsKey(objectName)) {
            return objectFieldLabelToApiNameMap.get(objectName);
        }
        return new Map<String, String>();
    }

    //Make this Code Asynchronous
    // /**
    //  * Sends an email with a CSV attachment containing the results of the insert operation.
    //  *
    //  * @param data The list of maps containing the insertion results.
    //  * @return The CSV content as a string.
    //  */
    // public static void sendEmailWithCSVAttachment(List<Map<String, Object>> data,String objectLabel) {
    //     Integer successCount = 0;
    //     Integer failCount = 0;
    //     Integer totalRecord = 0;
    // String currentUserName=UserInfo.getName();
    // String currenUserId=UserInfo.getUserId();
    // String description;
    //     List<String> headersToRemove = new List<String>{'Id', 'record', 'Status', 'Error'};
    //     Set<String> headerSet = new Set<String>();
    
    //     // Collect all headers from the data set
    //     for (Map<String, Object> record : data) {
    //         headerSet.addAll(record.keySet());
    //         Map<String, String> innerRecord = (Map<String, String>) record.get('record');
    //         headerSet.addAll(innerRecord.keySet());
    //     }
    //     headerSet.removeAll(headersToRemove);
    
    //     List<String> header = new List<String>(headerSet);
    //     header.add('Status');
    //     header.add('Error');
    
    //     // Initialize CSV content for success and error records
    //     String successCsvContent = String.join(header, ',') + '\n';
    //     String errorCsvContent = String.join(header, ',') + '\n';
    
    //     for (Map<String, Object> record : data) {
    //         List<String> row = new List<String>();
    //         for (String headerElement : header) {
    //             Object value = record.get(headerElement);
    //             if (value == null) {
    //                 Map<String, String> innerRecord = (Map<String, String>) record.get('record');
    //                 value = innerRecord.get(headerElement);
    //             }
    //             row.add('"' + String.valueOf(value) + '"');
    //         }
    
    //         String status = (String) record.get('Status');
    //         if (status == 'Success') {
    //             successCsvContent += String.join(row, ',') + '\n';
    //             successCount++;
    //         } else if (status == 'Fail') {
    //             errorCsvContent += String.join(row, ',') + '\n';
    //             failCount++;
    //         }
    //     }
    //     totalRecord = successCount + failCount;
    //     description = 'This is with reference to Data upload activity which has been performed by '+currentUserName+' for object '
    //     + objectLabel 
    //     + ' has been completed successfully. Error and success file can be found in attachment.\n'
    //     + 'Here is the Summary-\n'
    //     + 'Total Records: ' + totalRecord + '\n'
    //     + 'Success Records: ' + successCount + '\n'
    //     + 'Fail Records: ' + failCount;
    //     // Create a DataUpload record
    //     Data_Upload__c dataUploadRecord = new Data_Upload__c(
    //         Name = 'Data Upload on ' +objectLabel,
    //         RecordTypeId=getRecordTypeId('Data Upload Process Information'),
    //         Requester__c=currenUserId,
    //         Description__c=description
    //         );
    //     insert dataUploadRecord;
    
    //     // Save CSVs as files in the DataUpload custom object
    //     saveCsvAsFile(dataUploadRecord.Id, 'SuccessLogFile.csv', successCsvContent);
    //     saveCsvAsFile(dataUploadRecord.Id, 'ErrorLogFile.csv', errorCsvContent);
    
    //     // Send an email with both CSV attachments
    //     List<String> testEmailAddress = new List<String>{'Varsha.mahore@pfizer.com'};
    //     Messaging.EmailFileAttachment successCsvAttachment = createEmailAttachment('SuccessLogFile.csv', successCsvContent);
    //     Messaging.EmailFileAttachment errorCsvAttachment = createEmailAttachment('ErrorLogFile.csv', errorCsvContent);
    
    //     Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    //     mail.setSubject('CSV Files');
    //     mail.setToAddresses(testEmailAddress);
    //     // String emailBody = 'Hi User,\n\n' + 'Please find below the details of data uploaded.\n\n' +
    //     //     'Total Records: ' + totalRecord + '\n' +
    //     //     'Success Records: ' + successCount + '\n' +
    //     //     'Fail Records: ' + failCount;
    //     mail.setPlainTextBody(description);
    //     mail.setFileAttachments(new Messaging.EmailFileAttachment[]{successCsvAttachment, errorCsvAttachment});
    //     Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    
    //     // return 'Email sent with CSV attachments.';
    // }
    
    // private static Messaging.EmailFileAttachment createEmailAttachment(String fileName, String csvContent) {
    //     Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
    //     Blob csvBlob = Blob.valueOf(csvContent);
    //     csvAttachment.setFileName(fileName);
    //     csvAttachment.setBody(csvBlob);
    //     return csvAttachment;
    // }
    
    // private static void saveCsvAsFile(Id dataUploadId, String fileName, String csvContent) {
    //     ContentVersion cv = new ContentVersion();
    //     cv.Title = fileName;
    //     cv.PathOnClient = fileName;
    //     cv.VersionData = Blob.valueOf(csvContent);
    //     insert cv;
    
    //     ContentDocumentLink cdl = new ContentDocumentLink();
    //     cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
    //     cdl.LinkedEntityId = dataUploadId;
    //     cdl.ShareType = 'I';
    //     cdl.Visibility = 'AllUsers';
    //     insert cdl;
    // }
    


}
