package org.eclipse.xtend.core.tests.javaconverter

import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.xtend.core.tests.AbstractXtendTestCase
import org.eclipse.xtend.java2xtend.converter.Java2XtendBatchConverter
import org.eclipse.xtend.java2xtend.util.PathUtils.FileExtension
import org.junit.Before
import org.junit.Test

import static org.eclipse.xtend.java2xtend.util.PathUtils.*

/*
 * Use of Java2XtendBatchConverter. Integration tests: this series only checks 
 * the locations and names of source, backup and xtend generated files. 
 * 
 * TODO move this class in some specific integration test folder.
 * 
 */
class JavaConverterSeries3Test extends AbstractXtendTestCase {
    
    static val JAVA_SOURCE_DIR1 = "src/test/data1"
    static val JAVA_SOURCE_DIR3 = "src/test/data3"
    static val BASE_TMP_DIR = "target/xtend-test/series3/"
    
    @Inject 
    Provider<Java2XtendBatchConverter> javaConverterProvider

    extension Java2XtendBatchConverter j2x
    
    @Before 
    def void setUp() {
        j2x = javaConverterProvider.get() 
    }
    
    @Test 
    def void testKeepJavaFilesInPlaceAndArchiveXtendFilesCase() {
        val sourcedir = JAVA_SOURCE_DIR3
        val outputdir = BASE_TMP_DIR
        deleteDirectory(outputdir)
        
        addSourceDirectory(sourcedir)
        archive = true
        outputDirectory = outputdir
        runConverter
        
        val javaFilesNumber = retrieveFileList(sourcedir, FileExtension.java).size
        val xtendFilesNumber = retrieveFileList(outputdir, FileExtension.xtend).size
        assertTrue("There should be at least one java file.", javaFilesNumber > 0)
        assertTrue("There should be at least one xtend file.", xtendFilesNumber > 0)
        assertTrue("There should be the same number of Java and Xtend files.", javaFilesNumber == xtendFilesNumber)
    }
    
    @Test 
    def void testBackupJavaFilesAndPutXtendFilesInPlaceCase() {
        val javadir = JAVA_SOURCE_DIR3
        val tmpdir = BASE_TMP_DIR
        val sourcedir = tmpdir + "source"
        val backupdir = tmpdir + "backup"
        deleteDirectory(tmpdir)
        copyDirectory(javadir, sourcedir)

        addSourceDirectory(sourcedir)
        backupDirectory = backupdir
        runConverter
        
        val sourceFilesNumber = retrieveFileList(sourcedir, FileExtension.java).size
        val backupFilesNumber = retrieveFileList(backupdir, FileExtension.java).size
        val targetFilesNumber = retrieveFileList(sourcedir, FileExtension.xtend).size
        assertTrue("There should be no more java file in source directory.", sourceFilesNumber == 0)
        assertTrue("There should be at least one backup file.", backupFilesNumber > 0)
        assertTrue("There should be the same number of backup and Xtend files.", backupFilesNumber == targetFilesNumber)
    }

    @Test 
    def void testBackupJavaFilesInPlaceWithNewExtensionAndPutXtendFilesInPlaceCase() {
        val javadir = JAVA_SOURCE_DIR3
        val tmpdir = BASE_TMP_DIR
        val sourcedir = tmpdir + "source"
        deleteDirectory(tmpdir)
        copyDirectory(javadir, sourcedir)
        (j2x => [
            addSourceDirectory(sourcedir)
            backupFileExtension = FileExtension.backup.name
        ]).runConverter
        val sourceFilesNumber = retrieveFileList(sourcedir, FileExtension.java).size
        val backupFilesNumber = retrieveFileList(sourcedir, FileExtension.backup).size
        val targetFilesNumber = retrieveFileList(sourcedir, FileExtension.xtend).size
        assertTrue("There should be no more java file in source directory.", sourceFilesNumber == 0)
        assertTrue("There should be at least one backup file.", backupFilesNumber > 0)
        assertTrue("There should be the same number of backup and Xtend files.", backupFilesNumber == targetFilesNumber)
    }

    @Test 
    def void testBackupJavaFilesWithNewExtensionAndPutXtendFilesInPlaceCase() {
        val javadir = JAVA_SOURCE_DIR3
        val tmpdir = BASE_TMP_DIR
        val sourcedir = tmpdir + "source"
        val backupdir = tmpdir + "backup"
        deleteDirectory(tmpdir)
        copyDirectory(javadir, sourcedir)
        (j2x => [
            addSourceDirectory(sourcedir)
            backupDirectory = backupdir
            backupFileExtension = FileExtension.backup.name
        ]).runConverter
        val sourceFilesNumber = retrieveFileList(sourcedir, FileExtension.java).size
        val backupFilesNumber = retrieveFileList(backupdir, FileExtension.backup).size
        val targetFilesNumber = retrieveFileList(sourcedir, FileExtension.xtend).size
        assertTrue("There should be no more java file in source directory.", sourceFilesNumber == 0)
        assertTrue("There should be at least one backup file.", backupFilesNumber > 0)
        assertTrue("There should be the same number of backup and Xtend files.", backupFilesNumber == targetFilesNumber)
    }

