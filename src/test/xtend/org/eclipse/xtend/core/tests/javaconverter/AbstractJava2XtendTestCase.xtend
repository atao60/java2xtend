package org.eclipse.xtend.core.tests.javaconverter

import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.xtend.core.javaconverter.JavaConverter
import org.eclipse.xtend.core.javaconverter.JavaConverter.ConversionResult
import org.eclipse.xtend.core.tests.AbstractXtendTestCase
import org.eclipse.xtend.core.xtend.XtendAnnotationType
import org.eclipse.xtend.core.xtend.XtendClass
import org.eclipse.xtend.core.xtend.XtendEnum
import org.eclipse.xtend.core.xtend.XtendField
import org.eclipse.xtend.core.xtend.XtendFile
import org.eclipse.xtend.core.xtend.XtendFunction
import org.eclipse.xtend.core.xtend.XtendInterface
import org.eclipse.xtend.core.xtend.XtendTypeDeclaration
import org.junit.Before
import com.google.common.base.Strings

import static org.eclipse.xtext.formatting2.FormatterPreferenceKeys.*

/**
 * Add replaceTab and move some utility methods out of Xtend's JavaConverterTest
 */
class AbstractJava2XtendTestCase extends AbstractXtendTestCase {
    
    @Inject 
    Provider<JavaConverter> javaConverterProvider
    
    protected JavaConverter j2x
    
    protected boolean withTabReplaced = true
    
    protected boolean DUMP = false;

    @Before def void setUp() {
        j2x = javaConverterProvider.get()
    }
    
    def protected XtendClass toValidXtendClass(String javaCode) throws Exception {
        return toValidTypeDeclaration("Clazz", javaCode) as XtendClass
    }

    def protected XtendAnnotationType toValidXtendAnnotation(String javaCode) throws Exception {
        return toValidTypeDeclaration("Anno", javaCode) as XtendAnnotationType
    }

    def protected XtendInterface toValidXtendInterface(String javaCode) throws Exception {
        return toValidTypeDeclaration("Interfaze", javaCode) as XtendInterface
    }

    def protected XtendEnum toValidXtendEnum(String javaCode) throws Exception {
        return toValidTypeDeclaration("EnumClazz", javaCode) as XtendEnum
    }

    def protected XtendTypeDeclaration toValidTypeDeclaration(String unitName, String javaCode) throws Exception {
        var XtendFile file = toValidXtendFile(unitName, javaCode)
        var XtendTypeDeclaration typeDeclaration = file.xtendTypes.get(0)
        return typeDeclaration
    }

    def protected toXtendClassBodyDeclr(CharSequence string) {
        val xtendCode = j2x.bodyDeclarationToXtend(string.toString, null, null).xtendCode.trim.replaceTab
        dump(xtendCode)
        return xtendCode
    }

    def protected toXtendStatement(CharSequence string) {
        val xtendCode = j2x.statementToXtend(string.toString).xtendCode.trim.replaceTab
        dump(xtendCode)
        return xtendCode
    }

    def protected XtendFile toValidXtendFile(String unitName, String javaCode) throws Exception {

        var ConversionResult conversionResult = j2x.toXtend(unitName, javaCode)

        var String xtendCode = conversionResult.xtendCode
        assertFalse(xtendCode.empty)
        dump(xtendCode)
        for (String problem : conversionResult.problems) {
            dump('''ERROR: «problem»''')
        }
        return file(xtendCode, true)
    }

    def protected String toXtendCode(CharSequence javaCode) throws Exception {
        return j2x.toXtend("Temp", javaCode.toString).xtendCode.replaceTab
    }

    def XtendField field(XtendTypeDeclaration typeDecl, int i) {
        typeDecl.members.get(i) as XtendField
    }

    def XtendFunction method(XtendTypeDeclaration typeDecl, int i) {
        typeDecl.members.get(i) as XtendFunction
    }

    def dump(String text) {
        if (DUMP) {
            println(text)
        }
    }
    
    // ATM the converter returns tab and not four spaces 
    def replaceTab(String s) {
        if (withTabReplaced) {
            s.replaceAll("\t", Strings.repeat(String.valueOf(' '), Integer.parseInt(indentationLength.defaultValue)
            ))
        } else {
            s
        } 
        
    }
}