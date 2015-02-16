angular.module('cnpaContestApp')
    .service('renameFileService', ['$modal',
        function($modal) {

            var modalDefaults = {
                backdrop: true,
                keyboard: true,
                modalFade: true,
                templateUrl: 'rename-file-template.html'
            };

            var modalOptions = {
                closeButtonText: 'Cancel',
                actionButtonText: 'Rename',
                headerText: 'Rename File',
                bodyText: 'Perform this action?'
            };

            this.showModal = function(customModalDefaults, F) {
                if(!customModalDefaults) {
                    customModalDefaults = modalDefaults;
                }
                return this.show(customModalDefaults, modalOptions);
            };

            this.show = function(customModalDefaults, customModalOptions) {
                //Create temp objects to work with since we're in a singleton service
                var tempModalDefaults = {};
                var tempModalOptions = {};

                //Map angular-ui modal custom defaults to modal defaults defined in service
                angular.extend(tempModalDefaults, modalDefaults, customModalDefaults);

                //Map rename-file-template.html $scope custom properties to defaults defined in service
                angular.extend(tempModalOptions, modalOptions, customModalOptions);

                if(!tempModalDefaults.controller) {
                    tempModalDefaults.controller = function($scope, $modalInstance) {
                        $scope.modalOptions = tempModalOptions;
                        $scope.modalOptions.ok = function(result) {
                            $modalInstance.close($scope.fileName);
                        };
                        $scope.modalOptions.close = function(result) {
                            $modalInstance.dismiss('cancel');
                        };
                    }
                }

                return $modal.open(tempModalDefaults).result;
            };

        }]);