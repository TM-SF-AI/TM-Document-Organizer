@isTest
public class TestDocumentsOrganizer {
    @isTest
    public static void testController(){
        Account acc = new Account(Name='Test Account');
        insert acc;
        List<Account> account_Obj  =  [SELECT Id,Name,Type,ParentId from Account];
        Blob b = Blob.valueOf('Test Data');
        Attachment attachment = new Attachment();
        attachment.ParentId = acc.Id;
        attachment.Name = 'Test Attachment for Parent';
        attachment.Body = b;
        insert attachment;
        TechnologyMindz.DocumentsOrganizerController.FileUploaderWrapper obj = new TechnologyMindz.DocumentsOrganizerController.FileUploaderWrapper();
        obj = DocumentsOrganizerController.fetchAllFiles('', acc.Id, 'Title', 'ASC');
        obj = DocumentsOrganizerController.fetchAllFiles('', acc.Id, 'CreatedDate', 'ASC');
        obj = DocumentsOrganizerController.fetchAllFiles('', acc.Id, 'ContentSize', 'ASC');
        obj = DocumentsOrganizerController.fetchAllFiles('', acc.Id, 'FileType', 'ASC');
        System.assertEquals(true,account_Obj.size()>0);
    }
}