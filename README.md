A Java to Xtend Batch Converter [![Build Status](https://travis-ci.org/atao60/java2xtend.svg?branch=master)](https://travis-ci.org/atao60/java2xtend)
==========

Rational
-------

Since its version 2.8, [Xtend](https://eclipse.org/xtend/) under [Eclipse](https://projects.eclipse.org/) provides a Java-to-Xtend converter. But what about using such a tool outside of *Eclipse*?

This is where this project comes in.

It was a good opportunity to learn more about:  

- [Github](https://github.com/) as a [Maven](https://maven.apache.org/) repository: this capability is very useful to use the present project as a base of the [online project](https://github.com/atao60/j2x-on-openshift) (see below);
- [Travis-CI](https://travis-ci.org): this CI platform provides a free plan for open source projects. 

Additionally, it's a foundation stone to setup an [online Java to Xtend converter](http://j2xconverter-atao60.rhcloud.com/) with the help of [OpenShift Online](https://www.openshift.com/products/online): this PAAS platform provides a free plan which is enough to set up such an online service. The code is available with the project [j2x-on-openshift](https://github.com/atao60/j2x-on-openshift). 

Warning (15/08/2015)
-----   

This project uses:  
- *Xtend* 2.9.0.beta3: even if it seems there are no issues about it, it's still a beta version. 
- [Maven](https://maven.apache.org/) 3.3.1 or above. It provides the extension support (see file .mvn/extensions.xml). Many tools doesn't support it yet, e.g. *Travis-CI* or [M2Eclipse](http://eclipse.org/m2e/), more details below.
    

Licenses & credits
------

Licensed under [Eclipse Public License](http://www.eclipse.org/legal/epl-v10.html).

A first attempt to create a Java converter from scratch was made by [Krzysztof Rzymkowski's project](https://github.com/rzymek/java2xtend).

Java Patterns
-------

The converter tries to *Xtend*'ify *Java* constructs like:

| Java                                       | Xtend                              | 
| -------------------------------------------|------------------------------------|
| obj1.equals(obj2)                          | obj1 == obj2                       |
| obj1 == obj2                               | obj1 === obj2                      |
| System.out.println(...)                    | println(...)                    (°)|
| private final String v="abc";              | val v="abc"                     (°)|
| person.setName(other.getPerson().getName); | person.name = other.person.name    |

Note (°). Not fully implemented by the *Xtend* converter yet.

E.g. this code: 

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

after conversion (see note (°) above) will become:

	package com.example
	
	import java.io.Serializable
	import java.util.ArrayList
	import java.util.List
	
	class Test implements Serializable {
	
		static val serialVersionUID = 1L
		List<String> list = null
		var otherList = new ArrayList<String>()
	
		new(List<String> list) {
			this.list = list
		}
		
		def static void main(String[] args) {
			println("Hello World!")
		}
		
	}
	
Requirements
-----

This project requires:

- JDK 1.8
- *Maven* 3.3.1 or above
- a *GitHub* account,
- a *Travis-CI* account.

If working under *Eclipse*:

- [Xtend SDK](https://eclipse.org/xtend/download.html) 
- *M2Eclipse*.

The project is configured with [Maven Polyglot](https://github.com/takari/maven-polyglot) using [Groovy](http://groovy-lang.org/) as dialect. So it requires *Maven* 3.3.1 or above with extension support.

[Eclipse Luna](https://projects.eclipse.org/releases/luna) with *M2Eclipse* provides an embedded runtime of *Maven* 3.2.1. *Maven Polyglot* requires a version 3.3.1 or more recent, as specified above. So such an external *Maven* runtime must be available on the working station.

Under *Eclipse Luna*, *M2Eclipse* is not aware of *Maven Polyglot* yet. At the moment (*M2Eclipse* v. 1.5.1), the only workaround is to use JBoss Tools [m2e-polyglot-poc](https://github.com/jbosstools/m2e-polyglot-poc). This tool automatically generates pom.xml files from the Polyglot ones. Don't remove the pom.xml file, it is required by *m2e-polyglot-poc* to work.
	
Build & deploy
-----

### From the command line

Here under *Linux*, but it should be easy to adapt it under *Windows*:

**1.** Get the source

    cd <local workspace path>
    git clone https://github.com/atao60/java2xtend.git
    
**2.** Build and install in the *Maven* local repository:

    cd <local workspace path>java2xtend
    mvn install -Pstandalone
    
Two versions of the jar are now available:
  
- a "fat" one, i.e. that is executable,
- a standard one, to be used by other projects as the [online converter](https://github.com/atao60/j2x-on-openshift).
    
**3.** Deploy on snapshots repository

Continuous integration and deployment are managed with *Travis-CI* service. As soon as a commit is pushed on the *java2xtend* repository, a continuous integration cycle is launched. If it passes, then a new snapshot version of the artifact becomes available from this [Maven repository](https://github.com/atao60/snapshots).

    cd <local workspace path>java2xtend
    git commit -m "New update"
    git push
         
Note. As stated above, a pom.xml file is automatically generated by *m2e-polyglot-poc* from the pom.groovy file. This pom.xml file will stay mandatory for *Travis-CI*, as long as this service will not, or allow to, configure *Maven* with a version 3.3.1 or above, i.e with extension support. See [Maven 3.3.1 requires Java 7 #3778](https://github.com/travis-ci/travis-ci/issues/3778). 

### Under *Eclipse*

This project is ready to be imported under *Eclipse*, using the wizard:  
```File > Import... > Git > Projects from Git > Clone URI```  
with the same address as above, i.e. `https://github.com/atao60/java2xtend.git`. 

About CI and Deployment. At the moment, there is an other limitation of *M2Eclipse*: it doesn't know yet how to deal with the new extension support. So the profile `maven-repo-update` must be specified when the goal `deploy` is launched under Eclipse.
    
Usage
-------   

#### Online

Go [here](http://j2xconverter-atao60.rhcloud.com/).

#### Command line

    cd <local workspace path>java2xtend/target
    mvn package -Pstandalone
    java -jar java2xtend-2.0-SNAPSHOT-standalone.jar -bfe backup <java files directories>

With this configuration, the generated *Xtend* files will be in the same directories as the original *Java* files. In the meantime, these *Java* files will have been rename with the file extension `backup`.

#### Programmaticaly

**1.** Check the right snapshot artifact is available from the [Maven repository](https://github.com/atao60/snapshots)

**2.** Add a dependency in the pom.xml:

    <dependency>
        <groupId>org.eclipse.xtend</groupId>
        <artifactId>java2xtend</artifactId>
        <version>2.0-SNAPSHOT</version>
    </dependency>
 
**3.** Add a repository in the pom.xml:

    <repositories>
        <repository>
            <id>github-atao60</id>
            <name>atao60's Github based repo</name>
            <url>https://github.com/atao60/snapshots/raw/master/</url>
        </repository>
    </repositories> 
    
**4.** Use the converter in your code:

    val injector = new XtendStandaloneSetup().createInjectorAndDoEMFRegistration
    extension val j2x = injector.getInstance(Java2XtendBatchConverter)
    addSourceDirectory(sourcedir1)
    addSourceDirectory(sourcedir2)
    backupFileExtension = "backup"
    runConverter

With this configuration, the generated *Xtend* files will be in the same directories as the original *Java* files. In the meantime, these *Java* files will have been renamed with the file extension `backup`.

Note. Even if java2xtend's [Convert class](https://github.com/atao60/java2xtend/blob/master/src/main/xtend/org/eclipse/xtend/java2xtend/converter/Java2XtendBatchConverter.xtend) helps to hide a lot of details, it's always possible to convert any Java code available as a string by calling directly:
[JavaConverter](https://github.com/eclipse/xtext/blob/2.9.0.beta3/plugins/org.eclipse.xtend.core/src/org/eclipse/xtend/core/javaconverter/JavaConverter.xtend) 
and 
[XtendFormatter](https://github.com/eclipse/xtext/blob/2.9.0.beta3/plugins/org.eclipse.xtend.core/src/org/eclipse/xtend/core/formatting2/XtendFormatter.xtend).



