from brownie import accounts
import stats
import pytest

print(address(accounts[0]))
print(address(accounts[1]))

def test_compareSamePlayers(){
    stats.warlordFighter = address(accounts[0])
    stats.playerFighter = address(accounts[0])
    with pytest.reverts("You cannot duel yourself"):
        stats.comparePlayers()
}

def test_compareDiffPlayers(){
    stats.warlordFighter = address(accounts[0])
    stats.playerFighter = address(accounts[1])
    assert stats.comparePlayers()
}

def test_getWarlord(){
    stats.warlordActions=[1,2,3,1,2,3,1,2,3,1]
    stats.warlordHealth=1000
    stats.warlordPower=10
    assert stats.getWarlord == ([1,2,3,1,2,3,1,2,3,1], 1000, 10)
}

def test_getPlayer(){
    stats.playerHealth=800
    stats.playerPower=20
    assert stats.getWarlord == (800,20)
}

def test_newWarlord(){
    stats.warlordFighter = address(accounts[0])
    stats.warlordVictories = 99
    stats.playerFighter = address(accounts[1])
    stats.playerHealth=800
    stats.playerPower=20
    stats.newWarlord()
    assert stats.warlordFighter == stats.playerFighter
    assert stats.warlordHealth == stats.playerHealth
    assert stats.warlordPower == stats.playerFighter
    assert stats.warlordVictories = 1
}    

def test_victoryWarlord(){
    stats.warlordVictories = 15
    stats.victoryWarlord()
    assert stats.warlordVictories == 16
}

def test_tokenID_incriment(){
    stats.warlordVictories = 99
    stats.tokenID = 123
    stats.victoryWarlord()
    assert stats.tokenID == 124
}

    # function victoryWarlord() internal {
    #     warlordVictories = warlordVictories + 1;
    #     //has candidate reached 100 victories?
    #     if (warlordVictories == 100){
    #         //create new erc721
    #         WarlordToken Warlord = new WarlordToken();
    #         tokenID = tokenID + 1;
    #         //URI encoding. I hate solidity!! 
    #         string memory URI = appendUintToString("http://WebsiteForTokenData.data/?id=", tokenID);
    #         //Mint new token
    #         Warlord.mint(warlordFighter, tokenID, URI);
    #         deadWarlord();
    #     }
    # }

def test_appendUintToString(){
    assert appendUintToString("URL:?=fieldNum",404) == "URL:?=fieldNum404"
}

def test_deadWarlord(){
    stats.warlordFighter= address(accounts[0])
    stats.warlordVictories = 99
    stats.deadWarlord()
    assert stats.warlordFighter = address(0)
    assert stats.warlordVictories = 0
}

def test_InputActionFails(){
    with pytest.reverts():
        stats.InputActions(123)
    with pytest.reverts():
        stats.InputActions(1231231234)
    
    assert stats.InputActions(1231231231) == ([1,2,3,1,2,3,1,2,3,1],true)
}

def test_CreatePlayerStats(){
    stats.warlordFighter = address(0)
    stats.playerFighter = address(accounts[0])
    bool activeGame = stats.CreatePlayerStats([1,2,3,1,2,3,1,2,3,1])
    assert activeGame == false

    stats.warlordFighter = address(accounts[0])
    stats.playerFighter = address(accounts[1])
    bool activeGame = stats.CreatePlayerStats([1,2,3,1,2,3,1,2,3,1])
    assert activeGame == true
}


    #  function CreatePlayerStats (/*bytes32*/ uint8[] memory _actions) internal returns (bool){
    #     //if there is no warlord candidate, this player becomes it
    #     bool activeGame = true;
    #     if (warlordFighter == address(0)){
    #         warlordFighter = msg.sender;
    #         warlordActions = _actions;
    #         warlordHealth = 1000;
    #         warlordPower = 10;
    #         warlordVictories = 0;
    #         activeGame = false;
    #     }
    #     else {
    #         playerFighter = msg.sender;
    #         playerActions = _actions;
    #         playerHealth = 1000;
    #         playerPower = 10;
    #     }

    # }