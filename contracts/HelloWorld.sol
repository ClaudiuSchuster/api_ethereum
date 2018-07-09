pragma solidity ^0.4.23;

contract HelloWorld {
 
    uint256 counter = 4;            //state variable
    address owner = msg.sender;     //set owner as msg.sender
    
    function add() public {         //increases counter by 1
        counter++;
    }

    function subtract() public {    //decreases counter by 1
        if(counter > 0) counter--;
    }
    function getCounter() public constant returns (uint256) {
        return counter;
    } 
    function kill() public {        //self-destruct function
        if(msg.sender == owner) {
            selfdestruct(owner); 
        }
    }
    function () public payable {
        counter = 4;                //reset counter
    }
}