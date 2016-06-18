// for testint only - real code is in app.coffee
angular.module( 'cnpaContestApp', [
    'ngTouch',
    'ngRoute',
    'ui.bootstrap'
] )
    .config( [ '$routeProvider', '$locationProvider', function ( $routeProvider, $locationProvider ) {
//    $locationProvider.html5Mode({enabled: true, requireBase: false})
    $routeProvider.when( '/chooseContest', { templateUrl: 'views/partials/chooseContest.html' } );
    $routeProvider.when( '/contestFiles', { templateUrl: 'views/partials/contestFiles.html' } );
    $routeProvider.otherwise( { redirectTo: '/chooseContest' } );
}
            ] )
    .factory( '$exceptionHandler', function () {
                  return function ( exception, cause ) {
                      alert( exception.message );
                      alert( exception.stack );
                      console.log( exception.message );
                      console.log( exception.stack );
                      $rootScope.errorMessages = [ exception.message ];
                  };
              }
    );
