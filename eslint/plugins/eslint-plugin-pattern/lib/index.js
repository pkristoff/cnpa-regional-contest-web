/**
 * @fileoverview xxx
 * @author Paul Kristoff
 */
'use strict';

//------------------------------------------------------------------------------
// Requirements
//------------------------------------------------------------------------------

// var requireIndex = require('requireindex');

//------------------------------------------------------------------------------
// Plugin Definition
//------------------------------------------------------------------------------


// import all rules in lib/rules
// module.exports.rules = requireIndex(__dirname + '/rules');

module.exports = {
    rules: {
        'return-object-only': require('./rules/return-object-only')
    },
    rulesConfig: {
        'return-object-only': 2
    }
};