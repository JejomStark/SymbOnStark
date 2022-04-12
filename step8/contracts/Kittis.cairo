%lang starknet
# pedersen, compute the Pedersen hash function, and range_check, which allows to compare integers.
%builtins pedersen range_check bitwise

# Import a crypto Library 
from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.math import assert_not_zero
from starkware.cairo.common.uint256 import Uint256
# Import to obtain the adress of the caller
from starkware.starknet.common.syscalls import get_caller_address

######################################### @storage 
# Kitties[] ;
# Define a storage variable, to save all our fake Kitti.
# id = Uint256 our symbiote ID that is mapping to our struct "Symbiote"
@storage_var
func kittis_storage(kittiId: Uint256) -> (dna: Uint256):
end

# Storage to save admins's address 
@storage_var
func admins_storage(account: felt) -> (permission: felt):
end

######################################### @View
@view
func get_kitti{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
} (kittiId: Uint256) -> (dna: Uint256):
    let (dna) = kittis_storage.read(kittiId)
    return (dna)
end

######################################### @constructor
@constructor
func constructor{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
}(admin: felt):
    admins_storage.write(admin, 1)
    return()
end

######################################### @external
@external
func add_kitti{
    syscall_ptr : felt*, 
    pedersen_ptr : HashBuiltin*, 
    range_check_ptr
}(
    kittiId: Uint256,
    dna: Uint256
):
    # We get the caller address and compare with admin storage to verify if is admin
    let (caller) = get_caller_address()
    # We check if the caller is defined
    with_attr error_message("caller undefined !"):    
        assert_not_zero(caller)
    end
    let (permission) = admins_storage.read(caller)
    # We check if the caller is an admin
    with_attr error_message("only admin can do that !"):    
        assert permission = 1
    end
    # finally we add kitti to our storage
    kittis_storage.write(kittiId, dna)
    return()
end

