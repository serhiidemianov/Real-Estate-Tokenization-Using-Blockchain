pragma solidity 0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

import "@openzeppelin/contracts/access/Ownable.sol";

contract RealEstNFT is ERC721URIStorage, Ownable {
    constructor() ERC721("RealEstate Assets FINAL", "REF") {}

    function mint(
        address _to,
        uint256 _tokenId,
        string calldata _uri
    ) external onlyOwner {
        _mint(_to, _tokenId);
        _setTokenURI(_tokenId, _uri);
    }

    struct Agreement {
        address buyer;
        uint256 expirationTime;
        bool executed;
        uint256 advanceAmount; // Store the advance payment
    }

    mapping(uint256 => Agreement) public agreements;

    modifier onlyInvolvedParties(uint256 _tokenId) {
        require(
            msg.sender == agreements[_tokenId].buyer ||
                msg.sender == ownerOf(_tokenId),
            "Only buyer or seller can perform this action"
        );
        _;
    }

    function createAgreement(
        address _buyer,
        uint256 _tokenId,
        uint256 _durationInSeconds
    ) external payable {
        require(
            ownerOf(_tokenId) == msg.sender,
            "Only the owner can create an agreement for this NFT"
        );

        uint256 expirationTime = block.timestamp + _durationInSeconds;

        // Store the advance payment sent with the transaction
        uint256 advanceAmount = msg.value;

        agreements[_tokenId] = Agreement({
            buyer: _buyer,
            expirationTime: expirationTime,
            executed: false,
            advanceAmount: advanceAmount
        });
    }

    function executeAgreement(uint256 _tokenId) external onlyInvolvedParties(_tokenId) {
        require(
            agreements[_tokenId].expirationTime <= block.timestamp,
            "Agreement not yet expired"
        );
        require(!agreements[_tokenId].executed, "Agreement already executed");

        // Transfer the NFT to the buyer
        safeTransferFrom(msg.sender, agreements[_tokenId].buyer, _tokenId);

        // Transfer the advance payment to the seller
        payable(msg.sender).transfer(agreements[_tokenId].advanceAmount);

        agreements[_tokenId].executed = true;
    }

}
