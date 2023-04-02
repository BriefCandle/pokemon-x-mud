#!/bin/bash

echo "Running command 1: CreatePokemonClass"
forge script script/CreatePokemonClass.s.sol:CreatePokemonClassScript --rpc-url http://localhost:8545 --broadcast
# sleep 10
echo "Running command 2: CreateMoveClass"
forge script script/CreateMoveClass.s.sol:CreateMoveClassScript --rpc-url http://localhost:8545 --broadcast

echo "Running command 3: ConnectPokemonMoves"
forge script script/ConnectPokemonMoves.s.sol:ConnectPokemonMovesScript --rpc-url http://localhost:8545 --broadcast

echo "Running command 4: Create Parcel at (0,0)"
forge script script/parcel/CreateParcel00.s.sol:CreateParcel00Script --rpc-url http://localhost:8545 --broadcast

echo "Running command 4: Create Parcel at (1,0)"
forge script script/parcel/CreateParcel10.s.sol:CreateParcel10Script --rpc-url http://localhost:8545 --broadcast
