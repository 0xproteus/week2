//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import { PoseidonT3 } from "./Poseidon.sol"; //an existing library to perform Poseidon hash on solidity
import "./verifier.sol"; //inherits with the MerkleTreeInclusionProof verifier contract

contract MerkleTree is Verifier {
    uint256[] public hashes; // the Merkle tree in flattened array form
    uint256 public index = 0; // the current index of the first unfilled leaf
    uint256 public root; // the current Merkle root

    uint256 constant numberOfLevels = 3;
    uint256 constant numberOfLeaves = 8;

    constructor() {
        // [assignment] initialize a Merkle tree of 8 with blank leaves

        for(uint256 i = 0; i< numberOfLeaves; i++){
            hashes.push(0);
        }

        for(uint256 i= 0; i< numberOfLeaves - 1 ;i++){
            hashes.push(PoseidonT3.poseidon([hashes[i*2] , hashes[i*2+1]]));
        }

        root = hashes[numberOfLeaves *2  - 2];
    }

    function insertLeaf(uint256 hashedLeaf) public returns (uint256) {
        // [assignment] insert a hashed leaf into the Merkle tree
        require(index < numberOfLeaves," no more empty leaves available");

        hashes[index] = hashedLeaf;

        uint256 positionToWrite;

        if(index % 2 == 1){
            positionToWrite = index + numberOfLeaves - 1;
        }
        else{
            positionToWrite = index + numberOfLeaves ;
        }
        uint256 positionToRead = index;

        for(uint256 i = 0; i< numberOfLevels; i++){
 
            if(positionToRead % 2 == 0){
                hashes[positionToWrite] = PoseidonT3.poseidon([hashes[positionToRead] , hashes[positionToRead+1]]);
                positionToRead = positionToWrite;
                positionToWrite += numberOfLeaves / (2 * (i+1));
            }
            else{
                hashes[positionToWrite] = PoseidonT3.poseidon([hashes[positionToRead-1] , hashes[positionToRead]]);
                positionToRead = positionToWrite;
                positionToWrite += numberOfLeaves / (2 * (i+1)) - 1; 
            }

            
        }

        root = hashes[numberOfLeaves *2  - 2];
        index ++;

        return root;
    }

    function verify(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public view returns (bool) {

        // [assignment] verify an inclusion proof and check that the proof root matches current root
        return verifyProof(a,b,c,input);
    }
}
