import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent} from 'lightning/platformShowToastEvent';
import getRelatedFilesByRecordId from '@salesforce/apex/DUFileDowloadandUploadController.getRelatedFilesByRecordId'
import createEventAttendee from '@salesforce/apex/DUFileDowloadandUploadController.createEventAttendee';
import getFileContent from '@salesforce/apex/DUFileDowloadandUploadController.getFileContent';
import readExcelThenInsertData from '@salesforce/apex/DUFileDowloadandUploadController.readExcelThenInsertData';
import getFieldMappings from '@salesforce/apex/InsertDateEmailController.getFieldMappings';
import { refreshApex } from '@salesforce/apex';

export default class Lwc_dataupload extends LightningElement {

    //  recordId='a7OKG000000Cab42AC';
    @track IsEventAttendeeselected = false;
    @track listofobject;
    filesList = [];
    @track previewData = [];
    @track columns = [];
    @track excelColumns = [];
    @track showModal = false;
    @track modalMessage = '';
    documentId;
    objectName;
    objectLabel;
    @track showModalConfirmation=false;
    @track dataLoader=false;
    fileDataReferesh;
    get options() {
        return [
            { label: 'Event Attendee', value: 'Event_Attendee_vod__c' },

        ];
    }

    handleChange(event) {
        this.listofobject = event.detail.value;
    
        // Find the selected option based on the value
        const selectedOption = this.options.find(option => option.value === this.listofobject);
    
        if (selectedOption) {
            const selectedLabel = selectedOption.label;
            const selectedValue = selectedOption.value;
            this.objectName=selectedValue;
            this.objectLabel=selectedLabel;

            refreshApex(this.fileDataReferesh);
            this.IsEventAttendeeselected = true;
        }
    }

    @wire(getRelatedFilesByRecordId, {objectLabel: '$objectLabel'})
    wiredResult(result) {
        const { data, error }=result;
        this.fileDataReferesh=result
        if (data) {
            console.log(data)
            this.filesList = Object.keys(data).map(item => ({
                "label": data[item],
                "value": item,
                "url": `/sfc/servlet.shepherd/document/download/${item}`
            }))
            console.log(this.filesList)
        }
        if (error) {
            console.log(error)
        }
    }

    handleUploadFinished(event) { // processes the uploaded file
        const uploadedFiles = event.detail.files;
        if (uploadedFiles.length > 0) {
            const documentId = uploadedFiles[0].documentId;
            this.documentId=documentId;
           
            this.fetchFileContent(documentId);
        } else {
            this.showToast('Error', 'No file uploaded', 'error');
        }
    }
    fetchFileContent(documentId) {
        getFileContent({
            documentId
        }).then(data => {
            console.log('File content:', data); // Log file content for debugging 
            this.parseCSV(data);
        }).catch(error => {
            this.showToast('Error', 'Error fetching file content', 'error');
            console.error('Error fetching file content:', error);
        });
    }
    parseCSV(fileContent) { // parses the CSV content into a list of objects
        try {
            const lines = fileContent.split('\n');
            const result = [];
            const columns = [];
            const headers = lines[0].split(',').map(header => header.trim()); // Set up the columns for the datatable 
            headers.forEach(header => {
                columns.push({
                    label: header,
                    fieldName: header
                });
            });
            for (let i = 1; i < lines.length && i <= 10; i++) { // Limit to 10 records for preview 
                const obj = {
                    id: i
                }; // Add a unique id for the key field 
                const currentline = lines[i].split(',');
                for (let j = 0; j < headers.length; j++) {
                    if (currentline[j] !== undefined) {
                        obj[headers[j]] = currentline[j].trim();
                    } else {
                        obj[headers[j]] = ''; // Handle missing values 
                    }
                }
                result.push(obj);
            }
            this.previewData = result;
            this.columns = columns;
            console.log('Parsed CSV data for preview:',
                result); // Log parsed data for debugging 
        } catch (error) {
            this.showToast('Error', 'Error parsing CSV file: ' + (error.message || error), 'error');
            console.error('Error parsing CSV file:', error);
        }
    }
    // handleConfirmUpload() {
       
    //     var columValidate=this.validateColumns();
    //     console.log(columValidate);

    //     if (columValidate) {
    
    //         this.showModalConfirmation=true;
    //         // const csvData = this.previewData.map(record => {
    //         //     const {
    //         //         id,
    //         //         ...rest
    //         //     } = record;
    //         //     return rest;
    //         // });

           
    //                         // console.log('In handleConfirmUpload',csvData);
    //         // this.createEventAttendee(csvData);
    //     } else {
    //         // this.showModal = true;
    //         // this.modalMessage = 'The columns in the uploaded file do not match the expected format.';

    //         this.showToast('Error','Column not Matching','error');
    //     }
    // }
    handleCancelUpload() {
        this.previewData = [];
        this.columns = [];
        this.showModalConfirmation=false;
    }
    validateColumns() {
        getFieldMappings({ objectName: this.objectName })
        .then((fieldMappings) => {
            // Extract the keys (labels) from the fieldMappings
            const requiredColumns = Object.keys(fieldMappings);
            
            // Check for missing columns
            const missingColumns = requiredColumns.filter(column => 
                !this.columns.some(col => col.fieldName.trim() === column.trim())
            );

           
            if(missingColumns.length === 0)
            {
                this.showModalConfirmation=true;

            }else
            {

                this.showToast('Error','Column not Matching','error');
            }
        })
        .catch((error) => {
            console.error('Error fetching field mappings:', error);
            return false;
        });

    }
    
    createEventAttendee(csvData) {
        createEventAttendee({
            csvData
        }).then(() => {
            this.showToast('Success', 'Event Attendee Created successfully', 'success'); //displays success or error messages to the user
        }).catch(error => {
            this.showToast('Error', 'Error Event Attendee: ' + (error.body.message || error), 'error');
            console.error('Error Event Attendee:', error);
        });
    }
    showToast(title, message, variant) {
        const event = new ShowToastEvent({
            title,
            message,
            variant,
        });
        this.dispatchEvent(event);
    }
    handleCloseModal() {
        this.showModal = false;
    }
    
    processFileUpload()
    {
        this.dataLoader=true;
        readExcelThenInsertData({documentId:this.documentId,objectName:this.objectName,objectLabel:this.objectLabel}).then(result=>{
            console.log(result);
            this.dataLoader=false;

            this.showToast('Success', 'File processed successfully. You will receive an email with details.', 'success');

            this.handleCancelUpload();
            })
    }

       

        }
    