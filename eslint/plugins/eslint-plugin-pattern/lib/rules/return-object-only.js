/**
 * @fileoverview Given a function it returns an object
 * @author Paul Kristoff
 */

'use strict';

//------------------------------------------------------------------------------
// Rule Definition
//------------------------------------------------------------------------------

module.exports = function ( context ) {

    function angularState(node) {

        var functionStack = [ state( false, false, node ) ];

        function state( _isAngular, _isService, _node ) {

            function isTopLevelFunctionBody() {
                return isAngular() && isService() && functionStack.length === 2 && top().node().type === 'FunctionExpression';
            }

            function isAngular() {
                return _isAngular;
            }

            function isService() {
                return _isService;
            }

            function node() {
                return _node;
            }

            function setIsAngular( bool ) {
                _isAngular = bool;
            }

            function setIsService( bool ) {
                _isService = bool;
            }

            return {
                isTopLevelFunctionBody: isTopLevelFunctionBody,
                isAngular:              isAngular,
                isService:              isService,
                node: node,
                setIsAngular:           setIsAngular,
                setIsService:           setIsService
            };
        }

        function isTopLevel() {
            return top().isTopLevelFunctionBody();
        }

        function popStack() {
            return functionStack.pop();
        }

        function pushStack(node) {
            var topState = top();
            return functionStack.push( state( topState.isAngular(), topState.isService(), node ) );
        }

        function setAngular( bool ) {
            top().setIsAngular( bool );
        }

        function setService( bool ) {
            top().setIsService( bool );
        }

        function top() {
            return functionStack[ functionStack.length - 1 ];
        }

        return {
            isTopLevel: isTopLevel,
            popStack:   popStack,
            pushStack:  pushStack,
            setAngular: setAngular,
            setService: setService

        };

    }

    function getLogName( node ) {

        switch ( node.type ) {
            case 'CallExpression':
                return getLogName( node.callee );
            case 'FunctionDeclaration':
            case 'FunctionExpression':
                if (node.id){
                    return getLogName( node.id );
                } else {
                    return '<unknown>';
                }
                
            case 'Identifier':
                return node.name;
            case 'MemberExpression':
                return getLogName( node.property );
            default:
                return '<unknown>';
        }
    }

    function logLocation( node, pre ) {
        var message = pre ? pre + ': ' : '';
        message += '(' + node.loc.start.line + ':' + node.loc.start.column + '-' + node.loc.end.line + ':' + node.loc.end.column + ') ';
        // console.log( 'loc: ' + node.loc.start.line + ':' + node.loc.start.column );
        message += node.type + ': ' + getLogName( node );
        // console.log( message );
    }

    var state;

    function objectExpression( node ) {
        var properties = node.properties,
            len        = properties.length;
        for ( var i = 0; i < len; i++ ) {
            var property       = properties[ i ],
                property_value = property.value;
            switch ( property_value.type ) {
                case 'Identifier':
                case 'Literal':
                case 'MemberExpression':
                    break;
                case 'ObjectExpression':
                    objectExpression( property_value );
                    break;
                default:
                    context.report(
                        {
                            node:    property_value,
                            message: 'Function cannot return property of type: ' + property_value.type
                        } );
                    break;

            }
        }
    }

    function callExpression( node ) {
        logLocation( node );
        if ( node.callee.type == 'MemberExpression' && node.callee.property.type == 'Identifier' ) {
            // console.log( 'callExpression: ' + node.callee.property.name )
            if ( node.callee.property.name == 'service' ) {
                state.setService( true );
            }
            else if ( node.callee.property.name == 'module' ) {
                if ( node.callee.type == 'MemberExpression' && node.callee.object.type == 'Identifier' && node.callee.object.name == 'angular' ) {
                    state.setAngular( true );
                }
            }
        }
    }

    function callExpressionExit( node ) {
        logLocation( node, 'exit' );
    }

    function functionDeclaration( node ) {
        logLocation( node );
        state.pushStack(node);
    }

    function functionDeclarationExit( node ) {
        logLocation( node, 'exit' );
        state.popStack();
    }

    function functionExpression( node ) {
        logLocation( node );
        state.pushStack(node);
    }

    function functionExpressionExit( node ) {
        logLocation( node, 'exit' );
        state.popStack();
    }

    function identifier( node ) {
        // logLocation( node );
    }

    function memberExpression( node ) {
        logLocation( node );
    }

    function memberExpressionExit( node ) {
        logLocation( node, 'exit' );
    }

    function program( node ) {
        logLocation( node );
        state = angularState(node);
    }

    function programExit( node ) {
        logLocation( node, 'exit' );
        state.popStack();
    }

    function returnStatement( node ) {
        logLocation( node );
        if ( state.isTopLevel() ) {
            switch ( node.argument.type ) {
                case 'ObjectExpression':
                    objectExpression( node.argument );
                    break;
                default:
                    context.report(
                        {
                            node:    node,
                            message: 'Expected function to return an ObjectExpression not ' + node.argument.type
                        } );
            }
        }
    }

    function returnStatementExit( node ) {
        logLocation( node, 'exit' );
    }

    return {
        CallExpression:             callExpression,
        'CallExpression:exit':      callExpressionExit,
        FunctionDeclaration:        functionDeclaration,
        'FunctionDeclaration:exit': functionDeclarationExit,
        FunctionExpression:         functionExpression,
        'FunctionExpression:exit':  functionExpressionExit,
        Identifier:                 identifier,
        MemberExpression:           memberExpression,
        'MemberExpression:exit':    memberExpressionExit,
        Program:                   program,
        'Program:exit':            programExit,
        ReturnStatement:            returnStatement,
        'ReturnStatement:exit':     returnStatementExit
    };
};
