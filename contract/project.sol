
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NFTMarketplace {
    struct NFT {
        uint256 id;
        address payable owner;
        uint256 price;
        bool listed;
    }

    uint256 public nftCount;
    mapping(uint256 => NFT) public nfts;

    event NFTCreated(uint256 indexed id, address owner, uint256 price);
    event NFTListed(uint256 indexed id, uint256 price);
    event NFTSold(uint256 indexed id, address buyer, uint256 price);

    // Create a new NFT
    function createNFT(uint256 _price) external {
        require(_price > 0, "Price must be greater than zero");
        nftCount++;
        nfts[nftCount] = NFT(nftCount, payable(msg.sender), _price, true);

        emit NFTCreated(nftCount, msg.sender, _price);
    }

    // Buy a listed NFT
    function buyNFT(uint256 _id) external payable {
        NFT storage nft = nfts[_id];
        require(nft.listed, "NFT is not listed for sale");
        require(msg.value >= nft.price, "Not enough Ether sent");
        require(msg.sender != nft.owner, "Owner cannot buy their own NFT");

        // Transfer Ether to the seller
        nft.owner.transfer(msg.value);

        // Transfer ownership
        nft.owner = payable(msg.sender);
        nft.listed = false;

        emit NFTSold(_id, msg.sender, nft.price);
    }

    // List an owned NFT for sale
    function listNFT(uint256 _id, uint256 _price) external {
        NFT storage nft = nfts[_id];
        require(msg.sender == nft.owner, "Only owner can list the NFT");
        require(_price > 0, "Price must be greater than zero");

        nft.price = _price;
        nft.listed = true;

        emit NFTListed(_id, _price);
    }
}
