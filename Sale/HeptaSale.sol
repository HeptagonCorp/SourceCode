// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";


/** @title IDO contract does IDO
 * @notice
 */

contract HeptaSale is Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;


    struct User {
        uint256 totalFundedbusd; // total funded amount of user
        uint256 released; // currently released token amount
    }


    // 0x0 BNB, other: BEP20
    address public fundToken;
    address public saleToken;
    uint256 public tokenprice;
    address public receiver;
    uint256 public fundRaised;
    uint256 public tokenreleased;


    string public meta; // meta data json url

    mapping(address => User) public Funders;


    // all funder Addresses
    address[] public funderAddresses;


   modifier isOperatorOrOwner() {
        require(owner() == msg.sender, "Not owner or operator");

        _;
    }

    modifier onlyEOA() {
        require(tx.origin == msg.sender, "should be EOA");
        _;
    }




    constructor(

        address _fundToken,
        address _saleToken,
        uint256 _tokenprice,
        address _receiver
    ) {


        fundToken = _fundToken;
        saleToken = _saleToken;
        tokenprice = _tokenprice;
        receiver = _receiver;



    }



    function getFunderInfobusd(address funder) external view returns (User memory) {
        User memory info;

        info.totalFundedbusd =Funders[funder].totalFundedbusd;



        return info;
    }





    function setMeta(string memory _meta) external isOperatorOrOwner {
        meta = _meta;


    }


    function _processBuy(address buyer, uint256 amount,uint256 amountheptatoken) private {

            require(amount>=15*10**18,"You can minimum buy worth of 15 BUSD HEPTA!");
            require(amount<=150000*10**18,"You can maximum buy worth of 150.00 BUSD HEPTA");

             fundRaised = fundRaised + amount;
             tokenreleased = tokenreleased + amountheptatoken;
            if (Funders[buyer].totalFundedbusd == 0) {
                funderAddresses.push(buyer);
            }

            Funders[buyer].totalFundedbusd = Funders[buyer].totalFundedbusd + amount;
            Funders[buyer].released = Funders[buyer].released + amountheptatoken;

    }


    function buy(uint256 amount) public onlyEOA {
        require(fundToken != address(0), "It's not token-buy pool!");
        uint256 balancebusd = IERC20(fundToken).balanceOf(msg.sender);
        require(balancebusd>=amount,"You don't have enough money!");
        uint256 amountheptatoken = (amount/tokenprice)*10**18;

        _processBuy(msg.sender, amount,amountheptatoken);

        IERC20(fundToken).safeTransferFrom(msg.sender, receiver, amount);

        safeTokenTransfer(msg.sender, amountheptatoken,IERC20(saleToken));
    }

    function safeTokenTransfer(
      address to,
      uint256 amount,
      IERC20 token
  ) internal returns (uint256) {

          token.safeTransfer(to, amount);
          return amount;

  }


   function setFundandSaleToken(address _fundtoken,address _saletoken) external isOperatorOrOwner {


        fundToken = _fundtoken;
        saleToken = _saletoken;


    }
    function settokenprice(uint256 _tokenprice) external isOperatorOrOwner {


       tokenprice = _tokenprice;


    }


    function withdrawBNB() external isOperatorOrOwner {


        uint256 balance = address(this).balance;


        uint256 restAmount = balance;


        (bool success1, ) = payable(msg.sender).call{ value: restAmount }("");
        require(success1, "BNB withdraw failed");
    }

    function withdrawFundedToken() external isOperatorOrOwner  {
        require(fundToken != address(0), "It's not token-buy pool!");

        uint256 balance = IERC20(fundToken).balanceOf(address(this));




        uint256 restAmount = balance;


        IERC20(fundToken).safeTransfer(msg.sender, restAmount);
    }


    function withdrawSaledToken() external isOperatorOrOwner  {
        require(fundToken != address(0), "It's not token-buy pool!");

        uint256 balance = IERC20(saleToken).balanceOf(address(this));




        uint256 restAmount = balance;


        IERC20(saleToken).safeTransfer(msg.sender, restAmount);
    }

    function withdrawAnyToken(IERC20 _token, uint256 amount) external isOperatorOrOwner {
        _token.safeTransfer(msg.sender, amount);
    }




    receive() external payable {
        revert("Something went wrong!");
    }
}
