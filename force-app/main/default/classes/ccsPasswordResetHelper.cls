public class ccsPasswordResetHelper {
    @InvocableMethod(label='Reset User Password' description='Triggers the reset password workflow in Salesforce')
    public static void resetUserPassword(List<User> usersToUpdate) {
    for (User u : usersToUpdate) {
        try {
            System.resetPassword(u.id, TRUE);
            }
        catch(Exception e) 
            {
            System.debug('An exception occured: ' + e.getMessage());
            }
        }
    }
}