// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract Squares is Ownable, ERC721A, ReentrancyGuard {
    uint256 public collectionSize=4200;
    uint256 public maxPerAddressDuringMint=5;
    uint256 public price = 0.0069 ether;
    mapping (address => uint) public lastChangeTime;
    string begin="<svg baseProfile='full' width='32' height='32' viewBox='0 0 32 32' xmlns='http://www.w3.org/2000/svg' onclick='if ( this.paused != true ) { this.pauseAnimations(); this.paused = true; } else { this.unpauseAnimations(); this.paused = false; }'>";
    string end="</svg>";
    string black = "#000000";
    string [5] faceColor = ["#23C873", "url(#wave1)", "url(#wave2)", "#EBD9D9", "#DBB17F"];
    string [5] faceProperty = ["Kevin", "Alien", "Gold", "Pale", "White"];

    string [4] noseColor = ["#DDEE0C", "red", "blue", "#363636"];
    string [4] noseProperty = ["yellow", "red", "blue", "gray"];
    
    string [4] eyesColor = ["#533205", "#FFFFFF", "#9D77CC", "#6E4644"];
    string [4] eyesProperty = ["darkbrown", "white", "purple", "lightbrown"];

    string [4] mouthColor = ["#2F754F", "red", black, "#C9C9C9"];
    string [4] mouthProperty = ["darkgreen", "red", "black", "silver"];
    

    struct SquareObject {
        uint colorSeed;
        uint balance;
        uint holdTime;
        string prop;
        string result;
    }
  function randomSquare(uint tokenId) internal view returns (SquareObject memory){
      SquareObject memory square;
      address owner = _ownershipOf(tokenId).addr;
      square.colorSeed = uint(keccak256(abi.encodePacked(Strings.toString(tokenId))));
      square.balance = owner.balance;
      square.holdTime = block.timestamp - lastChangeTime[owner];
      square.prop = "";
      square.result = "";
      return square;
  }
  function rect(string memory x, string memory y, string memory width, string memory height, string memory color)internal pure returns(string memory){
      return string(abi.encodePacked("<rect x='", x,
                                     "' y='", y,
                                     "' width='", width,
                                     "' height='", height,
                                     "' fill='", color,
                                     "'/>")
      );
  }
  function f(SquareObject memory square) internal view returns (string memory){
      uint s = square.colorSeed % 40;
      uint num = 0;
      if (s < 2) num = 0;
      else if (s < 6) num = 1;
      else if (s < 10) num = 2;
      else if (s < 25) num = 3;
      else num = 4;
      square.prop = string(abi.encodePacked("['face' : '", faceProperty[num], "'"));
      return rect("0", "0", "32", "32", faceColor[num]);
  }
  function n(SquareObject memory square) internal view returns (string memory){
      string memory nose_type;
      string memory res = "";
      if (square.colorSeed % 5 == 0){
          nose_type = "Long";
          res = rect("12", "16", "2", "1", noseColor[square.colorSeed % 3]);
      }
      else{
          nose_type = "Normal";
      }
      square.prop = string(abi.encodePacked(square.prop, "'Nose' : '", noseProperty[square.colorSeed % 3], "'"));
      square.prop = string(abi.encodePacked(square.prop, "'Nose type' : '", nose_type, "'"));
      return string(abi.encodePacked(res, rect("14", "15", "2", "2", noseColor[square.colorSeed % 3]),
      rect("15", "17", "1", "1", noseColor[square.colorSeed % 3])));
  }
  function e(SquareObject memory square) internal view returns (string memory){
      if (square.colorSeed % 20 < 2){
          square.prop = string(abi.encodePacked(square.prop, "'Eyes' : 'Kevin'"));
          return string(abi.encodePacked(rect("7", "10", "2", "2", "#FFFFFF"),
          rect("21", "10", "2", "2", "#FFFFFF"),
          rect("7", "11", "1", "1", black),
          rect("21", "11", "1", "1", black)));
      }
      square.prop = string(abi.encodePacked(square.prop, "'Eyes' : '", eyesProperty[square.colorSeed % 4], "'"));
      return string(abi.encodePacked(rect("7", "10", "2", "2", eyesColor[square.colorSeed % 4]),
      rect("21", "10", "2", "2", eyesColor[square.colorSeed % 4])));
  }
  function m(SquareObject memory square) internal view returns (string memory){
      if (square.colorSeed % 20 > 0 && square.colorSeed % 20 < 3){
          square.prop = string(abi.encodePacked(square.prop, "'Mouth' : '", "Kevin", "'"));
          return string(abi.encodePacked(rect("13", "20", "4", "2", black),
          rect("13", "20", "2", "1", "#ECCB51"),
          rect("14", "21", "2", "1", "#ECCB51"),
          rect("16", "20", "1", "1", "#ECCB51")));
      }
      square.prop = string(abi.encodePacked(square.prop, "'Mouth' : '", mouthProperty[square.colorSeed % 3], "'"));
      return rect("13", "20", "4", "2", mouthColor[square.colorSeed % 3]);
  }
  function rn(SquareObject memory square) internal view returns (string memory){
      // Get some money, you are getting cold.
      if (square.balance < 1 ether) {
          square.prop = string(abi.encodePacked(square.prop, "'Running nose' : 'yes'"));
          return "<rect x='14' y='17' width='1' height='1' fill='#C6FDFC'><animate attributeName='y' to='33' dur='1s' repeatCount='indefinite' /></rect>";
      }
      else {
          square.prop = string(abi.encodePacked(square.prop, "'Running nose' : 'no'"));
          return "";
      }
  }
  function le(SquareObject memory square) internal view returns (string memory){
      string memory color = "";
      if (square.balance > 100 ether) {color = "red";}
      else if (square.holdTime > 4 weeks ) {color = "lime";}
      else if (square.balance < 0.05 ether) {color = "aqua";}
      else {color = "None";}
      square.prop = string(abi.encodePacked(square.prop, "'Laser eyes' : '", color, "']"));
      return string(abi.encodePacked("<line x1='7' y1='10' x2='40' y2='43' style='stroke:",
      color,
      ";stroke-width:2'> <animateTransform attributeName='transform' type='rotate' from='0 8 11' to='360 8 11' begin='0s' dur='5s' repeatCount='indefinite' />",
      "</line><line x1='21' y1='10' x2='55' y2='44' style='stroke:",
      color,
      ";stroke-width:2'> <animateTransform attributeName='transform' type='rotate' from='0 22 11' to='360 22 11' begin='0s' dur='5s' repeatCount='indefinite' />",
      "</line>"));
  }
  function generateImage(SquareObject memory square) internal view{
      square.result = begin;
      square.result = string(abi.encodePacked(square.result,
                                       "<defs><linearGradient id='wave1' x1='0' y1='0' x2='0' y2='32' gradientUnits='userSpaceOnUse'><stop offset='0' style='stop-color:#40A49A;stop-opacity:1'>",
                                       "<animate attributeName='offset' values='0;1;0' begin='0s' dur='5s' repeatCount='indefinite'/></stop><stop offset='32' style='stop-color:#E46844;stop-opacity:1'></stop>",
                                       "</linearGradient><linearGradient id='wave2' x1='0' y1='0' x2='0' y2='32' gradientUnits='userSpaceOnUse'><stop offset='0' style='stop-color:#F6E649;stop-opacity:1'>",
                                       "<animate attributeName='offset' values='0;0.5;0' begin='0s' dur='5s' repeatCount='indefinite'/></stop><stop offset='32' style='stop-color:#E5B338;stop-opacity:1'>",
                                       "<animate attributeName='offset' values='1;0.5;1' begin='2.5s' dur='5s' repeatCount='indefinite'/> </stop></linearGradient></defs>"
      ));
      square.result = string(abi.encodePacked(square.result,
      f(square),
      n(square),
      e(square),
      m(square),
      rn(square),
      le(square),
      end
      ));
  }

  function svgToImageURI(string memory _source) internal pure returns (string memory){
      string memory baseURL = "data:image/svg+xml;base64,";
      string memory svgBase64Encoded = Base64.encode(bytes(_source));
      return string(abi.encodePacked(baseURL, svgBase64Encoded));
  }

  function tokenURI(uint256 tokenId) public view override returns (string memory){
      string memory _name = string(abi.encodePacked("Squares! #", Strings.toString(tokenId)));
      string memory _description = "Squares - A fully on-chain animated dynamic pixelized ugly NFT as a tool pass created with the least gas possible.";
      SquareObject memory square = randomSquare(tokenId);
      string memory _properties = square.prop;
      generateImage(square);
      string memory _imageURI = svgToImageURI(square.result);
      return string(
          abi.encodePacked(
              "data:application/json;base64,",
              Base64.encode(
                  bytes(
                      abi.encodePacked(
                          '{"name":"', _name,
                          '", "description": "', _description, '"',
                          ', "attributes": ', _properties,
                          ', "image":"', _imageURI, '"}'
                      )
                  )
              )
          )
      );
  }

  constructor() ERC721A("Squares", "SQR") {
  }

  // Mint/Transfer
  function mint(uint256 quantity)
    external
    payable
  {
    require(totalSupply() + quantity <= collectionSize, "reached max supply");
    require(
      numberMinted(msg.sender) + quantity <= maxPerAddressDuringMint,
      "can not mint this many"
    );
    _safeMint(msg.sender, quantity);
    require(msg.value >= price * quantity, "Need more ETH.");
  }

  function _afterTokenTransfers(address from, address to, uint256 startTokenId, uint256 quantity)
    internal override
  {
      lastChangeTime[to] = block.timestamp;
  }

  // Dev
  function withdrawMoney() external onlyOwner nonReentrant {
    (bool success, ) = msg.sender.call{value: address(this).balance}("");
    require(success, "Transfer failed.");
  }
  function setPrice(uint price_) public onlyOwner{
      price = price_;
  }
  function numberMinted(address owner) public view returns (uint256) {
    return _numberMinted(owner);
  }
}

library Base64 {
    bytes internal constant TABLE = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/";

    function encode(bytes memory data) internal pure returns (string memory) {
        uint256 len = data.length;
        if (len == 0) return "";

        uint256 encodedLen = 4 * ((len + 2) / 3);

        bytes memory result = new bytes(encodedLen + 32);

        bytes memory table = TABLE;

        assembly {
            let tablePtr := add(table, 1)
            let resultPtr := add(result, 32)

            for {
                let i := 0
            } lt(i, len) {

            } {
                i := add(i, 3)
                let input := and(mload(add(data, i)), 0xffffff)

                let out := mload(add(tablePtr, and(shr(18, input), 0x3F)))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(12, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(shr(6, input), 0x3F))), 0xFF))
                out := shl(8, out)
                out := add(out, and(mload(add(tablePtr, and(input, 0x3F))), 0xFF))
                out := shl(224, out)

                mstore(resultPtr, out)

                resultPtr := add(resultPtr, 4)
            }

            switch mod(len, 3)
            case 1 {
                mstore(sub(resultPtr, 2), shl(240, 0x3d3d))
            }
            case 2 {
                mstore(sub(resultPtr, 1), shl(248, 0x3d))
            }

            mstore(result, encodedLen)
        }

        return string(result);
    }
}