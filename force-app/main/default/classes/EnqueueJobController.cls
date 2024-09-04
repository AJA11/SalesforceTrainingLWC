public with sharing class EnqueueJobController {


    public static void enqueueJobForProcessing(Map<String, List<Map<String, String>>> jsonData, String objectLabel,String objectName) {
        Integer batchSize = 1000;
        List<Map<String, Object>> allResults = new List<Map<String, Object>>();
        ExcelDataQueueableController q = new ExcelDataQueueableController(jsonData,objectName,objectLabel, batchSize, 0, allResults);
        System.enqueueJob(q);
    }
}