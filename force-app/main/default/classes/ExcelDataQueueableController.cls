public class ExcelDataQueueableController implements Queueable {
    private Map<String, List<Map<String, String>>> data;
    private String objectName;
    private String objectLabel;
    private Integer batchSize;
    private Integer position;

    private List<Map<String, Object>> allResults;

    public ExcelDataQueueableController(Map<String, List<Map<String, String>>> data, String objectName, String objectLabel, Integer batchSize, Integer position,List<Map<String, Object>> allResults) {
        this.data = data;
        this.objectName = objectName;
        this.objectLabel = objectLabel;
        this.batchSize = batchSize;
        this.position = position;
        this.allResults=allResults;
    }

    public void execute(QueueableContext context) {

        try{
        // Determine the end position for this batch
        Integer endPos = Math.min(position + batchSize, data.get('jsonList').size());
    
        System.debug(endPos);
        System.debug(data.get('jsonList').size());

        // Get a subset of the data for this batch
        Map<String, List<Map<String, String>>> batchDataMap = new Map<String, List<Map<String, String>>>();
        batchDataMap.put('jsonList', new List<Map<String, String>>());
        batchDataMap.put('originalJsonList', new List<Map<String, String>>());
    
        for(Integer i = position; i < endPos; i++) {
            batchDataMap.get('jsonList').add(data.get('jsonList')[i]);
            batchDataMap.get('originalJsonList').add(data.get('originalJsonList')[i]);



            
        }
    
        System.debug(batchDataMap);
        System.debug(batchDataMap.get('jsonList').size());
        System.debug(batchDataMap.get('originalJsonList').size());


        // Process the batch data
        List<Map<String, Object>> resultReturn = InsertDateEmailController.insertIntoCustomObject(objectName, batchDataMap, objectLabel);

        System.debug(resultReturn);

        allResults.addAll(resultReturn);
    
        // If there is more data, chain another job
        if (endPos < data.get('jsonList').size()) {
            System.enqueueJob(new ExcelDataQueueableController(data, objectName, objectLabel, batchSize, endPos,allResults));
        } else {
            // If this is the last batch, enqueue the email job
            System.enqueueJob(new EmailQueueableController(allResults, objectLabel));
        }
    }
        catch(Exception ex) {
              
            new EmailQueueableController(allResults, objectLabel).sendErrorNotification(ex.getMessage() + ex.getCause() + ex.getLineNumber() + ex.getStackTraceString() + ex.getTypeName());

            System.debug(ex.getMessage() +ex.getCause() +ex.getLineNumber()+ex.getStackTraceString()+ex.getTypeName());
        throw new AuraHandledException(ex.getMessage() +ex.getCause() +ex.getLineNumber());
        }
    }
    
}
