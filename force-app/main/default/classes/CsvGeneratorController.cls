public class CsvGeneratorController {
    public static Map<String, String> generateCsvContent(List<Map<String, Object>> data, List<String> headersToRemove) {
        Map<String, String> csvContentMap = new Map<String, String>();

        Set<String> headerSet = new Set<String>();
        for (Map<String, Object> record : data) {
            headerSet.addAll(record.keySet());
            Map<String, String> innerRecord = (Map<String, String>) record.get('record');
            headerSet.addAll(innerRecord.keySet());
        }
        headerSet.removeAll(headersToRemove);

        List<String> headers = new List<String>(headerSet);
        headers.add('Status');
        headers.add('Error');

        String successCsvContent = '';
        String errorCsvContent = '';

        Integer successCount = 0;
        Integer failCount = 0;

        for (Map<String, Object> record : data) {
            List<String> row = new List<String>();
            for (String headerElement : headers) {
                Object value = record.get(headerElement);
                if (value == null) {
                    Map<String, String> innerRecord = (Map<String, String>) record.get('record');
                    value = innerRecord.get(headerElement);
                }
                row.add('"' + String.valueOf(value) + '"');
            }

            String status = (String) record.get('Status');
            if (status == 'Success') {
                successCsvContent += (successCsvContent != '' ? '\n' : '') + String.join(row, ',');
                successCount++;
            } else if (status == 'Fail') {
                errorCsvContent += (errorCsvContent != '' ? '\n' : '') + String.join(row, ',');
                failCount++;
            }
        }

        if (successCsvContent != '') {
            successCsvContent = String.join(headers, ',') + '\n' + successCsvContent;
        }

        if (errorCsvContent != '') {
            errorCsvContent = String.join(headers, ',') + '\n' + errorCsvContent;
        }

        csvContentMap.put('successCsvContent', successCsvContent);
        csvContentMap.put('errorCsvContent', errorCsvContent);
        csvContentMap.put('successCount', String.valueOf(successCount));
        csvContentMap.put('failCount', String.valueOf(failCount));

        return csvContentMap;
    }
}
