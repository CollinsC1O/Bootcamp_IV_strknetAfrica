use starknet::ContractAddress;
#[starknet::interface]
trait IRewardpoint<TContractState> {
    fn add_points(ref self: TContractState, user: ContractAddress, points: felt252);
    fn redeem_points(self: @TContractState, user: ContractAddress) -> felt252;
    fn transfer_points(
        ref self: TContractState, user: ContractAddress, new_user: ContractAddress, points: felt252,
    ) -> bool;
}

#[derive(Drop, Copy)]
struct New_user {
    address: ContractAddress,
    points: felt252,
}


#[starknet::contract]
mod UserRewardPoint {
    use starknet::{ContractAddress, contract_address_const};
    use starknet::storage::{Map, StorageMapWriteAccess, StorageMapReadAccess};
    use super::IRewardpoint;
    use starknet::storage::{StoragePointerWriteAccess, StoragePointerReadAccess};

    #[storage]
    struct Storage {
        user_points: Map<ContractAddress, felt252>,
        //new_user_points: Map<ContractAddress, felt252>,
        owner: ContractAddress,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Add_point: Add_point,
        Redeem_point: Redeem_point,
        Transfer_point: Transfer_point,
    }

    #[derive(Drop, starknet::Event)]
    struct Add_point {
        user: ContractAddress,
        points: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct Redeem_point {
        user: ContractAddress,
        points: felt252,
    }

    #[derive(Drop, starknet::Event)]
    struct Transfer_point {
        user: ContractAddress,
        new_user: ContractAddress,
        points: felt252,
    }

    #[constructor]
    fn constructor(ref self: ContractState, owner: ContractAddress) {
        self.owner.write(owner)
    }

    #[abi(embed_v0)]
    impl RewardPointsImpl of IRewardpoint<ContractState> {
        fn add_points(ref self: ContractState, user: ContractAddress, points: felt252) {
            let zero_address = contract_address_const::<0>();
            assert(user != zero_address, 'Address cannot be zero');

            self.user_points.write(user, points);
        }

        fn redeem_points(self: @ContractState, user: ContractAddress) -> felt252 {
            let zero_address = contract_address_const::<0>();
            assert(user != zero_address, 'Address cannot be zero');

            self.user_points.read(user)
        }

        fn transfer_points(
            ref self: ContractState,
            user: ContractAddress,
            new_user: ContractAddress,
            points: felt252,
        ) -> bool {
            let zero_address = contract_address_const::<0>();
            assert(user != zero_address, 'Address cannot be zero');
            assert(new_user != zero_address, 'Address cannot be zero');
            assert(user != new_user, 'Cannot transfer to same address');

            let user_points = self.user_points.read(user);
            //check that the point is not zero
            assert(points != 0, 'can not transfer zero point');
            //check that user_points is not zero
            assert(user_points != 0, 'user balance is zero or less');

            //check that the user has the points to be transfered
            let user_points_u256: u256 = user_points.into();
            let points_u256: u256 = points.into();
            assert(user_points_u256 >= points_u256, 'insufficient points');

            //get receiver balance
            let reciever_points = self.user_points.read(new_user);

            //Transfer points
            self.user_points.write(user, user_points - points);
            self.user_points.write(new_user, reciever_points + points);

            true
        }
    }
}
