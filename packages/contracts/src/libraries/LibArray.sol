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

}