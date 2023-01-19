// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

struct Cooperative {
    uint256 coOpId;
    address payable coopAddress;
    uint256 numberOfFarmers;
}
struct Farmer {
    address payable farmerAddress;
    uint256 land;
    bool requested;
    uint256 requestedAmount;
}

contract FertilizerToken is
    ERC1155,
    AccessControl,
    ERC1155Burnable,
    ERC1155Supply
{
    string public constant NAME = "FertilizerToken";
    string public constant SYMBOL = "FTN";
    uint8 public constant DECIMAL = 5;

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

    function transferToken(address to, uint256 amount) private {
        address operator = msg.sender;
        address from = msg.sender;

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

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
