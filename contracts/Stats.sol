pragma solidity ^0.6.0;

import "./WarlordToken.sol";

/// @title Warlord
/// @author Genji
/// @notice Source of blockchain data
/// @dev TODO: Warlord actions encrypted/decrypted via Web3. Only Arena.sol inherits
contract Stats is WarlordToken{

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
    uint256 tokenID;

    // no need to store player history on the blockchain, each new player is dead or the new warlord at the end of combat.

    /// @notice Evaluate if the address of player matches warlord [FORBIDDEN]
    /// @return bool = True = address' match, which will prevent the game loop in Arena.sol
    /// @dev If there was no current warlord we only prevent the game loop, not require it, we still want to complete the block transaction
    function comparePlayers() internal view returns(bool){
        if (warlordFighter == playerFighter){
            return true;
        }
        return false;
    }
    
    /// @notice getter
    /// @return uint8[](10) memory = sequence of Warlord actions
    /// @return int16 = Warlord max HP
    /// @return uint8 = Warlord Power
    /// @dev HP&Power can be modified via Shrine.sol TODO: add name
    function getWarlord() internal view returns(uint8[] memory, int16, uint8){
        return (warlordActions, warlordHealth, warlordPower);
    }
    
    /// @notice getter
    /// @return int16 = Player max HP
    /// @return uint8 = Player Power
    /// @dev HP&Power can be modified via Shrine.sol TODO: add name
    function getPlayer() internal view returns(int16, uint8){
        return (playerHealth, playerPower);
    }
    
    /// @notice setter for player win
    /// @dev Victory is 1 due to battle
    function newWarlord() internal {
        warlordFighter = playerFighter;
        warlordActions = playerActions;
        warlordHealth = playerHealth;
        warlordPower = playerPower;
        warlordVictories = 1;
    }

    /// @notice setter for warlord win
    /// @dev TODO: Web3 event collection and URI of tokens
    function victoryWarlord() internal {
        warlordVictories = warlordVictories + 1;
        
        //has candidate reached 100 victories?
        if (warlordVictories == 100){
            //create new erc721
            WarlordToken Warlord = new WarlordToken();
            tokenID = tokenID + 1;
            //URI encoding. I hate solidity!! 
            string memory URI = appendUintToString("http://WebsiteForTokenData.data/?id=", tokenID);
            //Mint new token
            Warlord.mint(warlordFighter, tokenID, URI);
            deadWarlord();
        }
    }
    
    //source https://ethereum.stackexchange.com/questions/10811/solidity-concatenate-uint-into-a-string
    //modifications https://ethereum.stackexchange.com/questions/66438/issue-in-type-conversion-explicit-type-conversion-not-allowed-from-unit256-to
    function uintToString(uint v) private pure returns (string memory) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(uint8(48 + remainder % 10));
        }
        bytes memory s = new bytes(i);
        for (uint j = 0; j < i; j++) {
            s[j] = reversed[i - 1 - j];
        }
        return string(s);
    }
    function appendUintToString(string memory inStr, uint v) private pure returns (string memory) {
        uint maxlength = 100;
        bytes memory reversed = new bytes(maxlength);
        uint i = 0;
        while (v != 0) {
            uint remainder = v % 10;
            v = v / 10;
            reversed[i++] = byte(uint8(48 + remainder % 10));
        }
        bytes memory inStrb = bytes(inStr);
        bytes memory s = new bytes(inStrb.length + i);
        uint j;
        for (j = 0; j < inStrb.length; j++) {
            s[j] = inStrb[j];
        }
        for (j = 0; j < i; j++) {
            s[j + inStrb.length] = reversed[i - 1 - j];
        }
        return string(s);
    }
    
    /// @notice setter for total loss
    function deadWarlord() internal {
        warlordFighter = address(0);
        warlordVictories = 0;
    }
    
    /// @notice Checks if input falls within a valid range or cancels the transaction. Then converts valid ints into array
    /// @param _actions sequence passed into Arena.sol
    /// @return uint8[] Action sequence as array for game loop
    /// @dev we only want to store an encrypted action sequence in our stats. When encryption exists TODO: change the param passed into CreatePlayerStats
    function InputActions (uint32 _actions) internal returns (uint8[] memory){
        require(_actions >= 1111111111 && _actions <= 3333333333); //must be exactly 10 actions
        uint8[] memory player_actions = new uint8[](10);
        for (uint8 i=0;i<10;i++){
            uint8 action = uint8(_actions % 10);
            _actions = _actions / 10;
            require (action == 1 || action == 2 || action == 3); //invalid sequence of entries (1)Fast (2)Power (3)Tech
            player_actions[i] = uint8(action);
        }
        CreatePlayerStats(/*actions_encoded*/ player_actions);
        return player_actions;
    }

    /// @notice Set default stats. Optionally fill warlord slot if vacant
    /// @param _actions sequence received from InputActions()
    /// @dev 'THE' function that will cause comparePlayers() to return true at the start of combat
    /// @dev Victories = 0 as the player has not fought
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