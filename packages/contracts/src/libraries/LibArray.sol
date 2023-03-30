// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

library LibArray {
  
  // filter zero
  function filterZeroOffArray(uint256[] memory array_with_zero) internal pure returns(uint256[] memory array_without_zero) {
    uint countNonZeros = 0;
    for (uint i = 0; i < array_with_zero.length; i++) {
      if (array_with_zero[i] != 0) {
        countNonZeros++;
      }
    }
    uint counter = 0;
    array_without_zero = new uint256[](countNonZeros);
    for(uint i=0; i< array_with_zero.length; i++) {
      if(array_with_zero[i] != 0) {
        array_without_zero[counter] = array_with_zero[i];
        counter++;
      }
    }
  }

  function isValueInArray(uint value, uint[] memory array) internal pure returns (bool) {
    return getValueIndexInArray(value, array) > array.length ? false : true;
  }

  function getValueIndexInArray(uint value, uint[] memory array) internal pure returns (uint index) {
    for (uint i; i<array.length; i++) {
      if (array[i] == value) return i;
    }
    return array.length+1;
  }

  function removeValueFromArray(uint value, uint[] memory array) internal pure returns (uint[] memory) {
    if (!LibArray.isValueInArray(value, array)) return array;
    uint256[] memory new_array = new uint256[](array.length-1);
    for (uint i=0; i<array.length; i++) {
      if (array[i] == value) {
        for (uint j=i; j<array.length-1; j++) {new_array[j] = array[j+1];}
        break;
      }
      new_array[i] = array[i];
    }
    return new_array;
  }

  function removeFirstFromArray(uint[] memory array) internal pure returns (uint[] memory) {
    uint256[] memory new_array = new uint256[](array.length-1);
    for (uint i = 0; i < array.length - 1; i++) {
      new_array[i] = array[i+1];
    }
    return new_array;
  }

  // relative complement of B w.r.t. A: i.e., elements of A that are not in B
  function getRelativeComplement(uint[] memory array_a, uint[] memory array_b) internal pure returns (uint[] memory) {
    uint[] memory result = new uint[](array_a.length);
    uint index = 0;

    for (uint i=0; i<array_a.length; i++) {
        bool found = false;
      for (uint j=0; j<array_b.length; j++) {
        if (array_a[i] == array_b[j]) {
          found = true;
          break;
        }
      }
      if (!found) {
        result[index] = array_a[i];
        index++;
      }
    }
    
    // Trim the result array to the correct size
    uint[] memory finalResult = new uint[](index);
    for (uint k = 0; k < index; k++) {
      finalResult[k] = result[k];
    }
        
    return finalResult;
  }

  // compare two arrays with same elements, not necessarily in the same order
  function compareArrays(uint[] memory array1, uint[] memory array2) public pure returns (bool) {
    if (array1.length != array2.length) return false;

    uint[] memory array2Copy = new uint[](array2.length);
      for (uint i = 0; i < array2.length; i++) {
        array2Copy[i] = array2[i];
      }
        
      for (uint i = 0; i < array1.length; i++) {
        bool found = false;
        for (uint j = 0; j < array2Copy.length; j++) {
          if (array1[i] == array2Copy[j]) {
            found = true;
            delete array2Copy[j];
            break;
          }
        }
        
        if (!found) {
          return false;
        }
      }
        
    return true;
  }

}