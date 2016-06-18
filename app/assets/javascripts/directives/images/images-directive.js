/**
 * Created by joeuser on 10/5/14.
 */

angular.module('cnpaContestApp')
    .directive('imagesDirective', ['$http', 'fileImageService', '$location', function($http, fileImageService, $location) {

        function _link(scope) {
            scope.vm.contest = scope.contest;
        }
        
        return {
            controller: 'imagesController',
            controllerAs: 'vm',
            restrict: 'E',
            scope: {
                contest: '='
            },
            templateUrl: '/assets/javascripts/directives/images/images-template.html',
            link: _link
        };
    }]);