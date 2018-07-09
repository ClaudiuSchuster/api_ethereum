pragma solidity ^0.4.23;

contract HelloWorld {
 
    uint256 counter = 4;            //state variable we assigned earlier
    
    function add() public {         //increases counter by 1
        counter++;
    }

    function subtract() public {    //decreases counter by 1
        if(counter > 0) counter--;
    }
    function getCounter() public constant returns (uint256) {
        return counter;
    } 
}