/**
 * Created by joeuser on 10/5/14.
 */

angular.module('cnpaContestApp')
    .directive('imagesDirective', ['$http', 'fileImageService', '$location', function($http, fileImageService, $location) {
        return {
            controller: 'imagesController',
            controllerAs: 'vm',
            restrict: 'E',
            scope: {
                contest: '='
            },
            templateUrl: '/assets/javascripts/directives/images/images-template.html',
            link: function(scope) {
                scope.vm.contest = scope.contest;
            }
        };
    }]);