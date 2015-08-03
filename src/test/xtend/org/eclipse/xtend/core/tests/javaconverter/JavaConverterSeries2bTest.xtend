package org.eclipse.xtend.core.tests.javaconverter

import org.junit.Before
import org.junit.Test

/*
 * Just to check the example given in the README.mv file.
 * 
 * See JavaConverterSeries4Test for the expected generated code refactoring not implemented yet by
 * the Xtend converter. 
 * 
 */
class JavaConverterSeries2bTest extends AbstractFormattedJava2XtendTestCase {
        
    @Before override void setUp() {
        super.setUp
        withTabReplaced = true
    }

    @Test def void testReadmeExample() throws Exception {
        var xtendCode = toXtendCode(
            '''
    package com.example;
    
    import java.io.Serializable;
    import java.util.ArrayList;
    import java.util.List;
    
    public class Test implements Serializable {
        private static final long serialVersionUID = 1L;
        private List<String> list = null;
        private List<String> otherList = new ArrayList<String>();
    
        public Test(List<String> list) {
            this.list = list;
        }
        public static void main(String[] args) {
            System.out.println("Hello World!");
        }
    }
        ''').formatXtendCode
        val expected = '''
    package com.example
    
    import java.io.Serializable
    import java.util.ArrayList
    import java.util.List
    
    class Test implements Serializable {
    
        static final long serialVersionUID = 1L
        List<String> list = null
        List<String> otherList = new ArrayList<String>()
    
        new(List<String> list) {
            this.list = list
        }
    
        def static void main(String[] args) {
            System.out.println("Hello World!")
        }
    
    }
        '''
        assertEquals(expected, xtendCode)
    }
    
}
