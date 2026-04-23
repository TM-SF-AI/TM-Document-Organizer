public with sharing class DocumentsOrganizerController {
    @AuraEnabled
    public static FileUploaderWrapper fetchAllFiles(String searchKeyWord, String parentId, String sortField, String orderType){
        FileUploaderWrapper wrapperObj = new FileUploaderWrapper(); 
        system.debug('parentId'+parentId);
        List<ContentDocumentLink> controllerList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: parentId];
        List<ContentDocumentLink> controllerList2 = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT ID From EmailMessage WHERE ParentId =: parentId)];
        Set<Id> controllerIds = new Set<Id>();
        Set<Id> controllerIds2 = new Set<Id>();
        for(ContentDocumentLink con : controllerList){
            controllerIds.add(con.ContentDocumentId);
        } 
        for(ContentDocumentLink con : controllerList2){
            controllerIds2.add(con.ContentDocumentId);
        }  
        
        String searchKey = '%' + searchKeyWord + '%';
        
        List <String> FilesCategory = new List <String> {'JPG', 'JPEG', 'PNG', 'GIF','BMP'};            
            String query1 = 'SELECT Id, Title, FileType,CreatedDate, ContentSize FROM ContentDocument WHERE Id IN :controllerIds AND Title LIKE :searchKey ORDER BY '+sortField+' '+orderType;
        List <ContentDocument> listOfAllFiles = Database.query(query1);
        String query2 = 'SELECT Id, Title, FileType,CreatedDate, ContentSize FROM ContentDocument WHERE Id IN :controllerIds AND FileType IN :FilesCategory AND Title LIKE :searchKey ORDER BY '+sortField+' '+orderType;
        List <ContentDocument> listOfAllImages = Database.query(query2);
        String query3 = 'SELECT Id, Title, FileType,CreatedDate, ContentSize FROM ContentDocument WHERE Id IN :controllerIds AND FileType NOT IN :FilesCategory AND Title LIKE :searchKey ORDER BY '+sortField+' '+orderType;
        List <ContentDocument> listOfOtherFiles = Database.query(query3);
        String Attachmentquery = 'SELECT Id, Title, FileType,CreatedDate, ContentSize FROM ContentDocument WHERE Id IN :controllerIds2 AND Title LIKE :searchKey ORDER BY '+sortField+' '+orderType;
        List <ContentDocument> listOfAllAttachment = Database.query(Attachmentquery);
        String query4 = 'SELECT Id, Title, FileType,CreatedDate, ContentSize FROM ContentDocument WHERE Id IN :controllerIds2 AND FileType IN :FilesCategory AND Title LIKE :searchKey ORDER BY '+sortField+' '+orderType;
        List <ContentDocument> attachmentImageList = Database.query(query4);
        String query5 = 'SELECT Id, Title, FileType,CreatedDate, ContentSize FROM ContentDocument WHERE Id IN :controllerIds2 AND FileType NOT IN :FilesCategory AND Title LIKE :searchKey ORDER BY '+sortField+' '+orderType;
        List <ContentDocument> attachmentDocumentList = Database.query(query5);
        
        
        Integer total = listOfAllAttachment.size() + listOfAllFiles.size();
        wrapperObj.allimages = listOfAllImages;
        wrapperObj.allAttachment = listOfAllAttachment;
        wrapperObj.otherfiles = listOfOtherFiles;
        wrapperObj.allFiles = listOfAllFiles;
        wrapperObj.allEmailImages = attachmentImageList;
        wrapperObj.allEmailDocuments = attachmentDocumentList;
        wrapperObj.TotalFilesAndAttachment = total;
        return wrapperObj;
    }
    public class FileUploaderWrapper{
        @AuraEnabled
        public List <ContentDocument> allAttachment {get;set;}
        @AuraEnabled
        public List <ContentDocument> allimages {get;set;}
        @AuraEnabled
        public List <ContentDocument> otherfiles {get;set;}
        @AuraEnabled
        public List <ContentDocument> allFiles {get;set;}
        @AuraEnabled
        public List <ContentDocument> allEmailImages {get;set;}
        @AuraEnabled
        public List <ContentDocument> allEmailDocuments {get;set;}
        @AuraEnabled
        public Integer TotalFilesAndAttachment {get;set;}
    }
}