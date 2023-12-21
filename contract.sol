// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract ContractFactory {
    // Event to track the deployment of a new contract
    event NewContract(
        address indexed deployedContract,
        address indexed creator
    );

    // Function to deploy a new contract
    function deployNewContract() public {
        // Create a new instance of the Organisation contract
        Organisation newContract = new Organisation(msg.sender);

        // Emit an event to log the deployment
        emit NewContract(address(newContract), msg.sender);
    }
}

contract Organisation {
    address public Creator;
    address[] public Admins;
    address[] public Departments;
    mapping(address => uint256) public DepartmentFunds;

    // Constructor to set the creator of the contract
    constructor(address _creator) {
        Creator = _creator;
    }

    // Function to get all admins
    function getAdmins() public view returns (address[] memory) {
        return Admins;
    }

    // Function to get all departments
    function getDepartments() public view returns (address[] memory) {
        return Departments;
    }

    // Function to add an admin
    function addAdmin(address _admin) public {
        Admins.push(_admin);
    }

    // Function to add a department
    function addDepartment(address _dept) public {
        Departments.push(_dept);
    }

    function isAdmin(address _address) internal view returns (bool) {
        for (uint256 i = 0; i < Admins.length; i++) {
            if (Admins[i] == _address) {
                return true;
            }
        }
        return false;
    }

    function isDepartment(address _address) internal view returns (bool) {
        for (uint256 i = 0; i < Departments.length; i++) {
            if (Departments[i] == _address) {
                return true;
            }
        }
        return false;
    }

    function depositFunds(address _department, uint256 _amount) public {
        require((isAdmin(msg.sender) || msg.sender == Creator), "Only Admins can deposit funds");
        require(isDepartment(_department), "Invalid department address");
        require(_amount > 0, "Amount must be greater than zero");

        DepartmentFunds[_department] += _amount;
        (bool success, ) = payable(address(this)).call{value: _amount}("");
        require(success, "Transaction failed");
    }

    function withdrawFunds(uint256 _amount) public {
        require (isDepartment(msg.sender),"Only Departments can withdraw the funds");
        require(_amount > 0,"Amount should be greater than zero");
        require (_amount <= DepartmentFunds[msg.sender],"Insufficient funds");

        (bool success,) = payable(msg.sender).call{value:_amount}("");
        require(success,"Transaction failed");
    }
}   
