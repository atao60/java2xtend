package org.eclipse.xtend.java2xtend.util

import java.nio.file.Paths
import java.nio.file.SimpleFileVisitor
import java.nio.file.attribute.BasicFileAttributes
import java.nio.file.Path
import java.nio.file.FileVisitResult

import static java.nio.file.FileVisitResult.*
import static java.nio.file.Files.*
import org.apache.log4j.Logger
import java.io.IOException
import java.nio.file.FileSystems

import static java.lang.String.format

class PathUtils {
    
    public static val FILE_EXTENSION_SEP = '.'
    public static val FILE_EXTENSION_MATCHER_PATTERN = "glob:**/*%s"
    public static val JAVA_FILE_EXTENSION = "java"
    public static val XTEND_FILE_EXTENSION = "xtend"
    
    enum FileExtension {java, xtend, backup}
    
    private new(){}
    
    static val extension Logger LOGGER = Logger.getLogger(PathUtils)

    def static isContainedIn(Path child, Path possibleParent) {
        for (var dir = child; dir !== null; dir = dir.parent) {
            if (dir == possibleParent) {
                return true
            }
        }
        false
    }

    def static deleteDirectory(String rootPath) {
        val dir = Paths.get(rootPath).toAbsolutePath
        if(!exists(dir)) {
            '''Directory «dir» doesn't exist and so can't be deleted.'''.toString.warn
            return dir
        }
        '''Directory «dir» will be deleted.'''.toString.info
        walkFileTree(dir, new SimpleFileVisitor<Path> {
            override FileVisitResult visitFile(Path file, BasicFileAttributes attrs) {
                delete(file)
                CONTINUE
            }
            override FileVisitResult postVisitDirectory(Path directory, IOException ioe) {
                delete(directory);
                CONTINUE;
            }
        });
    }

    def static copyDirectory(String source, String target) {
        val sourcePath = Paths.get(source).toAbsolutePath
        val targetPath = Paths.get(target).toAbsolutePath
        
        walkFileTree(sourcePath, new SimpleFileVisitor<Path> {
            override FileVisitResult preVisitDirectory(Path dir, BasicFileAttributes attrs) {
                createDirectories(targetPath.resolve(sourcePath.relativize(dir)))
                CONTINUE
            }
            override FileVisitResult visitFile(Path file, BasicFileAttributes attrs) {
                copy(file, targetPath.resolve(sourcePath.relativize(file)))
                CONTINUE
            }
        });
    }

    def static retrieveFileList(String rootPath, FileExtension fileExtension) {
        val matcher = FileSystems.getDefault.getPathMatcher(
            format(FILE_EXTENSION_MATCHER_PATTERN, FILE_EXTENSION_SEP + fileExtension.name))
        val dir = Paths.get(rootPath).toAbsolutePath
        val list = <Path>newArrayList
        walkFileTree(dir, new SimpleFileVisitor<Path> {
            override FileVisitResult visitFile(Path file, BasicFileAttributes attrs) {
                if (attrs.isRegularFile && matcher.matches(file)) {
                   list.add(file)
                }
                CONTINUE
            }
        });
        list
    }

}