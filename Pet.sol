// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DynamicPetNFT is ERC721URIStorage {
    struct Pet {
        uint256 growthLevel; //成长等级
        string color; // 颜色
        uint256 bodySize; // 体型
        string outfit; // 服装
        string action; // 动作
    }

    event Birth(
        address owner, // 拥有者
        uint256 petId, // 宠物ID
        uint256 mintTime //mint时间
    );

    uint256 private nextTokenId;
    mapping(uint256 => Pet) public pets;
    mapping(uint256 => address) private _owners;
    IERC20 public foodToken; // 假设的ERC20代币作为“食物”

    constructor(address _foodTokenAddress) ERC721("DynamicPet", "DPET") {
        foodToken = IERC20(_foodTokenAddress);
    }

    // 生成 tokenURI 的函数
    function generateTokenURI(uint256 tokenId, Pet memory pet)
        internal
        pure
        returns (string memory)
    {
        // 创建包含有关宠物样式的 JSON 字符串
    bytes memory jsonBytes = abi.encodePacked(
        '{"color": "',
        pet.color,
        '", "growthLevel": ',
        Strings.toString(pet.growthLevel),
        '", "bodySize": ',
        Strings.toString(pet.bodySize),
        '", "outfit": "',
        pet.outfit,
        '", "action": "',
        pet.action,
        '"}'
    );

    // 将 bytes 转换为 string
    string memory json = string(jsonBytes);

    // 构建完整的 tokenURI
    string memory tokenIdStr = Strings.toString(tokenId);
    string memory tokenURI = string(
        abi.encodePacked(tokenIdStr, "_", json)
    );

    return tokenURI;
    }

    function mintPet(address to) public returns (uint256) {
        uint256 tokenId = nextTokenId++;
        _mint(to, tokenId);

        // 生成随机的宠物样式随机
        uint256 growthLevel = 0;
        string memory color = generateRandomColor();
        uint256 bodySize = 1;
        string memory outfit = generateRandomOutfit();
        string memory action = generateRandomAction();
        pets[tokenId] = Pet(growthLevel, color, bodySize, outfit, action);

        // 构建 tokenURI（可以使用 baseURI 或包含完整的元数据信息）
        Pet memory petData = pets[tokenId];
        string memory tokenURI = generateTokenURI(tokenId, petData);
        _setTokenURI(tokenId, tokenURI);

        emit Birth(to, tokenId, block.timestamp);
        return tokenId;
    }

    // 自定义函数来生成随机颜色、服装和动作
    function generateRandomColor() internal pure returns (string memory) {
        // 实现生成随机颜色的逻辑
        // 这里可以使用随机数或其他方法来生成颜色
        // 返回生成的颜色字符串
    }

    function generateRandomOutfit() internal pure returns (string memory) {
        // 实现生成随机服装的逻辑
        // 这里可以使用随机数或其他方法来生成服装
        // 返回生成的服装字符串
    }

    function generateRandomAction() internal pure returns (string memory) {
        // 实现生成随机动作的逻辑
        // 这里可以使用随机数或其他方法来生成动作
        // 返回生成的动作字符串
    }

    function _exists(uint256 tokenId) internal view virtual returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function feedPet(uint256 tokenId, uint256 amount) public {
        require(_exists(tokenId), "Pet does not exist");
        require(
            foodToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        // 应该怎么解决喂食
    }

    
}
