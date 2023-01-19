// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

// struct Cooperative {
//     string role;
//     uint256 coOpId;
//     address payable coopAddress;
//     uint256 numberOfFarmers;
// }
// struct  Farmer  {
//     address payable farmerAddress;
//     uint256 land;
//     bool requested;
//     uint256 requestedAmount;

// }

// mapping(uint256 => Farmer)  idToFarmer;
// mapping(uint256 => Cooperative)  idToCooperative;

contract FertilizerToken is
    ERC1155,
    AccessControl,
    ERC1155Burnable,
    ERC1155Supply
{
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
        bool farmer;
    }

    mapping(uint256 => Farmer) idToFarmer;
    mapping(uint256 => Cooperative) idToCooperative;

    string public constant NAME = "FertilizerToken";
    string public constant SYMBOL = "FTN";
    uint8 public constant DECIMAL = 5;
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
        bool setToBurn;
    }

    function setURI(string memory newuri) public onlyRole(HEAD_OF_STATE) {
        /*URI_SETTER_ROLE */
        _setURI(newuri);
    }

    function mint(
        address account,
        uint256 id,
        uint256 amount
    ) public onlyRole(HEAD_OF_STATE) {
        _mint(account, id = 1, amount, "");
    }

    // function mintBatch(
    //     address to,
    //     uint256[] memory ids,
    //     uint256[] memory amounts
    // ) public onlyRole(HEAD_OF_STATE) {
    //     _mintBatch(to, ids, amounts, "");
    // }
    function RegisterAsCooperative(uint256 coOpId) public {
        idToCooperative[coOpId] = Cooperative(
            coOpId,
            payable(msg.sender),
            0,
            true
        );
    }

    function RegisterAsFarmer(uint256 userId, uint256 land) public {
        idToFarmer[userId] = Farmer(
            userId,
            payable(msg.sender),
            land,
            false,
            0,
            true
        );
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
    function transferFODToken(uint256 coopId, uint256 amount)
        public
        onlyOwner
        returns (string memory)
    {
        address operator = msg.sender;
        address from = msg.sender;
        address to = idToCooperative[coopId].coopAddress;
        emit TransferSingle(operator, from, to, 1, amount);
    }

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
