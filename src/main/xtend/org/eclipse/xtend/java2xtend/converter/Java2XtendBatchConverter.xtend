package org.eclipse.xtend.java2xtend.converter

import com.google.common.base.Predicate
import com.google.common.collect.Iterables
import com.google.common.collect.Lists
import com.google.inject.Inject
import com.google.inject.Provider
import java.nio.CharBuffer
import java.nio.charset.Charset
import java.nio.file.FileSystems
import java.nio.file.FileVisitResult
import java.nio.file.Files
import java.nio.file.Path
import java.nio.file.PathMatcher
import java.nio.file.Paths
import java.nio.file.SimpleFileVisitor
import java.nio.file.attribute.BasicFileAttributes
import java.util.HashMap
import java.util.List
import java.util.regex.Pattern
import org.eclipse.emf.common.util.URI
import org.eclipse.xtend.core.formatting2.XtendFormatter
import org.eclipse.xtend.core.formatting2.XtendFormatterPreferenceKeys
import org.eclipse.xtend.core.javaconverter.JavaConverter
import org.eclipse.xtend.core.xtend.XtendFile
import org.eclipse.xtend.java2xtend.config.formatting.XtendFormatterPreferencesReader
import org.eclipse.xtend.java2xtend.converter.Java2XtendBatchConverter.SkipValidation
import org.eclipse.xtend.lib.annotations.Accessors
import org.eclipse.xtext.diagnostics.Severity
import org.eclipse.xtext.formatting2.FormatterRequest
import org.eclipse.xtext.formatting2.regionaccess.ITextRegionAccess
import org.eclipse.xtext.formatting2.regionaccess.TextRegionAccessBuilder
import org.eclipse.xtext.preferences.MapBasedPreferenceValues
import org.eclipse.xtext.preferences.PreferenceKeysProvider
import org.eclipse.xtext.resource.XtextResource
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.util.CancelIndicator
import org.eclipse.xtext.util.ExceptionAcceptor
import org.eclipse.xtext.util.StringInputStream
import org.eclipse.xtext.validation.CheckMode
import org.eclipse.xtext.validation.Issue

import static java.lang.String.format
import static java.nio.charset.Charset.*
import static java.nio.charset.StandardCharsets.*
import static java.nio.file.FileVisitResult.*
import static java.nio.file.Files.*
import static java.nio.file.StandardCopyOption.*
import static org.eclipse.xtend.core.formatting2.XtendFormatterPreferenceKeys.*
import org.eclipse.xtend.java2xtend.converter.Java2XtendBatchConverter.SkipFormatting
import static org.eclipse.xtend.java2xtend.util.PathUtils.*
import java.util.Map
import org.slf4j.Logger
import org.slf4j.LoggerFactory

/*
 * Convert to Xtend all the Java files found under a list of source directories
 * 
 * 
 */
class Java2XtendBatchConverter implements Converter, BackupAndConvertConfig {

    static val BACKUP_NOT_INSIDE_SOURCE_MSG = "The configured backup path \"%s\" cannot be a child of the configured source directory \"%s\"."
    static val BACKUP_NOT_INSIDE_DESTINATION_MSG = "The configured backup path \"%s\" cannot be a child of the configured destination directory \"%s\"."
    static val COMMON_PARENT_PATH_REQUIRED_MSG = "All source folders and the output folder should have a common parent non-top level folder (like project folder)"
    static val COMMON_PARENT_PATH_REQUIRED_SOURCE_FOLDER_MSG = "(- source folder: '%s')"
    static val COMMON_PARENT_PATH_REQUIRED_OUTPUT_FOLDER_MSG = "(- output folder: '%s')"
    static val OPTION_ARCHIVE_IGNORED_MSG = "Option 'archive' has been ignored: Java files has been kept in place."
    static val JAVA_FILES_KEPT_IN_PLACE_MSG = "Original Java files are kept in place and Xtend files have been archived."
    static val NO_MORE_XTEND_OR_JAVA_IN_SOURCES_MSG = "Neither Xtend nor Java files are any more under any source directory."
    static val JAVA_AND_XTEND_UNDER_SAME_SOURCE_DIRS_MSG = "Java files has been kept and together with Xtend files are under some source directories."
    static val SOURCE_FOLDERS_MUST_BE_PROVIDED_MSG = "At least one source directory must be specified."
    static val BACKUP_DIR_OR_FILE_EXT_REQUIRED_MSG = "Either backup directory, backup file extension " +
        "or both must be provided when Xtend files are not put in an archive directory."

