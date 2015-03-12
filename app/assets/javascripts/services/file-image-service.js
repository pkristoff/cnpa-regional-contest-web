/**
 * Created by joeuser on 10/5/14.
 */

angular.module( 'cnpaContestApp' )
    .service( 'fileImageService', [ function() {


        function isFileAgeValid( date, pictureAgeDate ) {
            if( pictureAgeDate && date ) {
                console.log('isFileAgeValid: found both');
                return date >= pictureAgeDate;
            } else {
                console.log('isFileAgeValid: not found both');
                console.log(date);
                console.log(pictureAgeDate);

                return !!date; // age is within limits.
            }
        }

        function isCopyrightValid( copyrightNotice ) {
            return !!copyrightNotice &&
                (copyrightNotice.indexOf( "©" ) >= 0 ||
                copyrightNotice.indexOf( "Copyright" ) >= 0);
        }

        function isDimensionValid( dim ) {
            return dim <= 1024;
        }

        function isFilenameValid( filename ) {
            var filenameSplit = filename.split( "-" );
            return filenameSplit.length == 2 && filenameSplit[ 0 ].length > 0 && filenameSplit[ 1 ].length > 0;
        }

        function isFileSizeValid( fileSize ) {
            return ((fileSize / 1024) <= 300);
        }

        function sortByKey( array, key ) {
            return array.sort( function( a, b ) {
                var x = a[ key ].value;
                var y = b[ key ].value;
                return ((x < y) ? -1 : ((x > y) ? 1 : 0));
            } );
        }

        function sortUpdatedFiles( updatedFiles ) {
            return sortByKey( updatedFiles, 'filename' );
        }

        function updateContest( response, vm ) {

            console.log( 'updateContest-result' );

            var result = response.data;
            console.log( result );
            var contest = vm.contest;
            contest.isPictureAgeRequired = result.isPictureAgeRequired;
            contest.pictureAgeDate = result.pictureAgeDate ? new Date( result.pictureAgeDate ) : new Date();
            contest.files = updateFiles( result.filenames, contest.pictureAgeDate );
            contest.directory = result.directory;
            contest.directories = result.directories.map( function( dirName ) {
                return { value: dirName, text: dirName };
            } );
            contest.email = result.email;
            contest.showGenerateContest = contest.files.length > 0 && contest.directories.length <= 2;
            contest.showRegenerateContest = contest.files.length > 0 && !contest.showGenerateContest;
            contest.showEmailContest = contest.directories.length > 2 && contest.email;
            console.log( 'updateContest-contest' );
            console.log( contest );
        }

        function updateFiles( rawFiles, pictureAgeDate ) {
            var files = [];
            rawFiles.forEach( function( fileEntry ) {
                var fn = fileEntry.filename;
                var fnSplit = fn.split( "-" );
                var date2 = fileEntry.dateCreated ? Date.parse( fileEntry.dateCreated ) : '';
                var newEntry = {
                    filename:        {
                        value: fn,
                        title: fn,
                        valid: true
                    },
                    contestantName:  {
                        value: fnSplit.length > 0 ? fnSplit[ 0 ].trim() : "",
                        title: fnSplit.length > 0 ? fnSplit[ 0 ].trim() : "",
                        valid: isFilenameValid( fn )
                    },
                    title:           {
                        value: fnSplit.length > 1 ? fnSplit[ 1 ].trim() : "",
                        title: fnSplit.length > 1 ? fnSplit[ 1 ].trim() : "",
                        valid: isFilenameValid( fn )
                    },
                    fileSize:        {
                        value: (fileEntry.fileSize),
                        title: (fileEntry.fileSize),
                        valid: isFileSizeValid( fileEntry.fileSize )
                    },
                    imageWidth:      {
                        value: fileEntry.imageWidth,
                        title: fileEntry.imageWidth,
                        valid: isDimensionValid( fileEntry.imageWidth )
                    },
                    imageHeight:     {
                        value: fileEntry.imageHeight,
                        title: fileEntry.imageHeight,
                        valid: isDimensionValid( fileEntry.imageHeight )
                    },
                    copyrightNotice: {
                        value: fileEntry.copyrightNotice,
                        title: fileEntry.copyrightNotice,
                        valid: isCopyrightValid( fileEntry.copyrightNotice )
                    },
                    dateCreated:     {
                        value: fileEntry.dateCreated,
                        title: fileEntry.dateCreated,
                        date: date2,
                        valid: isFileAgeValid( date2, pictureAgeDate )
                    }
                };
                files.push( newEntry );
            } );
            return sortUpdatedFiles( files );
        }

        return {
            updateFiles:       updateFiles,
            sortUpdatedFiles:  sortUpdatedFiles,
            updateContest:     updateContest,
            // testing only
            _isFileSizeValid:  isFileSizeValid,
            _isFilenameValid:  isFilenameValid,
            _isDimensionValid: isDimensionValid,
            _isCopyrightValid: isCopyrightValid,
            _isFileAgeValid:   isFileAgeValid
        }
    } ] );
