pragma solidity ^0.8.4;

import {ResumeBase} from "./ResumeBase.sol";

contract Resume is ResumeBase {
    constructor(
        string memory name,
        address account,
        uint8 age, 
        Gender gender
    ) public ResumeBase (
        name, account, age, gender
    ){}

    // @notice 回傳父陣列的長度
    function getEducationCount() public view returns(uint){
        return educations.length;        
    }
    function getExperienceCount() public view returns(uint){
        return experiences.length;
    }
    function getSkillCount() public view returns(uint){
        return skills.length;        
    }
    // @notice  Read the inside of an array. 需要額外指定哪一格、才可以看到底下的長度。
    function getCourseCount(uint index) public view IndexValidator(index, getEducationCount()) returns(uint){
        return educations[index].courses.length;        
    }
    function getLicenseCount(uint index) public view IndexValidator(index, getEducationCount()) returns(uint){
        return educations[index].licenses.length;
    }

    // @notice 取得 Education[] 的長度後、指定第幾個 index
    function getEducation(uint index) public view IndexValidator(index, getEducationCount()) returns(string memory, EducationStatus, string memory) {
        Education memory edu = educations[index];
        return(edu.school.name, edu.status, edu.major);
    }

    // @notice 返回經驗：
    function getExperience(uint index) public view IndexValidator(index, getExperienceCount()) returns(string memory, string memory, uint, uint) {
        Job memory exp = experiences[index];
        return(exp.company.name, exp.position, exp.startDate, exp.endDate);
    }
    
    function getSkill(uint index) public view IndexValidator(index, getSkillCount()) returns(string memory, string memory) {
        Skill memory skill = skills[index];
        return(skill.class, skill.name);
    }

    function getCourse(uint eduIndex, uint index) public view 
        IndexValidator(eduIndex, getEducationCount())
        IndexValidator(index, getCourseCount(eduIndex)) 
        returns(string memory, string memory, string memory, uint8){
            Course memory course = educations[eduIndex].courses[index];
            return(course.name, course.content, course.comment, course.grade);
        }
    function getLicense(uint eduIndex, uint index) public view IndexValidator(eduIndex, getEducationCount()) IndexValidator(index, getCourseCount(eduIndex)) returns (string memory, string memory) {
        License memory license = educations[eduIndex].licenses[index];
        return(license.name, license.content);
    }

    // notice: 邏輯 function,
    function setPermission(address account, string memory name, OrganizationType property, bool permission) public onlyGov{
        organizations_addr[account] = Organization ({
            name: name,
            property: property,
            account: account,
            permission: permission
        });
        emit done(DoneCode.setPermission, "Set Permission for Org");
    }
    
    // 設置工作經歷與離職日
    function setExperience(string memory _position, uint _startDate) public onlyCompany {
        Job memory info = Job({
            company: organizations_addr[msg.sender],
            position: _position,
            startDate: _startDate,
            endDate: 0
        });
        experiences.push(info);
        emit done(DoneCode.setExperience, "Set Experience");
    }

    function setJobEndDate(uint endDate) public onlyCompany {
        uint index = uint(findOrganization(msg.sender, "experience")); // 設置為 "experience"
        experiences[index].endDate = endDate;
        emit done(DoneCode.setJobEndDate, "Set JobEndDate");
    }


    // About Educations. 設置學歷
    function setEducation(EducationStatus status, string memory major) public onlySchool {
        educations.push();
        Education storage edu = educations[educations.length - 1];
        Course memory course = Course({
            name: "",
            content: "",
            comment: "",
            grade: 0
        });

        License memory license =License({ 
            name:"", 
            content:""
        });
        
        edu.school = organizations_addr[msg.sender];
        edu.status = status;
        edu.major = major;
        edu.courses.push(course);
        edu.licenses.push(license);
        emit done(DoneCode.setEducation, "Set Education");
    }

    // 設置 License
    function setLicense(string memory _name, string memory _content) public onlySchool {
        uint index = uint(findOrganization(msg.sender, "education"));
        Education storage edu = educations[index]; // 生成一個 storage local variable 
        edu.licenses.push(License({ // 啊這個新變數的結構按照 License 該有的數據格式、存進去得斯
            name: _name, 
            content: _content
        }));
        emit done(DoneCode.setLicense, "Set License");
    }

    function setCourse(string memory _name, string memory _content, string memory _comment, uint8 _grade) public onlySchool {
        uint index = uint(findOrganization(msg.sender, "education"));
        Education storage edu = educations[index];
        edu.courses.push(Course({
            name: _name,
            content: _content,
            comment: _comment,
            grade: _grade
        }));
        emit done(DoneCode.setCourse, "Set Course");
    }

    // 設置自傳
    // @param text
    function setAutobiography(string memory _text) public onlyHost {
        profile.autobiography = _text;
        emit done(DoneCode.setAutobiography, "Set Autobiography"); 
    }
    // 設置專業技能
    function setSkill(string memory _class, string memory _name) public onlyHost {
        skills.push(Skill({ class: _class, name: _name}));
        emit done(DoneCode.setSkill, "Set Skill");
    }

    function setContact(string memory contact) public onlyHost {
        profile.contact = contact;
        emit done(DoneCode.setContact, "Set Contact");
    }


    // Remove Area
    function removePermission(address account) public onlyGov {
        Organization storage org = organizations_addr[account]; // check this input address [account] is having in array or not.
        org.permission = false; //dataType = bool 
        emit done(DoneCode.removePermission,"Remove Permission");
    }

    // remove Skills 
    function removeSkill(string memory _class, string memory _name) public onlyHost {
        uint index = 0;
        for (uint i = 0; i < skills.length; i++) {
            if ( keccak256(abi.encodePacked(skills[i].name)) == keccak256(abi.encodePacked(_name)) 
                &&  keccak256(abi.encodePacked(skills[i].class)) == keccak256(abi.encodePacked(_class)) 
                            // if (skills[i].name.compare(_name) && skills[i].class.compare(_class)){
                    ){
                index = i;
                break;
            }
        }
        for (uint i = index; index < skills.length - 1; i++) {
            skills[i] = skills[i+1];
        }
        delete skills[skills.length - 1];
        // skills[skills.length-1]--;
        emit done(DoneCode.removeSkill, "Remove Skill");
    }
}