'use strict';

/**
 * @ngdoc function
 * @name cnpaContestApp.controller:CnpaContestController
 * @description
 * # CnpaContestController
 * Controller of the cnpaContestApp
 */
angular.module('cnpaContestApp')
    .controller('CnpaContestController', ['$scope', '$http', '$location', 'fileImageService', '$modal',
        function($scope, $http, $location, fileImageService, $modal) {
            var modal;
            //hideBusy();
            if($scope.contest == undefined) {
                $scope.contest = {
                    rootFolder: 'Contests',
                    name: '',
                    pictureAge: false,
                    pictureAgeDate: new Date(),
                    contests: [], //{rootFolder: '', name: ''}
                    directories: []  // name of directories
                };
            }
            getContests();

            function errorCallback($scope) {
                return function(response) {
                    var message = "error " + response.status + ": " + response.data.message;
                    console.log(message);
                    alert(message);
                    $scope.errorMessages = message;
                    hideBusy();
                }
            }

            function showBusy() {
                $scope.isLoading = true;
            }

            function hideBusy() {
                $scope.isLoading = false;
            }

            function getContestsResult(response) {
                console.log(response);
                if(response.status === 200) {
                    $scope.contest.contests = [];
                    response.data.forEach(function(contestName, index) {
                        if(index === 0) {  // select first contest by default
                            $scope.contest.name = contestName;
                        }
                        $scope.contest.contests.push({rootFolder: $scope.contest.rootFolder, name: contestName});
                    });
                    if($scope.contest.contests.length > 0) {
                        $scope.radioModel = 'existing-contest';
                    } else {
                        $scope.radioModel = 'new-contest';
                    }
                    $location.path("/chooseContest");
                    hideBusy();
                    return (response.data);
                } else {
                    errorCallback($scope)(response);
                }
                hideBusy();
            }

            function getAuthenticationToken() {
                return $('#mmm')[0].value;
            }

            function getContests() {
                showBusy();


                $scope.contest.authenticity_token = getAuthenticationToken();

                $http.post('/getContests', $scope.contest, {
                    "authenticity_token": getAuthenticationToken(),
                    "Content-Type": "application/json"
                }).then(
                    getContestsResult,
                    errorCallback($scope)
                );
            }

            function contestResult(response) {
                if(response.status === 200) {
                    fileImageService.updateContest(response, $scope);

                    $location.path("/contestFiles");
                } else {
                    errorCallback($scope)(response);
                }
                hideBusy();
            }

            function createContest() {
                if($scope.contest.name.indexOf(' ') > -1) {
                    window.alert('contest name cannot contain a space: ' + $scope.contest.name);
                } else {
                    showBusy();
                    //$scope.contest.authenticity_token = getAuthenticationToken();

                    $http.post('/createContest', $scope.contest, {"Content-Type": "application/json"}).then(
                        contestResult,
                        errorCallback($scope)
                    )
                }
            }

            function deleteContest() {

                showBusy();
                $scope.contest.authenticity_token = getAuthenticationToken();
                $http.post('/deleteContest?contestName=' + $scope.contest.name, {
                    "authenticity_token": getAuthenticationToken(),
                    "Content-Type": "application/json"
                }).then(
                    getContestsResult,
                    errorCallback($scope)
                )
            }

            function selectContest() {

                showBusy();
                $http.get('/contest?rootFolder=' + $scope.contest.rootFolder + "&name=" + $scope.contest.name, {
                    "Content-Type": "application/json"
                }).then(
                    contestResult,
                    errorCallback($scope)
                )
            }


            $scope.createContest = createContest;
            $scope.deleteContest = deleteContest;
            $scope.getContests = getContests;
            $scope.selectContest = selectContest;
            // test
            $scope._errorCallback = errorCallback;
            $scope._getContestsResult = getContestsResult;
            $scope._contestResult = contestResult;

        }]);
