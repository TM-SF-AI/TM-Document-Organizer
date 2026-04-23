import { LightningElement, api, track } from 'lwc';
import fetchAllFiles from '@salesforce/apex/Documents_OrganizerController.fetchAllFiles';
import { NavigationMixin } from 'lightning/navigation'

export default class Document_Organizer extends NavigationMixin(LightningElement) {

    @api recordId;
    @track isSpiner = false;
    /* All Files List */
    @track recordFiles = [];
    @track recordImageFiles = [];
    @track recordDocumentFiles = [];
    @track emailFiles = [];
    @track emailImageFiles = [];
    @track emailOtherFiles = [];
    @track defaultTypeOptions = 'uploadFiles';
    @track defaultImgTypeOptions = 'uploadImages';
    @track defaultDocTypeOptions = 'uploadFileDoc';

    @track searchKeyWord = '';
    @track sortField = 'Title';
    @track orderType = 'asc';

    @track showAllList = true;
    @track showImages = true;
    @track showDocuments = true;
    @track showAllEmailList = false;
    @track showAllDocumentList = false;
    @track Buttontrue = true;

    @track SelectPicklist;
    @track selectEmailPicklist = false;
    @track slectDocPicklist = false;

    @track imagePicklist;
    @track selectImagEmPicklist = false;
    @track slectImagDocPicklist = false;

    @track DocumentPicklist;
    @track selectEmDocpicklist = false;
    @track selectFileDocpicklist = false;

    sortedDirection = 'asc';
    sortedColumn;

    typeOptions = [{ label: 'All Email Attachments:', value: 'emailAttachnent' },
    { label: 'All Uploaded Files:', value: 'uploadFiles' }];

    typeImgOptions = [{ label: 'Received Images:', value: 'recivedImage' },
    { label: 'Uploaded Images:', value: 'uploadImages' }];

    typeDoceOptions = [{ label: 'Received Documents:', value: 'recivedEmDoc' },
    { label: 'Uploaded Documents:', value: 'uploadFileDoc' }];


