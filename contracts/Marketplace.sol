// SPDX-License-Identifier: UNLICENSED
pragma solidity >0.5.0;

import "./Tokenship.sol";
import "@openzeppelin/contracts/token/ERC721/utils/ERC721Holder.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract Marketplace is IERC721Receiver, ERC721Holder {

    Tokenship public token;

    struct Sale {
        uint tokenId;
        uint price;
        address payable owner;
    }

    Sale[] public sales;

    mapping(uint => uint) tokenToSale;

    event NewSale(uint indexed tokenId, uint price, address owner);

    event TokenBought(uint indexed tokenId, uint price, address newOwner, address prevOwner);

    constructor(address _token) {
        token = Tokenship(_token);
    }

    function enlist(uint _tokenId, uint _price) public {
        require(token.ownerOf(_tokenId) == msg.sender);
        token.safeTransferFrom(msg.sender, address(this), _tokenId);

        Sale memory s = Sale({
            tokenId: _tokenId,
            price: _price,
            owner: payable(msg.sender)
        });

        sales.push(s);
        uint saleId = sales.length - 1;
        tokenToSale[_tokenId] = saleId;

        emit NewSale(_tokenId, _price, msg.sender);
    }

    function getSale(uint _tokenId) view public returns(uint, uint, address) {
        uint saleId = tokenToSale[_tokenId];
        Sale memory sale = sales[saleId];
        require(sale.owner != address(0x0), "Error, sale info does not exist");
        
        require(sale.owner == msg.sender, "Error, only owner can view sale info");
        return (sale.tokenId, sale.price, sale.owner);
    }


    function buy(uint _saleId) public payable {
        Sale storage s = sales[_saleId];

        require(msg.sender != s.owner, "Error, owner can't buy their own token");
        require(msg.value >= s.price, "Error, paid amount should be at least the listed price");

        // send eth
        s.owner.transfer(s.price);

        // send token
        token.approve(msg.sender, s.tokenId);
        token.safeTransferFrom(address(this), msg.sender, s.tokenId);

        emit TokenBought(s.tokenId, s.price, msg.sender, s.owner);

        // clear sales info
        delete tokenToSale[s.tokenId];
        delete sales[_saleId];
    }

    function delist(uint _tokenId) public {
        require(sales[tokenToSale[_tokenId]].owner == msg.sender);

        // clear data
        delete sales[tokenToSale[_tokenId]];
        delete tokenToSale[_tokenId];

        // transfer back token
        token.safeTransferFrom(address(this), msg.sender, _tokenId);
    }

    function onERC721Received(address, address, uint256, bytes memory) public virtual override(IERC721Receiver, ERC721Holder) returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
