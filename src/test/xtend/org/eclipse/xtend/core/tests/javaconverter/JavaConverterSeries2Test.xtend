package org.eclipse.xtend.core.tests.javaconverter

import com.google.common.collect.ImmutableList
import com.google.inject.Inject
import com.google.inject.Provider
import java.nio.charset.StandardCharsets
import java.nio.file.Path
import java.nio.file.Paths
import java.util.regex.Pattern
import org.eclipse.xtend.core.javaconverter.JavaConverter
import org.eclipse.xtend.core.tests.AbstractXtendTestCase
//import org.eclipse.xtend.core.test.rules.parameterized.test.ListGenerator
import org.junit.Before
import org.junit.Rule
import org.junit.Test

import static java.nio.file.Files.*
import static java.nio.file.LinkOption.*
import org.eclipse.xtend.core.test.rules.parameterized.ListGenerator

/*
 * Code samples adapted from Krzysztof Rzymkowski's project: java2xtend(https://github.com/rzymek/java2xtend)
 * Test the files directly with Xtend's JavaConverter
 * Doesn't do any validation: 
 * - the code samples are not granted to be valid,
 * - the test passes even if the converter catches issues.
 * 
 * Note. Even if these tests access the file system, they are unit tests, as here the files
 *       are just a convenient way to store code.
 */
class JavaConverterSeries2Test extends AbstractXtendTestCase {
    
    val static int NUMBER_OF_CASES = 13  // in fact, the number of java files  
    
    @Inject 
    Provider<JavaConverter> javaConverterProvider
    
    JavaConverter j2x

    @Rule
    public val javafiles = new ListGenerator(retrieveFilePaths(".java"))
    
    boolean withTabReplaced = true

    @Before def void setUp() {
        j2x = javaConverterProvider.get()    
    }
    
    def private static retrieveFilePaths(String fileExtension) {
        val dir = Paths.get("src/test/data2").toAbsolutePath
        val paths = newDirectoryStream(dir)
            .filter[isRegularFile(it, NOFOLLOW_LINKS)]
            .filter[toString.endsWith(fileExtension)]
        ImmutableList.copyOf(paths)
    }

    @Test def void checkNumberOfFiles() {
        assertEquals(NUMBER_OF_CASES, javafiles.numberOfCases)
    }

    @Test def void testFilesAccess() {
        convertResource(javafiles.value)  
    }
    
    def convertResource(Path java) { 
        val parent = java.parent
        val xtendFileName = java.fileName.toString.replaceAll(".java$", ".xtend")
        val xtend = parent.resolve(xtendFileName)
        if(! exists(xtend)) {
            throw new IllegalStateException('''Missing file «xtendFileName»''')
        }
        val xtendref = new String(readAllBytes(xtend), StandardCharsets.UTF_8)
        
        val javacode = new String(readAllBytes(java), StandardCharsets.UTF_8)
        val un = getFileNameFromCode(javacode)
        val xtendgen = j2x.toXtend(un, javacode).xtendCode.replaceTab
        assertEquals(xtendref, xtendgen)
    }

    def private String getFileNameFromCode(String codesource) {
        val packMatcher = Pattern.compile("package (\\S+)").matcher(codesource)
        val classMatcher = Pattern.compile("class (\\w+)").matcher(codesource)
        val pathName = if (packMatcher.find) {
                packMatcher.group(1).replace('.', '/') + "/"
            } else {
                ""
            }
        if (classMatcher.find) {
            pathName + classMatcher.group(1)
        } else {
            "Sample"
        }
    }

    def private replaceTab(String s) {
        if (withTabReplaced) {
            s.replaceAll("\t","    ")
        } else {
            s
        } 
        
    }
}
