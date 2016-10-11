angular.module('cnpaContestApp', [
  'ngTouch',
  'ngRoute',
  'ui.bootstrap'
]).
config(['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
    $routeProvider.when("/chooseContest", {templateUrl: "views/partials/chooseContest.html"})
    $routeProvider.when("/contestFiles", {templateUrl: "views/partials/contestFiles.html"})
    $routeProvider.otherwise({redirectTo: "/chooseContest"})
  ]).
factory('$exceptionHandler', () ->
  return (exception, cause) ->
    alert('see console browser for more info: ' + exception.message)
    console.log(exception.message)
    console.log(exception.stack)
)