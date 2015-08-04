package org.eclipse.xtend.core.tests.javaconverter

import com.google.inject.Inject
import com.google.inject.Provider
import org.eclipse.xtend.core.formatting2.XtendFormatter
import org.eclipse.xtext.formatting2.FormatterRequest
import org.eclipse.xtext.formatting2.regionaccess.TextRegionAccessBuilder
import org.junit.Before
import org.eclipse.xtext.util.ExceptionAcceptor
import org.eclipse.xtext.formatting2.regionaccess.ITextRegionAccess
import org.eclipse.xtext.preferences.PreferenceKeysProvider
import org.eclipse.xtend.core.formatting2.XtendFormatterPreferenceKeys
import java.util.HashMap
import com.google.common.base.Strings
import org.eclipse.xtext.preferences.MapBasedPreferenceValues

import static org.eclipse.xtend.core.formatting2.XtendFormatterPreferenceKeys.*
import org.eclipse.xtext.resource.XtextResource
import org.slf4j.LoggerFactory
import org.slf4j.Logger

class AbstractFormattedJava2XtendTestCase extends AbstractJava2XtendTestCase {
 
    static val extension Logger LOGGER = LoggerFactory.getLogger(JavaConverterSeries4Test)

    @Inject
    Provider<XtendFormatter> formatterProvider
    @Inject
    Provider<TextRegionAccessBuilder> regionBuilderProvider
    @Inject
    Provider<FormatterRequest> requestProvider

    XtendFormatter formatter
    
    @Before override void setUp() {
        super.setUp()
        formatter = formatterProvider.get()
    }
    
        def protected formatXtendCode(String xtendCode) {
            try {
                val xtendFile = file(xtendCode)
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

        def private commentOut(String msg) {
            msg.replaceAll("?m^", "//")
        }

        def private initRequest(ITextRegionAccess regionaccess) {
            extension val request = requestProvider.get
            allowIdentityEdits = false
            formatUndefinedHiddenRegionsOnly = false
            preferences = defaultProfileSettings 
            textRegionAccess = regionaccess
            if (regionaccess.hasSyntaxError)
                exceptionHandler = ExceptionAcceptor.IGNORING
            else
                exceptionHandler = ExceptionAcceptor.LOGGING
        }

        def private getDefaultProfileSettings() {
            val keys = PreferenceKeysProvider.allConstantKeys(XtendFormatterPreferenceKeys)
            val keymap = new HashMap<String, String> => [
                for (key : keys) {
                    put(key.id, key.defaultValue)
                }
                put(blankLinesBeforeFirstMember.id, String.valueOf(1))
                put(indentation.id, Strings.repeat(String.valueOf(' '), Integer.parseInt(indentationLength.defaultValue)))
            ]
            new MapBasedPreferenceValues(keymap)
        }

}