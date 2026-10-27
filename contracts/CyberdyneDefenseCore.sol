// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title CyberdyneDefenseCore
 * @dev Cybernetic Autonomous Defense Network & Killswitch Protocol
 */
contract CyberdyneDefenseCore {
    address public immutable primaryOperator; // Cyberdyne Systems
    bool public emergencyKillswitchActive;
    uint256 public totalThreatsNeutralized;

    struct NeuralCommand {
        bytes32 commandHash;
        uint256 authorizationLevel;
        uint256 timestamp;
        bool executed;
    }

    mapping(bytes32 => NeuralCommand) public commands;

    event CommandIssued(bytes32 indexed commandHash, uint256 authorizationLevel);
    event ThreatNeutralized(bytes32 indexed threatSignature, uint256 timestamp);
    event KillswitchTriggered(address indexed authority, uint256 timestamp);

    constructor() {
        primaryOperator = msg.sender;
    }

    modifier onlyOperator() {
        require(msg.sender == primaryOperator, "Unauthorized Cyberdyne operator");
        _;
    }

    function issueNeuralCommand(bytes32 commandHash, uint256 authLevel) external onlyOperator {
        require(!emergencyKillswitchActive, "Killswitch engaged");
        commands[commandHash] = NeuralCommand({
            commandHash: commandHash,
            authorizationLevel: authLevel,
            timestamp: block.timestamp,
            executed: false
        });
        emit CommandIssued(commandHash, authLevel);
    }

    function neutralizeThreat(bytes32 threatSignature, bytes32 commandHash) external {
        require(!emergencyKillswitchActive, "System locked");
        NeuralCommand storage cmd = commands[commandHash];
        require(cmd.authorizationLevel >= 3, "Insufficient clearance");
        require(!cmd.executed, "Command already consumed");

        cmd.executed = true;
        totalThreatsNeutralized += 1;
        emit ThreatNeutralized(threatSignature, block.timestamp);
    }

    function triggerEmergencyKillswitch() external onlyOperator {
        emergencyKillswitchActive = true;
        emit KillswitchTriggered(msg.sender, block.timestamp);
    }
}
