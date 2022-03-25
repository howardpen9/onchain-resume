pragma solidity ^0.8.4;

import "hardhat/console.sol";

import "./StrLib.sol";

contract ResumeBase {
    constructor(
        string memory _name,
        address _account,
        uint8 _age,
        Gender _gender
    )  {
        govermenetAddress = msg.sender;
        profile = Profile({
            name: _name,
            account: _account,
            age: _age,
            gender: _gender,
            contact: "",
            autobiography:""
        });
    }
    // notice for modifiers 
    modifier onlyGov {
        require(msg.sender == govermenetAddress, "Permission denied. Please use the admin account.");
        _;
    }
    modifier onlySchool {
        bool isSchool = organizations_addr[msg.sender].property == OrganizationType.school;
        require(isSchool && organizations_addr[msg.sender].permission, "Permission denied. Please use school account");
        _;
    }
    modifier onlyCompany {
        bool isCompany = organizations_addr[msg.sender].property == OrganizationType.company;
        require(isCompany && organizations_addr[msg.sender].permission, "Permission denied. Please use company account.");
        _;
    }
    modifier onlyHost {
        require(msg.sender == profile.account, "Permission denied. Please use host account.");
        _;
    }
    // notice: to get the data in array, we need check the length of the array. 
    modifier IndexValidator(uint index, uint max){
        require(index < max, "Out of ranges.");
        _;
    }

    // State Variable
    address internal govermenetAddress;

    Profile public profile;
    struct Profile {
        string name; 
        address account; 
        uint8 age; 
        Gender gender; 
        string contact; 
        string autobiography; 
    }
    enum Gender {
        male,
        female,
        other
    }

    // @notice 儲存組織系列的數據
    // Organization
    mapping(address => Organization) internal organizations_addr;
    struct Organization { // 宣告一個“組織”的數據形態
        string name;
        OrganizationType property;  // 這個組織屬於哪種機構（數據類型
        address account; 
        bool permission;
    }
    enum OrganizationType {
        standard, // 一班人
        school,
        company // 企業
    }

    // For 求職者, 陣列底下、某個數據還有一個陣列在裡面。
    Education[] internal educations; 
    struct Education{
        Organization school; 
        EducationStatus status;
        string major; 
        Course[] courses; 
        License[] licenses; 
    }
    enum EducationStatus {
        dropOff, //  
        studying, // still in school 
        graduate 
    }
    struct Course {
        string name; 
        string content; 
        string comment; // Teacher's feedback 
        uint8 grade; 
    }
    struct License {
        string name; 
        string content; 
    }
    
    // @notice for Jon description, resume with positions 
    Job[] internal experiences;
    struct Job {
        Organization company;
        string position; 
        uint startDate; // on-board date
        uint endDate; // quit date
    }

    // @notice Skillset 
    Skill[] internal skills;
    struct Skill {
        string class;
        string name;
    }

    event done(DoneCode eventCode, string message);
    // DataType: DoneCode, DataValue: eventCode
    enum DoneCode {
        setPermission, //設置機構權限
        setEducation, //設置學歷
        setLicense, //設置證照
        setCourse, //設置修課證明
        setExperience, //設置工作經歷
        setJobEndDate, //設置離職日
        setAutobiography, //設置自傳
        setSkill, //設置專業技術
        setContact, //設置聯絡方式
        removePermission, //移除機構權限
        removeSkill //移除專業技術
    }
    ////////////////////////////////////////////////////////////////
    using StrLib for string; 

    // check the string in which Index in array. (check School name)
    // @param _org, an address that whether is a organization owner or not.
    // @param __property, 
    function findOrganization(address _org, string memory __property) 
        public 
        view 
        returns(int){
            int index = -1; 
            if(__property.compare("studying")){
                for(uint i=0; i<educations.length; i++) {
                    if (educations[i].school.account == _org) {
                        index = int(i);
                        break;
                    }
                }
            } else if(__property.compare("experience")) {
                for (uint i=0; i < experiences.length; i++) {
                    if (experiences[i].company.account == _org) {
                        index = int(i);
                        break;
                    }
                }
            }
            else if (__property.compare("educations")){
                console.log("1234",__property);
            }
            return index; 
        }

}
