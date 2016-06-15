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
ruleTester.run('return-object-only', rule, {
    valid: [
        'function zzz() {function fun() {} return {xxx: fun}}',
        'function zzz() {var x = true; return {xxx: x}}',
        'function zzz() {return {xxx: true}}',
        'function zzz() {return {xxx: true}}',
        'function zzz() {return {xxx: false}}',
        'function zzz(param) {return {xxx: param}}',
        'function zzz(xxx) {return {xxx: "string"}}',
        'function zzz() {return {}}'
    ],
    invalid: [
        {
            code: 'function zzz(foo) {return {xxx: []}}',
            errors: [{ message: 'Function cannot return property of type: ArrayExpression', type: 'ArrayExpression'}]
        },
        {
            code: 'function zzz(foo) {return foo}',
            errors: [{ message: 'Expected function to return an object', type: 'ReturnStatement'}]
        },
        {
            code: 'function zzz(foo) {return foo}',
            errors: [{ message: 'Expected function to return an object', type: 'ReturnStatement'}]
        },
        {
            code: 'function zzz(foo) {function fun(bar) {return bar} return {xxx: fun}}',
            errors: [{ message: 'Expected function to return an object', type: 'ReturnStatement'}]
        }
    ]
});