pragma solidity ^0.4.22;


/**
* The Arrays library is a collection of utility methods operating on arrays.
*/
library Utilities {

    function equals(string a, string b) internal pure returns (bool) {
        if(bytes(a).length != bytes(b).length) {
            return false;
        } else {
            return keccak256(bytes(a)) == keccak256(bytes(b));
        }
    }
}
