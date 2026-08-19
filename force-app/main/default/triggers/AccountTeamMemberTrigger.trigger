trigger AccountTeamMemberTrigger on AccountTeamMember (after insert, after update) {
    new AccountTeamMemberTriggerHandler().run();
}