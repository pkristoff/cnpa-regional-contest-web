/**
 * Created by joeuser on 3/12/15.
 */

angular.module('cnpaContestApp')
    .controller('renameFileController', ['$scope', 'filename',
        function($scope, filename) {
            $scope.filename = filename;

            $scope.ok = function () {
                $scope.$close($scope.filename);
            };

            $scope.cancel = function () {
                $scope.$dismiss('cancel');
            };

            console.log('renameFileController: $scope=');
            console.log($scope);


        }]
);