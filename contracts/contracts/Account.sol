// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import {IR1Validator} from "./interfaces/IValidator.sol";

contract Account is IR1Validator {
    // Constant public keys for the account
    bytes32[2] private publicKey;

    // Array for passwords (could be optimized further if order is not necessary)
    bytes32[] private passwords;

    // Mapping for the names to passwords
    mapping(string => bytes32) private nameToPassword;

    // Mapping to check existence of a password to optimize deletion
    mapping(bytes32 => bool) private passwordExists;

    constructor(bytes32[2] memory _publicKey) {
        publicKey = _publicKey;
    }

    function addPassword(
        bytes32 _signedHash,
        bytes memory _signature,
        bytes32 _password,
        string memory _name
    ) public {
        require(
            validateSignature(_signedHash, _signature, publicKey),
            "Account: Cannot validate signature"
        );
        require(
            nameToPassword[_name] == bytes32(0),
            "Account: Password already exists"
        );
        require(bytes(_name).length > 0, "Account: Name cannot be empty");

        passwords.push(_password);
        nameToPassword[_name] = _password;
        passwordExists[_password] = true;
    }

    function getPassword(
        bytes32 _signedHash,
        bytes memory _signature,
        string memory _name
    ) public view returns (bytes32) {
        require(
            validateSignature(_signedHash, _signature, publicKey),
            "Account: Cannot validate signature"
        );
        require(bytes(_name).length > 0, "Account: Name cannot be empty");

        return nameToPassword[_name];
    }

    function deletePassword(
        bytes32 _signedHash,
        bytes memory _signature,
        string memory _name
    ) public {
        require(
            validateSignature(_signedHash, _signature, publicKey),
            "Account: Cannot validate signature"
        );
        require(
            nameToPassword[_name] != bytes32(0),
            "Account: Password does not exist"
        );

        // Remove the password from the array if it exists
        bytes32 toDelete = nameToPassword[_name];
        require(
            passwordExists[toDelete],
            "Account: Password does not exist in array"
        );

        for (uint256 i = 0; i < passwords.length; i++) {
            if (passwords[i] == toDelete) {
                passwords[i] = passwords[passwords.length - 1]; // Replace with last element
                passwords.pop(); // Remove last element
                break;
            }
        }

        delete nameToPassword[_name];
        passwordExists[toDelete] = false;
    }
}