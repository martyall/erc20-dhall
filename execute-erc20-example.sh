#!/bin/bash

# Simple ERC20 Demo Script

set -e

echo "🪙 ERC20 Token Demo"
echo "=================="

mkdir states

# Step 1: Mint 100 tokens to account 1
echo
echo "Step 1: Mint 100 tokens to account 1"

dhall <<< '
let erc20 = ./erc20.dhall 
in erc20.execute ([] : List { key : Natural, value : Natural }) (erc20.Command.Mint { to = 1, amount = 100 })
' > states/step1.dhall

dhall-to-json < ./states/step1.dhall | jq '.'

# Step 2: Check account 1 balance
echo
echo "Step 2: Check account 1 balance"

dhall <<< '
let erc20 = ./erc20.dhall 
let step1 = ./states/step1.dhall
in erc20.execute step1.state (erc20.Command.CheckBalance 1)
' > ./states/step2.dhall

dhall-to-json < ./states/step2.dhall | jq '.output'

# Step 3: Check account 2 balance  
echo
echo "Step 3: Check account 2 balance"

dhall <<< '
let erc20 = ./erc20.dhall 
let step2 = ./states/step2.dhall
in erc20.execute step2.state (erc20.Command.CheckBalance 2)
' > states/step3.dhall

dhall-to-json < ./states/step3.dhall | jq '.output'

# Step 4: Transfer 30 tokens
echo
echo "Step 4: Transfer 30 tokens (1 → 2)"

dhall <<< '
let erc20 = ./erc20.dhall 
let step3 = ./states/step3.dhall
in erc20.execute step3.state (erc20.Command.Transfer { from = 1, to = 2, amount = 30 })
' > states/step4.dhall

dhall-to-json < ./states/step4.dhall | jq '.'

# Step 5: Final balances
echo
echo "Final balances:"

echo "Account 1:"
dhall <<< '
let erc20 = ./erc20.dhall 
let step4 = ./states/step4.dhall
in erc20.execute step4.state (erc20.Command.CheckBalance 1)
' | dhall-to-json | jq '.output'

echo "Account 2:"
dhall <<< '
let erc20 = ./erc20.dhall 
let step4 = ./states/step4.dhall
in erc20.execute step4.state (erc20.Command.CheckBalance 2)
' | dhall-to-json | jq '.output'

echo
echo "Final state:"
dhall <<< '(./states/step4.dhall).state' | dhall-to-json | jq '.'