    static val DEFAULT_ENCODING = UTF_8

    protected static val extension Logger LOGGER = LoggerFactory.getLogger(Java2XtendBatchConverter)
    
    protected enum SkipFormatting {yes, no}
    protected enum SkipValidation {yes, no}

    @Inject 
    Provider<BackupAndConvert> backupAndConvertProvider

    @Accessors(PUBLIC_SETTER)
    String outputDirectory
    @Accessors(PUBLIC_SETTER, PRIVATE_GETTER)
    boolean archive
    @Accessors(PUBLIC_SETTER)
    String javaFileExtension
    @Accessors(PUBLIC_SETTER)
    String backupDirectory
    @Accessors
    String backupFileExtension
    @Accessors(PUBLIC_SETTER)
    String fileEncoding
    @Accessors(PUBLIC_SETTER)
    String preferences

    @Accessors(PUBLIC_GETTER)
    boolean isXtendGeneratedInPlace 
    @Accessors(PUBLIC_GETTER)
    boolean isOriginalFilesMoved
    @Accessors(PUBLIC_GETTER)
    SkipValidation skipValidation = SkipValidation.no 
    @Accessors(PUBLIC_GETTER)
    SkipFormatting skipFormatting = SkipFormatting.no 
    @Accessors(PUBLIC_GETTER)
    String originalFileExtension  
    @Accessors(PUBLIC_GETTER)
    Path outputDirectoryPath     
    @Accessors(PUBLIC_GETTER)
    Path backupDirectoryPath
    @Accessors(PUBLIC_GETTER)
    Charset encoding        
    @Accessors(PUBLIC_GETTER)
    Map<String, String> preferenceKeys

    val List<String> sourceDirectories = newArrayList
    List<Path> sourceDirectoryPaths
    boolean isWithJavaFileExtension
    boolean isWithBackupFileExtension 
    BackupAndConvert backupAndConvert
    PathMatcher originalFileMatcher
    
    override runConverter() {
        format("runConverter, outputDirectory: %s", outputDirectory).debug
        setConfigParams
        if (! checkConfiguration) {
            return false
        }
        backupAndConvert = backupAndConvertProvider.get.configure(this)
        convertJavaFiles
        true
    }

    override void addSourceDirectory(String path) {
        sourceDirectories.add(path)
    }
    
    override setSkipValidation(boolean skip) {
        skipValidation = if (skip) SkipValidation.yes else SkipValidation.no
    }
    
    override setSkipFormatting(boolean skip) {
        skipFormatting = if (skip) SkipFormatting.yes else SkipFormatting.no
    }
    
    private def setConfigParams() {
        isXtendGeneratedInPlace = outputDirectory === null
        isOriginalFilesMoved = backupDirectory !== null
        isWithJavaFileExtension = javaFileExtension !== null
        isWithBackupFileExtension = backupFileExtension !== null
        backupFileExtension = if (isWithBackupFileExtension && backupFileExtension.startsWith(FILE_EXTENSION_SEP)) {
            backupFileExtension.substring(FILE_EXTENSION_SEP.length)
        } else {
            backupFileExtension
        }
        originalFileExtension = if (isWithJavaFileExtension) {
            if (javaFileExtension.startsWith(FILE_EXTENSION_SEP)) {
                javaFileExtension.substring(FILE_EXTENSION_SEP.length)
            } else {
                javaFileExtension
            }
        } else {
            JAVA_FILE_EXTENSION
        }
        originalFileMatcher = FileSystems.getDefault.getPathMatcher(
            format(FILE_EXTENSION_MATCHER_PATTERN, FILE_EXTENSION_SEP + originalFileExtension))
        sourceDirectoryPaths = sourceDirectories.map[Paths.get(it).toAbsolutePath]
        outputDirectoryPath = if(isXtendGeneratedInPlace) null else Paths.get(outputDirectory).toAbsolutePath
        backupDirectoryPath = if(! isOriginalFilesMoved) null else Paths.get(backupDirectory).toAbsolutePath
        encoding = if (fileEncoding == null) {
            DEFAULT_ENCODING
        } else if (! isSupported(fileEncoding)) {
            format("Unknown encoding: %s. %s _used by default.", fileEncoding, DEFAULT_ENCODING).warn
            DEFAULT_ENCODING
        } else {
            forName(fileEncoding)
        }
        preferenceKeys = if (preferences === null) null 
        else {
            val preferencesPath = Paths.get(preferences).toAbsolutePath
            new XtendFormatterPreferencesReader().read(preferencesPath)
        }
    }

