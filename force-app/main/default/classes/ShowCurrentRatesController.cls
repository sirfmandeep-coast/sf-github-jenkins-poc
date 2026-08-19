public without sharing class ShowCurrentRatesController {
    Public String contentVersionId { 
        get
        {
            String versionId;
            List <ContentDocument> CDList = [SELECT Id, LatestPublishedVersionId, FileExtension, FileType, Title, IsArchived, PublishStatus, SharingOption, SharingPrivacy FROM ContentDocument WHERE title = 'Current Interest Rates' and FileType = 'PDF' and PublishStatus = 'P' Limit 1];
            If (!CDList.isEmpty())
            {
                versionId = CDList.get(0).LatestPublishedVersionId;
            }
            return versionId;
        } 
        set; 
    }
    
    Public String contentHostname { 
        get
        {   
            return DomainCreator.getContentHostname();
        } 
        set; 
    }
    

    public String versionData {
        get 
        {
            ContentVersion cv = [SELECT Id, VersionData FROM ContentVersion Where Id = :contentVersionId Limit 1]; 
            String vData = EncodingUtil.base64Encode(cv.VersionData);
            return vData;
        }
        set;
    }
}