/**
 * @fileoverview Given a function it returns an object
 * @author Paul Kristoff
 */

'use strict';

//------------------------------------------------------------------------------
// Rule Definition
//------------------------------------------------------------------------------

module.exports = function ( context ) {
    return {
        'ReturnStatement:exit': function ( node ) {
            if ( node.argument.type !== 'ObjectExpression' ) {
                context.report( {
                                    node:    node,
                                    message: 'Expected function to return an object'
                                } );
            }
            else {
                var properties = node.argument.properties,
                    len        = properties.length;
                for ( var i = 0; i < len; i++ ) {
                    var property       = properties[ i ],
                        property_value = property.value;
                    switch ( property_value.type ) {
                        case 'Identifier':
                        case 'Literal':
                            break;
                        default:
                            context.report( {
                                                node:    property_value,
                                                message: 'Function cannot return property of type: ' + property_value.type
                                            } );
                            break;

                    }
                }

            }
        }
    };
};
// module.exports = {
//     meta:   {
//         docs: {
//             description: 'Given a function it returns an object expressions with only types:  '
//         }
//     },
//     schema: [
//         { enum: [ 'always', 'never' ] }
//     ],
//     create: function ( context ) {
//         return {
//             'ReturnStatement:exit': function ( node ) {
//                 if (node.argument.type !== 'ObjectExpression') {
//                     context.report( {
//                                         node:    node,
//                                         message: 'Expected function to return an object'
//                                     } );
//                 } else {
//                     var properties = node.argument.properties,
//                         len = properties.length;
//                     for (var i = 0; i < len; i++) {
//                         var property = properties[i],
//                             property_value = property.value;
//                         switch (property_value.type){
//                             case 'Identifier':
//                             case 'Literal':
//                                 break;
//                             default:
//                                 context.report( {
//                                                     node:    property_value,
//                                                     message: 'Function cannot return property of type: ' + property_value.type
//                                                 } );
//                                 break;
//
//                         }
//                     }
//
//                 }
//             }
//         };
//     }
// };