@isTest
public class TimeSlotLogicTest {
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
            //pa20191016
            lastname = 'theadmints',
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
            //pa20191016
            LastName = 'facingts',
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
            //pa20191016
            LastName = 'facing1ts',
            Email = generateRandomEmail(),
            Username = generateRandomEmail() + System.currentTimeMillis(),
            CompanyName = generateRandomString(3),
            Title = generateRandomString(3),
            Alias = 'alias',
            TimeZoneSidKey = 'GMT',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            UserRoleId=[select Id from UserRole where Name='Branch: Shelbourne'].Id
        );
        
        users.add(facing1);   
        insert users;
        facing1.managerId=facing.Id;
        update facing1;
        
    }
    @isTest static void validateInsertAdminTest() {
//pa20191016        
        User adminUser =[SELECT Id, LastName FROM User WHERE lastname='theadmints' limit 1];
        System.runAs(adminUser){
            Test.startTest();
            OperatingHours oh = new OperatingHours();
            oh.name = generateRandomString(5);
            insert oh;
            TimeSlot ts = new TimeSlot();
            DateTime dt = System.today();
            Time starttime = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
            Time endtime = Time.newInstance(dt.hour()+1, dt.minute(), dt.second(), dt.millisecond());
            ts.StartTime = starttime;
            ts.EndTime = endtime;
            ts.OperatingHoursId = oh.Id;
            insert ts;
            Test.stopTest();
            System.assertEquals(1,[SELECT Id FROM OperatingHours].size());
            System.assertEquals(1,[SELECT Id FROM TimeSlot].size());
        }
    }
    
    @isTest static void validateInsertFacingTest() {
//pa20191016 ts
        User adminUser =[SELECT Id, LastName FROM User WHERE lastname='facingts' limit 1];
        OperatingHours oh = new OperatingHours();
        oh.name = generateRandomString(5);
        insert oh;
        System.runAs(adminUser){
            Test.startTest();
            TimeSlot ts = new TimeSlot();
            ts.OperatingHoursId = oh.Id;  
            DateTime dt = System.today();
            Time starttime = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
            Time endtime = Time.newInstance(dt.hour()+1, dt.minute(), dt.second(), dt.millisecond());
            ts.StartTime = starttime;
            ts.EndTime = endtime;
            try{
                insert ts;
            }catch(Exception e) {
//pa2019106                System.Assert(e.getMessage().contains(Label.Trigger_Error_Message_Time_Slot_Insert));
                System.Assert(e.getMessage().contains(Label.Trigger_Error_Message_Time_Slot_Insert));

            }
            
            Test.stopTest();
            System.assertEquals(1,[SELECT Id FROM OperatingHours].size());
            System.assertEquals(1,[SELECT Id FROM TimeSlot].size());
        }
    }
    
    @isTest static void validateDeleteAdminTest() {
        //pa20191016
        User adminUser =[SELECT Id, LastName FROM User WHERE lastname='theadmints' limit 1];
        System.runAs(adminUser){
            Test.startTest();
            OperatingHours oh = new OperatingHours();
            oh.name = generateRandomString(5);
            insert oh;
            TimeSlot ts = new TimeSlot();
            ts.OperatingHoursId = oh.Id;  
            DateTime dt = System.today();
            Time starttime = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
            Time endtime = Time.newInstance(dt.hour()+1, dt.minute(), dt.second(), dt.millisecond());
            ts.StartTime = starttime;
            ts.EndTime = endtime;
            insert ts;
            delete ts;
            Test.stopTest();
            System.assertEquals(1,[SELECT Id FROM OperatingHours].size());
            System.assertEquals(0,[SELECT Id FROM TimeSlot].size());
        }
    }
    
    @isTest static void validateDeleteFacingTest() {
        User adminUser =[SELECT Id, LastName FROM User WHERE lastname='facingts' limit 1];
        OperatingHours oh = new OperatingHours();
        oh.name = generateRandomString(5);
        insert oh;
        TimeSlot ts = new TimeSlot();
        ts.OperatingHoursId = oh.Id;  
        DateTime dt = System.today();
        Time starttime = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
        Time endtime = Time.newInstance(dt.hour()+1, dt.minute(), dt.second(), dt.millisecond());
        ts.StartTime = starttime;
        ts.EndTime = endtime;
        insert ts;
        System.runAs(adminUser){
            Test.startTest();
            
            try{
                delete ts;
            }catch(Exception e) {
//pa20191016                System.Assert(e.getMessage().contains(Label.Trigger_Error_Message_Time_Slot_Delete));
                System.Assert(e.getMessage().contains(Label.Trigger_Error_Message_Time_Slot_Delete));
            }
            Test.stopTest();
            System.assertEquals(1,[SELECT Id FROM OperatingHours].size());
            System.assertEquals(0,[SELECT Id FROM TimeSlot].size());
        }
    }
    
    @isTest static void validateUpdateAdminTest() {
        //pa20191016
        User adminUser =[SELECT Id, LastName FROM User WHERE lastname='theadmints' limit 1];
        System.runAs(adminUser){
            Test.startTest();
            OperatingHours oh = new OperatingHours();
            oh.name = generateRandomString(5);
            insert oh;
            TimeSlot ts = new TimeSlot();
            ts.OperatingHoursId = oh.Id;  
            DateTime dt = System.today();
            Time starttime = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
            Time endtime = Time.newInstance(dt.hour()+1, dt.minute(), dt.second(), dt.millisecond());
            ts.StartTime = starttime;
            ts.EndTime = endtime;
            insert ts;
            endtime = Time.newInstance(dt.hour()+2, dt.minute(), dt.second(), dt.millisecond());
            ts.EndTime = endtime;
            update ts;
            
            Test.stopTest();
            System.assertEquals(1,[SELECT Id FROM OperatingHours].size());
            System.assertEquals(1,[SELECT Id FROM TimeSlot].size());
            System.assertEquals(endtime,[SELECT Id, EndTime FROM TimeSlot].EndTime);
        }
    }
    
    @isTest static void validateUpdateFacingTest() {
//pa20191016
        User adminUser =[SELECT Id, LastName FROM User WHERE lastname='facingts' limit 1];
        OperatingHours oh = new OperatingHours();
        oh.name = generateRandomString(5);
        insert oh;

        ServiceTerritory territory = new ServiceTerritory();
        territory.Name = 'test location';
        territory.OperatingHoursId = oh.Id;
        territory.IsActive = true;
        insert territory;
        ServiceResource resource = new ServiceResource();
        resource.RelatedRecordId = UserInfo.getUserId();
        resource.Name = 'test';
        resource.IsActive = true;
        insert resource;
        ServiceTerritoryMember member = new ServiceTerritoryMember();
        member.ServiceTerritoryId = territory.Id;
        member.ServiceResourceId = resource.Id;
        member.OperatingHoursId = oh.Id;
        member.EffectiveStartDate = Datetime.now();
        insert member;

        TimeSlot ts = new TimeSlot();
        ts.OperatingHoursId = oh.Id;  
        DateTime dt = System.today();
        Time starttime = Time.newInstance(1, dt.minute(), dt.second(), dt.millisecond());
        Time endtime = Time.newInstance(2, dt.minute(), dt.second(), dt.millisecond());
        ts.StartTime = starttime;
        ts.EndTime = endtime;
        insert ts;
        System.runAs(adminUser){
            Test.startTest();
            Time endtime2 = Time.newInstance(3, dt.minute(), dt.second(), dt.millisecond());
            ts.EndTime = endtime2;
            try{
                
                update ts;
            }catch(Exception e) {
                System.Assert(e.getMessage().contains(Label.Trigger_Error_Message_Time_Slot_Update));
            }
            Test.stopTest();
            System.assertEquals(1,[SELECT Id FROM OperatingHours].size());
            System.assertEquals(1,[SELECT Id FROM TimeSlot].size());
            System.assertEquals(endtime,[SELECT Id, EndTime FROM TimeSlot].EndTime);
        }
    }
    
    @isTest static void validateUpdateFacingWithTerritoryTest() {
        //pa20191016
        User facingUser =[SELECT Id, LastName FROM User WHERE lastname='facingts' limit 1];
        User facingUser1 =[SELECT Id, LastName FROM User WHERE lastname='facing1ts' limit 1];
        OperatingHours oh = new OperatingHours();
        oh.name = generateRandomString(5);
        insert oh;
        TimeSlot ts = new TimeSlot();
        ts.OperatingHoursId = oh.Id;  
        DateTime dt = System.today();
        Time starttime = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
        Time endtime = Time.newInstance(dt.hour()+1, dt.minute(), dt.second(), dt.millisecond());
        ts.StartTime = starttime;
        ts.EndTime = endtime;
        insert ts;
        Time endtime2 = Time.newInstance(dt.hour()+2, dt.minute(), dt.second(), dt.millisecond());
        ServiceResource sr = new ServiceResource(Name=generateRandomString(5), RelatedRecordId=facingUser1.Id, ResourceType='T',IsActive=true);
        insert sr;
        ServiceTerritory st = new ServiceTerritory(Name=generateRandomString(5),Description=generateRandomString(15),OperatingHoursId=oh.Id,IsActive=true);
        insert st;
        ServiceTerritoryMember stm = new ServiceTerritoryMember(OperatingHoursId=oh.Id, ServiceResourceId=sr.Id, ServiceTerritoryId=st.Id, EffectiveStartDate=system.now());
        insert stm;
        System.runAs(facingUser1){
            Test.startTest();
            ts.EndTime = endtime2;
            try{
                update ts;
            }catch(Exception e) {
                System.Assert(e.getMessage().contains(Label.Trigger_Error_Message_Time_Slot_Update));
            }
            
            Test.stopTest();
            System.assertEquals(1,[SELECT Id FROM OperatingHours].size());
            System.assertEquals(1,[SELECT Id FROM TimeSlot].size());
            System.assertEquals(endtime,[SELECT Id, EndTime FROM TimeSlot].EndTime);
        }
    }

    @isTest static void validateUpdateFacingWithTerritoryMemberTest() {
        //pa20191016
        User facingUser =[SELECT Id, LastName FROM User WHERE lastname='facingts' limit 1];
        User facingUser1 =[SELECT Id, LastName FROM User WHERE lastname='facing1ts' limit 1];
        OperatingHours oh = new OperatingHours();
        oh.name = generateRandomString(5);

        OperatingHours oh1 = new OperatingHours();
        oh1.name = generateRandomString(7);
        insert new List<OperatingHours>{oh, oh1};
        TimeSlot ts = new TimeSlot();
        ts.OperatingHoursId = oh.Id;  
        DateTime dt = System.today();
        Time starttime = Time.newInstance(dt.hour(), dt.minute(), dt.second(), dt.millisecond());
        Time endtime = Time.newInstance(dt.hour()+1, dt.minute(), dt.second(), dt.millisecond());
        ts.StartTime = starttime;
        ts.EndTime = endtime;
        insert ts;
        Time endtime2 = Time.newInstance(dt.hour()+2, dt.minute(), dt.second(), dt.millisecond());
        ServiceResource sr = new ServiceResource(Name=generateRandomString(5), RelatedRecordId=facingUser1.Id, ResourceType='T',IsActive=true);
        insert sr;
        ServiceTerritory st = new ServiceTerritory(Name=generateRandomString(5),Description=generateRandomString(15),OperatingHoursId=oh1.Id,IsActive=true);
        insert st;
        ServiceTerritoryMember stm = new ServiceTerritoryMember(OperatingHoursId=oh.Id, ServiceResourceId=sr.Id, ServiceTerritoryId=st.Id, EffectiveStartDate=system.now());
        insert stm;
        System.runAs(facingUser1){
            Test.startTest();
            ts.EndTime = endtime2;
            update ts;
            
            Test.stopTest();
            System.assertEquals(2,[SELECT Id FROM OperatingHours].size());
            System.assertEquals(endtime2,[SELECT Id, EndTime FROM TimeSlot WHERE Id =: ts.Id].EndTime);
        }
    }
}