pragma solidity ^0.6.0;

import "./Pi.sol";
import "./Stats.sol";

/// @title Warlord
/// @author Genji
/// @notice Player combat via RPS comparison player vs saved inputs of champion player aka 'Warlord'
/// @dev Works without error or warnings on Remix.etherium.org
contract Arena is Pi,Stats {
    
    /// @notice Evaluate Player and Warlord actions, Warlord victory adds victory to chain. Player victory makes them the new Warlord.
    /// @dev TODO: encrypt actions off contract but store on chain. This function will only evaluate decrypted data
    /// @param _actions = a non-space sequence of 10 int[1,2,3 ONLY] represents 1=Fast Attack, 2=Power, 3=Tech
    function DeclareCombat(uint32 _actions) public {
        Stats.comparePlayers();
        uint8[] memory playerActions;
        // int16 warlordHealth; //we need negatives
        // int16 playerHealth; //possible to go -0 health
        // uint8 warlordPower;
        // uint8 playerPower;
        uint8 rng;
        uint8 ROUNDS = 10;
        bool activeGame = true;
        (playerActions, activeGame) = Stats.InputActions(_actions);
        (uint8[] memory warlordActions, int16 warlordHealth, uint8 warlordPower) = Stats.getWarlord();
        (int16 playerHealth, uint8 playerPower) = Stats.getPlayer();
        
        log0(bytes32(activeGame ? bytes32('t') : bytes32('f')));
        if (activeGame){
            
            for (uint i=0;i<ROUNDS;i++){
                //get current action
                uint8 w_action = warlordActions[i];
                uint8 p_action = playerActions[i];

                //copy power levels
                uint8 w_power = warlordPower;
                uint8 p_power = playerPower;
                
                //call rng
                rng = Pi.RNG();
                
                //modify power levels based on action and on rng
                //(1)Fast is 1/2 strength. (2)Power is normal. (3)Tech is inverse
                if(w_action == 1)w_power = w_power * rng % 5;
                else if (w_action == 2)w_power = w_power * rng;
                else w_power = w_power * (9-rng);
                if(p_action == 1)p_power = p_power * rng % 5;
                else if (p_action == 2)p_power = p_power * rng;
                else p_power = p_power * (9-rng);
                
                //check RPS and apply damage
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
                
                //check for total loss of HP
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
                //gameloop
            }
            
            //checking if game loop did not end prematurely
            if (activeGame){
                //determine winner
                if (playerHealth > warlordHealth){
                    log0("defeat");
                    Stats.newWarlord();
                }
                else {
                    log0("victory");
                    Stats.victoryWarlord();
                }
            }
        }
        
    }
}