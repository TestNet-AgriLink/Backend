// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

// Testing hardcoded Farmer: 0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db
// Cooperative : 0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2
//Hos :0x5B38Da6a701c568545dCfcB03FcB875f56beddC4

contract FertilizerToken is
    ERC1155,
    AccessControl,
    ERC1155Burnable,
    ERC1155Supply
{
    using Counters for Counters.Counter;
    Counters.Counter private _FTTokenId;
    Counters.Counter private _cooperativeId;
    Counters.Counter private _farmerId;
    Counters.Counter private _burnId;

    struct Cooperative {
        uint256 coOpId;
        address payable coopAddress;
        uint256 numberOfFarmers;
        bool coop;
    }

    struct Farmer {
        uint256 userId;
        address payable farmerAddress;
        uint256 land;
        bool requested;
        uint256 requestedAmount;
        bool isfarmer;
    }

    mapping(uint256 => address) public _setToBurn;
    address[] public cooperativeAddressArray;
    address[] public farmerAddressArray;

    mapping(uint256 => Farmer) public idToFarmer;
    mapping(uint256 => Cooperative) public idToCooperative;
    mapping(address => Farmer) public addressToFarmer;
    mapping(address => Cooperative) public addressToCooperative;

    address public headOfState;
    address public contractAddress;

    // bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant HEAD_OF_STATE = keccak256("HEAD_OF_STATE");
    bytes32 public constant COOPERATIVE = keccak256("COOPERATIVE");
    bytes32 public constant FARMER = keccak256("FARMER");

    constructor() ERC1155("") {
        // _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        // _grantRole(URI_SETTER_ROLE, msg.sender);
        _grantRole(HEAD_OF_STATE, msg.sender);
        _grantRole(COOPERATIVE, msg.sender);
        _grantRole(FARMER, msg.sender);
        headOfState = msg.sender;
        contractAddress = address(this);
    }

    function setURI(string memory newuri) public onlyRole(HEAD_OF_STATE) {
        /*URI_SETTER_ROLE */
        _setURI(newuri);
    }

    function mint(uint256 amount) public onlyRole(HEAD_OF_STATE) {
        uint256 id = 1;
        _mint(msg.sender, id, amount, "");
    }

    // function mintBatch(
    //     address to,
    //     uint256[] memory ids,
    //     uint256[] memory amounts
    // ) public onlyRole(HEAD_OF_STATE) {
    //     _mintBatch(to, ids, amounts, "");
    // }
    function RegisterAsCooperative() public {
        _cooperativeId.increment();
        uint256 coOpId = _cooperativeId.current();
        idToCooperative[coOpId] = Cooperative(
            coOpId,
            payable(msg.sender),
            0,
            true
        );
        cooperativeAddressArray.push(msg.sender);
    }

    function RegisterAsFarmer(uint256 land) public {
        _farmerId.increment();
        uint256 userId = _farmerId.current();
        idToFarmer[userId] = Farmer(
            userId,
            payable(msg.sender),
            land,
            false,
            0,
            true
        );
        farmerAddressArray.push(msg.sender);
    }

    function getcoopAddress(uint256 id) public view returns (address) {
        return idToCooperative[id].coopAddress;
    }

    function transferFTToken(
        uint256 userId,
        address to,
        uint256 amount
    ) public returns (string memory) {
        address operator = msg.sender;
        address from = msg.sender;
        require(
            from == headOfState || from == idToCooperative[userId].coopAddress,
            "You're not authorized"
        );
        if (from == headOfState && idToCooperative[userId].coop) {
            emit TransferSingle(operator, from, to, 1, amount);
            return "Transfered successfully";
        } else if (idToCooperative[userId].coop) {
            emit TransferSingle(operator, from, to, 1, amount);
            return "Transfered successfully";
        } else {
            return "Transaction cannot be performed";
        }
    }

    function checkIfCooperative() public view returns (bool) {
        for (uint256 i = 0; i < cooperativeAddressArray.length; i++) {
            if (cooperativeAddressArray[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function checkIfFarmer() public view returns (bool) {
        for (uint256 i = 0; i < farmerAddressArray.length; i++) {
            if (farmerAddressArray[i] == msg.sender) {
                return true;
            }
        }
        return false;
    }

    function setBurnFTToken() public {
        require(checkIfFarmer(), "Youre not a farmer");
        _burnId.increment();
        uint256 burnId = _burnId.current();
        _setToBurn[burnId] = msg.sender;
    }

    function burnThemAll() private {
        uint256 len = _burnId.current();
        for (uint256 i = 1; i <= len; i++) {
            _burn(_setToBurn[i], 1, balanceOf(_setToBurn[i], 1));
        }
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}

// ____________________________________________________________________________________________________________________________________________________________________

contract FoodToken is ERC1155, ERC1155Burnable, Ownable, ERC1155Supply {
    constructor() ERC1155("") {}

    // FertilizerToken FTT = FertilizerToken(address contractAddress);

    function mint(uint256 id, uint256 amount) public onlyOwner {
        _mint(msg.sender, id, amount, "");
    }

    FertilizerToken tempToken = new FertilizerToken();

    // function mintBatch(
    //     address to,
    //     uint256[] memory ids,
    //     uint256[] memory amounts,
    //     bytes memory data
    // ) public onlyOwner {
    //     _mintBatch(to, ids, amounts, data);
    // }
    //  function getCoopAddress(uint256 id )public returns  (address payable){
    // return payable (FTT.idToCooperative(id).coopAddress);
    //    }
    // function transferFODToken(uint256 coopId, uint256 amount)
    //     public
    //     onlyOwner
    //     returns (string memory)
    // {
    //     address operator = msg.sender;
    //     address from = msg.sender;
    //     address to = idToCooperative[coopId].coopAddress;
    //     emit TransferSingle(operator, from, to, 1, amount);
    // }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal override(ERC1155, ERC1155Supply) {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
}
