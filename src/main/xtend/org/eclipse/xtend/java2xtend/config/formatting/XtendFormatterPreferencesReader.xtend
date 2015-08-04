package org.eclipse.xtend.java2xtend.config.formatting

import java.io.IOException
import java.io.InputStream
import java.nio.file.Files
import java.nio.file.Path
import org.apache.commons.digester3.Digester
import org.xml.sax.SAXException

import static java.lang.String.format
import static org.eclipse.xtend.java2xtend.config.formatting.Profiles.*
import org.slf4j.LoggerFactory
import org.slf4j.Logger

class XtendFormatterPreferencesReader {

    static val String DEFAULT_PREFERENCES_USED = "Default Xtend formatter preferences will be used."
    static val String NO_PROFILES_FOUND = "No profiles found in config file. " + DEFAULT_PREFERENCES_USED
    static val String NO_XTEND_FORMATTER_PROFILE_FOUND = format(
        "No profile of kind '%s' found in config file. " +
            DEFAULT_PREFERENCES_USED
        ,
        PROFILE_KIND
    )
    static val String UNABLE_TO_READ_XTEND_FORMATTER_PREFERENCES_FILE = "Unable to read Xtend formatter preferences file. " +
        DEFAULT_PREFERENCES_USED

    static val extension Logger LOGGER = LoggerFactory.getLogger(XtendFormatterPreferencesReader)

    def read(Path path) {
        read(Files.newInputStream(path))
    }

    def read(InputStream input) {
        try {
            val result = (new Digester => [
                addRuleSet(new RuleSet)
            ]).parse(input)
            if (result == null || !(result instanceof Profiles)) {
                NO_PROFILES_FOUND.warn
                return null
            }
            val profiles = result as Profiles
            val list = profiles.profiles
            if (list.isEmpty) {
                NO_XTEND_FORMATTER_PROFILE_FOUND.warn
                return null
            }
            list.get(0)
        } catch (IOException ioe) {
            UNABLE_TO_READ_XTEND_FORMATTER_PREFERENCES_FILE.error(ioe)
            null
        } catch (SAXException se) {
            UNABLE_TO_READ_XTEND_FORMATTER_PREFERENCES_FILE.error(se)
            null
        }
    }
}