pragma solidity ^0.4.22;

import "./Utilities.sol";

/**
* The DeviceCustody contract contains a record of a device and the
* software installed. This contract records the "state" of the device
* at each ownership transition with the list of installed software (with hash values)
* and a hash of the system as a whole.
* Transfer of custody and modifications to the executables are traceable in the transactions
* on the blockchain.
*/
contract DeviceCustody {
    // a structure to encapsulate the properties of an executable installation
    struct Executable {
        string name;
        string location;
        string hashAlgorithm;
        uint hashCode;
    }

    // A struct to encapsulate all of the information about a single device
    struct Device {
        // the manufacturer of the device, this may not be changed after instantiation
        string manufacturer;
        // the model of the device, this may not be changed after instantiation
        string model;
        // the serial number of the device, this may not be changed after instantiation
        string serialNumber;
        // The current custodian of the hardware is the owner of the contract
        address currentCustodian;

        // The global hash MUST be included when the current custodian transfers custody to the next custodian,
        uint globalHash;
    }

    // the known devices
    Device[] private devices;

    // the known executable installations
    Executable[] private executables;

    // a map from a Device index number to an Executable index number
    // save space when a number of devices
    // are configured identically (something like a SQL join table)
    // NOTE: this makes deletion of either Device or Executable difficult and
    // expensive because the indexes will shift and all of the references
    // would have to be fixed
    // so, for purposes of this POC, deletion is not supported
    // BTW: indices are zero-based and access works in the opposite way of the declaration
    uint[2][] installedExecutableReferences;

    // indexes into the above array, each element of the inner (2 element) array
    // is a reference to an element in the devices and executables arrays respectively
    uint constant DEVICE_INDEX = 0;
    uint constant EXECUTABLE_INDEX = 1;

    /* An event to notify when the custody of a Device changes */
    event CustodyTransfer(address oldCustodian, address newCustodian, uint index);

    /* restrict some methods to only the current custodian of the device */
    modifier onlyCurrentCustodian(uint _index) {
        require(
            msg.sender == devices[_index].currentCustodian,
            "Only the current custodian can call this function."
        );
        _;
    }

    // no-arg constructor
    constructor () public {

    }

    function deviceCount() public view returns(uint) {
        return devices.length;
    }

    function executableCount() public view returns(uint) {
        return executables.length;
    }

    /*
     * Constructor requires that the immutable manufacturer, model and serial number be set
     */
    function newDevice (string _manufacturer, string _model, string _serialNumber) public returns (uint) {
        require(bytes(_manufacturer).length > 0 && bytes(_model).length > 0 && bytes(_serialNumber).length > 0,
            "Manufacturer, model and serial number are all required parameters");

        devices.push(Device({
            manufacturer: _manufacturer,
            model :_model,
            serialNumber : _serialNumber,
            currentCustodian : msg.sender,
            globalHash: 0
        }));

        return devices.length - 1;
    }

    function getDeviceManufacturer(uint _deviceIndex) public view returns(string) {
        require(_deviceIndex >= 0 && _deviceIndex < devices.length,
            "deviceIndex is out of range");
        return devices[_deviceIndex].manufacturer;
    }

    function getDeviceModel(uint _deviceIndex) public view returns(string) {
        require(_deviceIndex >= 0 && _deviceIndex < devices.length,
            "deviceIndex is out of range");
        return devices[_deviceIndex].model;
    }

    function getDeviceSerialNumber(uint _deviceIndex) public view returns(string) {
        require(_deviceIndex >= 0 && _deviceIndex < devices.length,
            "deviceIndex is out of range");
        return devices[_deviceIndex].serialNumber;
    }

    function getDeviceCurrentCustodian(uint _deviceIndex) public view returns(address) {
        require(_deviceIndex >= 0 && _deviceIndex < devices.length,
            "deviceIndex is out of range");
        return devices[_deviceIndex].currentCustodian;
    }

    /*
     * Called when the current custodian transfers responsibility to the new custodian
     */
    function transfer(
        uint _deviceIndex,
        address _newCustodian,
        uint _globalHash)
    onlyCurrentCustodian(_deviceIndex) public {
        require(_deviceIndex >= 0 && _deviceIndex < devices.length,
            "deviceIndex is out of range");

        address oldCustodian = devices[_deviceIndex].currentCustodian;

        devices[_deviceIndex].currentCustodian = _newCustodian;
        devices[_deviceIndex].globalHash = _globalHash;

        emit CustodyTransfer(oldCustodian, _newCustodian, _deviceIndex);
    }

    /**
     * Add an Executable to storage
     * the name, location and has algorithm must be non-null
     */
    function newExecutable(
        string _name,
        string _location,
        string _hashAlgorithm,
        uint _hashCode)
    public returns (uint) {
        require(bytes(_name).length > 0 && bytes(_location).length > 0 && bytes(_hashAlgorithm).length > 0,
            "Name, location, hash algorithm and hash code are all required parameters");

        executables.push(Executable(_name, _location, _hashAlgorithm, _hashCode));
        return executables.length - 1;
    }

    /**
     * Add a new Executable to a Device
     * the name, location and hash algorithm must be non-null
     */
    function addExecutable(
        uint _deviceIndex,
        string _name,
        string _location,
        string _hashAlgorithm,
        uint _hashCode)
    onlyCurrentCustodian(_deviceIndex) public {
        require(_deviceIndex >= 0 && _deviceIndex < devices.length,
            "deviceIndex is out of range");
        require(bytes(_name).length > 0 && bytes(_location).length > 0 && bytes(_hashAlgorithm).length > 0,
            "Index, name, location, hash algorithm and hash code are all required parameters");

        uint executableIndex = newExecutable(_name, _location, _hashAlgorithm, _hashCode);
        addExecutable(_deviceIndex, executableIndex);
    }

    /**
    * Add an existing Executable to a Device
    */
    function addExecutable(
        uint _deviceIndex,
        uint _executableIndex)
    public {
        require(_deviceIndex >= 0 && _deviceIndex < devices.length,
            "_deviceIndex is out of range");
        require(_executableIndex >= 0 && _executableIndex < executables.length,
            "_executableIndex is out of range");

        installedExecutableReferences.push([_deviceIndex, _executableIndex]);
    }

    /**
      * Remove the installed executable with the given name if found.
      * This only removes thlink between the Device and the Executable, it
      * does not remove anything from the Device or Executable arrays.
      */
    function removeInstalledExecutable(
        uint _deviceIndex,
        string _name)
    onlyCurrentCustodian(_deviceIndex) public returns (bool) {
        require(_deviceIndex >= 0 && _deviceIndex < devices.length,
            "deviceIndex is out of range");
        require(bytes(_name).length > 0,
            "Name is are required parameters");

        bool referenceFound = false;
        uint deadReference = 0;
        for (uint executableIndex = 0; executableIndex < executables.length; ++executableIndex) {
            if (Utilities.equals(executables[executableIndex].name, _name)) {
                for (uint referenceIndex = 0; referenceIndex < installedExecutableReferences.length; ++referenceIndex) {
                    if (installedExecutableReferences[referenceIndex][0] == _deviceIndex
                        && installedExecutableReferences[referenceIndex][1] == executableIndex) {
                        // remove this relationship
                        referenceFound = true;
                        deadReference = referenceIndex;
                        break;
                    }
                }
            }
        }

        if (referenceFound) {
            removeDeadReference(deadReference);
            return true;
        } else {
            return false;
        }
    }

    // removes the indicated relationship between a Device and an Executable
    function removeDeadReference(uint _deadReferenceIndex) private {
        for (uint index = _deadReferenceIndex; index < installedExecutableReferences.length; ++index) {
            // if the current is the one to be removed or is after the one to be removed
            // then copy the following element over this element
            installedExecutableReferences[index][DEVICE_INDEX] = installedExecutableReferences[index + 1][DEVICE_INDEX];
            installedExecutableReferences[index][EXECUTABLE_INDEX] = installedExecutableReferences[index + 1][EXECUTABLE_INDEX];
        }

        // shorten the array if we found the specified element
        if (_deadReferenceIndex < installedExecutableReferences.length) {
            installedExecutableReferences.length -= 1;
        }
    }

    /**
     * returns true/false if a named executable is installed
     * 'view' function as it does not modify state
     */
    function isExecutableInstalled(uint _deviceIndex, string _name) public view returns (bool) {
        require(_deviceIndex >= 0 && _deviceIndex < devices.length, "_deviceIndex is out of range");
        require(bytes(_name).length > 0, "Name is a required parameters");

        for (uint index = 0; index < installedExecutableReferences.length; ++index) {
            if (installedExecutableReferences[index][DEVICE_INDEX] == _deviceIndex) {
                uint executableReference = installedExecutableReferences[index][EXECUTABLE_INDEX];
                string memory executableName = getExecutableName(executableReference);
                if (Utilities.equals(executableName, _name)) {
                    return true;
                }
            }
        }

        return false;
    }

    function getExecutableName(uint _index) private view returns(string) {
        return executables[_index].name;
    }

    /**
     * returns the number of executables installed
     * 'view' function as it does not modify state
     */
    function executableInstalledCount(uint _deviceIndex) public view returns (uint) {
        uint count = 0;
        for (uint index = 0; index < installedExecutableReferences.length; ++index)
            if (installedExecutableReferences[index][DEVICE_INDEX] == _deviceIndex)
                ++count;

        return count;
    }

    // Fallback function - Called if other functions don't match call or
    // sent ether without data
    // Typically, called when invalid data is sent
    // Added so ether sent to this contract is reverted if the contract fails
    // otherwise, the sender's money is transferred to contract
    function() public {
        revert();
    }

}
