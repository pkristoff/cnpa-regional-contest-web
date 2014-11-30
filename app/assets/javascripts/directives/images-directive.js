/**
 * Created by joeuser on 10/5/14.
 */

angular.module('cnpaContestApp')
    .directive('images', ['$http', 'fileImageService', '$location', function ($http, fileImageService, $location) {
        return {
            restrict: 'E',
            scope: {
                images: '=',
                contestName: '=',
                folder: '=',
                directories: '=',
                directory: '='
            },
            templateUrl: '/assets/javascripts/directives/images-template.html',
            link: function (scope) {
                scope.scopeName = 'images';

                function errorCallback($scope) {
                    return function (response) {
                        console.log("error " + response.status + ": " + response.data);
                        scope.errorMessages = [response.data];
                    }
                }

                // this is copied from CnpaContestController - need to merge
                function contestResult(response) {
                    if (response.status === 200) {
                        var result = response.data;
                        scope.images = fileImageService.updateFiles(result.filenames);
                        scope.directory = result.directory;
                        scope.directories = result.directories.map(function(dirName){
                            return {value: dirName, text: dirName};
                        });
                        $location.path("/contestFiles");
                    } else {
                        errorCallback(scope)(response);
                    }
                }

                scope.changeDirectory = function (select) {
                    $http.get('/directory?rootFolder=' + scope.folder + '&name=' + scope.contestName
                        + '&directory=' + select[select.value].text, {
                        "Content-Type": 'application/json'
                    }).then(contestResult, errorCallback(scope));
                };

                scope.deleteFile = function(fileInfo){

                    var params = {
                        rootFolder : scope.folder,
                        contestName : scope.contestName,
                        filename : fileInfo.filename.value,
                        directory : scope.directory,
                        authenticity_token: $('#mmm')[0].value
                    };

                    $http.post('/deleteFile', params, {"Content-Type": "application/json"}).then(
                        contestResult,
                        errorCallback(scope)
                    )
                };

                scope.setCopyright = function(fileInfo){

                    function setCopyrightResult(response) {
                        if (response.status === 200) {
                            fileInfo.copyrightNotice.value = response.data;
                            fileInfo.copyrightNotice.title = response.data;
                            fileInfo.copyrightNotice.valid = true;
                            $location.path("/contestFiles");
                        } else {
                            errorCallback(scope)(response);
                        }
                    }

                    if (! fileInfo.copyrightNotice.valid){

                        var dateSplit = fileInfo.dateCreated.value ? fileInfo.dateCreated.value.split(':') : [],
                            year = dateSplit && dateSplit.length > 0 ? dateSplit[0] : '2014',
                            copyrightNotice = "©" + " " + year + " " + fileInfo.contestantName.value;

                        var params = {
                            rootFolder : scope.folder,
                            contestName : scope.contestName,
                            copyright : copyrightNotice,
                            filename : fileInfo.filename.value,
                            authenticity_token: $('#mmm')[0].value
                        };

                        $http.post('/setCopyright', params, {"Content-Type": "application/json"}).then(
                            setCopyrightResult,
                            errorCallback(scope)
                        )
                    }
                };


                scope.uploadFile = function (files) {
                    var fd = new FormData();
                    fd.append("authenticity_token", $('#mmm')[0].value);
                    for (var i = 0, len = files.length; i < len; i++) {
                        fd.append('file' + i, files.item(i));
                    }
                    fd.append('rootFolder', scope.folder);
                    fd.append('name', scope.contestName);

                    $http.post('/addFiles', fd, {
                        withCredentials: true,
                        headers: {'Content-Type': undefined },
                        transformRequest: angular.identity,
                        multiple: true
                    }).then(function (response) {
                        var result = response.data;
                        scope.images = fileImageService.sortUpdatedFiles(fileImageService.updateFiles(result.filenames));
                    });

                }
            }
        };
    }]);