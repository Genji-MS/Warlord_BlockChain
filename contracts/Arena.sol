pragma solidity ^0.6.0;

import "./Pi.sol";
import "./Stats.sol";

/// @title Warlord
/// @author Genji
/// @notice Player combat via a RPS style of input which is compared against the blockChains current Warlord Candidate saved inputs
/// @dev All function calls work without error or warnings on Remis.etherium.org
contract Arena is DefinePi,Stats {
    
    /// @notice Evaluate Player and Warlord actions, Warlord victory adds victory to chain. Player victory makes them the new Warlord.
    /// @dev actions passed in should be encrypted off contract to be stored on the blockchain. This function will only evaluate decrypted data
    /// @param _actions = a non-space sequence of 10 int[1,2,3 ONLY] represents 1=Fast Attack, 2=Power, 3=Tech
    function DeclareCombat(uint32 _actions) public {
        //uint8[] memory warlordActions;
        uint8[] memory playerActions;
        // int16 warlordHealth; //we need negatives
        // int16 playerHealth; //possible to go -0 health
        // uint8 warlordPower;
        // uint8 playerPower;
        uint8 rng;
        uint8 ROUNDS = 10;
        bool activeGame = true;
        
        playerActions = Stats.InputActions(_actions);
        activeGame = !(comparePlayers()); //You cannot fight against yourself, or you just took the throne
        (uint8[] memory warlordActions, int16 warlordHealth, uint8 warlordPower) = Stats.getWarlord();
        (int16 playerHealth, uint8 playerPower) = Stats.getPlayer();
        
        //perhaps not require, but end the function and allow it to write.
        //require(!(comparePlayers())
        //prevous version to parse an encoded actions from hash
        // uint8[] memory player_actions = new uint8[](10);
        // uint8[] memory warlord_actions = new uint8[](10);
        
        if (activeGame){
            
            for (uint i=0;i<ROUNDS;i++){
                //get the current action from our list
                uint8 w_action = warlordActions[i];
                uint8 p_action = playerActions[i];
                // uint8 w_action = uint8(warlordActions % 10);
                // uint8 p_action = uint8(playerActions % 10);
                // w_action = w_action / 10;
                // p_action = p_action / 10;
                
                //copy of original power levels
                uint8 w_power = warlordPower;
                uint8 p_power = playerPower;
                
                //call rng to modify power levels
                rng = DefinePi.Pi_RNG();
                
                //modify power levels based on current action based on rng
                //(1)Fast is 1/2 strength. (2)Power is normal. (3)Tech is the inverse
                if(w_action == 1)w_power = w_power * rng % 5;
                else if (w_action == 2)w_power = w_power * rng;
                else w_power = w_power * (9-rng);
                if(p_action == 1)p_power = p_power * rng % 5;
                else if (p_action == 2)p_power = p_power * rng;
                else p_power = p_power * (9-rng);
                
                //check RPS between characters and apply damage
                if (w_action+1 == p_action || w_action == 3 && p_action == 1){
                    //warlord advantage
                    playerHealth = playerHealth - w_power;
                }
                else if (w_action == p_action){
                    //equal
                    playerHealth = playerHealth - (w_power / 2);
                    warlordHealth = warlordHealth - (p_power / 2);
                }
                else {
                    //player advantage
                    warlordHealth = warlordHealth - p_power;
                }
                
                //check for premature game winner due to loss of HP
                if (playerHealth <= 0 && warlordHealth > 0){
                    //player lose
                    Stats.victoryWarlord();
                    activeGame = false;
                    break;
                }
                else if (warlordHealth <= 0 && playerHealth > 0){
                    //player wins
                    Stats.newWarlord();
                    activeGame = false;
                    break;
                }
                else if (warlordHealth <=0 && playerHealth <= 0){
                    //total loss, empty warlord slot
                    Stats.deadWarlord();
                    activeGame = false;
                    break;
                }
                //else loop continues
            }
        }
        
        //only checking if the game did not end prematurely
        if (activeGame){
            //determine winner and adjust records of warlord, or assign new warlord address
            if (playerHealth > warlordHealth){
                Stats.newWarlord();
            }
            else {
                Stats.victoryWarlord();
            }
        }
    }
}