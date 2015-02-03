/**
 * Created by joeuser on 1/30/15.
 */


angular.module('cnpaContestApp')
    .controller('imagesController', ['$scope', '$http', 'fileImageService', '$location',
        function($scope, $http, fileImageService, $location) {

            var vm = this;


            function changeDirectory(select) {
                showBusy();
                $http.get('/directory?rootFolder=' + vm.contest.rootFolder + '&name=' + vm.contest.name
                + '&directory=' + vm.contest.directory, {
                    "Content-Type": 'application/json'
                }).then(contestResult, errorCallback($scope));
            }

            // this is copied from CnpaContestController - need to merge
            function contestResult(response) {
                if(response.status === 200) {
                    var result = response.data;
                    vm.contest.files = fileImageService.updateFiles(result.filenames);
                    vm.contest.directory = result.directory;
                    vm.contest.directories = result.directories.map(function(dirName) {
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
                    rootFolder: vm.contest.rootFolder,
                    contestName: vm.contest.name,
                    filename: fileInfo.filename.value,
                    directory: vm.contest.directory,
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

            function openDate($event) {
                $event.preventDefault();
                $event.stopPropagation();

                vm.dateOpened = true;
            }

            function setCopyright(fileInfo) {

                function setCopyrightResult(response) {
                    if(response.status === 200) {
                        fileInfo.copyrightNotice.value = response.data;
                        fileInfo.copyrightNotice.title = response.data;
                        fileInfo.copyrightNotice.valid = true;
                        $location.path("/contestFiles");
                    } else {
                        errorCallback($scope)(response);
                    }

                    hideBusy();
                }

                showBusy();

                if(!fileInfo.copyrightNotice.valid) {

                    var dateSplit = fileInfo.dateCreated.value ? fileInfo.dateCreated.value.split(':') : [],
                        year = dateSplit && dateSplit.length > 0 ? dateSplit[0] : '2014',
                        copyrightNotice = "©" + " " + year + " " + fileInfo.contestantName.value;

                    var params = {
                        rootFolder: vm.contest.rootFolder,
                        contestName: vm.contest.name,
                        copyright: copyrightNotice,
                        filename: fileInfo.filename.value,
                        authenticity_token: $('#mmm')[0].value
                    };

                    $http.post('/setCopyright', params, {"Content-Type": "application/json"}).then(
                        setCopyrightResult,
                        errorCallback($scope)
                    )
                } else {
                    hideBusy();
                }
            }

            function showBusy() {
                $scope.isLoading = true;
            }

            function uploadFile(files) {
                showBusy();
                var fd = new FormData();
                fd.append("authenticity_token", $('#mmm')[0].value);
                for(var i = 0, len = files.length; i < len; i++) {
                    fd.append('file' + i, files.item(i));
                }
                fd.append('rootFolder', vm.contest.directory);
                fd.append('name', vm.contest.name);

                $http.post('/addFiles', fd, {
                    withCredentials: true,
                    headers: {'Content-Type': undefined},
                    transformRequest: angular.identity,
                    multiple: true
                }).then(function(response) {
                    var result = response.data;
                    vm.contest.files = fileImageService.sortUpdatedFiles(fileImageService.updateFiles(result.filenames));
                    hideBusy();
                });

            }

            //API
            vm.changeDirectory = changeDirectory;
            vm.dateOptions = {
                formatYear: 'yy',
                startingDay: 0
            };
            vm.deleteFile = deleteFile;
            vm.openDate = openDate;
            vm.setCopyright = setCopyright;
            vm.uploadFile = uploadFile;

        }]);

