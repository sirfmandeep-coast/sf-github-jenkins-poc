@isTest
public class ccsPasswordResetHelperTest
{
    public static testMethod void passwordresettest()
    {
        Profile profile1 = [Select Id from Profile where name = 'System Administrator'];
        UserRole role1 = [Select Id From UserRole Where name LIKE '%branch%' Limit 1];
        User u1 = new User(
            UserRoleId = role1.Id,
            ProfileId = profile1.Id,
            Username = System.now().millisecond() + 'test2@test.com',
            Alias = 'batman',
            Email='bruce.wayne@wayneenterprises.com',
            EmailEncodingKey='UTF-8',
            Firstname='Bruce',
            Lastname='Wayne',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            TimeZoneSidKey='America/Chicago'
            );
        insert u1;
        
        List<User> ulist;
        ulist = new list<User>([Select id, CreatedDate,LastPasswordChangeDate,LastModifiedById, LastModifiedDate from User where Alias = 'batman']);

        for( User u : ulist ) {
        System.debug('Pre-Run: Password Changed Date: ' + u.LastPasswordChangeDate);
        System.debug('Pre-Run: Changed By: ' + u.LastModifiedById);
        System.debug('Pre-Run: Last Changed: ' + u.LastModifiedDate);
        System.assertEquals(null, u.LastPasswordChangeDate);
        }

        
        ccsPasswordResetHelper.resetUserPassword(ulist);
        
        ulist = new list<User>([Select id, CreatedDate,LastPasswordChangeDate,LastModifiedById, LastModifiedDate from User where Alias = 'batman']);

        for( User u : ulist ) {        
        System.debug('Post-Run: Password Changed Date: ' + u.LastPasswordChangeDate);
        System.debug('Post-Run: Changed By: ' + u.LastModifiedById );
        System.debug('Post-Run: Last Changed: ' + u.LastModifiedDate);
        System.assertNotEquals(null, u.LastPasswordChangeDate);
        }
    }
}