    @Test 
    def void testBackupJavaFilesInPlaceWithNewExtensionAndMoveXtendFilesCase() {
        val javadir = JAVA_SOURCE_DIR3
        val tmpdir = BASE_TMP_DIR
        val sourcedir = tmpdir + "source"
        val targetdir = tmpdir + "generated"
        deleteDirectory(tmpdir)
        copyDirectory(javadir, sourcedir)
        (j2x => [
            addSourceDirectory(sourcedir)
            backupFileExtension = FileExtension.backup.name
            outputDirectory = targetdir
        ]).runConverter
        val sourceFilesNumber = retrieveFileList(sourcedir, FileExtension.java).size
        val backupFilesNumber = retrieveFileList(sourcedir, FileExtension.backup).size
        val targetFilesNumber = retrieveFileList(targetdir, FileExtension.xtend).size
        assertTrue("There should be no more java file in source directory.", sourceFilesNumber == 0)
        assertTrue("There should be at least one backup file.", backupFilesNumber > 0)
        assertTrue("There should be the same number of backup and Xtend files.", backupFilesNumber == targetFilesNumber)
    }

    @Test 
    def void testBackupJavaFilesAndMoveXtendFilesCase() {
        val javadir = JAVA_SOURCE_DIR3
        val tmpdir = BASE_TMP_DIR
        val sourcedir = tmpdir + "source"
        val backupdir = tmpdir + "backup"
        val targetdir = tmpdir + "generated"
        deleteDirectory(tmpdir)
        copyDirectory(javadir, sourcedir)
        (j2x => [
            addSourceDirectory(sourcedir)
            backupDirectory = backupdir
            outputDirectory = targetdir
        ]).runConverter
        val sourceFilesNumber = retrieveFileList(sourcedir, FileExtension.java).size
        val backupFilesNumber = retrieveFileList(backupdir, FileExtension.java).size
        val targetFilesNumber = retrieveFileList(targetdir, FileExtension.xtend).size
        assertTrue("There should be no more java file in source directory.", sourceFilesNumber == 0)
        assertTrue("There should be at least one backup file.", backupFilesNumber > 0)
        assertTrue("There should be the same number of backup and Xtend files.", backupFilesNumber == targetFilesNumber)
    }

    @Test 
    def void testBackupJavaFilesWithNewExtensionAndMoveXtendFilesCase() {
        val javadir = JAVA_SOURCE_DIR3
        val tmpdir = BASE_TMP_DIR
        val sourcedir = tmpdir + "source"
        val backupdir = tmpdir + "backup"
        val targetdir = tmpdir + "generated"
        deleteDirectory(tmpdir)
        copyDirectory(javadir, sourcedir)
        (j2x => [
            addSourceDirectory(sourcedir)
            backupDirectory = backupdir
            backupFileExtension = FileExtension.backup.name
            outputDirectory = targetdir
        ]).runConverter
        val sourceFilesNumber = retrieveFileList(sourcedir, FileExtension.java).size
        val backupFilesNumber = retrieveFileList(backupdir, FileExtension.backup).size
        val targetFilesNumber = retrieveFileList(targetdir, FileExtension.xtend).size
        assertTrue("There should be no more java file in source directory.", sourceFilesNumber == 0)
        assertTrue("There should be at least one backup file.", backupFilesNumber > 0)
        assertTrue("There should be the same number of backup and Xtend files.", backupFilesNumber == targetFilesNumber)
    }

    @Test 
    def void testMultiSourcesBackupJavaFilesWithNewExtensionAndMoveXtendFilesCase() {
        val javadir1 = JAVA_SOURCE_DIR1
        val javadir3 = JAVA_SOURCE_DIR3
        val tmpdir = BASE_TMP_DIR
        val sourcedir1 = tmpdir + "source1"
        val sourcedir3 = tmpdir + "source3"
        val backupdir = tmpdir + "backup"
        val targetdir = tmpdir + "generated"
        deleteDirectory(tmpdir)
        copyDirectory(javadir1, sourcedir1)
        copyDirectory(javadir3, sourcedir3)
        val java1FilesNumber = retrieveFileList(sourcedir1, FileExtension.java).size
        val java3FilesNumber = retrieveFileList(sourcedir3, FileExtension.java).size
        assertTrue("There should be at least one java file in source #1 directory.", java1FilesNumber > 0)
        assertTrue("There should be at least one java file in source #3 directory.", java3FilesNumber > 0)
        (j2x => [
            addSourceDirectory(sourcedir1)
            addSourceDirectory(sourcedir3)
            backupDirectory = backupdir
            backupFileExtension = FileExtension.backup.name
            outputDirectory = targetdir
        ]).runConverter
        val source1FilesNumber = retrieveFileList(sourcedir1, FileExtension.java).size
        val source3FilesNumber = retrieveFileList(sourcedir3, FileExtension.java).size
        val backupFilesNumber = retrieveFileList(backupdir, FileExtension.backup).size
        val targetFilesNumber = retrieveFileList(targetdir, FileExtension.xtend).size
        assertTrue("There should be no more java file in source #1 directory.", source1FilesNumber == 0)
        assertTrue("There should be no more java file in source #3 directory.", source3FilesNumber == 0)
        assertTrue("There should be at least one backup file.", backupFilesNumber > 0)
        assertTrue("There should be the same number of backup and Xtend files.", backupFilesNumber == targetFilesNumber)
        assertTrue("There should be the same number of Java and Xtend files.", 
            backupFilesNumber == java1FilesNumber + java3FilesNumber)
    }
    
}
