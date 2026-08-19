public class AddEACConfiguration {
   @InvocableMethod ( label='AddEACUser' description='Adds User to EAC Configuration' )
    public static void AddEACUser ( List<Id> userId ) {
        UserEmailCalendarSync user = new UserEmailCalendarSync ( ConfigurationId ='0632B00000000FvQAI', AssignedId = userId[0] );
        Database.SaveResult results = Database.insertImmediate(user);
    }
    
}