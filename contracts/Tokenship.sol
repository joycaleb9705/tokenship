pragma solidity >0.5.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";


// If want to use TokenURI, need to set contract to ERC721URIStorage
contract Tokenship is ERC721Enumerable, AccessControl {
    // TODO: Set minter to smart contract
    constructor() ERC721("Tokenship", "TKS") {
        _setupRole(MINTER_ROLE, msg.sender);
    }

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // TODO: Add owner
    // TODO: Include association address so that we can pay when selling TKS
    // TODO: sales price?
    struct tksInfo {
        uint256 id;
        string association;
    }
    tksInfo[] private _tksInfoList;

    mapping(string => bool) private _mintedTks;
    mapping(string => mapping(address => bool)) private _isMember;
    mapping(string => uint256[]) private _associateToIndex;

    event Mint(
        string association,
        uint256[] ids
    );

    modifier onlyMember(string memory association) {
        require(
            _isMember[association][msg.sender],
            "Only members of this association can call this function."
        );
        _;
    }

    // TODO: Mint to smart contract 
    // TODO: Minting TKSs has no restriction; but restriction to minted TKSs (only members of the association can access all the TKSs)
    // Don't need the "onlyRole" modifier
    function mint(address owner, uint n, string memory association) public onlyRole(MINTER_ROLE) {
        require(!_mintedTks[association] || _isMember[association][msg.sender], "Cannot mint for the provided association.");

        uint256[] memory ids = new uint256[](n);

        for (uint i = 0; i < n; i++) {
            uint256 currId = _tokenIds.current();
            _mint(owner, currId);

            tksInfo memory currInfo = tksInfo(currId, association);
            _tksInfoList.push(currInfo);
            _associateToIndex[association].push(currId);

            ids[i] = currId;
            _tokenIds.increment();
        }

        _mintedTks[association] = true;
        _isMember[association][msg.sender] = true;

        emit Mint(association, ids);
    }

    function getAllInfo(string memory association) public view onlyMember(association) returns (uint256[] memory, string[] memory) {
        uint256[] memory index = _associateToIndex[association];
        uint n = index.length;
        uint256[] memory ids = new uint256[](n);
        string[] memory associations = new string[](n);

        tksInfo memory currTks; 
        for (uint i = 0; i < n; i++) {
            currTks = getInfo(index[i]);
            ids[i] = currTks.id;
            associations[i] = currTks.association;
        }

        return (ids, associations);
    }

    function getInfo(uint256 id) private view returns (tksInfo memory) {
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