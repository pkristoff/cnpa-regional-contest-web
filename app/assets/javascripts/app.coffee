
angular.module('cnpaContestApp', [
    'ngTouch',
    'ngRoute'
  ]).
  config(['$routeProvider', '$locationProvider', ($routeProvider, $locationProvider) ->
#    $locationProvider.html5Mode({enabled: true, requireBase: false})
    $routeProvider.when("/chooseContest", { templateUrl: "views/partials/chooseContest.html" })
    $routeProvider.when("/contestFiles", { templateUrl: "views/partials/contestFiles.html" })
    $routeProvider.otherwise( { redirectTo: "/chooseContest" })
  ]).
  factory('$exceptionHandler',  () ->
    return (exception, cause) ->
      alert(exception.message)
      console.log(exception.message)
      console.log(exception.stack)
  )