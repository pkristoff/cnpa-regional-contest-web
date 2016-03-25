/**
 * Created by joeuser on 1/30/15.
 */


angular.module( 'cnpaContestApp' )
    .controller( 'imagesController', [
        '$scope', '$http', 'fileImageService', '$location', '$modal',
        function ( $scope, $http, fileImageService, $location, $modal ) {

            var vm = this;


            function changeDirectory() {
                showBusy();
                $http.get( '/directory?rootFolder=' + vm.contest.rootFolder + '&name=' + vm.contest.name
                           + '&directory=' + vm.contest.directory, {
                    "Content-Type": 'application/json'
                } ).then( contestResult, errorCallback( $scope ) );
            }

            // this is copied from CnpaContestController - need to merge
            function contestResult( response ) {
                if ( response.status === 200 ) {
                    fileImageService.updateContest( response, vm );
                    $location.path( "/contestFiles" );
                }
                else {
                    errorCallback( $scope )( response );
                }
                hideBusy();
            }

            function deleteFile( fileInfo ) {
                showBusy();
                var params = {
                    rootFolder:         vm.contest.rootFolder,
                    contestName:        vm.contest.name,
                    filename:           fileInfo.filename.value,
                    directory:          vm.contest.directory,
                    authenticity_token: $( '#mmm' )[ 0 ].value
                };

                $http.post( '/deleteFile', params, { "Content-Type": "application/json" } ).then(
                    contestResult,
                    errorCallback( $scope )
                )
            }

            function errorCallback( scope ) {
                return function ( response ) {
                    console.log( "error " + response.status + ": " + response.data );
                    scope.errorMessages = [ response.data ];
                    hideBusy();
                }
            }

            function generateContest() {
                showBusy();
                var params = {
                    rootFolder:         vm.contest.rootFolder,
                    contestName:        vm.contest.name,
                    authenticity_token: $( '#mmm' )[ 0 ].value
                };

                $http.post( '/generateContest', params, { "Content-Type": "application/json" } ).then(
                    contestResult,
                    errorCallback( $scope )
                )

            }

            function regenerateContest() {
                showBusy();
                var params = {
                    rootFolder:         vm.contest.rootFolder,
                    contestName:        vm.contest.name,
                    authenticity_token: $( '#mmm' )[ 0 ].value
                };

                $http.post( '/regenerateContest', params, { "Content-Type": "application/json" } ).then(
                    contestResult,
                    errorCallback( $scope )
                )

            }

            function emailContest() {
                showBusy();
                var params = {
                    rootFolder:         vm.contest.rootFolder,
                    contestName:        vm.contest.name,
                    emailAddress:       vm.contest.email,
                    authenticity_token: $( '#mmm' )[ 0 ].value
                };

                $http.post( '/email_contest', params, { "Content-Type": "application/json" } ).then(
                    contestResult,
                    errorCallback( $scope )
                )

            }

            function hideBusy() {
                $scope.isLoading = false;
            }

            function openDate( $event ) {
                $event.preventDefault();
                $event.stopPropagation();

                vm.dateOpened = true;
            }

            function rename_file( old_filename ) {

                var filename = {
                    original:       old_filename.filename.value,
                    contestantName: old_filename.contestantName.value,
                    imageTitle:     old_filename.title.value
                };
                console.log( $scope.filename );

                var modalInstance = $modal.open( {
                    templateUrl: '/assets/javascripts/directives/rename-file/rename-file-template.html',
                    controller:  'renameFileController',
                    resolve:     {
                        filename: function () {
                            return filename;
                        }
                    }
                } );

                modalInstance.result.then( function ( newFileName ) {
                    var params = {
                        rootFolder:         vm.contest.rootFolder,
                        contestName:        vm.contest.name,
                        old_filename:       old_filename.filename.value,
                        new_filename:       newFileName.contestantName + "-" + newFileName.imageTitle + ".jpg",
                        directory:          vm.contest.directory,
                        authenticity_token: $( '#mmm' )[ 0 ].value
                    };

                    $http.post( '/rename_file', params, { "Content-Type": "application/json" } ).then(
                        contestResult,
                        errorCallback( $scope )
                    )
                }, function () {
                    console.log( 'Modal dismissed at: ' + new Date() );
                } );

            }

            function setCopyright( fileInfo ) {

                function setCopyrightResult( response ) {
                    if ( response.status === 200 ) {
                        fileInfo.copyrightNotice.value = response.data;
                        fileInfo.copyrightNotice.title = response.data;
                        fileInfo.copyrightNotice.valid = true;
                        $location.path( "/contestFiles" );
                    }
                    else {
                        errorCallback( $scope )( response );
                    }

                    hideBusy();
                }

                showBusy();

                var dateSplit       = fileInfo.dateCreated.value ? fileInfo.dateCreated.value.split( ':' ) : [],
                    year            = dateSplit && dateSplit.length > 0 ? dateSplit[ 0 ].split( '-' )[ 0 ] : '2015',
                    copyrightNotice = "©" + " " + year + " " + fileInfo.contestantName.value;

                var params = {
                    rootFolder:         vm.contest.rootFolder,
                    contestName:        vm.contest.name,
                    copyright:          copyrightNotice,
                    filename:           fileInfo.filename.value,
                    authenticity_token: $( '#mmm' )[ 0 ].value
                };

                $http.post( '/setCopyright', params, { "Content-Type": "application/json" } ).then(
                    setCopyrightResult,
                    errorCallback( $scope )
                )
            }

            function showBusy() {
                $scope.isLoading = true;
            }

            function saveConfigInfo() {
                var params = {
                    rootFolder:           vm.contest.rootFolder,
                    contestName:          vm.contest.name,
                    email:                vm.contest.email,
                    pictureAgeDate:       vm.contest.pictureAgeDate,
                    isPictureAgeRequired: vm.contest.isPictureAgeRequired,
                    directory:            vm.contest.directory,
                    authenticity_token:   $( '#mmm' )[ 0 ].value
                };


                $http.post( '/saveConfigInfo', params, { "Content-Type": "application/json" } ).then(
                    contestResult,
                    errorCallback( $scope )
                )
            }

            function isPictureAgeRequiredClicked() {
                vm.contest.isPictureAgeRequired = !vm.contest.isPictureAgeRequired;
                saveConfigInfo();
            }

            function uploadFile( files ) {
                showBusy();
                var fd = new FormData();
                fd.append( "authenticity_token", $( '#mmm' )[ 0 ].value );
                for ( var i = 0, len = files.length; i < len; i++ ) {
                    fd.append( 'file' + i, files.item( i ) );
                }
                fd.append( 'rootFolder', vm.contest.directory );
                fd.append( 'name', vm.contest.name );

                $http.post( '/addFiles', fd, {
                    withCredentials:  true,
                    headers:          { 'Content-Type': undefined },
                    transformRequest: angular.identity,
                    multiple:         true
                } ).then(
                    contestResult,
                    errorCallback( $scope )
                );

            }

            //API
            vm.changeDirectory = changeDirectory;
            vm.dateOptions = {
                formatYear:  'yy',
                startingDay: 0
            };
            vm.deleteFile = deleteFile;
            vm.emailContest = emailContest;
            vm.generateContest = generateContest;
            vm.isPictureAgeRequiredClicked = isPictureAgeRequiredClicked;
            vm.openDate = openDate;
            vm.regenerateContest = regenerateContest;
            vm.rename_file = rename_file;
            vm.setCopyright = setCopyright;
            vm.saveConfigInfo = saveConfigInfo;
            vm.uploadFile = uploadFile;

        } ] );

