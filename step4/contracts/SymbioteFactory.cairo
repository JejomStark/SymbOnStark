# with %lang starknet we declare that this file should be read as a StarkNet contract file
%lang starknet
# pedersen, compute the Pedersen hash function, and range_check, which allows to compare integers.
%builtins pedersen range_check bitwise

# Import a crypto Library 
from starkware.cairo.common.cairo_builtins import HashBuiltin, BitwiseBuiltin
# import uint256 to create uints and perform addition and subtraction operations
from starkware.cairo.common.uint256 import Uint256, uint256_sub, uint256_add
# import alloc to acces local memory 
from starkware.cairo.common.alloc import alloc
#import get_fp_and_pc to access function memory
from starkware.cairo.common.registers import get_fp_and_pc

# import unsigned_div_rem to perform modulo operations ## ADD check if diff to zero
from starkware.cairo.common.math import unsigned_div_rem, assert_not_zero, assert_not_equal

# Import to obtain the adress of the caller
from starkware.starknet.common.syscalls import get_caller_address, get_block_timestamp


######################################### @const
# To make sure our DNA is only 16 characters, we make an uint equal to 10^16. 
# Next we will us a modulus operator % to shorten an integer to 16 digits
const DNA_MODULUS = 10 ** 16

######################################### @struct
# Definition to our symbiote structure
struct Symbiote:
    member id: Uint256
    member name: felt
    member dna: Uint256
end

########################################## @event
# Event emit when our symbiote was minted
@event 
func symb_created(
    id: Uint256,
    name: felt,
    dna: Uint256
    ):
end

######################################### @storage (mapping to solidity dev)
# Symbiotes[] ;
# Define a storage variable, to save all our symbiotes.
# id = Uint256 our symbiote ID that is mapping to our struct "Symbiote"
@storage_var
func Symbiotes(id: Uint256) -> (symb: Symbiote):
end

# Define another storage, to save how much symbiote are minted
@storage_var
func counter_symb() -> (counter: Uint256):
end

# Mapping that return owner of symb
@storage_var
func symbToOwner (id: Uint256) -> (owner: felt):
end

# Mapping that return symbiote of owner
@storage_var
func ownerToSymb (owner: felt) -> (symb: Symbiote):
end

# Mapping that return owner minted
@storage_var
func ownerMint (owner: felt) -> (mint: Uint256):
end

######################################### @external functions
# Create a random symbiote.
# materialize at @external if we authorize an external API to contact our contract
@external
func create_random_symbiote{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr,
        bitwise_ptr : BitwiseBuiltin*
    }(name:felt) -> (res: Uint256):
    alloc_locals
    # we get the address of the contract that call our function
    let (caller) = get_caller_address()
    
    with_attr error_message("Wallet caller undefined."):
        # check that caller is defined
        assert_not_zero(caller)
    end
    
    #check if caller have not mint yet a symb
    let (mint) = ownerMint.read(caller)

    with_attr error_message("Wallet has already minted a symb."):
        # check that caller not minted a symb
        assert mint = Uint256(0, 0)
    end
    
    # we call our function to generate a pseudo random DNA
    let (dna) = _generate_dna{
        syscall_ptr=syscall_ptr,
        pedersen_ptr=pedersen_ptr,
        range_check_ptr=range_check_ptr,
    }(name)    

    # We get an ID for our symbiote
    let (counter) = counter_symb.read()    
        
    # Write our symbiote in starknet
    let symb = Symbiote(id=counter, name=name, dna=dna)
    
    # Save our symbiote in blockchain
    Symbiotes.write(counter, symb)  
    # we emited an event to informe everyone that we have a symbiote
    # Nota currently is not possible to subscribe on this events witj Javascript
    symb_created.emit(counter, name, dna)

    # we add our new owner of symb
    symbToOwner.write(counter, caller) 
    ownerToSymb.write(caller, symb) 
    
    # we flag the wallet to not allowed another mint
    ownerMint.write(caller, Uint256(1,0))
    
    # with the library uint256 we can simply add uint.
    # the function return two elements, the first is our add
    let (res,_) = uint256_add(counter, Uint256(1, 0))

    # finally we increase the counter and return the generate dna
    counter_symb.write(res)    
    return(res=dna)     
end


####################################### getters 
# Function view to get a symbiote based on its ID
@view
func get_symbiote{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(id: felt) -> (symb: Symbiote):
    let (symb) = Symbiotes.read(Uint256(id, 0))
    return (symb)
end

# Function view to get a symbiote's owner based on its ID
@view
func get_owner_of{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(id: felt) -> (owner: felt):
    let (owner) = symbToOwner.read(Uint256(id, 0))
    return (owner)
end

# Function view to get a owner's symbiote based on its address
@view
func get_symb_of{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt) -> (symb: Symbiote):    
    let (symb) = ownerToSymb.read(owner)
    return (symb)
end

# Function view to get a owner's symbiote based on its address
@view
func check_owner_mint{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(owner: felt) -> (hasMinted: Uint256):    
    let (mint) = ownerMint.read(owner)
    return (mint)
end

# Private function to generate a random DNA
func _generate_dna{
    syscall_ptr : felt*,
    pedersen_ptr : HashBuiltin*,
    range_check_ptr,
}(name: felt) -> (dna : Uint256):
    # pseudo random number    
    let (block_timestamp) = get_block_timestamp() 
    # we add 123456 because on devnet block-timestamp return 0 all time
    let mul = (block_timestamp + 123456) * name
    # we use unsigned_div_rem to do a modulus on our resul
    let (e, dna) = unsigned_div_rem(mul, DNA_MODULUS)    
    return (dna=Uint256(dna, 0))
end