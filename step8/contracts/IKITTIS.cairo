%lang starknet

from starkware.cairo.common.uint256 import Uint256

@contract_interface
namespace IKITTIS:
    func get_kitti(kittiId: Uint256) -> (dna: Uint256):
    end
    func add_kitti(kittiId: Uint256, dna: Uint256):
    end    
end