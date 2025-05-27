use starknet::ContractAddress;

trait IRewardpoint<TContractState>{
    fn add_points(ref self: TContractState, user: ContractAddress, points: felt252);
    fn redeem_points(self: @TContractState, user: ContractAddress) -> felt252;
    fn transfer_points(ref self: TContractState, user: ContractAddress, new_user: ContractAddress) -> bool;
}

#[starknet::contract]
mod UserRewardPoint {
    use starknet::{ContractAddress};
    use starknet::storage::{Map, StorageMapWriteAccess, StorageMapReadAccess};
    use super::IRewardpoint;
    use starknet::storage::{StoragePointerWriteAccess, StoragePointerReadAccess};

    #[storage]
    struct Storage{
        user_points: Map<ContractAddress, felt252>,
    }

    impl RewardPointsImpl of IRewardpoint<ContractState> {
        fn add_points(ref self: ContractState, user: ContractAddress, points: felt252){

        }
        fn redeem_points(self: @ContractState, user: ContractAddress) -> felt252 {

        }
        fn transfer_points(ref self: ContractState, user: ContractAddress, new_user: ContractAddress) -> bool{

        }
    }
}