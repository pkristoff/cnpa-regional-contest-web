describe('file-image-service', function ( ) {

    var service;

    beforeEach(module('cnpaContestApp'));

    beforeEach(inject(function(fileImageService) {

        service = fileImageService;

    }));

    it('initialization', function () {
        expect(service.updateFiles).toBeDefined();
        expect(service.sortUpdatedFiles).toBeDefined();
        expect(service.updateContest).toBeDefined();

        // tests
        expect(service._isFileSizeValid).toBeDefined();
        expect(service._isFilenameValid).toBeDefined();
        expect(service._isDimensionValid).toBeDefined();
        expect(service._isCopyrightValid).toBeDefined();
        expect(service._isFileAgeValid).toBeDefined();

        expect(Object.keys(service).length).toBe(8);

    });


});