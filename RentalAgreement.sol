// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract RentalAgreement {

    enum RentalStatus {
        Available,
        Rented,
        Completed
    }

    struct Rental {
        address payable landlord;
        address payable tenant;
        uint rentAmount;
        uint depositAmount;
        uint startTime;
        uint duration;
        RentalStatus status;
    }

    Rental public rental;

    function createRental(uint _rentAmount, uint _depositAmount, uint _duration) public {
        require(
            rental.status == RentalStatus.Available || rental.status == RentalStatus.Completed,
            "Rental already active"
        );

        rental = Rental({
            landlord: payable(msg.sender),
            tenant: payable(address(0)),
            rentAmount: _rentAmount,
            depositAmount: _depositAmount,
            startTime: 0,
            duration: _duration,
            status: RentalStatus.Available
        });
    }

    function rentProperty() public payable {
        require(rental.status == RentalStatus.Available, "Property not available");
        require(msg.value == rental.depositAmount, "Incorrect deposit amount");

        rental.tenant = payable(msg.sender);
        rental.startTime = block.timestamp;
        rental.status = RentalStatus.Rented;
    }

    function releaseDeposit() public {
        require(msg.sender == rental.landlord, "Only landlord can release deposit");
        require(rental.status == RentalStatus.Rented, "Rental not active");
        require(
            block.timestamp >= rental.startTime + rental.duration,
            "Rental period not ended"
        );

        rental.tenant.transfer(rental.depositAmount);
        rental.status = RentalStatus.Completed;
    }
}
