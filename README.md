# erc20-dhall

## Example Demo Trace

Assuming you have all the dhall tooling, if you run `./execute-erc20-example` you should see the following trace.
The intermediate states are serialized as dhall in the `states` dir

```bash
🪙 ERC20 Token Demo
==================

Step 1: Mint 100 tokens to account 1
{
  "output": {
    "amount": 100,
    "to": 1
  },
  "state": [
    {
      "key": 1,
      "value": 100
    }
  ]
}

Step 2: Check account 1 balance
100

Step 3: Check account 2 balance
0

Step 4: Transfer 30 tokens (1 → 2)
{
  "output": {
    "amount": 30,
    "from": 1,
    "to": 2
  },
  "state": [
    {
      "key": 1,
      "value": 70
    },
    {
      "key": 2,
      "value": 30
    }
  ]
}

Final balances:
Account 1:
70
Account 2:
30

Final state:
[
  {
    "key": 1,
    "value": 70
  },
  {
    "key": 2,
    "value": 30
  }
]

```
