let Prelude = https://prelude.dhall-lang.org/package.dhall

-- Types
let Address = Natural
let Balance = Natural

-- Key-value pair for our manual "Map"
let Entry = { key : Address, value : Balance }

-- Token state is a list of entries (address -> balance mapping)
let TokenState = List Entry

-- Commands/Operations
let Command = 
  < CheckBalance : Address
  | Transfer : { from : Address, to : Address, amount : Balance }
  | Mint : { to : Address, amount : Balance }
  >

-- Results of operations
let OperationResult = 
  < BalanceResult : Balance
  | TransferSuccess : { from : Address, to : Address, amount : Balance }
  | TransferFailure : Text
  | MintSuccess : { to : Address, amount : Balance }
  >

-- Helper: Find balance for an address (returns 0 if not found)
let getBalance : TokenState -> Address -> Balance =
  \(state : TokenState) ->
  \(address : Address) ->
    let matchingEntries = Prelude.List.filter Entry (\(entry : Entry) -> Prelude.Natural.equal entry.key address) state
    let maybeEntry = List/head Entry matchingEntries
    in merge {
      Some = \(entry : Entry) -> entry.value,
      None = 0
    } maybeEntry

-- Helper: Update or insert an entry
let setBalance : TokenState -> Address -> Balance -> TokenState =
  \(state : TokenState) ->
  \(address : Address) ->
  \(balance : Balance) ->
    let otherEntries = Prelude.List.filter Entry (\(entry : Entry) -> Prelude.Bool.not (Prelude.Natural.equal entry.key address)) state
    let newEntry = { key = address, value = balance }
    in otherEntries # [newEntry]

-- Main step function
let execute : TokenState -> Command -> { state : TokenState, output : OperationResult } =
  \(currentState : TokenState) ->
  \(command : Command) ->
    merge {
      CheckBalance = 
        \(address : Address) ->
          let balance = getBalance currentState address
          in {state = currentState, output = OperationResult.BalanceResult balance},
      Transfer = 
        \(transferData : { from : Address, to : Address, amount : Balance }) ->
          let fromBalance = getBalance currentState transferData.from
          in if Prelude.Natural.lessThanEqual transferData.amount fromBalance
             then -- Sufficient balance, execute transfer
                  let newFromBalance = Natural/subtract transferData.amount fromBalance
                  let toBalance = getBalance currentState transferData.to
                  let newToBalance = toBalance + transferData.amount
                  let stateAfterFrom = setBalance currentState transferData.from newFromBalance
                  let finalState = setBalance stateAfterFrom transferData.to newToBalance
                  in { state = finalState, 
                       output = OperationResult.TransferSuccess transferData }
             else -- Insufficient balance
                  { state = currentState,
                    output = OperationResult.TransferFailure "Insufficient balance" },
      
      Mint = 
        \(mintData : { to : Address, amount : Balance }) ->
          let currentBalance = getBalance currentState mintData.to
          let newBalance = currentBalance + mintData.amount
          let newState = setBalance currentState mintData.to newBalance
          in { state = newState, output = OperationResult.MintSuccess mintData },

    } command

in {
  -- Types
  Address = Address,
  Balance = Balance,
  Entry = Entry,
  Command = Command,
  OperationResult = OperationResult,

  execute = execute,
}