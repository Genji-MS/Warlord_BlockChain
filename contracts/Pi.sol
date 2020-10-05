pragma solidity ^0.6.0;

/// @title Warlord
/// @author Genji
/// @notice Purpose is to avoid calling RNG off the chain. And prevent re-roll cheats. Its implementation in the Arena is to modify the damage one player does to another
/// @dev All function calls work without error or warnings on Remis.etherium.org. Only Arena.sol inherits currently, but should also be implemented in Shrine.sol
contract Pi {
    
    uint16 public PIndex = 0;
    
    /// @notice stores 1001 sequential digits of Pi in memory. Consecutive digits have been truncated to a single digit.
    /// @return uint8 a single digit 0-9 that corresponds to the array of Pi[PIndex] value
    /// @dev uint256 holds 78 digits, but to avoid the upper range we store only 77 per array sequence.
    function RNG() internal returns(uint8) {
        uint Length = 77;
        uint256[] memory PI = new uint256[](13);
        PI[0] = 31415926535897932384626438327950284197169393751058209749459230781640628620898;
        PI[1] = 62803482534217067982148086513282306470938460950582317253594081284817450284102;
        PI[2] = 70193852105964629489549303819642810975659346128475648237867831652712019091456;
        PI[3] = 48569234603486104543264821393607260249141273724587060631581748152092096282925;
        PI[4] = 40917153643678925903601305305482046521384146951941516094305727036575959195309;
        PI[5] = 21861738193261793105185480746237962749567351857527248912793818301949129836736;
        PI[6] = 24065643086021394946395247371907021798609437027053921717629317675238467481846;
        PI[7] = 76940513205681271452635608278571342757896091736371787214684090124953430146549;
        PI[8] = 58537105079279689258923542019561212902196086403418159813629747130960518707213;
        PI[9] = 49837297804951059731732816096318595024594534690830264252308253468503526193181;
        PI[10]= 71010313783875286587532083814206171769147303598253490428754687315956286382353;
        PI[11]= 78759375195781857805321712680613019278761959092164201989380952572010654858632;
        PI[12]= 78659361538182796823030195203530185296895736259413891249721752834791315157485;

        //reset the PIndex
        PIndex = PIndex + 1;
        if (PIndex > 1000){
            PIndex = 0;
        }

        //break the int down to a single digit
        uint8 line = uint8(PIndex / Length);
        uint8 position = uint8(PIndex % Length);
        uint256 number = PI[line];
    	uint256 divisor = 10**uint256(Length - position); //-position or else we will read the array right to left
	    uint256 truncated = number / divisor;
	    uint8 rng = uint8(truncated % 10);
        
        return rng;
    }
}