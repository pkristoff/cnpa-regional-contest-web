/**
 * Created by joeuser on 3/12/15.
 */

angular.module('cnpaContestApp')
    .controller('renameFileController', ['$scope',
        function($scope, filename) {
            $scope.filename = filename;

            $scope.ok = function () {
                $modalInstance.close($scope.filename);
            };

            $scope.cancel = function () {
                $modalInstance.dismiss('cancel');
            };

        }]
);