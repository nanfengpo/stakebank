let options = {
    networks: { },
    mocha: {
        reporter: 'eth-gas-reporter'
    }
};

let reporterArg = process.argv.indexOf('--report');
if (reporterArg === -1) {
    delete  options['mocha'];
}

module.exports = options;