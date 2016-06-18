describe('images-controller', function ( ) {

    var scope, controller;

    beforeEach(module('cnpaContestApp'));

    beforeEach(inject(function($rootScope, $controller, $http, fileImageService, $location) {

        scope = $rootScope.$new();
        controller = $controller('imagesController', {
            $scope: scope,
            $location: $location,
            fileImageService: fileImageService,
            $modal: {open: function (){}}
        });
    }));

    it('initialization', function (){
        expect(controller.changeDirectory).toBeDefined();
        expect(controller.dateOptions).toBeDefined();
        expect(controller.dateOptions.formatYear).toEqual('yy');
        expect(controller.dateOptions.startingDay).toEqual(0);
        expect(controller.deleteFile).toBeDefined();
        expect(controller.generateContest).toBeDefined();
        expect(controller.isPictureAgeRequiredClicked).toBeDefined();
        expect(controller.openDate).toBeDefined();
        expect(controller.regenerateContest).toBeDefined();
        expect(controller.rename_file).toBeDefined();
        expect(controller.setCopyright).toBeDefined();
        expect(controller.saveConfigInfo).toBeDefined();
        expect(controller.uploadFile).toBeDefined();

        expect(Object.keys(controller).length).toBe(11);
    });
});