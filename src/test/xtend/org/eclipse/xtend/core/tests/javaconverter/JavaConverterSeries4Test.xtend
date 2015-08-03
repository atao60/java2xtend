package org.eclipse.xtend.core.tests.javaconverter

import java.util.regex.Pattern
import org.junit.Before
import org.junit.Test

/*
 * Use of Java2XtendBatchConverter
 * 
 * This series only checks some converter's refactoring issues and the ability of the formatter 
 * to correct some of them. Uses directly Xtend's JavaConverter.
 *  
 * FIXME: tab in place of 4 spaces: not always???
 * here, it's always incrementation with tab
 */
class JavaConverterSeries4Test extends AbstractFormattedJava2XtendTestCase {

    @Before override setUp() {
        super.setUp
        withTabReplaced = false
    }

    @Test 
    // see testCommentsCase_01 from Xtend unit tests
    def void testNonExpectedSemiColonCase() {
        var xtendCode = toXtendCode(
            '''
        public class NonExpectedSemiColon {
            public void doStuff() {
                return;
            }
        }''')
        val expected = '''
        class NonExpectedSemiColon {
        	def void doStuff() {
        		return;
        	}
        	
        }'''
        assertEquals(expected, xtendCode)
        assertTrue(Pattern.compile("return;$", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(! Pattern.compile("[ ]+$", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(Pattern.compile("^\\t+", Pattern.MULTILINE).matcher(xtendCode).find)
        
    }
    
    @Test 
    def void testSystemOutNotRemovedCase() {
        var xtendCode = toXtendCode(
            '''
        public class SystemOutNotRemoved{
            public static void main(String[] args) {
                System.out.println("Hello!");
            }
        }''')
        val expected = '''
        class SystemOutNotRemoved {
        	def static void main(String[] args) {
        		System.out.println("Hello!") 
        	}
        	
        }'''
        assertEquals(expected, xtendCode)
        assertTrue(Pattern.compile("System\\.out\\.", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(Pattern.compile("[ ]+$", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(Pattern.compile("^\\t+", Pattern.MULTILINE).matcher(xtendCode).find)
        
        // To remove the trailing spaces and the tab
        xtendCode = formatXtendCode(xtendCode)
        val formatted = '''
        class SystemOutNotRemoved {
        
            def static void main(String[] args) {
                System.out.println("Hello!")
            }
        
        }
        '''
        assertEquals(formatted, xtendCode)
        assertTrue(Pattern.compile("System\\.out\\.", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(! Pattern.compile("[ ]+$", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(! Pattern.compile("^\\t+", Pattern.MULTILINE).matcher(xtendCode).find)
        
    }

    @Test 
    def void testTypeNotRemovedCase() {
        var xtendCode = toXtendCode(
            '''
        public class TypeNotRemoved{
            public static void main(String[] args) {
                String msg1 = "Again...";
                System.out.println(msg1);
            }
        }''')
        val expected = '''
        class TypeNotRemoved {
        	def static void main(String[] args) {
        		var String msg1="Again..." 
        		System.out.println(msg1) 
        	}
        	
        }'''
        assertEquals(expected, xtendCode)
        assertTrue(Pattern.compile("var\\s+String", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(Pattern.compile("[ ]+$", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(Pattern.compile("^\\t+", Pattern.MULTILINE).matcher(xtendCode).find)
        
        // To remove the trailing spaces
        xtendCode = formatXtendCode(xtendCode)
        val formatted = '''
        class TypeNotRemoved {
        
            def static void main(String[] args) {
                var String msg1 = "Again..."
                System.out.println(msg1)
            }
        
        }
        '''
        assertEquals(formatted, xtendCode)
        assertTrue(Pattern.compile("var\\s+String", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(! Pattern.compile("[ ]+$", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(! Pattern.compile("^\\t+", Pattern.MULTILINE).matcher(xtendCode).find)
        
    }

    @Test 
    // and there is one trailing space on some lines
    def void testTwoInstructionsOnSameLineCase() {
        var xtendCode = toXtendCode(
            '''
        public class TwoInstructionsOnSameLine{
            public static void main(String[] args) {
                System.out.println("Hello!");
                String msg1 = "Again...";
                System.out.println(msg1);
            }
        }''')
        val expected = '''
        class TwoInstructionsOnSameLine {
        	def static void main(String[] args) {
        		System.out.println("Hello!") var String msg1="Again..." 
        		System.out.println(msg1) 
        	}
        	
        }'''
        assertEquals(expected, xtendCode)
        assertTrue(Pattern.compile("\\)[ ]+var", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(Pattern.compile("[ ]+$", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(Pattern.compile("^\\t+", Pattern.MULTILINE).matcher(xtendCode).find)
        
        // To split the two instructions on different lines
        // and to remove the trailing spaces
        xtendCode = formatXtendCode(xtendCode)
        val formatted = '''
        class TwoInstructionsOnSameLine {
        
            def static void main(String[] args) {
                System.out.println("Hello!")
                var String msg1 = "Again..."
                System.out.println(msg1)
            }
        
        }
        '''
        assertEquals(formatted, xtendCode)
        assertTrue(! Pattern.compile("\\)[ ]+var", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(! Pattern.compile("[ ]+$", Pattern.MULTILINE).matcher(xtendCode).find)
        assertTrue(! Pattern.compile("^\\t+", Pattern.MULTILINE).matcher(xtendCode).find)
        
    }

}
