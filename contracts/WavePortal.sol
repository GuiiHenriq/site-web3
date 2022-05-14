// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;
    uint256 private seed;

    event NewWave(address indexed from, uint256 timestamp, string message);

    struct Wave {
        address waver;
        string message;
        uint256 timestamp;
    }

    Wave[] waves;

    // Este é um endereço => uint mapping, o que significa que eu posso associar o endereço com um número!
    // Neste caso, armazenarei o endereço com o último horário que o usuário mensagem.
    mapping(address => uint256) public lastWavedAt;

    constructor() payable {
        console.log("Contract built!");
        // Define a semente inicial
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {
        // Precisamos garantir que o valor corrente de timestamp é ao menos 30 segundos maior que o último timestamp armazenado
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "You must wait 30 seconds before sending another message."
        );

        // Atualiza o timestamp atual do usuário
        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves += 1;
        console.log("%s message!", msg.sender);

        waves.push(Wave(msg.sender, _message, block.timestamp));

        // Gera uma nova semente para o próximo usuário que mandar mensagem
        seed = (block.difficulty + block.timestamp + seed) % 100;

        if (seed <= 50) {
            console.log("%s win!", msg.sender);

            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "The contract does not have this value."
            );
            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money.");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getTotalWaves() public view returns (uint256) {
        return totalWaves;
    }
}
