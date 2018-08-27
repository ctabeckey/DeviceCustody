function alertMsg(msg) {
    var x = msg;
    var person = {
        firstName: "John",
        lastName : "Doe",
        id       : 5566,
        fullName : function() {
            return this.firstName + " " + this.lastName;
        }
    };
    var cars = ["Saab", "Volvo", "BMW"];                // Array
    var typeMsg = typeof cars;                          // typeof an array is 'object'
    x = undefined;        // Value is undefined, type is undefined

    var bad = new String();        // Declares x as a String object, don't do this !!!

    person = null;        // Now value is null, but type is still an object

    var funcType = typeof alertMsg;     // will be 'function'

    window.alert(typeMsg);
    console.log(msg);       // write to debugging console
}

function showForm(formDivs, divId) {
    var index;
    console.log('Showing form ' + divId);
    for (index = 0; index < formDivs.length; ++index) {
        if (formDivs[index] === divId) {
            document.getElementById(formDivs[index]).style.display='block';
        } else {
            document.getElementById(formDivs[index]).style.display='none';
        }
    }
}
