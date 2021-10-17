// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma abicoder v2;

import "./Ownable.sol";

contract Library is Ownable{
    
    event NewBookAddedToLibrary(uint id,string name,uint64 copies);
    event BookCopiesUpdated (uint id,string name,uint64 newCopies);
    event BookBorrowed (uint id,string name,uint64 copiesLeft);
    event BookReturned(uint id,string name,uint64 copiesLeft);
    
   struct Book{
       string Name;
       uint64 Copies;
   }
   
   Book[] private BooksInLibrary;
   //Mapping to keep track if an address has borrowed a book by id since we can only take 1 copy of a single book
   mapping (address=>mapping(uint => bool)) ownerToBooks;
   //Mapping to keep track of which addresses are already in the _haveBorrowedBooks array so we dont have duplicated entries
   mapping (address=>bool) ownerInArray;
   
   address[] private _haveBorrowedBooks;
   
  
   
   modifier hasBook(uint _id){
    require(ownerToBooks[msg.sender][_id]==true);
       _;
   }
   
   modifier doesNotHaveBook(uint _id){
    require(ownerToBooks[msg.sender][_id]==false);
       _;
   }
   
   function addBookToLibrary(string memory _name,uint64 _copies) public onlyOwner{
       BooksInLibrary.push(Book(_name,_copies));
       //We use the index of a book in the BooksInLibrary array as its id
       uint id = BooksInLibrary.length;
       emit NewBookAddedToLibrary(id,_name,_copies);
   }
   
   function updateBookCopies (uint _id,uint64 _newCopies) public onlyOwner {
       BooksInLibrary[_id].Copies = _newCopies;
       emit BookCopiesUpdated(_id,BooksInLibrary[_id].Name,_newCopies);
   }
   
   function getAvailableBooksToBorrow() public view returns (Book[] memory){
    
    return BooksInLibrary; 
  
     
   }
   
   function borrowBook(uint _id) public doesNotHaveBook(_id) {
       
       require(BooksInLibrary[_id].Copies > 0 );
       BooksInLibrary[_id].Copies--;
       ownerToBooks[msg.sender][_id]=true;
       //No point of adding the address of the borrower to the _haveBorrowedBooks array if he already is there
       if(ownerInArray[msg.sender] == false){
       _haveBorrowedBooks.push(msg.sender);
       ownerInArray[msg.sender] = true;}
       emit BookBorrowed(_id,BooksInLibrary[_id].Name,BooksInLibrary[_id].Copies);
   }
   
   function returnBook(uint _id) public hasBook(_id){
       BooksInLibrary[_id].Copies++;
       ownerToBooks[msg.sender][_id] = false;
       emit BookReturned(_id,BooksInLibrary[_id].Name,BooksInLibrary[_id].Copies);
       
   }
   
   function allAddressesThatHaveBorrowedBooks() public view returns (address[] memory){
       return _haveBorrowedBooks;
   }
    
    
}