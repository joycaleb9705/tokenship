// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.5.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";

contract Tokenship is ERC721Enumerable, AccessControl {
    constructor() ERC721("Tokenship", "TKS") {}

    using Counters for Counters.Counter;
    Counters.Counter private tokenIds;

    // Struct with Tokenship Info
    struct tksInfo {
        uint256 tokenId;
        string association;
    }

    // All the Tokenship minted
    tksInfo[] private tksInfoList;

    // Checks if association name has already been used
    mapping(string => bool) private hasMinted;
    // For given association, checks if given address is a member
    mapping(string => mapping(address => bool)) private isMember; // isMember[_association][_address]
    // List of all the TKSIndex info for a given association
    mapping(string => uint256[]) private associateToId;

    event Mint(string association, uint256[] ids, uint256 amount);

    modifier onlyMember(string memory _association) {
        require(
            isMember[_association][msg.sender],
            "Error, only members of this association can call this function"
        );
        _;
    }

    /// @notice Mint a token
    /// @param _association Association of the minted Tokenship
    /// @param _n Number of Tokenship that will be minted
    function mint(string memory _association, uint256 _n) public {
        require(
            !hasMinted[_association] || isMember[_association][msg.sender],
            "Error, cannot mint for the provided association"
        );

        uint256[] memory ids = new uint256[](_n);

        for (uint256 i = 0; i < _n; i++) {
            uint256 currId = tokenIds.current();
            _safeMint(msg.sender, currId);

            tksInfo memory currTks = tksInfo(currId, _association);
            tksInfoList.push(currTks);
            associateToId[_association].push(currId);

            ids[i] = currId;
            tokenIds.increment();
        }

        hasMinted[_association] = true;
        isMember[_association][msg.sender] = true;

        emit Mint(_association, ids, _n);
    }

    /// @notice Get Tokenship info
    /// @param _tokenId Token ID
    function getInfo(uint256 _tokenId) public view returns (uint256, string memory) {
        tksInfo memory info = tksInfoList[_tokenId];

        require(
            bytes(info.association).length != 0,
            "Error, info for the given tokenId does not exist"
        );
        require(
            isMember[info.association][msg.sender],
            "Error, only members of this association can call this function"
        );

        return (info.tokenId, info.association);
    }

    /// @notice Get all info for the given association
    /// @param _association Association
    function getAllInfo(string memory _association) public view onlyMember(_association) 
    returns (uint256[] memory, string[] memory) {
        uint256[] memory index = associateToId[_association];
        uint256 n = index.length;
        uint256[] memory ids = new uint256[](n);
        string[] memory associations = new string[](n);

        uint256 currId;
        string memory currAssociation;
        for (uint256 i = 0; i < n; i++) {
            (currId, currAssociation) = getInfo(index[i]);
            ids[i] = currId;
            associations[i] = currAssociation;
        }

        return (ids, associations);
    }

    /// @notice Get number of Tokens for a given association
    /// @param _association Association
    function getSupply(string memory _association) public view onlyMember(_association) returns (uint256) {
        uint256[] memory index = associateToId[_association];
        return index.length;
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Enumerable, AccessControl)
    returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
