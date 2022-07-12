pragma circom 2.0.0;

include "../node_modules/circomlib/circuits/poseidon.circom";

template CheckRoot(n) { // compute the root of a MerkleTree of n Levels 
    signal input leaves[2**n];
    signal output root;

    //[assignment] insert your code here to calculate the Merkle root from 2^n leaves
    var k = 0;
    component poseidon[2**n -1];
    for(var i = 0; i< 2**n/2; i= i+2){
        poseidon[k] = Poseidon(2);
        poseidon[k].inputs[0] <== leaves[i];
        poseidon[k].inputs[1] <== leaves[i+1];
        k++;
    }

    var l = 0;
    for(var i = 1; i < n; i++){
        for(var g = 0; g < 2**(n-i)/2 ; g = g+2){
            poseidon[k] = Poseidon(2);
            poseidon[k].inputs[0]  <== poseidon[l*2].out;
            poseidon[k].inputs[1]  <== poseidon[l*2+1].out;
            k++;
            l++;
        }
    }

    root <== poseidon[2**n -2].out;
}

template MerkleTreeInclusionProof(n) {
    signal input leaf;
    signal input path_elements[n];
    signal input path_index[n]; // path index are 0's and 1's indicating whether the current element is on the left or right
    signal output root; // note that this is an OUTPUT signal

    //[assignment] insert your code here to compute the root from a leaf and elements along the path

    assert(path_index[0] * (1 - path_index[0]) == 0);
    component poseidon[n];
    poseidon[0] = Poseidon(2);
    
    poseidon[0].inputs[0] <-- path_index[0]? leaf : path_elements[0];
    poseidon[0].inputs[1] <-- path_index[0]? path_elements[0]: leaf;


    for(var i = 1; i< n ; i++){
        assert(path_index[i] * (1 - path_index[i]) == 0);
        poseidon[i] = Poseidon(2);

       
        poseidon[i].inputs[0] <-- path_index[i]? poseidon[i-1].out: path_elements[i];
        poseidon[i].inputs[1] <-- path_index[i]? path_elements[i]: poseidon[i-1].out;
       
    }

    root <== poseidon[n-1].out;
}