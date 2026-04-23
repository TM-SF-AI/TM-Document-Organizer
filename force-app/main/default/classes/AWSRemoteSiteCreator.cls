public class AWSRemoteSiteCreator {
    public static void createForCustomer(AWS_Customer__c c) {

 if (String.isBlank(c.Customer_Org_Instance_Url__c)) {
        throw new CalloutException('Instance URL is blank');
    }

    if (String.isBlank(c.AWS_Customer_Id__c)) {
        throw new CalloutException('Customer Id is blank');
    }

    String safeName =
        'AWS_' +
        c.AWS_Customer_Id__c.trim()
            .replaceAll('[^A-Za-z0-9_]', '_')
            .left(40);

    MetadataService.MetadataPort service = new MetadataService.MetadataPort();
    service.SessionHeader = new MetadataService.SessionHeader_element();
    service.SessionHeader.sessionId = UserInfo.getSessionId();

    MetadataService.RemoteSiteSetting rs = new MetadataService.RemoteSiteSetting();

    rs.fullName = safeName;
    rs.url = c.Customer_Org_Instance_Url__c.trim();
    rs.description = 'Auto-created by scheduled job';

    // ✅ SET EVERY BOOLEAN (THIS PREVENTS BLANK BOOLEAN IN SOAP)
    rs.isActive = true;
    rs.disableProtocolSecurity = false;

    MetadataService.SaveResult[] results =
        service.createMetadata(new MetadataService.Metadata[] { rs });

    if (results == null || results.isEmpty()) {
        throw new CalloutException('No response from Metadata API');
    }

    if (!results[0].success) {
        throw new CalloutException(results[0].errors[0].message);
    }

}
}