    getAllFiles() {
        this.isSpiner = true;

        fetchAllFiles({ searchKeyWord: this.searchKeyWord, parentId: this.recordId, sortField: this.sortField, orderType: this.orderType })
            .then((result) => {
                console.log('result', result);
                this.recordFiles = [];
                this.recordDocumentFiles =[];
                var recordFiles = result.recordFiles;
                var recordImageFiles = result.recordImageFiles;
                var recordDocumentFiles = result.recordOtherFiles;
                 console.log('recordFiles'+result.recordFiles);
                /** Record File */
                recordFiles.forEach(currentItem => {
                    var obj = {};
                    obj.checkbox = false;
                    const bytes = currentItem.ContentSize;
                    obj.ContentSize = this.getFileSize(bytes);
                    obj.Title = currentItem.Title;
                    obj.Id = currentItem.Id;
                    obj.cdId = currentItem.ContentDocumentId;
                    obj.CreatedDate = currentItem.CreatedDate;
                    obj.FileType = currentItem.FileType;
                    if (obj.FileType == 'ZIP') {
                        obj.isZip = true;
                    } else if (obj.FileType == 'WORD_X' || obj.FileType == 'DOCX') {
                        obj.isWord = true;
                    } else if (obj.FileType == 'EXCEL' || obj.FileType == 'EXCEL_X') {
                        obj.isExcel = true;
                    } else if (obj.FileType == 'POWER_POINT_X' || obj.FileType == 'POWER_POINT') {
                        obj.isPpt = true;
                    } else if (obj.FileType == 'TEXT') {
                        obj.isText = true;
                    } else if (obj.FileType == 'JPEG' || obj.FileType == 'JPG' || obj.FileType == 'PNG' || obj.FileType == 'GIF' || obj.FileType == 'BMP') {
                        obj.isImage = true;
                    } else if (obj.FileType == 'PDF') {
                        obj.isPdf = true;
                    }
                    this.recordFiles.push(obj);
                });

                /*  Record Image Files */
                recordImageFiles.forEach(currentItem => {
                    var obj = {};
                    obj.checkbox = false;
                    const bytes = currentItem.ContentSize;
                    obj.ContentSize = this.getFileSize(bytes);
                    obj.Title = currentItem.Title;
                    obj.Id = currentItem.Id;
                    obj.cdId = currentItem.ContentDocumentId;
                    obj.CreatedDate = currentItem.CreatedDate;
                    obj.FileType = currentItem.FileType;
                    if (obj.FileType == 'ZIP') {
                        obj.isZip = true;
                    } else if (obj.FileType == 'WORD_X' || obj.FileType == 'DOCX') {
                        obj.isWord = true;
                    } else if (obj.FileType == 'EXCEL' || obj.FileType == 'EXCEL_X') {
                        obj.isExcel = true;
                    } else if (obj.FileType == 'POWER_POINT_X' || obj.FileType == 'POWER_POINT') {
                        obj.isPpt = true;
                    } else if (obj.FileType == 'TEXT') {
                        obj.isText = true;
                    } else if (obj.FileType == 'JPEG' || obj.FileType == 'JPG' || obj.FileType == 'PNG' || obj.FileType == 'GIF' || obj.FileType == 'BMP') {
                        obj.isImage = true;
                    } else if (obj.FileType == 'PDF') {
                        obj.isPdf = true;
                    }
                    this.recordImageFiles.push(obj);

                });
                /*  Record Document Files */
                recordDocumentFiles.forEach(currentItem => {
                    var obj = {};
                    obj.checkbox = false;
                    const bytes = currentItem.ContentSize;
                    obj.ContentSize = this.getFileSize(bytes);
                    obj.Title = currentItem.Title;
                    obj.Id = currentItem.Id;
                    obj.cdId = currentItem.ContentDocumentId;
                    obj.CreatedDate = currentItem.CreatedDate;
                    obj.FileType = currentItem.FileType;
                    if (obj.FileType == 'ZIP') {
                        obj.isZip = true;
                    } else if (obj.FileType == 'WORD_X' || obj.FileType == 'DOCX') {
                        obj.isWord = true;
                    } else if (obj.FileType == 'EXCEL' || obj.FileType == 'EXCEL_X') {
                        obj.isExcel = true;
                    } else if (obj.FileType == 'POWER_POINT_X' || obj.FileType == 'POWER_POINT') {
                        obj.isPpt = true;
                    } else if (obj.FileType == 'TEXT') {
                        obj.isText = true;
                    } else if (obj.FileType == 'JPEG' || obj.FileType == 'JPG' || obj.FileType == 'PNG' || obj.FileType == 'GIF' || obj.FileType == 'BMP') {
                        obj.isImage = true;
                    } else if (obj.FileType == 'PDF') {
                        obj.isPdf = true;
                    }
                    this.recordDocumentFiles.push(obj);

                });

                console.log('this.recordFiles', this.recordFiles);
                console.log('this.recordImageFiles', this.recordImageFiles);
                console.log(' this.recordOtherFiles ', this.recordDocumentFiles);

                if (this.recordFiles.length == 0) {
                    this.showAllList = false;

                } else {
                    this.showAllList = true;
                }
                if (this.recordImageFiles.length == 0) {
                    this.showImages = false;
                } else {
                    this.showImages = true;
                }
                if (this.recordOtherFiles.length == 0) {
                    this.showImages = false;
                } else {
                    this.showImages = true;
                }
                if (this.recordDocumentFiles.length == 0) {
                    this.showDocuments = false;
                } else {
                    this.showDocuments = false;
                }


                // this.totalRecords = result.length; // update total records count                 
                // this.pageSize = this.pageSizeOptions[0]; //set pageSize with default value as first option
                // this.paginationHelper();

                this.isSpiner = false;
            })
            .catch((error) => {
                console.log('error==>', error);
                this.isSpiner = false;
            });

    }
    connectedCallback() {
        this.getAllFiles();
    }
    handleAllFileTypeChange(event) {
        console.log(event.target.value);
        this.SelectPicklist = event.target.value;
        if (this.SelectPicklist == 'emailAttachnent') {
            this.selectEmailPicklist = true;
        } else {
            this.selectEmailPicklist = false;
        }
        if (this.SelectPicklist == 'uploadFiles') {
            this.slectDocPicklist = false;
        } else {
            this.slectDocPicklist = true;
        }
    }
    handleImgTypeChange(event) {
        // console.log(event.target.value);
        this.imagePicklist = event.target.value;
        if (this.imagePicklist == 'recivedImage') {
            this.selectImagEmPicklist = true;
        } else {
            this.selectImagEmPicklist = false;
        }
        if (this.imagePicklist == 'uploadImages') {
            this.slectImagDocPicklist = false;
        } else {
            this.slectImagDocPicklist = true;
        }
    }
    handleDocTypeChange(event) {
        this.DocumentPicklist = event.target.value;
        if (this.DocumentPicklist == 'recivedEmDoc') {
            this.selectEmDocpicklist = true;
        } else {
            this.selectEmDocpicklist = false;
        }
        if (this.DocumentPicklist == 'uploadFileDoc') {
            this.selectFileDocpicklist = false;
        } else {
            this.selectFileDocpicklist = true;
        }
    }
    handleSearchKeyChange(event) {
        console.log(event.target.value);
        this.searchKeyWord = event.target.value;
        this.getAllFiles();
    }
    tabChangeHandler(event) {

        this.activetabContent = event.target.value;
    }
    previewHandler(event) {
        console.log(event.target.dataset.id)
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview'
            },
            state: {
                selectedRecordId: event.target.dataset.id
            }
        })
    }
    handleDeleteFile(event) {
        console.log('Delete', event.target.value);
    }
    handleUploadFinished(event){
        this.getAllFiles();
    }
    getFileSize(size) {
        console.log("originalSize***:" + size);
        var result;
        if (size < 1024) //1KB
        {
            result = size + " Bytes";
        }
        else if (size < 1048576) //1MB
        {
            result = (size / 1024).toFixed(2) + " KB";
        }
        else if (size < 1073741824) //1GB
        {
            result = (size / 1048576).toFixed(2) + " MB";
        }
        else {
            result = (size / 1073741824).toFixed(2) + " GB";
        }
        return result;
    }
}