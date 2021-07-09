pragma solidity >0.5.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

// TODO: TransferNFT!

// If want to use TokenURI, need to set contract to ERC721URIStorage
contract Tokenship is ERC721Enumerable, AccessControl {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    struct tksInfo {
        uint256 id;
        string association;
    }

    mapping(string => uint256[]) private indexMap;
    tksInfo[] private tksInfoList;
    

    constructor() ERC721("Tokenship", "TKS") {
        _setupRole(MINTER_ROLE, msg.sender);
    }

    function mint(address owner, uint n, string memory association) public onlyRole(MINTER_ROLE) {   
        for (uint i = 0; i < n; i++) {
            uint256 currId = _tokenIds.current();
            _mint(owner, currId);

            tksInfo memory currInfo = tksInfo(currId, association);
            tksInfoList.push(currInfo);
            indexMap[association].push(currId);

            _tokenIds.increment();
        }
    }

    function getAllInfo(string memory association) public view returns (uint256[] memory, string[] memory) {
        require(indexMap[association].length != 0, "TKS for the given association does not exist.");

        uint256[] memory index = indexMap[association];
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

    function getInfo(uint id) private view returns (tksInfo memory) {
        return tksInfoList[id];
    }

    function getSupply(string memory association) public view returns (uint256) {
        require(indexMap[association].length != 0, "TKS for the given association does not exist.");
        
        uint256[] memory index = indexMap[association];
        return index.length;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}