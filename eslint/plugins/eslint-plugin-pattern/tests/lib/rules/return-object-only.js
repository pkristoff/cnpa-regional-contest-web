/**
 * @fileoverview Tests  return-object-only
 * @author Paul Kristoff
 */

'use strict';

//------------------------------------------------------------------------------
// Requirements
//------------------------------------------------------------------------------

var rule = require( '../../../lib/rules/return-object-only'),
    RuleTester = require('/usr/local/lib/node_modules/eslint/lib/testers/rule-tester');

//------------------------------------------------------------------------------
// Tests
//------------------------------------------------------------------------------

var ruleTester = new RuleTester();
var validRules = [
    // valid returning of ObjectExpression
    'function zzz() {return {}}',
    'function zzz(foo) {function fun(bar) {return bar} return {xxx: fun}}',

    // valid object expression
    'function zzz(xxx) {return {old: {yyy: xxx.filename.value}}}',
    'function zzz() {var x = true; return {xxx: x}}',
    'function zzz() {return {xxx: true}}',
    'function zzz() {return {xxx: false}}',
    'function zzz(param) {return {xxx: param}}',
    'function zzz(xxx) {return {xxx: "string"}}'
];
validRules = validRules.map(function ( rule ) {
    return "angular.module( 'cnpaContestApp' ).service( 'fileImageService', [ " + rule + '])';
});
var invalidRules = [
    // not returning an ObjectExpression
    {
        code: 'function() {return function () {}}',
        errors: [{ message: 'Expected function to return an ObjectExpression not FunctionExpression', type: 'ReturnStatement'}]
    },
    {
        code: 'function() {return "string"}',
        errors: [{ message: 'Expected function to return an ObjectExpression not Literal', type: 'ReturnStatement'}]
    },
    // returning the wrong type of property value in ObjectExpression
    {
        code: 'function zzz() {return {xxx: function() {} }}',
        errors: [{ message: 'Function cannot return property of type: FunctionExpression', type: 'FunctionExpression'}]
    },
    {
        code: 'function zzz(foo) {return {xxx: []}}',
        errors: [{ message: 'Function cannot return property of type: ArrayExpression', type: 'ArrayExpression'}]
    },
    {
        code: 'function zzz(foo) {return foo}',
        errors: [{ message: 'Expected function to return an ObjectExpression not Identifier', type: 'ReturnStatement'}]
    },
    {
        code: 'function main() {function updateFiles(ggg){ ggg.forEach(function fe(x){x()}); return hhh();} {return {foo: [foo]}}}',
        errors: [{ message: 'Function cannot return property of type: ArrayExpression', type: 'ArrayExpression'}]
    }
];
invalidRules = invalidRules.map(function ( rule ) {
    rule.code = "angular.module( 'cnpaContestApp' ).service( 'fileImageService', [ " + rule.code + '])';
    return rule;
});
ruleTester.run( 'return-object-only', rule, {
    valid:   validRules,
    invalid: invalidRules
});