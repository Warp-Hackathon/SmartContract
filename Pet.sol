// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract DynamicPetNFT is ERC721URIStorage {
    struct Pet {
        string color; // 颜色
        uint256 bodySize; // 体型
        string outfit; // 服装
        string action; // 动作
    }

    struct Owner{
        address owner; // 主人地址
        uint256 calculate; // 活跃度
    }

    struct PetGrowth {
        uint256 lastGrowthTime; // 上次成长的时间
        uint256 growthDegree; // 成长程度，范围0~100
    }

    event Birth(
        address owner, // 拥有者
        uint256 petId, // 宠物ID
        uint256 mintTime //mint时间
    );

    uint256 private nextTokenId;
    mapping(uint256 => Pet) public pets;
    mapping(uint256 => PetGrowth) public petGrowths;
    mapping(address => Owner) public ownerActivities;
    mapping(uint256 => address) private _owners;
    mapping(uint256 => uint256) public nftPrices;
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
        _owners[tokenId] = to;

        // 生成随机的宠物样式随机
        string memory color = generateRandomColor();
        uint256 bodySize = 1;
        string memory outfit = generateRandomOutfit();
        string memory action = generateRandomAction();
        pets[tokenId] = Pet(color, bodySize, outfit, action);

        // 构建 tokenURI（可以使用 baseURI 或包含完整的元数据信息）
        Pet memory pet = pets[tokenId];
        string memory tokenURI = generateTokenURI(tokenId, pet);
        _setTokenURI(tokenId, tokenURI);

        emit Birth(to, tokenId, block.timestamp);
        return tokenId;
    }

    // 预设的颜色、动作和服装
    string[] private colors = ["Red", "Blue", "Green", "Yellow", "Purple"];
    string[] private actions = ["Jumping", "Running", "Sleeping", "Eating", "Playing"];
    string[] private outfits = ["Hat", "Scarf", "Glasses", "Shirt", "Pants"];

    // 生成随机颜色
    function generateRandomColor() internal view returns (string memory) {
        uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % colors.length;
        return colors[rand];
    }

    // 生成随机动作
    function generateRandomAction() internal view returns (string memory) {
        uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % actions.length;
        return actions[rand];
    }

    // 生成随机服装
    function generateRandomOutfit() internal view returns (string memory) {
        uint256 rand = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % outfits.length;
        return outfits[rand];
    }

    // 成长函数
    function chengzhang(uint256 tokenId) private {
        Pet memory pet = pets[tokenId];
        PetGrowth memory growth = petGrowths[tokenId];

        uint256 chengzhangtime = block.timestamp - growth.lastGrowthTime;
        uint256 activity = getUserActivity(msg.sender); // 获取用户活跃度
        uint256 gailv = getRandomNumber();

        if (gailv <= 30) {
            colorchange(tokenId);
        } else if (gailv <= 50) {
            bodychange(tokenId);
        } else if (gailv <= 70) {
            outfitchange(tokenId);
        } else {
            actionchange(tokenId);
        }

        // 更新成长时间和成长度
        growth.lastGrowthTime = block.timestamp;
        growth.growthDegree += 1; // 或根据其他逻辑更新成长度

        string memory tokenURI = generateTokenURI(tokenId, pet);
        _setTokenURI(tokenId, tokenURI);
    }

    function updateActivity() public {
        Owner memory owner = ownerActivities[msg.sender];
        owner.owner = msg.sender;
        owner.calculate += 1; // 增加活跃度计数
    }

    // 获取用户活跃度的函数（需要实现）
    function getUserActivity(address user) private view returns (uint256) {
        // 根据用户地址返回活跃度
        Owner memory owner = ownerActivities[user];
        return owner.calculate;
    }

    // 修改颜色的函数
    function colorchange(uint256 tokenId) private {
        // 颜色改变的逻辑
        string memory color = generateRandomColor();
        pets[tokenId].color = color;
    }

    // 修改体型的函数
    function bodychange(uint256 tokenId) private {
        // 体型改变的逻辑
    }

    // 修改服装的函数
    function outfitchange(uint256 tokenId) private {
        // 服装改变的逻辑
        string memory outfit = generateRandomOutfit();
        pets[tokenId].outfit = outfit;
    }

    // 修改动作的函数
    function actionchange(uint256 tokenId) private {
        // 动作改变的逻辑
        string memory action = generateRandomAction();
        pets[tokenId].action = action;
    }

    // 随机数生成函数
    uint256 private seed;
    function getRandomNumber() private returns (uint256) {
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, seed)));
        seed = randomNumber;
        return (randomNumber % 100); // 返回 0 到 99 之间的数
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
        chengzhang(tokenId);
        
    }
    // 获取宠物颜色的函数
    function getPetColor(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Pet does not exist");
        return pets[tokenId].color;
    }

    // 获取宠物体型的函数
    function getPetBodySize(uint256 tokenId) public view returns (uint256) {
        require(_exists(tokenId), "Pet does not exist");
        return pets[tokenId].bodySize;
    }

    // 获取宠物服装的函数
    function getPetOutfit(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Pet does not exist");
        return pets[tokenId].outfit;
    }

    // 获取宠物动作的函数
    function getPetAction(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Pet does not exist");
        return pets[tokenId].action;
    }

    // 设置NFT价格的函数
    function setNFTPrice(uint256 tokenId, uint256 price) public {
        require(_exists(tokenId), "NFT does not exist");
        require(_owners[tokenId] == msg.sender, "Only owner can set price");
        nftPrices[tokenId] = price;
    }

    // 买家支付ETH并购买NFT的函数
    function buyNFT(uint256 tokenId) public payable { 
        address seller = _owners[tokenId]; 
        require(msg.sender != seller, "Seller cannot buy their own NFT"); 
        require(_exists(tokenId), "NFT does not exist"); 
        uint256 price = nftPrices[tokenId]; 
        // 确保发送的金额等于或大于价格 
        require(msg.value >= price, "Not enough funds sent"); 
        // 使用send方法将资金转给卖家 
        (bool success, ) = payable(seller).call{value: price}(""); 
        require(success, "Transfer to seller failed"); 
        // 将NFT所有权转移到买家 
        _transfer(seller, msg.sender, tokenId); 
        // 在映射中更新所有者 
        _owners[tokenId] = msg.sender; 
    }

    
}