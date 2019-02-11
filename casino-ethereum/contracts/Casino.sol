pragma solidity 0.4.21;

contract Casino {
   address public owner;
   uint256 public minimumBet = 10000000000;
   uint256 public totalBet;
   uint256 public numberOfBets;
   uint256 public maxAmountOfBets = 100;
   uint256 public lastNumberWinner = 0;
   address[] public players;
   
   struct Player {
      uint256 amountBet;
      uint256 numberSelected;
   }
   
   event Winner(
        uint _number
    );
    
    event BetPlaced(
        address _sender
    );
    
    event Reset(
        bool _resetStatus
    );
    
   // The address of the player and => the user info   
   mapping(address => Player) public playerInfo;
   
   function() public payable {}
   
   function Casino(uint256 _minimumBet) public {
      owner = msg.sender;
      if(_minimumBet != 0 ) minimumBet = _minimumBet;
   }
   function kill() public {
      if(msg.sender == owner) selfdestruct(owner);
   }
   function checkPlayerExists(address player) public constant returns(bool){
      for(uint256 i = 0; i < players.length; i++){
         if(players[i] == player) return true;
      }
      return false;
   }
   // To bet for a number between 1 and 10 both inclusive
   function bet(uint256 numberSelected) public payable {
      // Check that the max amount of bets hasn't been met yet
      require(numberOfBets < maxAmountOfBets);
      
      // Check that the player doesn't exists
      //require(!checkPlayerExists(msg.sender));
      
      // Check that the number to bet is within the range
      require(numberSelected >= 1 && numberSelected <= 10);
      
      // Check that the number to bet is within the range
      require(msg.value >= minimumBet);
      
      playerInfo[msg.sender].amountBet = msg.value;
      playerInfo[msg.sender].numberSelected = numberSelected;
      
      numberOfBets++;
      
      players.push(msg.sender);
      totalBet += msg.value;
   }

   

   // Generates a number between 1 and 10 that will be the winner
   function generateNumberWinner() public {
      uint256 numberGenerated = block.number % 10 + 1; // This isn't secure
      lastNumberWinner = numberGenerated;
      distributePrizes(numberGenerated);
   }
   // Sends the corresponding ether to each winner depending on the total bets
   function distributePrizes(uint256 numberWinner) public {
      address[100] memory winners; // We have to create a temporary in memory array with fixed size
      uint256 count = 0; // This is the count for the array of winners
      for(uint256 i = 0; i < players.length; i++){
         address playerAddress = players[i];
         if(playerInfo[playerAddress].numberSelected == numberWinner){
            winners[count] = playerAddress;
            count++;
         }
         delete playerInfo[playerAddress]; // Delete all the players
      }
      players.length = 0; // Delete all the players array
      uint256 winnerEtherAmount = totalBet / winners.length; // How much each winner gets
      for(uint256 j = 0; j < count; j++){
         if(winners[j] != address(0)) // Check that the address in this fixed array is not empty
         winners[j].transfer(winnerEtherAmount);
      }
      emit Winner(numberWinner);
      resetData();
   }
   
   function resetData() public{
   players.length = 0; // Delete all the players array
   totalBet = 0;
   numberOfBets = 0;
   emit Reset(true);
    }
}