/**
 * Created by joeuser on 10/5/14.
 */

angular.module('cnpaContestApp')
    .service('fileImageService', [function () {


        function isFileAgeValid(date, isPictureAgeRequired, pictureAgeDate) {
            if (isPictureAgeRequired && pictureAgeDate && date) {
                return date >= pictureAgeDate;
            } else {
                // if cannot find date and/or pictureAgeDate then valid only if not required.
                return !isPictureAgeRequired;
            }
        }

        function isCopyrightValid(copyrightNotice) {
            return !!copyrightNotice &&
                (copyrightNotice.indexOf("©") >= 0 ||
                copyrightNotice.indexOf("Copyright") >= 0);
        }

        function isFilenameValid(filename) {
            var filenameSplit = filename.split("-");
            return filenameSplit.length == 2 && filenameSplit[0].length > 0 && filenameSplit[1].length > 0;
        }

        function sortByKey(array, key) {
            return array.sort(function (a, b) {
                var x = a[key].value;
                var y = b[key].value;
                return ((x < y) ? -1 : ((x > y) ? 1 : 0));
            });
        }

        function sortUpdatedFiles(updatedFiles) {
            return sortByKey(updatedFiles, 'filename');
        }

        function updateContest(response, vm) {

            console.log('updateContest-result');

            var result = response.data;
            console.log(result);
            var contest                   = vm.contest;
            contest.max_size              = result.max_size;
            contest.max_width             = result.max_width;
            contest.max_height            = result.max_height;
            contest.isPictureAgeRequired  = result.isPictureAgeRequired;
            contest.pictureAgeDate        = result.pictureAgeDate ? new Date(result.pictureAgeDate) : new Date();
            contest.files                 = updateFiles(result.filenames, contest.isPictureAgeRequired, contest.pictureAgeDate,
                contest.max_size, contest.max_width, contest.max_height);
            contest.directory             = result.directory;
            contest.directories           = result.directories.map(function (dirName) {
                return {value: dirName, text: dirName};
            });
            contest.showGenerateContest   = contest.files.length > 0 && contest.directories.length <= 2;
            contest.showRegenerateContest = contest.files.length > 0 && !contest.showGenerateContest;
            contest.showDownloadContest   = contest.files.length > 0 && contest.directories.length > 2;
            console.log('updateContest-contest');
            console.log(contest);
        }

        function updateFiles(rawFiles, isPictureAgeRequired, pictureAgeDate, max_size, max_width, max_height) {
            var files = [];
            rawFiles.forEach(function (fileEntry) {
                var fn           = fileEntry.filename;
                var rootFilename = fn.split('.');
                var fnSplit      = rootFilename[0].split("-");
                var date2        = fileEntry.dateCreated ? Date.parse(fileEntry.dateCreated) : '';
                console.log(fn, max_height)
                var newEntry     = {
                    filename:        {
                        value: fn,
                        title: fn,
                        valid: true
                    },
                    contestantName:  {
                        value: fnSplit.length > 0 ? fnSplit[0].trim() : "",
                        title: fnSplit.length > 0 ? fnSplit[0].trim() : "",
                        valid: isFilenameValid(fn)
                    },
                    title:           {
                        value: fnSplit.length > 1 ? fnSplit[1].trim() : "",
                        title: fnSplit.length > 1 ? fnSplit[1].trim() : "",
                        valid: isFilenameValid(fn)
                    },
                    fileSize:        {
                        value: (fileEntry.fileSize),
                        title: (fileEntry.fileSize),
                        valid: fileEntry.fileSize <= max_size
                    },
                    imageWidth:      {
                        value: fileEntry.imageWidth,
                        title: fileEntry.imageWidth,
                        valid: fileEntry.imageWidth <= max_width
                    },
                    imageHeight:     {
                        value: fileEntry.imageHeight,
                        title: fileEntry.imageHeight,
                        valid: fileEntry.imageHeight <= max_height
                    },
                    copyrightNotice: {
                        value: fileEntry.copyrightNotice,
                        title: fileEntry.copyrightNotice,
                        valid: isCopyrightValid(fileEntry.copyrightNotice)
                    },
                    dateCreated:     {
                        value: fileEntry.dateCreated,
                        title: fileEntry.dateCreated,
                        date:  date2,
                        valid: isFileAgeValid(date2, isPictureAgeRequired, pictureAgeDate)
                    }
                };
                files.push(newEntry);
            });
            return sortUpdatedFiles(files);
        }

        return {
            sortUpdatedFiles:  sortUpdatedFiles,
            updateContest:     updateContest,
            // testing only
            _isFilenameValid:  isFilenameValid,
            _isCopyrightValid: isCopyrightValid,
            _isFileAgeValid:   isFileAgeValid
        }
    }]);
