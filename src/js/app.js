App = {
  web3Provider: null,
  contracts: {},

  init: function() {
    // Load Manufacturers
    $.getJSON('../manufacturers.json', function(data) {
      var mfrDropdown = $('#dev-mfr');

      for (i = 0; i < data.length; i ++) {
      }
    });

    return App.initWeb3();
  },

  initWeb3: function() {
    // Is there an injected web3 instance?
    if (typeof web3 !== 'undefined') {
      App.web3Provider = web3.currentProvider;

    } else {
      // If no injected web3 instance is detected, fall back to Ganache
      App.web3Provider = new Web3.providers.HttpProvider('http://localhost:8545');
    }

    web3 = new Web3(App.web3Provider);
    return App.initContract();
  },

  initContract: function() {
    $.getJSON('DeviceCustody.json', function(data) {
      // Get the necessary contract artifact file and instantiate it with truffle-contract
      var DeviceCustodyArtifact = data;
      App.contracts.DeviceCustody = TruffleContract(DeviceCustodyArtifact);

      // Set the provider for our contract
      App.contracts.DeviceCustody.setProvider(App.web3Provider);
    });

    return App.bindEvents();
  },

  bindEvents: function() {
  },

  createDevice: function() {
      var deviceCustodyInstance;
      var account = accounts[0];

      App.contracts.DeviceCustody.deployed().then(function(instance) {
        deviceCustodyInstance = instance;

        var mfr = $('#dev-mfr').value;
        var mdl = $('#dev-mdl').value;
        var sn = $('#dev-sn').value;

        console.log('manufacturer=' + mfr + ', model=' + mdl + ', serial number =' + sn);
        var index = deviceCustodyInstance.createDevice(mfr, mdl, sn, {from: account});
        console.log("Created device index " + index);
      },
  },
  createExec: function() {
  },
}