    // TODO: check if exists when preferencesPath is not null
    private def checkConfiguration() {
        if (sourceDirectories.empty) {
            SOURCE_FOLDERS_MUST_BE_PROVIDED_MSG.error
            return false
        }
        if ((isXtendGeneratedInPlace || ! isArchive ) && ! isOriginalFilesMoved && ! isWithBackupFileExtension) {
            BACKUP_DIR_OR_FILE_EXT_REQUIRED_MSG.error
            return false
        }
        if ((isXtendGeneratedInPlace || ! isArchive ) && isOriginalFilesMoved && ! isWithBackupFileExtension) {
            if (! checkBackupDirIsOutsideAnySourceDir) {
                JAVA_AND_XTEND_UNDER_SAME_SOURCE_DIRS_MSG.error
                if (isArchive) {
                    OPTION_ARCHIVE_IGNORED_MSG.error
                }
                return false
            }
        }
        if (! isXtendGeneratedInPlace && isArchive && isWithBackupFileExtension) {
            NO_MORE_XTEND_OR_JAVA_IN_SOURCES_MSG.warn
        } else if (outputDirectory !== null && isArchive && isOriginalFilesMoved && ! isWithBackupFileExtension) {
            if (! checkBackupDirIsOutsideAnySourceDir) {
                NO_MORE_XTEND_OR_JAVA_IN_SOURCES_MSG.warn
            }
        } else if (outputDirectory !== null && isArchive && ! isOriginalFilesMoved && ! isWithBackupFileExtension) {
            JAVA_FILES_KEPT_IN_PLACE_MSG.warn
        } else if (isXtendGeneratedInPlace && isArchive && isWithBackupFileExtension) {
            OPTION_ARCHIVE_IGNORED_MSG.warn
        }
        checkNotRootAsWorkspace
    }

    private def checkBackupDirIsOutsideAnySourceDir() {
        if (! isXtendGeneratedInPlace && ! isArchive &&
            isContainedIn(backupDirectoryPath.normalize, outputDirectoryPath.normalize)) {
            format(BACKUP_NOT_INSIDE_DESTINATION_MSG, backupDirectoryPath, outputDirectoryPath).error
            return false
        }
        for (sourceDirPath : sourceDirectoryPaths) {
            if (isContainedIn(backupDirectoryPath.normalize, sourceDirPath.normalize)) {
                format(BACKUP_NOT_INSIDE_SOURCE_MSG, backupDirectoryPath, sourceDirPath).error
                return false
            }
        }
        true
    }

    private def checkNotRootAsWorkspace() {
        // We don't want to use root ("/") as a workspace folder, didn't we?
        val commonRoot = determineCommonRoot(outputDirectoryPath, sourceDirectoryPaths)
        if (commonRoot === null || commonRoot.parent === null || commonRoot.parent.parent === null) {
            COMMON_PARENT_PATH_REQUIRED_MSG.error
            for (sourceDirPath : sourceDirectoryPaths) {
                format(COMMON_PARENT_PATH_REQUIRED_SOURCE_FOLDER_MSG, sourceDirPath).error
            }
            if (outputDirectoryPath !== null) {
                format(COMMON_PARENT_PATH_REQUIRED_OUTPUT_FOLDER_MSG, outputDirectoryPath).error
            }
            return false
        }
        true
    }

    private def void convertJavaFiles() {
        sourceDirectoryPaths.forEach[it.convertJavaFiles]
    }

    private def convertJavaFiles(Path sourceDirPath) {
        if (! isDirectory(sourceDirPath)) {
            format("Source should be a directory but is not: %s", sourceDirPath.toFile.name).error
            return
        }
        walkFileTree(sourceDirPath, new SimpleFileVisitor<Path>() {

            override FileVisitResult visitFile(Path source, BasicFileAttributes attrs) {
                if (source !== null && originalFileMatcher.matches(source)) {
                    backupAndConvert.run(source, sourceDirPath)
                }
                CONTINUE
            }

        });
    }

    private def determineCommonRoot(Path outputDirPath, List<Path> sourceDirList) {
        val dirList = newArrayList => [
            addAll(sourceDirList)
            if (outputDirPath !== null) {
                add(outputDirPath)
            }
        ]
        val commonRoot = determineCommonRoot(dirList)
        commonRoot
    }

