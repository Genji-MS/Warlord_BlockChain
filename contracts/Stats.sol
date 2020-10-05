pragma solidity ^0.6.0;

/// @title Warlord
/// @author Genji
/// @notice Source of blockchain data. includes stats of the current Warlord Candidate the # of Victores and current Players stats
/// @dev Warlord Candidate stats are provided via Web3, looking at the most recent contracts data. Only Arena.sol inherits
contract Stats {

    address public warlordFighter;
    //bytes32 private warlordActions;  //if encrypted
    uint8[] private warlordActions;
    int16 private warlordHealth;
    uint8 private warlordPower;
    uint8 public warlordVictories;
    address private playerFighter;
    // bytes32 private playerActions;
    uint8[] private playerActions;
    int16 private playerHealth;
    uint8 private playerPower;

    // no need to store player history on the blockchain, each new player is dead or the new warlord at the end of combat.
    // struct PlayerData {
    //     address player;
    //     bytes32 commands;  //SHA3 aka keccak256 hash of 10 command sequence. (1000 possible options)
    //     uint8 health;
    //     uint8 power;
    // }  
    // PlayerData[] players;
    
    /// @notice Evaluate if the address of the current player matches with the Warlord Candidate [FORBIDDEN]
    /// @return bool = True = address' match, which will prevent the game loop in Arena.sol
    /// @dev It is possible there was no current warlord, so while we prevent the game loop, we still want to complete the transaction to the block chain
    function comparePlayers() internal view returns(bool){
        if (warlordFighter == playerFighter){
            return true;
        }
        return false;
    }
    
    /// @notice getter for Warlord Candidates private data.
    /// @return uint8[](10) memory = unencrpted sequence of the current Warlord Candidates actions
    /// @return int16 = Warlord Candidates Health. Health is recovered each battle, however the maximum may have been modified via Shrine.sol
    /// @return uint8 = Warlord Candidates Power, Power is a players base damage. This value begins at 10 but can be increated via Shrine.sol
    /// @dev including a stored name would be a nice addition
    function getWarlord() internal view returns(uint8[] memory, int16, uint8){
        return (warlordActions, warlordHealth, warlordPower);
    }
    
    /// @notice getter for Players stored private data.
    /// @return int16 = Players Health. Health is recovered each battle, however the maximum may have been modified via Shrine.sol
    /// @return uint8 = Players Power, Power is a players base damage. This value begins at 10 but can be increated via Shrine.sol
    /// @dev including a stored name would be a nice addition
    function getPlayer() internal view returns(int16, uint8){
        return (playerHealth, playerPower);
    }
    
    /// @notice setter for when the player becomes the new Warlord Candidate
    /// @dev Victory is 1 here as this function is only called when they have defeated the previous Warlord Candidate via Arena.sol
    function newWarlord() internal {
        warlordFighter = playerFighter;
        warlordActions = playerActions;
        warlordHealth = playerHealth;
        warlordPower = playerPower;
        warlordVictories = 1;
    }

    /// @notice setter for when Warlord Candidate was victorious via Arena.sol
    /// @dev TODO: Implement creation of ERC721 token to the Warlord's address. Then call deadWarlord to empty the Warlord Candidate
    function victoryWarlord() internal {
        warlordVictories = warlordVictories + 1;
        //if (warlordVictories == 100){
            //hall of fame!!
        //}
    }
    
    /// @notice setter to empty the Warlord Candidate slot
    /// @dev Called when the Warlord and Player have both died due to 0 HP via Arena.sol or when the Warlord has ascended due to 100 victories
    function deadWarlord() internal {
        warlordFighter = address(0);
        warlordVictories = 0;
    }
    
    // decoding a hash should be done outside of the block
    // function decodeWarlordActions() internal returns(uint8[] memory){
    //     uint8[] memory warlord_actions = new uint8[](10);
    //     bytes32 actions_decoded = keccak256(abi.decodePacked(warlordActions));
    //     for (uint8 i=0;i<10;i++){
    //         uint8 action = uint8(_actions % 10);
    //         _actions = _actions / 10;
    //         require (action == 1 || action == 2 || action == 3); //invalid sequence of entries (1)Fast (2)Power (3)Tech
    //         player_actions[i] = uint8(action);
    //     }
    // }
    
    /// @notice Checks if input falls within a valid range or cancels the transaction. Then converts a valid int into an array
    /// @param uint32 _actions The same sequence passed into Arena.sol a non-space sequence of 10 int[1,2,3 ONLY]
    /// @return uint8[] memory The action sequence converted into an array for the game loop. stored as playerActions in Arena.sol
    /// @dev we only want to store an encrypted action sequence in our stats. When encryption exists via WEB3 we will change the param passed into CreatePlayerStats
    function InputActions (uint32 _actions) internal returns (uint8[] memory){
        require(_actions >= 1111111111 && _actions <= 3333333333); //must be exactly 10 actions
        uint8[] memory player_actions = new uint8[](10);
        for (uint8 i=0;i<10;i++){
            uint8 action = uint8(_actions % 10);
            _actions = _actions / 10;
            require (action == 1 || action == 2 || action == 3); //invalid sequence of entries (1)Fast (2)Power (3)Tech
            player_actions[i] = uint8(action);
        }
        //encoding on the block is pointless, keccak isn't encryption
        //bytes32 actions_encoded = keccak256(abi.encodePacked(_actions));
        
        CreatePlayerStats(/*actions_encoded*/ player_actions);
        return player_actions;
    }

    /// @notice When a player begins the combat loop of Arena.sol set default stats. Will optionally fill the warlord Candidate slot if it is vacant
    /// @param uint8[] memory actions_encoded a non-space sequence of 10 int[1,2,3 ONLY] represents 1=Fast Attack, 2=Power, 3=Tech
    /// @dev we receive a memory array, not a storage one, even thou we write this data to storage
    /// @dev this is THE function will cause comparePlayers() to return true at the start of combat, and why we want to write their data to the chain
    /// @dev the warlordVictories is set to 0 here as the player has not participated in combat
    function CreatePlayerStats (/*bytes32*/ uint8[] memory _actions) internal {
        //if there is no warlord candidate, this player becomes it
        if (warlordFighter == address(0)){
            warlordFighter = msg.sender;
            warlordActions = _actions;
            warlordHealth = 1000;
            warlordPower = 10;
            warlordVictories = 0;
        }
        else {
            playerFighter = msg.sender;
            playerActions = _actions;
            playerHealth = 1000;
            playerPower = 10;
        }

    }
}