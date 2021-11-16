This project was a class assignment for Solidity Certification.
The intent is to provide a validation mechanism of installed software on a computer/phone/tablet/etc as it passes through a supply chain.
The primary use case is for large coporations that buy many devices and may rely on suppliers to install software. Each step in the supply
chain updates a contract with what has been installed along with a hash of the computer persistent state. Once the device reashes the end user
they can determine what is installed and by whom.


To run:
0.) git clone git@github.com:ctabeckey/DeviceCustody.git
1.) cd DeviceCustody
2.) ganache-cli & (wait for ganache to respond with accounts/private keys)
3.) truffle compile
4.) truffle test

To run GUI:
5.) npm dev run
