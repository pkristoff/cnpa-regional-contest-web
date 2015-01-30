/**
 * Created by joeuser on 1/30/15.
 */


angular.module('cnpaContestApp')
    .controller('imagesController', ['$scope', '$http', 'fileImageService', '$location',
        function($scope, $http, fileImageService, $location) {

            var vm = this;


            // this is copied from CnpaContestController - need to merge
            function contestResult(response) {
                if(response.status === 200) {
                    var result = response.data;
                    vm.images = fileImageService.updateFiles(result.filenames);
                    vm.directory = result.directory;
                    vm.directories = result.directories.map(function(dirName) {
                        return {value: dirName, text: dirName};
                    });
                    $location.path("/contestFiles");
                } else {
                    errorCallback($scope)(response);
                }
                hideBusy();
            }

            function deleteFile(fileInfo) {
                showBusy();
                var params = {
                    rootFolder: vm.folder,
                    contestName: vm.contestName,
                    filename: fileInfo.filename.value,
                    directory: vm.directory,
                    authenticity_token: $('#mmm')[0].value
                };

                $http.post('/deleteFile', params, {"Content-Type": "application/json"}).then(
                    contestResult,
                    errorCallback($scope)
                )
            }

            function errorCallback(scope) {
                return function(response) {
                    console.log("error " + response.status + ": " + response.data);
                    scope.errorMessages = [response.data];
                    hideBusy();
                }
            }

            function hideBusy() {
                $scope.isLoading = false;
            }

            function showBusy() {
                $scope.isLoading = true;
            }

            //API
            vm.deleteFile = deleteFile;

            //_.assign(vm, {
            //    deleteFile: deleteFile
            //});

        }]);

