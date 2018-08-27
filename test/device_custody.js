var DeviceCustody = artifacts.require("./DeviceCustody.sol");

contract('DeviceCustody', function(accounts) {
  const manufacturer = accounts[0]
  const distributor = accounts[1];
  const enduser = accounts[2];

  let deviceCustodyContract = null;

  beforeEach('setup contract for each test', async() => {
    deviceCustodyContract = await DeviceCustody.new()
  })

  it("assert newDevice", async() => {
    assert.isTrue(deviceCustodyContract != null);

    var deviceCount = await deviceCustodyContract.deviceCount();
    assert.equal(deviceCount, 0);
    var executableCount = await deviceCustodyContract.executableCount();
    assert.equal(executableCount, 0);

    var deviceIndex = await deviceCustodyContract.newDevice('Apple', 'A1502', '655321');
    deviceIndex *= 1;   // coerce deviceIndex to a number

    deviceCount = await deviceCustodyContract.deviceCount();
    assert.equal(deviceCount, 1);

    executableCount = await deviceCustodyContract.executableCount();
    assert.equal(executableCount, 0);

    console.log("deviceIndex is " + (typeof deviceIndex));
    var mfr = await deviceCustodyContract.getDeviceManufacturer(deviceIndex);
    var mdl = await deviceCustodyContract.getDeviceModel(deviceIndex);
    var sn = await deviceCustodyContract.getDeviceSerialNumber(deviceIndex);

    assert.equal(mfr, 'Apple');
    assert.equal(mdl, 'A1502');
    assert.equal(sn, "655321");
  });

  it("assert newExec", async() => {
    assert.isTrue(deviceCustodyContract != null);

    var exeIndex = await deviceCustodyContract.newExecutable('Excel', '/opt/ms/excel', 'SHA3', 926895);
    exeIndex *= 1;   // coerce deviceIndex to a number
  });

  it("assert addExec", async() => {
    assert.isTrue(deviceCustodyContract != null);

    var deviceIndex = await deviceCustodyContract.newDevice('Apple', 'A1502', '655321');
    deviceIndex *= 1;   // coerce deviceIndex to a number

    var exeIndex = await deviceCustodyContract.addExecutable(deviceIndex, 'Excel', '/opt/ms/excel', 'SHA3', 926895);
    exeIndex *= 1;   // coerce deviceIndex to a number

  });

});
