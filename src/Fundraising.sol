// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

/*
 * @author not-so-secure-dev
 * @title Fundraising
 * @notice This contract allows you to collect funds and withdraw them when you want
 */
contract Fundraising {
    address owner;
    string public title;
    bool public finished;
    uint256 public amountCollected;
    mapping(address => uint256) public contributions;

    event FundsWithdrawn(uint256 amount);
    event ContributionMade(address contributor, uint256 amount);
    event FundraisingFinished(uint256 amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "only owner");
        _;
    }

    modifier notFinished(){
        require(finished == false, "fundraising finished");
        _;
    }

    /*
     * @notice contract constructor
     * @param title_ reason for the Fundraising
     */
    constructor(string memory title_) {
        owner = msg.sender;
        title = title_;
    }

    /*
     * @notice This function allows the owner to modify the title
     * @param title_ The new title to set.
     */
    function setTitle(string memory title_) external {
        title = title_;
    }

    function getTitle() external view returns (string memory) {
        return title;
    }

    /*
     * @notice This function allows users to contribute their funds
     * if fundraising is not finished
     */
    function contribute() external payable notFinished {
        amountCollected += msg.value;
        contributions[msg.sender] += msg.value;
        emit ContributionMade(msg.sender, msg.value);
    }

    /*
     * @notice This function allows the owner to collect funds
     */
    function collect() external onlyOwner notFinished {

        (bool sent, ) = owner.call{value: amountCollected}("");
        require(sent, "withdraw error");

        finished = true;
        
        emit FundraisingFinished(amountCollected);
    }

    /*
     * @notice This function allows the owner to collect funds
     */
    function withdraw() external notFinished {
        uint256 contribution = contributions[msg.sender];
        (bool sent, ) = msg.sender.call{value: contribution}("");
        require(sent, "withdraw error");

        contributions[msg.sender] = 0;

        emit FundsWithdrawn(amountCollected);
    }
}
