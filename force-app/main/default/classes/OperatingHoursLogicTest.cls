@isTest
public class OperatingHoursLogicTest {
    
    public Static String generateRandomString(Integer len) {
        final String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789abcdefghijklmnopqrstuvwxyz';
        String randStr = '';
        while (randStr.length() < len) {
            Integer idx = Math.mod(Math.abs(Crypto.getRandomInteger()), chars.length());
            randStr += chars.substring(idx, idx+1);
        }
        return randStr.substring(0,len);
    }
    
    public Static String generateRandomEmail()
    {
        String emailString=generateRandomString(6)+'@'+generateRandomString(6)+'.com';
        return emailString;
    }
    
    @testSetup static void setup(){
        
        list<User> users = new list<User>();
        User adminUser = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
                lastname = 'theadmin',
                Email = generateRandomEmail(),
                Username = generateRandomEmail() + System.currentTimeMillis(),
                CompanyName = generateRandomString(3),
                Title = generateRandomString(3),
                Alias = 'alias',
                TimeZoneSidKey = 'GMT',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
        );
        users.add(adminUser);
        User facing = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'CCS Member Facing'].Id,
                LastName = 'facing',
                Email = generateRandomEmail(),
                Username = generateRandomEmail() + System.currentTimeMillis(),
                CompanyName = generateRandomString(3),
                Title = generateRandomString(3),
                Alias = 'alias',
                TimeZoneSidKey = 'GMT',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
        );
        users.add(facing); 
        User facing1 = new User(
                ProfileId = [SELECT Id FROM Profile WHERE Name = 'CCS Member Facing'].Id,
                LastName = 'facing1',
                Email = generateRandomEmail(),
                Username = generateRandomEmail() + System.currentTimeMillis(),
                CompanyName = generateRandomString(3),
                Title = generateRandomString(3),
                Alias = 'alias',
                TimeZoneSidKey = 'GMT',
                EmailEncodingKey = 'UTF-8',
                LanguageLocaleKey = 'en_US',
                LocaleSidKey = 'en_US'
        );
        
        users.add(facing1);   
        insert users;
        facing1.managerId=facing.Id;
        update facing1;
        
                
    }
    @isTest static void validateInsertAdminTest() {
        User adminUser =[SELECT Id, LastName FROM User WHERE lastname='theadmin' limit 1];
        System.runAs(adminUser){
            Test.startTest();
            OperatingHours oh = new OperatingHours();
            oh.name = generateRandomString(5);
            insert oh;
            Test.stopTest();
            System.assertEquals(1,[SELECT Id FROM OperatingHours].size());
        }
    }
    
    @isTest static void validateInsertFacingTest() {
        User adminUser =[SELECT Id, LastName FROM User WHERE lastname='facing' limit 1];
        System.runAs(adminUser){
            Test.startTest();
            OperatingHours oh = new OperatingHours();
            oh.name = generateRandomString(5);
            try{
                insert oh;
            }catch(Exception e) {
//pa20191016                System.Assert(e.getMessage().contains(Label.Trigger_Error_Message_Operating_hours_Insert));
                System.Assert(e.getMessage().contains(Label.Trigger_Error_Message_Operating_hours_Insert));                
            }
            
                
            Test.stopTest();
            System.assertEquals(0,[SELECT Id FROM OperatingHours].size());
        }
    }
    
    @isTest static void validateDeleteAdminTest() {
        User adminUser =[SELECT Id, LastName FROM User WHERE lastname='theadmin' limit 1];
        System.runAs(adminUser){
            Test.startTest();
            OperatingHours oh = new OperatingHours();
            oh.name = generateRandomString(5);
            insert oh;
            delete oh;
            Test.stopTest();
            System.assertEquals(0,[SELECT Id FROM OperatingHours].size());
        }
    }
    
    @isTest static void validateDeleteFacingTest() {
        User adminUser =[SELECT Id, LastName FROM User WHERE lastname='facing' limit 1];
        OperatingHours oh = new OperatingHours(name = generateRandomString(5));
       
        insert oh;
        System.runAs(adminUser){
            Test.startTest();

            try{
                delete oh;
            }catch(Exception e) {
//pa20191016                System.Assert(e.getMessage().contains(Label.Trigger_Error_Message_Operating_hours_Delete));
                //System.Assert(e.getMessage().contains(Label.Trigger_Error_Message_Operating_hours_Delete));

            }
            Test.stopTest();
            System.assertEquals(1,[SELECT Id FROM OperatingHours].size());
        }
    }
    
    @isTest static void validateUpdateAdminTest() {
        User adminUser =[SELECT Id, LastName FROM User WHERE lastname='theadmin' limit 1];
        System.runAs(adminUser){
            Test.startTest();
            OperatingHours oh = new OperatingHours();
            oh.name = generateRandomString(5);
            insert oh;
            oh.name = generateRandomString(6);
            update oh;
            Test.stopTest();
            System.assertEquals(1,[SELECT Id FROM OperatingHours].size());
        }
    }
    
    @isTest static void validateUpdateFacingTest() {
        User adminUser =[SELECT Id, LastName FROM User WHERE lastname='facing' limit 1];
        OperatingHours oh = new OperatingHours();
        oh.name = generateRandomString(5);
        oh.Description = 'test123';
        insert oh;
        System.runAs(adminUser){
            Test.startTest();
            oh.Description = 'test1234';
            try{
                update oh;
            }catch(Exception e) {
                System.debug('------'+e.getMessage());
                System.Assert(e.getMessage().contains(Label.Trigger_Error_Message_Operating_hours_Update));
            }
            Test.stopTest();
            System.assertEquals(1,[SELECT Id FROM OperatingHours].size());
        }
    }
    
    @isTest static void validateUpdateFacingWithTerritoryMemberTest() {
        User facingUser =[SELECT Id, LastName FROM User WHERE lastname='facing' limit 1];
        User facingUser1 =[SELECT Id, LastName FROM User WHERE lastname='facing1' limit 1];
        OperatingHours oh = new OperatingHours();
        oh.name = generateRandomString(5);
        insert oh;
        ServiceResource sr = new ServiceResource(Name=generateRandomString(5), RelatedRecordId=facingUser.Id, ResourceType='T',IsActive=true);
        insert sr;
        ServiceTerritory st = new ServiceTerritory(Name=generateRandomString(5),Description=generateRandomString(15),OperatingHoursId=oh.Id,IsActive=true);
        insert st;
        ServiceTerritoryMember stm = new ServiceTerritoryMember(OperatingHoursId=oh.Id, ServiceResourceId=sr.Id, ServiceTerritoryId=st.Id, EffectiveStartDate=system.now());
        insert stm;
        System.runAs(facingUser1){
            Test.startTest();
//pa20191016            String newName = generateRandomString(6);
//pa20191016            oh.name = newName;
            String newDesc = generateRandomString(6);
            oh.Description = newDesc;
//pa20191016            update oh;
            try{
                update oh;
            }catch(Exception e) {
                System.Assert(e.getMessage().contains(Label.Trigger_Error_Message_Operating_hours_Update));
            }
            Test.stopTest();
//pa20191016            System.assertEquals(1,[SELECT Id FROM OperatingHours].size());
//pa20191016            System.assertEquals(newName,[SELECT Id, Name FROM OperatingHours].Name);
            System.assertNOTEquals(newDesc,[SELECT Id, Description FROM OperatingHours].Description);
        }
    }
}