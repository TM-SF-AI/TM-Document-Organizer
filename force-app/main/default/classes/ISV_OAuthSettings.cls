public class ISV_OAuthSettings {
    // TODO: Fill in your actual values
    public static String clientId     { get { return '3MVG9G9pzCUSkzZspzk03Kc24s0hhWWtlgo0GiIe1pOWNlBhphBbIPUIyWeWFnuPRYaNe8G9fv96ai3RN3l_d'; } }
    public static String clientSecret { get { return '40F918C4CF9FB34A02EA04DD2C1210D5F949941361AA394ECE385A75EB57D960'; } }

    // Must MATCH your Connected App callback URL exactly
    public static String redirectUri  { 
        get { 
          //  return 'https://technologymindz-dev-ed.my.salesforce.com/services/apexrest/TechnologyMindz/ISV/OAuthCallback';
              return 'https://technologymindz-dev-ed.my.salesforce-sites.com/awsvalidation/OAuthProcessing';
        } 
    }

    public static String loginUrl     { 
        get { 
            return 'https://login.salesforce.com'; 
        } 
    }
}