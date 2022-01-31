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
# import unsigned_div_rem to perform modulo operations
from starkware.cairo.common.math import unsigned_div_rem
# import external library
from starknet.lib.keccak import keccak256

######################################### @const
# To make sure our DNA is only 16 characters, we make an uint equal to 10^16. 
# Next we will us a modulus operator % to shorten an integer to 16 digits
const DNA_MODULUS = 10 ** 16

######################################### @struct
# Definition to our symbiote structure
struct Symbiote:
    member name: felt
    member dna: Uint256
end

######################################### @storage (mapping to solidity dev)
# Symbiotes[] ;
# Define a storage variable, to save all our symbiotes.
# id = Uint256 our symbiote ID that is mapping to our struct "Symbiote"
@storage_var
func Symbiotes(id: Uint256) -> (symb: Symbiote):
end

# Define another storage, to save howw much symbiote are minted
# in the next step, we will see how use it.
@storage_var
func counter_symb() -> (counter: Uint256):
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
      # We define this function to access to our memore function 
    alloc_locals
    let fp_and_pc = get_fp_and_pc()
    local __fp__ = fp_and_pc.fp_val
    # __fp__ we permit us to access to memory of name with "&" that equal to fp
    # more info https://www.cairo-lang.org/docs/how_cairo_works/functions.html
    let (local dna) = _generate_dna(1, 1, &name)
    let (counter) = counter_symb.read()    
    
    # Write our symbiote in starknet
    Symbiotes.write(counter, Symbiote(name=name, dna=dna))   
    # with the library uint256 we can simply add uint.
    # the function return two elements, the first is our add
    let (res,_) = uint256_add(counter, Uint256(1, 0))
    # finally we increase the counter and return the generate dna
    counter_symb.write(res)    
    
    return(res=dna)     
end

@external
func t{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*,
    range_check_ptr
}(a:felt) -> (b: felt):
    let b = a + a
    return (b=b)
end

####################################### getters 
# our function to get our symbiote data
@view
func get_symbiote{
        syscall_ptr : felt*, 
        pedersen_ptr : HashBuiltin*,
        range_check_ptr
    }(id: felt) -> (symb: Symbiote):
    let (symb) = Symbiotes.read(Uint256(id, 0))
    return (symb)
end


######################################### Private
# create a private function that generate our aleatory DNA
# we use the keccak256 function that's allow us to generate an random int
func _generate_dna{
    range_check_ptr, 
    bitwise_ptr : BitwiseBuiltin*
}(
    keccak_input_length: felt, 
    input_len : felt, 
    input : felt*
) -> (dna: Uint256):
    # our input the pointer of our variable name
    alloc_locals
    let (local keccak_ptr : felt*) = alloc()
    let keccak_ptr_start = keccak_ptr
    # we use the function keccak256 to generate an random numer, more precisely it generate an array of number
    let (keccak_hash) = keccak256{keccak_ptr=keccak_ptr}(input, keccak_input_length)
    # We use the function "unsigned_div_rem" to operate the modulo operation on our keccak first element.
    let (d, res) = unsigned_div_rem(keccak_hash[0], DNA_MODULUS)    
    # an we "cast" our result to an Uint256.
    return (Uint256(res, 0))
end