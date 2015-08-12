A Java to Xtend Batch Converter
==========

Rational
-------

Since its version 2.8, [Xtend](https://eclipse.org/xtend/) under [Eclipse](https://projects.eclipse.org/) provides a Java-to-Xtend converter. But what about using such a tool outside of *Eclipse*?

This is where this project comes in.

It was a good opportunity to learn more about:  

- [OpenShift Online](https://www.openshift.com/products/online): this PAAS platform provides a free plan which is enough to set up an online service. So you can try the *Xtend*'s Java to Xtend converter at [j2x converter](http://j2xconverter-atao60.rhcloud.com/).
- [Github](https://github.com/) as a [Maven](https://maven.apache.org/) repository: this capability is very useful to use the present project as a base of the above [online project](https://github.com/atao60/j2x-on-openshift). 

Licenses & credits
------

Licenced under [Eclipse Public License](http://www.eclipse.org/legal/epl-v10.html).

There is a first attempt to create a Java converter from scratch, see [Krzysztof Rzymkowski's project](https://github.com/rzymek/java2xtend).

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

This project uses the version 2.9.0.beta3 of *Xtend*.

It requires:

- JDK 1.8
- [Maven](https://maven.apache.org/) 3.3.1 or above

If working under *Eclipse*:

- [Xtend SDK](https://eclipse.org/xtend/download.html) 
- [M2Eclipse](http://eclipse.org/m2e/).

The project is configured with [Maven Polyglot](https://github.com/takari/maven-polyglot) using [Groovy](http://groovy-lang.org/) as dialect.

[Eclipse Luna](https://projects.eclipse.org/releases/luna) with *M2Eclipse* provides an embedded runtime of *Maven* 3.2.1. *Maven Polyglot* requires a version 3.3.1 or more recent, as specified above. So such an external *Maven* runtime must be available on the working station.

Under *Eclipse Luna*, *M2Eclipse* is not aware of *Maven Polyglot* yet. At the moment (*M2Eclipse* v. 1.5.1), the only workaround is to use JBoss Tools [m2e-polyglot-poc](https://github.com/jbosstools/m2e-polyglot-poc). This tool automatically generates pom.xml files from the Polyglot ones. Don't remove the pom.xml file, it is required by *m2e-polyglot-poc* to work.
	
Build & deploy
-----

### From the command line

Here under *Linux*:

**1.** Get the source

    cd <local workspace path>
    git clone https://github.com/atao60/java2xtend.git
    
**2.** Build and install to *Maven* local repository:

    cd <local workspace path>java2xtend
    mvn install -Pstandalone
    
Two versions of the jar are now available:
  
- a "fat" one, i.e. that is executable,
- a standard one, to be used by other projects as the [online converter](https://github.com/atao60/j2x-on-openshift).
    
**3.** Deploy on a public *Maven* repository

    cd <local git path>
    git clone git@github.com:atao60/snapshots.git
    
    cd <local workspace path>java2xtend
    mvn deploy -Dsnapshots.staging.repo=<local git path>/snapshots
    
    cd <local git path>/snapshots
    git status
    git add .
    git commit -m "New update"
    git push 
         
Then the standard jar file is available from this [Github repository](https://github.com/atao60/snapshots/raw/master/) working as a *Maven* repository.  

**Warning** As it is, Maven deploy doesn't remove the files of the previous deployments. It has to be done manually otherwise there is no guarantees a user pom will catch the good files.       

### Under *Eclipse*

This project is ready to be imported under *Eclipse*, using the wizard:  
```File > Import... > Git > Projects from Git > Clone URI```  
with the same address as above, i.e. `https://github.com/atao60/java2xtend.git`.    
    
Usage
-------   

#### Online

Go [here](http://j2xconverter-atao60.rhcloud.com/).

#### Command line

    cd <local git path>java2xtend/target
    java -jar java2xtend-2.0-SNAPSHOT-standalone.jar -bfe backup <java files directories>

The new Xtend files will be in the same directories as the original Java files. These Java files will be rename with
the file extension *backup*.

#### Programmaticaly

**1.** Add a dependency in the pom.xml:

    <dependency>
        <groupId>org.eclipse.xtend</groupId>
        <artifactId>java2xtend</artifactId>
        <version>2.0-SNAPSHOT</version>
    </dependency>
 
**2.** Add a repository in the pom.xml:

    <repositories>
        <repository>
            <id>github-atao60</id>
            <name>atao60's Github based repo</name>
            <url>https://github.com/atao60/snapshots/raw/master/</url>
        </repository>
    </repositories> 
    
**3.** Use the converter in your code, here with *Xtend*:

    val injector = new XtendStandaloneSetup().createInjectorAndDoEMFRegistration
    extension val j2x = injector.getInstance(Java2XtendBatchConverter)
    addSourceDirectory(sourcedir1)
    addSourceDirectory(sourcedir2)
    backupFileExtension = "backup"
    runConverter

With it, the new *Xtend* files will be in the same directories as the original Java files. In the meantime, these Java files will have been renamed with the file extension `backup`.

Note. Even if java2xtend's [Convert class](https://github.com/atao60/java2xtend/blob/master/src/main/xtend/org/eclipse/xtend/java2xtend/converter/Java2XtendBatchConverter.xtend) helps to hide a lot of details, it's always possible to convert Java code available as a string by calling directly
[JavaConverter](https://github.com/eclipse/xtext/blob/2.9.0.beta3/plugins/org.eclipse.xtend.core/src/org/eclipse/xtend/core/javaconverter/JavaConverter.xtend) 
and 
[XtendFormatter](https://github.com/eclipse/xtext/blob/2.9.0.beta3/plugins/org.eclipse.xtend.core/src/org/eclipse/xtend/core/formatting2/XtendFormatter.xtend).



