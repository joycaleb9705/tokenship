pragma solidity >0.5.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// If want to use TokenURI, need to set contract to ERC721URIStorage
contract Tokenship is ERC721Enumerable, AccessControl {
    // TODO: Set minter to smart contract
    // Or do we really need a minter? Can anyone just mint this?
    constructor() ERC721("Tokenship", "TKS") {
        _setupRole(MINTER_ROLE, msg.sender);
    }

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct TKSInfo {
        uint256 id;
        string association;
        uint salesPrice; // gwei
        address minter;
    }
    TKSInfo[] private _tksInfoList;

    // Checks if association name has already been used
    mapping(string => bool) private _hasMinted;
    // Checks if for an association, given address is a member
    mapping(string => mapping(address => bool)) private _isMember;
    // List of all the TKSIndex info for a given association
    mapping(string => uint256[]) private _associateToIndex;

    event Mint(string association, uint256[] ids);

    modifier onlyMember(string memory association) {
        require(
            _isMember[association][msg.sender],
            "Only members of this association can call this function."
        );
        _;
    }

    // TODO: Mint to smart contract
    function mint(string memory association, uint256 n, uint price) public {
        require(
            !_hasMinted[association] || _isMember[association][msg.sender],
            "Cannot mint for the provided association."
        );

        uint256[] memory ids = new uint256[](n);

        for (uint256 i = 0; i < n; i++) {
            uint256 currId = _tokenIds.current();
            _safeMint(msg.sender, currId);

            TKSInfo memory currInfo = TKSInfo(currId, association, price, msg.sender);
            _tksInfoList.push(currInfo);
            _associateToIndex[association].push(currId);

            ids[i] = currId;
            _tokenIds.increment();
        }

        _hasMinted[association] = true;
        _isMember[association][msg.sender] = true;

        emit Mint(association, ids);
    }

    function getAllInfo(string memory association) public view onlyMember(association) returns (uint256[] memory, string[] memory, uint[] memory, address[] memory) {
        uint256[] memory index = _associateToIndex[association];
        uint256 n = index.length;
        uint256[] memory ids = new uint256[](n);
        string[] memory associations = new string[](n);
        uint[] memory salesPrices = new uint[](n);
        address[] memory minters = new address[](n);

        TKSInfo memory currTks;
        for (uint256 i = 0; i < n; i++) {
            currTks = getInfo(index[i]);
            ids[i] = currTks.id;
            associations[i] = currTks.association;
            salesPrices[i] = currTks.salesPrice;
            minters[i] = currTks.minter;
        }

        return (ids, associations, salesPrices, minters);
    }

    function getInfo(uint256 id) private view returns (TKSInfo memory) {
        return _tksInfoList[id];
    }

    function getSupply(string memory association) public view onlyMember(association) returns (uint256) {
        uint256[] memory index = _associateToIndex[association];
        return index.length;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // TODO
    function buy(address buyer, uint256 id) public {
        // Receive eth from buyer -- require(paid amount == TKS price + gas)
        // Send eth - commission to association
        // Transfer TKS to buyer
        // Change owner in the tksInfo
    }

    // TODO: After TKS is bought, transfer
    // TODO: Add owner in tksInfo? Since it can be accessed each time this is called
    // function transferTo() {

    // }
}
