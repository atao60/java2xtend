package org.eclipse.xtend.java2xtend

import java.util.Arrays
import java.util.Iterator
import org.eclipse.xtend.core.XtendStandaloneSetup
import org.eclipse.xtend.java2xtend.converter.Converter
import org.eclipse.xtend.java2xtend.converter.Java2XtendBatchConverter

/*
 * TODO: 
 * - option debug/verbose?
 * - option filter on the source paths?
 */
class Java2XtendBatchRunner {
    
    val static OPTION_KEYS = #{ /* key ---> tag */
        "-d" -> "destination",
        "-a" -> "archive",
        "-jfe" -> "javaextension",
        "-b" -> "backup",
        "-bfe" -> "backupextension",
        "-e" -> "encoding",
        "-p" -> "preferences",
        "-sf" -> "skipformatting",
        "-sv" -> "skipvalidating",
        "-destination" -> "destination",
        "-archive" -> "archive",
        "-javafileextension" -> "javaextension",
        "-backup" -> "backup",
        "-backupfileextension" -> "backupextension",
        "-encoding" -> "encoding",
        "-preferences" -> "preferences",
        "-skipformatting" -> "skipformatting",
        "-skipvalidating" -> "skipvalidating"
    }
    
    val static OPTIONS = newLinkedHashMap( /* tag ---> option */
        'destination' -> (new Option => [
            msg = '''
                «org.eclipse.xtend.java2xtend.Java2XtendBatchRunner.joinOptionKeys('destination')» <destination>     
                                Destination directory where to place generated Xtend files.
                                By default the same directory as the source one.'''
            action = [
                converter, argument, arguments | converter.outputDirectory = arguments.next.trim
            ]
            ]),
        'archive' -> (new Option => [val defaultValue = false
            msg = '''
                «org.eclipse.xtend.java2xtend.Java2XtendBatchRunner.joinOptionKeys('archive')»   
                                Force the destination directory as an archive folder not a source one.
                                Then neither backup directory nor backup file extension are required. 
                                By default: «defaultValue».'''
            action = [converter, argument, arguments | converter.archive = ! defaultValue]
            ]),
        'javaextension' -> (new Option => [
            msg = '''
                «org.eclipse.xtend.java2xtend.Java2XtendBatchRunner.joinOptionKeys('javaextension')» <extension>
                                Java file extension. By defaut: java.'''
            action = [converter, argument, arguments | converter.javaFileExtension = arguments.next.trim]
            ]),
        'backup' -> (new Option => [
            msg = '''
                «org.eclipse.xtend.java2xtend.Java2XtendBatchRunner.joinOptionKeys('backup')» <path>
                                Backup directory where to move Java files. Mandatory if no backup file
                                extension is provided.
                                By default the Java files are kept in place.'''
            action = [converter, argument, arguments | converter.backupDirectory = arguments.next.trim]
            ]),
        'backupextension' -> (new Option => [
            msg = '''
                «org.eclipse.xtend.java2xtend.Java2XtendBatchRunner.joinOptionKeys('backupextension')» <extension> 
                                Backup file extension. Mandatory if no backup directory is provided.
                                By default the file extension is kept.'''
            action = [converter, argument, arguments | converter.backupFileExtension = arguments.next.trim]
            ]),
        'encoding' -> (new Option => [
            msg = '''
                «org.eclipse.xtend.java2xtend.Java2XtendBatchRunner.joinOptionKeys('encoding')» <encoding> 
                                Specify character encoding used by source files. By default: UTF-8.'''
            action = [converter, argument, arguments | converter.fileEncoding = arguments.next.trim]
            ]),
        'preferences' -> (new Option => [
            msg = '''
                «org.eclipse.xtend.java2xtend.Java2XtendBatchRunner.joinOptionKeys('preferences')» <preferences> 
                                Formatting preferences file path. 
                                By default, XtendFormatterPreferenceKeys class values.'''
            action = [converter, argument, arguments | converter.preferences = arguments.next.trim]
            ]),
        'skipformatting' -> (new Option => [val defaultValue = false
            msg = '''
                «org.eclipse.xtend.java2xtend.Java2XtendBatchRunner.joinOptionKeys('skipformatting')»
                                Skip Xtend formatting. By default: «defaultValue».'''
            action = [converter, argument, arguments | converter.skipFormatting = ! defaultValue]
            ]),
        'skipvalidating' -> (new Option => [val defaultValue = false
            msg = '''
                «org.eclipse.xtend.java2xtend.Java2XtendBatchRunner.joinOptionKeys('skipvalidating')»
                                Skip Xtend validation. By default: «defaultValue».'''
            action = [converter, argument, arguments | converter.skipValidation = ! defaultValue]
            ]),
        null -> (new Option => [
            action = [converter, argument, arguments | converter.addSourceDirectory(argument)]
            ])
      )
      
    private static def joinOptionKeys(String tag) {
        OPTION_KEYS.entrySet.filter[value == tag].map[getKey].sortBy[length].join(" | ")
    }
    
    private static class Option {
        public String msg = null
        public (Converter, String, Iterator<String>)=>void action = null
    }  
    
    static def void main(String[] args) {
        if ((args === null) || (args.length == 0)) {
            printUsage
            return
        }

        val injector = new XtendStandaloneSetup().createInjectorAndDoEMFRegistration
        extension val j2xConverter = injector.getInstance(Java2XtendBatchConverter)

        val arguments = Arrays.asList(args).iterator
        while (arguments.hasNext) {
            val a = arguments.next.trim
            OPTIONS.get(OPTION_KEYS.get(a)).action.apply(j2xConverter, a, arguments)
        }
        if (! runConverter) {
            System.exit(1);
        }
        
    }
    
    private static def printUsage() {
        println('''
            Usage: java java2xtend-2.0-SNAPSHOT-runnable.jar [options] sources
            where <sources> is a space separeted list of paths where to search Java classes to convert. 
            Possible options include:
            «OPTIONS.values.filter[msg !== null].join(System.getProperty("line.separator")) [msg]»
        ''')
    }

}