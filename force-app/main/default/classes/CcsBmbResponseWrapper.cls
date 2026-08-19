public with sharing class CcsBmbResponseWrapper {
   
    public List<Membership> memberships;

    public class Membership {
        public List<Signer> signers;
        public String membershipNumber;
        public String membershipIndustry;
        public String membershipType;
    }

    public class Signer {
        public String signerId;
        public String signerGivenName;
        public String signerFamilyName;
        public String signerRole;
    }

}