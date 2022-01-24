# with %lang starknet we declare that this file should be read as a StarkNet contract file
%lang starknet
# pedersen, compute the Pedersen hash function, and range_check, which allows to compare integers.
%builtins pedersen range_check

# Import a crypto Library 
from starkware.cairo.common.cairo_builtins import HashBuiltin

# Define a storage variable.
@storage_var
func balance() -> (res : felt):
end

# Define our constructor which initializes our balance variable.
@constructor
func constructor{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
} (initial_balance : felt):
    balance.write(initial_balance)
    return ()
end

# 
# without explicit declaration of cryptography and utilities libraries (syscall_ptr,pedersen_ptr, range_check_ptr), we can write like this.
#
# func constructor{}(initial_balance : felt):
#    balance.write(initial_balance)
#    return ()
# end
#
# We see that's this function expects an argument "initial_balance" and writes it to the blockchain.
# Note: this declaration is needed, it is just an example for a simpler understanding of the function.
#

# Increases the balance by the given amount.
@external
func increase_balance{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(amount : felt):
    
    # we get the current balance from the blockchain with the keyword "read" and stock it in a variable "res"
    let (res) = balance.read()
    # we update the amount and write to blockchain with the keyword "write"
    balance.write(res + amount)
    return ()
end

# Returns the current balance.
@view
func get_balance{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }() -> (res : felt):
    # We get the current balance and return it
    let (res) = balance.read()
    return (res)
end