    private def determineCommonRoot(List<Path> pathList) {
        val index = [ List<Path> paths |
            var k = -1
            // loop on the path parts; the common root can't be longer than the first path
            for (var j = 0; j < paths.get(0).getNameCount(); j++) {
                val part = paths.get(0).getName(j)
                for (var i = 1; i < paths.size; i++) { // loop on the paths, skipping the first path
                // return the current common path if one of the path is not longer than the current root
                // or as soon as two parts aren't the same
                    if (paths.get(i).nameCount < j || !paths.get(i).getName(j).equals(part)) {
                        return k
                    }
                }
                k = j
            }
            k
        ].apply(pathList)
        if(index < 0) return null
        val root = pathList.get(0).root
        val rel = pathList.get(0).subpath(0, index)
        root.resolve(rel)
    }

}    

package class BackupAndConvert {

    static val DUMMY_TMP_DEST_DIR = "target/tmp/"

    @Inject
    Provider<TextRegionAccessBuilder> regionBuilderProvider
    @Inject
    Provider<FormatterRequest> requestProvider
    @Inject
    Provider<JavaConverter> converterProvider
    @Inject
    Provider<XtendFormatter> formatterProvider
    @Inject
    Provider<XtextResourceSet> resourceSetProvider

    JavaConverter converter
    XtendFormatter formatter
    XtextResourceSet resourceSet

    int tmpFileNameSuffixGenerator = 0
 
        extension static val Logger LOGGER = Java2XtendBatchConverter.LOGGER

        extension var BackupAndConvertConfig batchConverter

        Path sourceDirPath

        public def configure(BackupAndConvertConfig batchConverter) {
            this.batchConverter = batchConverter
            this
        }

        public def run(Path source, Path sourceDirPath) {
            if (batchConverter === null) {
                throw new IllegalStateException("BackupAndConvert instance not configured yet.")
            }
            converter = converterProvider.get
            formatter = formatterProvider.get
            resourceSet = resourceSetProvider.get => [
                classpathURIContext = class.classLoader
            ]
            
            this.sourceDirPath = sourceDirPath

            val backupFilePath = moveToBackup(source)
            val javaCode = readJavaCode(backupFilePath)
            val xtendCode = converter.toXtend(getUnitNameFrom(source), javaCode)
            val xtendFormattedCode = formatXtendCode(xtendCode.xtendCode)
            val destFilePath = getXtendFilePathFrom(source)
            saveGeneratedCode(xtendFormattedCode, destFilePath)
        }

        private def formatXtendCode(String xtendCode) {
            if (skipFormatting === SkipFormatting.yes) {
                return xtendCode
            }
            try {
                val xtendFile = file(xtendCode, skipValidation)
                val resource = xtendFile.eResource as XtextResource
                val regionAccess = regionBuilderProvider.get.forNodeModel(resource).create
                val request = initRequest(regionAccess)
                val replacements = formatter.format(request)
                regionAccess.rewriter.renderToString(replacements)
            } catch (Exception e) {
                val msg = '''
                // Formatting step canceled due to an exception:
                «e.message.commentOut»
                Raw xtend code:
                «xtendCode»
                '''
                msg.error(e)
                msg
            } 
        }
        
        private def commentOut(String msg) {
            msg.replaceAll("?m^", "//")
        }

        private def URI getDummyFileUriFromCode(String codesource) {
            val packMatcher = Pattern.compile("package (\\S+)").matcher(codesource)
            val classMatcher = Pattern.compile("class (\\w+)").matcher(codesource)
            var filepath = if (packMatcher.find) {
                    packMatcher.group(1).replace('.', '/') + "/"
                } else {
                    ""
                }
            filepath += if (classMatcher.find) {
                classMatcher.group(1)
            } else {
                "Sample"
            }
            filepath += format("%6d", tmpFileNameSuffixGenerator++) + FILE_EXTENSION_SEP + XTEND_FILE_EXTENSION
            URI.createURI(DUMMY_TMP_DEST_DIR + filepath)
        }

        private def file(String codesource, SkipValidation skipValidation) throws Exception {
            val resource = resourceSet.createResource(getDummyFileUriFromCode(codesource))
            resource.load(new StringInputStream(codesource), null)
            if (resource.errors.size > 0) {
                val msg = format("Xtend generated file contains error(s): %s", resource.errors.map[message].join('\n'))
                msg.error
                throw new IllegalStateException(msg)
            } 
            if (skipValidation === SkipValidation.no) {
                val issues = Lists.newArrayList(
                    Iterables.filter(
                        (resource as XtextResource).resourceServiceProvider.resourceValidator.validate(resource,
                            CheckMode.ALL, CancelIndicator.NullImpl), new Predicate<Issue>() {
                            override apply(Issue issue) {
                                return issue.severity === Severity.ERROR
                            }
                        }))
                if (! issues.isEmpty) {
                    val msg = format("Resource contained error(s): %s", issues)
                    msg.error
                    throw new IllegalStateException(msg)
                }
            }
            resource.contents.get(0) as XtendFile
        }

        private def initRequest(ITextRegionAccess regionaccess) {
            extension val request = requestProvider.get
            allowIdentityEdits = false
            formatUndefinedHiddenRegionsOnly = false
            preferences = new MapBasedPreferenceValues(preferenceKeys?: defaultProfileSettings)
            textRegionAccess = regionaccess
            if (regionaccess.hasSyntaxError)
                exceptionHandler = ExceptionAcceptor.IGNORING
            else
                exceptionHandler = ExceptionAcceptor.LOGGING
        }

        private def getDefaultProfileSettings() {
            val keys = PreferenceKeysProvider.allConstantKeys(XtendFormatterPreferenceKeys)
            new HashMap<String, String> => [
                for (key : keys) {
                    put(key.id, key.defaultValue)
                }
                put(blankLinesBeforeFirstMember.id, String.valueOf(1))
            ]
        }
        
        private def void saveGeneratedCode(String xtendcode, Path dest) {
            val buffer = CharBuffer.wrap(xtendcode)
            val result = encoding.newEncoder.encode(buffer).array
            format("Generated Xtend file: %s", dest.normalize).info
            createDirectories(dest.parent)
            write(dest, result)
        }

        private def getXtendFilePathFrom(Path source) {
            getDestinationFileFrom(
                source,
                outputDirectoryPath,
                isXtendGeneratedInPlace,
                XTEND_FILE_EXTENSION
            )
        }

        private def getUnitNameFrom(Path source) {
            extension val fileName = source.fileName.toString
            substring(0, length - originalFileExtension.length - FILE_EXTENSION_SEP.length)
        }

        private def readJavaCode(Path source) {
            new String(readAllBytes(source), encoding)
        }

        private def getDestinationFileFrom(Path source, Path dest, boolean inPlace, String fileExtension) {
            var destFileName = source.fileName.toString
            format("File extension: %s", fileExtension).debug
            if (fileExtension !== null) {
                destFileName = destFileName.replaceFirst(originalFileExtension + '$', fileExtension)
            }
            format("File name: %s (%s)", destFileName, originalFileExtension).debug
            var destFilePath = source.parent
            if (! inPlace) {
                val packagepath = sourceDirPath.relativize(destFilePath)
                val destparent = dest.resolve(packagepath)
                val movepath = destFilePath.relativize(destparent)
                destFilePath = destFilePath.resolve(movepath)
            }
            destFilePath.resolve(destFileName)
        }

        private def moveToBackup(Path source) {
            format("Backup file: %s", backupDirectoryPath).debug
            val backupFilePath = getDestinationFileFrom(
                source,
                backupDirectoryPath,
                ! isOriginalFilesMoved,
                backupFileExtension
            )
            format("Backup file: %s", backupFilePath.normalize).info
            Files.createDirectories(backupFilePath.parent)
            move(source, backupFilePath, ATOMIC_MOVE)
        }
}
    
package interface BackupAndConvertConfig {
    
    def String getOriginalFileExtension()
    
    def String getBackupFileExtension()
    
    def boolean isOriginalFilesMoved()
    
    def boolean isXtendGeneratedInPlace()
    
    def SkipValidation getSkipValidation()
    
    def SkipFormatting getSkipFormatting()
    
    def Path getOutputDirectoryPath()
    
    def Path getBackupDirectoryPath()
    
    def Charset getEncoding()
    
    def Map<String, String> getPreferenceKeys()
    
}

interface Converter {
    
    def boolean runConverter()

    def void addSourceDirectory(String path)

    def void setArchive(boolean isArchive)

    def void setFileEncoding(String enc)

    def void setOutputDirectory(String path)

    def void setJavaFileExtension(String ext)

    def void setBackupDirectory(String path)

    def void setBackupFileExtension(String ext)
    
    def void setSkipFormatting(boolean skip)
    
    def void setSkipValidation(boolean skip)
    
    def void setPreferences(String path)
    
}