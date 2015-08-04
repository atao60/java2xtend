package org.eclipse.xtend.java2xtend.config.log

import ch.qos.logback.classic.spi.Configurator
import java.util.Properties
import ch.qos.logback.core.Context
import ch.qos.logback.core.status.Status

import static java.lang.String.format
import ch.qos.logback.core.status.InfoStatus
import ch.qos.logback.classic.LoggerContext
import ch.qos.logback.classic.Level
import ch.qos.logback.classic.Logger
import ch.qos.logback.classic.encoder.PatternLayoutEncoder
import ch.qos.logback.core.ConsoleAppender
import ch.qos.logback.classic.spi.ILoggingEvent

/**
 * Use to configure Logback without any xml file.
 * 
 * <configuration>
 *   <appender name="stdout" class="ch.qos.logback.core.ConsoleAppender">
 *     <encoder>
 *       <pattern>%d %p [%c] - &lt;%m&gt;%n</pattern>
 *     </encoder>
 *   </appender>
 *   <logger name="org.eclipse.xtend.java2xtend" level="DEBUG"/>
 *   <root level="INFO">
 *     <appender-ref ref="stdout"/>
 *   </root>
 * </configuration>
 *
 */
class LogbackConfigurator implements Configurator {
    
    public static val PROPERTIES_FILE_PATH = "logback.properties"
    
    public static val PATTERN_LABEL = "pattern"
    public static val ROOT_LEVEL_LABEL = "root.level"
    
    static val SETTING_UP_CONFIGURATION_MSG = "Setting up OMS Core configuration."
    static val APPENDER_NAME = "console"
    static val DEFAULT_PATTERN = "Logback Config with Xtend: %d{HH:mm:ss.SSS} [%thread] %-5level %logger{36} - %msg%n"
    
    extension val Properties properties
        
    def private doConfigure(LoggerContext lc) {
        val stdout = new ConsoleAppender<ILoggingEvent> => [
            context = lc
            name = APPENDER_NAME
            encoder = new PatternLayoutEncoder => [
                context = lc
                pattern = PATTERN_LABEL.property?:DEFAULT_PATTERN
                start
            ]
            start
        ]
        lc.getLogger("org.eclipse.xtend.java2xtend") => [
            level = Level.DEBUG
        ]
        lc.getLogger(Logger.ROOT_LOGGER_NAME) => [
            level = Level.toLevel(ROOT_LEVEL_LABEL.property?:Level.WARN.toString)
            addAppender(stdout)
        ]
    }

    var Context ctxt
    override setContext(Context context) {
        this.ctxt = context
    }
    override getContext() {
        this.ctxt
    }

    new() {
        properties = new Properties => [
            load(LogbackConfigurator.classLoader.getResourceAsStream(PROPERTIES_FILE_PATH))
        ]
    }

    override configure(LoggerContext lc) {
        
        val sm = lc.getStatusManager
        if (sm !== null) {
            sm.add(new InfoStatus(SETTING_UP_CONFIGURATION_MSG, lc))
        }
        
        doConfigure(lc)
    }
    
    override addError(String arg0) {
        throw new NotImplementedException("addError(String arg0)")
    }

    override addError(String arg0, Throwable arg1) {
        throw new NotImplementedException("addError(String arg0, Throwable arg1)")
    }

    override addInfo(String arg0) {
        throw new NotImplementedException("addInfo(String arg0)")
    }

    override addInfo(String arg0, Throwable arg1) {
        throw new NotImplementedException("addInfo(String arg0, Throwable arg1)")
    }

    override addStatus(Status arg0) {
        throw new NotImplementedException("addStatus(String arg0)")
    }

    override addWarn(String arg0) {
        throw new NotImplementedException("addWarn(String arg0)")
    }

    override addWarn(String arg0, Throwable arg1) {
        throw new NotImplementedException("addWarn(String arg0, Throwable arg1)")
    }
    
    private final static class NotImplementedException extends UnsupportedOperationException {
        static val NOT_IMPLEMENTED = "%s is not implemented yet."
        new(String methodSig) {
            super(format(NOT_IMPLEMENTED, methodSig))
        }
    }

}