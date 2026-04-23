public class Documents_OrganizerController {
 @AuraEnabled
    public static Map<String, List <ContentVersion>> fetchAllFiles(String searchKeyWord, String parentId, String sortField, String orderType){
        system.debug('parentId'+parentId);
        List<ContentDocumentLink> controllerList = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId =: parentId];
        List<ContentDocumentLink> controllerList2 = [SELECT ContentDocumentId FROM ContentDocumentLink WHERE LinkedEntityId IN (SELECT ID From EmailMessage WHERE ParentId =: parentId)];
        Set<Id> controllerIds = new Set<Id>();
        Set<Id> controllerIds2 = new Set<Id>();
        for(ContentDocumentLink con : controllerList){
            controllerIds.add(con.ContentDocumentId);
            controllerIds2.add(con.ContentDocumentId);
        } 
        for(ContentDocumentLink con : controllerList2){
            controllerIds2.add(con.ContentDocumentId);
        }  
        
        String searchKey = '%' + searchKeyWord + '%';
        
        List <String> FilesCategory = new List <String> {'JPG', 'JPEG', 'PNG', 'GIF','BMP'};            
            String query1 = 'SELECT Id, Title, FileType,CreatedDate, ContentSize, ContentDocumentId FROM ContentVersion WHERE ContentDocumentId IN :controllerIds2 AND Title LIKE :searchKey ORDER BY '+sortField+' '+orderType;
        
        Map<String, List <ContentVersion>> mapToReturn = new Map<String, List <ContentVersion>>{ 'recordFiles'=> new List <ContentVersion>(), 'recordImageFiles'=> new List <ContentVersion>(),
            'recordOtherFiles'=> new List <ContentVersion>(), 'emailFiles'=> new List <ContentVersion>(), 'emailImageFiles'=> new List <ContentVersion>(), 
            'emailOtherFiles'=> new List <ContentVersion>()
            };
                 system.debug('mapToReturn '+mapToReturn);   
        for(ContentVersion cdObj : Database.query(query1)){
            if(controllerIds.contains(cdObj.ContentDocumentId)){
                mapToReturn.get('recordFiles').add(cdObj);
                if(FilesCategory.contains(cdObj.FileType)){
                    mapToReturn.get('recordImageFiles').add(cdObj);
                }else{
                    mapToReturn.get('recordOtherFiles').add(cdObj);
                }
            }else{
                mapToReturn.get('emailFiles').add(cdObj);
                if(FilesCategory.contains(cdObj.FileType)){
                    mapToReturn.get('emailImageFiles').add(cdObj);
                }else{
                    mapToReturn.get('emailOtherFiles').add(cdObj);
                }
            }
        }
        
        return mapToReturn;
    }
}