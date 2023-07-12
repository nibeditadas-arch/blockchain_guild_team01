
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract SupplyChain {
    address public owner;
    address public farmer;
    address public distributor;
    address public retailer;

    struct Product {
        string Pdt_Name;
        string Pdt_Description;
        string DateofHarvest;
        string origin;
        uint256 price;
        bool exists;
        bool approvedByDistributor;
        address owner;
        address[] ownershipHistory;
    }

    mapping(uint256 => Product) public products;
    uint256 public productCount;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can perform this action.");
        _;
    }

    modifier onlyFarmer() {
        require(msg.sender == farmer, "Only the farmer can perform this action.");
        _;
    }

    modifier onlyDistributor() {
        require(msg.sender == distributor, "Only the distributor can perform this action.");
        _;
    }

    modifier onlyRetailer() {
        require(msg.sender == retailer, "Only the retailer can perform this action.");
        _;
    }

    function assignFarmer(address _farmer) public onlyOwner {
        require(_farmer != address(0), "Invalid farmer address.");

        farmer = _farmer;
    }

    function assignDistributor(address _distributor) public onlyOwner {
        require(_distributor != address(0), "Invalid distributor address.");

        distributor = _distributor;
    }

    function assignRetailer(address _retailer) public onlyOwner {
        require(_retailer != address(0), "Invalid retailer address.");

        retailer = _retailer;
    }

    function createProduct(string memory _Pdt_Name, string memory _Pdt_Description, string memory _DateofHarvest, string memory _origin, uint256 _price) public onlyFarmer {
        require(bytes(_Pdt_Name).length > 0, "Product name cannot be empty.");
        require(_price > 0, "Product price must be greater than zero.");

        productCount++;
        products[productCount] = Product(_Pdt_Name, _Pdt_Description, _DateofHarvest, _origin, _price, true, false, farmer, new address[](0));
    }

    function approveProduct(uint256 _productId) public onlyDistributor {
        require(products[_productId].exists, "Product does not exist.");
        require(!products[_productId].approvedByDistributor, "Product is already approved by the distributor.");

        products[_productId].approvedByDistributor = true;
        transferOwnership(_productId, distributor);
    }

    function declineByDistributor(uint256 _productId) public onlyDistributor {
        require(products[_productId].exists, "Product does not exist.");
        require(!products[_productId].approvedByDistributor, "Product is already approved by the distributor.");

        products[_productId].approvedByDistributor = false;
    }

    function finalizeProduct(uint256 _productId) public onlyRetailer {
        require(products[_productId].exists, "Product does not exist.");
        require(products[_productId].approvedByDistributor, "Product is not approved by the distributor.");

        transferOwnership(_productId, retailer);
    }

    function declineByRetailer(uint256 _productId) public onlyRetailer {
        require(products[_productId].exists, "Product does not exist.");
        require(products[_productId].approvedByDistributor, "Product is not approved by the distributor.");

        transferOwnership(_productId, distributor);
    }

    function viewProduct(uint256 _productId) public view returns (address, string memory, string memory, string memory, string memory, uint256, bool, bool, address[] memory) {
        require(products[_productId].exists, "Product does not exist.");

        Product memory product = products[_productId];
        return (product.owner, product.Pdt_Name, product.Pdt_Description, product.DateofHarvest, product.origin, product.price, product.exists, product.approvedByDistributor, product.ownershipHistory);
    }

    function viewAllProducts() public view returns (Product[] memory) {
        Product[] memory allProducts = new Product[](productCount);

        for (uint256 i = 1; i <= productCount; i++) {
            allProducts[i - 1] = products[i];
        }

        return allProducts;
    }

    function transferOwnership(uint256 _productId, address _newOwner) private {
        require(_newOwner != address(0), "Invalid new owner address.");

        products[_productId].ownershipHistory.push(products[_productId].owner);
        products[_productId].owner = _newOwner;
    }
}
