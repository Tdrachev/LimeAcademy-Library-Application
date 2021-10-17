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
   mapping (address=>uint[]) ownerToBooks;
   mapping (address=>bool) ownerInArray;
   
   address[] private _haveBorrowedBooks;
   
   uint private _bookLocationInOwnerArray =0;
   
   modifier hasBook(uint _id){
       bool _hasBook = false;
       for(uint i = 0; i<ownerToBooks[msg.sender].length;i++){
           if(ownerToBooks[msg.sender][i]==_id){
               _hasBook=true;
               _bookLocationInOwnerArray = i;
               break;
           }
       }
       require(_hasBook);
       _;
   }
   
   modifier doesNotHaveBook(uint _id){
       bool _hasBook = false;
       for(uint i = 0; i<ownerToBooks[msg.sender].length;i++){
           if(ownerToBooks[msg.sender][i]==_id){
               _hasBook=true;
               break;
           }
       }
       require(!_hasBook);
       _;
   }
   
   function addBookToLibrary(string memory _name,uint64 _copies) public onlyOwner{
       BooksInLibrary.push(Book(_name,_copies));
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
       ownerToBooks[msg.sender].push(_id);
       if(ownerInArray[msg.sender] == false){
       _haveBorrowedBooks.push(msg.sender);
       ownerInArray[msg.sender] = true;}
       emit BookBorrowed(_id,BooksInLibrary[_id].Name,BooksInLibrary[_id].Copies);
   }
   
   function returnBook(uint _id) public hasBook(_id){
       BooksInLibrary[_id].Copies++;
       uint ownerBooksArrayLength = ownerToBooks[msg.sender].length-1;
      ownerToBooks[msg.sender][_bookLocationInOwnerArray] = ownerToBooks[msg.sender][ownerBooksArrayLength];
      delete ownerToBooks[msg.sender][ownerBooksArrayLength];
       _bookLocationInOwnerArray=0;
       emit BookReturned(_id,BooksInLibrary[_id].Name,BooksInLibrary[_id].Copies);
       
   }
   
   function allAddressesThatHaveBorrowedBooks() public view returns (address[] memory){
       return _haveBorrowedBooks;
   }
    
    
}