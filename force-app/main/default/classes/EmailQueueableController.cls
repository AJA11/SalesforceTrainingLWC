public class EmailQueueableController implements Queueable {
    private List<Map<String, Object>> data;
    private String objectLabel;

    public EmailQueueableController(List<Map<String, Object>> data, String objectLabel) {
        this.data = data;
        this.objectLabel = objectLabel;
    }

    public void execute(QueueableContext context) {
        try {
            // Generate the CSV contents
            List<String> headersToRemove = new List<String>{'Id', 'record', 'Status', 'Error'};
            Map<String, String> csvContents = CsvGeneratorController.generateCsvContent(data, headersToRemove);

            String successCsvContent = csvContents.get('successCsvContent');
            String errorCsvContent = csvContents.get('errorCsvContent');
            Integer successCount = Integer.valueOf(csvContents.get('successCount'));
            Integer failCount = Integer.valueOf(csvContents.get('failCount'));

            Integer totalRecord = successCount + failCount;
            String currentUserName = UserInfo.getName();
            String currentUserId = UserInfo.getUserId();

            String description = 'This is with reference to Data upload activity which has been performed by ' + currentUserName +
                ' for object ' + objectLabel + ' has been completed successfully. Error and success files can be found in the attachment.\n' +
                'Here is the Summary-\n' +
                'Total Records: ' + totalRecord + '\n' +
                'Success Records: ' + successCount + '\n' +
                'Fail Records: ' + failCount;

            // Create DataUpload record
            Data_Upload__c dataUploadRecord = new Data_Upload__c(
                Name = 'Data Upload on ' + objectLabel,
                RecordTypeId = InsertDateEmailController.getRecordTypeId('Data Upload Process Information'),
                Requester__c = currentUserId,
                Description__c = description
            );
            insert dataUploadRecord;

            // Save non-empty CSVs as files in the DataUpload custom object
            if (successCsvContent != '') {
                saveCsvAsFile(dataUploadRecord.Id, 'SuccessLogFile.csv', successCsvContent);
            }
            if (errorCsvContent != '') {
                saveCsvAsFile(dataUploadRecord.Id, 'ErrorLogFile.csv', errorCsvContent);
            }

            // Send the email with non-empty attachments
            sendEmailWithAttachments(description, successCsvContent, errorCsvContent);

        } catch (Exception ex) {
            // Handle any errors and notify the user via email
            sendErrorNotification(ex.getMessage() + ex.getCause() + ex.getLineNumber() + ex.getStackTraceString() + ex.getTypeName());
            throw new AuraHandledException(ex.getMessage() + ex.getCause() + ex.getLineNumber());
        }
    }

    private void sendEmailWithAttachments(String description, String successCsvContent, String errorCsvContent) {
        List<String> emailAddresses = new List<String>{'Varsha.mahore@pfizer.com'};
        List<Messaging.EmailFileAttachment> attachments = new List<Messaging.EmailFileAttachment>();

        if (successCsvContent != '') {
            attachments.add(createEmailAttachment('SuccessLogFile.csv', successCsvContent));
        }
        if (errorCsvContent != '') {
            attachments.add(createEmailAttachment('ErrorLogFile.csv', errorCsvContent));
        }

        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('CSV Files');
        mail.setToAddresses(emailAddresses);
        mail.setPlainTextBody(description);
        mail.setFileAttachments(attachments);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }

    public void sendErrorNotification(String errorMessage) {
        List<String> emailAddresses = new List<String>{'Varsha.mahore@pfizer.com'};
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('Error in Data Upload Process');
        mail.setToAddresses(emailAddresses);
        mail.setPlainTextBody('An error occurred during the data upload process: ' + errorMessage);
        Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
    }

    private static Messaging.EmailFileAttachment createEmailAttachment(String fileName, String csvContent) {
        Messaging.EmailFileAttachment csvAttachment = new Messaging.EmailFileAttachment();
        Blob csvBlob = Blob.valueOf(csvContent);
        csvAttachment.setFileName(fileName);
        csvAttachment.setBody(csvBlob);
        return csvAttachment;
    }

    private static void saveCsvAsFile(Id dataUploadId, String fileName, String csvContent) {
        if (csvContent != '') {
            ContentVersion cv = new ContentVersion();
            cv.Title = fileName;
            cv.PathOnClient = fileName;
            cv.VersionData = Blob.valueOf(csvContent);
            insert cv;

            ContentDocumentLink cdl = new ContentDocumentLink();
            cdl.ContentDocumentId = [SELECT ContentDocumentId FROM ContentVersion WHERE Id = :cv.Id LIMIT 1].ContentDocumentId;
            cdl.LinkedEntityId = dataUploadId;
            cdl.ShareType = 'I';
            cdl.Visibility = 'AllUsers';
            insert cdl;
        }
    }
}
