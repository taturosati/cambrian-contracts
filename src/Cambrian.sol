pragma solidity ^0.8.20;

struct Event {
    uint64 blockNumber;
    bytes32 transaction;
    address from;
    address to;
    address contractAddress;
    bytes data;
}

struct Response {
    uint256 messageId;
    Event[] events;
}

struct Status {
    uint256 messageId;
    uint8 status;
    string message;
}

interface IClient {
    function handleSuccess(Response memory response) external;

    function handleStatus(Status calldata status) external;
}
