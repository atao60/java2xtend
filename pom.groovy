project(modelVersion: '4.0.0') {

	groupId 'org.eclipse.xtend'
	artifactId 'java2xtend'
	version '2.0-SNAPSHOT'
	
	name 'Java2xtend Converter'
	description 'A Java to Xtend Batch Converter'

	licenses {
		license {
			name 'Eclipse Public License - v 1.0'
			url 'http://www.eclipse.org/legal/epl-v10.html'
		}
	}
	
	scm {
//		connection '${scm.gitScmUrl}'
//		/* project.scm.developerConnection is used by 'scm:checkin' */
//		developerConnection '${scm.publish.pubScmUrl}'
		url '${github.repo.url}'
	}
	
	distributionManagement {
		snapshotRepository(id: 'snapshots.staging.repo') {
			name 'Staging Repository - Snapshots'
			url 'file://${snapshots.staging.repo}'
		}
	}

	/* just to keep versions-maven-plugin quiet (as it's not a Maven plugin project)  */
	prerequisites { maven '${maven.minimal.version}' }

	properties {

		'main.class' 'org.eclipse.xtend.java2xtend.Java2XtendBatchRunner'
		'jar.runnable.classifier' 'standalone'

		'xtend.outputDir' '${project.build.directory}/xtend-gen/main'
		'xtend.testOutputDir' '${project.build.directory}/xtend-gen/test'

		'snapshots.staging.repo' '${project.build.directory}/mvn-repo'
		
		'repository.domain' 'github.com'
		'repository.user' 'atao60'
		'repository.name' 'snapshots'
		'github.repo.url' 'https://${repository.domain}/${repository.user}/${repository.name}'
		'git.https.url' '${github.repo.url}.git'
		'git.git.url' 'git@${repository.domain}:${repository.user}/${repository.name}.git' 
		'git.ssh.url' 'ssh://${repository.domain}/${repository.user}/${repository.name}.git'
		/* With 'master' no needs to generate an index.html file in each (sub-)dir with the dir content list
		   but no more access through http://${repository.user}.github.io/${repository.name},
		   at least without automatic synchronisation between 'master' and 'gh-pages'
		 */
		'scm.gitScmUrl' 'scm:git:${git.git.url}'
		'scm.publish.pubScmUrl' 'scm:git:${git.git.url}'
		'scm.publish.scmBranch' 'master' /*'gh-pages'*/
		
		'xtend.path' 'org/eclipse/xtend'
		'j2x.path' '${xtend.path}/${project.artifactId}/${project.version}'
		'scmWorkingDirectory' '${project.build.directory}/checkout'
		'scmToBeRemovedDirectory' '${scmWorkingDirectory}/${j2x.path}'
		
		
		/* Compiler and encoding */
		'jdk.version' '1.8'
		'default.encoding' 'UTF-8'

		'project.build.sourceEncoding' '${default.encoding}'
		'project.reporting.outputEncoding' '${default.encoding}'

		'maven.compiler.source' '${jdk.version}'
		'maven.compiler.target' '${jdk.version}'
		'maven.compiler.compilerVersion' '${jdk.version}'
		'maven.compiler.optimize' 'true'
		'maven.compiler.fork' 'true'
		'maven.compiler.debug' 'true'
		'maven.compiler.verbose' 'true'

		/* Maven and plugin management */
		'maven.minimal.version' '3.3.1'

		'xtendVersion' '2.9.0.beta3'

		'maven.surefire.plugin.version' '2.18.1'
		'maven.clean.plugin.version' '2.6.1'
		'maven.compiler.plugin.version' '3.3'
		'maven.install.plugin.version' '2.5.2'
		'maven.deploy.plugin.version' '2.8.2'
		'maven.site.plugin.version' '3.4'
		'maven.resource.plugin.version' '2.7'
		'maven.jar.plugin.version' '2.6'
		'build.helper.maven.plugin.version' '1.9.1'
		'maven.enforcer.plugin.version' '1.4'
		'maven.resources.plugin.version' '2.7'
		'versions.maven.plugin.version' '2.2'
		'xtend.maven.plugin.version' '${xtendVersion}'
		'spring.boot.maven.plugin.version' '1.2.5.RELEASE'
		'maven.antrun.plugin.version' '1.8'
		/* 'github.site.maven.plugin.version' '0.9' */
		'maven.scm.publish.plugin.version' '1.1'
		'maven.scm.plugin.version' '1.9.4'

		/* Dependencies management */
		'xtend.version' '${xtendVersion}'

		'guice.version' '4.0'
		'eclipse.jdt.core.version' '3.11.0.v20150602-1242'
		/* org.eclipse.core:org.eclipse.core.resources: 3.7.100, 3.8.101.v20130717-0806 */
		'eclipse.core.resources.version' '3.9.1.v20140825-1431' 
		/* org.eclipse.core.runtime:org.eclipse.core.runtime: 3.7.0, 3.9.0.v20130326-1255 */
		'eclipse.core.runtime.version' '3.10.0-v20140318-2214'
		'digester3.version' '3.2'
		'logback.version' '1.1.3'
		'slf4j.version' '1.7.12'
		'junit.version' '4.12'
		'asm.version' '5.0.4'
	}

	dependencies {
		dependency('org.eclipse.xtend:org.eclipse.xtend.core:${xtend.version}') {
			exclusions {
				exclusion('org.eclipse.equinox:common') /* provided by org.eclipse.core.resources */
				exclusion('com.google.guava:guava') /* provided by guice */
				exclusion('org.ow2.asm:asm-commons')
			}}
		dependency('org.ow2.asm:asm-commons:${asm.version}')
		dependency('org.eclipse.xtext:org.eclipse.xtext.ui:${xtend.version}') {
			exclusions {
				exclusion('log4j:log4j')
				exclusion('com.google.guava:guava')  /* provided by guice */
				exclusion('com.ibm.icu:icu4j') /* no i18n */
			}}
		dependency('org.eclipse.core:runtime:${eclipse.core.runtime.version}')
		dependency('org.eclipse.tycho:org.eclipse.jdt.core:${eclipse.jdt.core.version}')
		dependency('org.eclipse.birt.runtime:org.eclipse.core.resources:${eclipse.core.resources.version}')
		dependency('com.google.inject:guice:${guice.version}')
		dependency('org.apache.commons:commons-digester3:${digester3.version}') {
			exclusions {
				exclusion('commons-logging:commons-logging')
				exclusion('asm:asm') /* provided by org.eclipse.xtend.core */
				exclusion('cglib:cglib')
			}}

		/* tests */
		dependency('junit:junit:${junit.version}:test')
		dependency('org.eclipse.xtext:org.eclipse.xtext.junit4:${xtend.version}:test')

		/* logs */
		dependency('org.slf4j:log4j-over-slf4j:${slf4j.version}')
		dependency('org.slf4j:jcl-over-slf4j:${slf4j.version}')
		dependency('ch.qos.logback:logback-classic:${logback.version}')
	}

	build {
		plugins {
			plugin('org.codehaus.mojo:build-helper-maven-plugin')
			plugin('org.eclipse.xtend:xtend-maven-plugin')
			plugin('com.github.sviperll:coreext-maven-plugin:0.15')
		}
		pluginManagement {
			plugins {
				plugin('org.codehaus.mojo:build-helper-maven-plugin:${build.helper.maven.plugin.version}') {
					executions {
						execution(id: 'get-maven-version') {
							/* provides enforcer and maven version with maven.version property */
							goals { goal 'maven-version' /* default phase: validate */ }
						}
						execution(id: 'add-source') {
							/* required to be be able to put the xtend classes in a separate source folder */
							phase 'generate-sources'
							goals { goal 'add-source' }
							configuration { sources { source 'src/main/xtend' } }
						}
						execution(id: 'add-test-source') {
							/* required to be be able to put the xtend test classes in a separate source folder */
							phase 'generate-test-sources'
							goals { goal 'add-test-source' }
							configuration { sources { source 'src/test/xtend' } }
						}}}
				plugin('org.eclipse.xtend:xtend-maven-plugin:${xtend.maven.plugin.version}') {
					executions {
						execution {
							goals {
								goal 'compile'
								goal 'testCompile'
							}
							configuration {
								outputDirectory '${xtend.outputDir}'
								testOutputDirectory '${xtend.testOutputDir}'
								skipXtend 'false'
							}
							}}
					dependencies {
						dependency('org.ow2.asm:asm-commons:${asm.version}')
					}

					}
				plugin('org.apache.maven.plugins:maven-surefire-plugin:${maven.surefire.plugin.version}') {
					configuration {
						includes {
							include '**/*Tests.java'
							/* Standard Test Maven names */
							include '**/Test*.java'
							include '**/*Test.java'
							include '**/*TestCase.java'
						}
						excludes { exclude '**/org/eclipse/xtend/core/tests/**/*TestCase.java' }
					}
				}
				plugin('org.apache.maven.plugins:maven-clean-plugin:${maven.clean.plugin.version}')
				plugin('org.apache.maven.plugins:maven-compiler-plugin:${maven.compiler.plugin.version}')
				plugin('org.apache.maven.plugins:maven-resources-plugin:${maven.resources.plugin.version}')
				plugin('org.apache.maven.plugins:maven-jar-plugin:${maven.jar.plugin.version}')
				plugin('org.apache.maven.plugins:maven-install-plugin:${maven.install.plugin.version}')
				plugin('org.apache.maven.plugins:maven-deploy-plugin:${maven.deploy.plugin.version}')
				plugin('org.apache.maven.plugins:maven-site-plugin:${maven.site.plugin.version}')
			}}}
	profiles {
		profile(id: 'maven-repo-update') {
			/* Neither Github's site-maven-plugin nor maven-scm-publish-plugin can't deal with 
			   removing old files for a published Maven snapshot artifact. It must be dealt with 
			   explicitly, e.g. with maven-scm-plugin. But with scm:remove, the option --ignore-unmatch 
			   for git-rm is not available. The command git-rm can't deal with an empty set of files, 
			   e.g. when the directory for a Maven artifact version is missing. The Maven build will 
			   stop immediately.
			   This is why antrun:run must be used to launch git-rm with --ignore-unmatch.
			 */
			properties {
				'profile.active' 'true'
			}
			build {
				plugins {
					plugin('org.apache.maven.plugins:maven-antrun-plugin:${maven.antrun.plugin.version}') {
						executions {
							execution {
								/* maven-antrun-plugin must be placed before maven-scm-plugin 
								   in the build/plugins section so that 'mark-all-files-to-be-removed'
								   will be run between scm:checkout (in phase 'install')
								   and scm:checkin (in phase 'deploy') */
								id 'mark-all-files-to-be-removed'
								phase 'deploy'  
								configuration {
									target {  
										exec(executable:'/bin/sh', osfamily:'unix') {
											arg(value:'-c')
											arg(value:'cd ${scmWorkingDirectory} && git rm -r --ignore-unmatch ${j2x.path}/')
										}
									}}
								goals { goal 'run' }
							}}}
					plugin('org.apache.maven.plugins:maven-scm-plugin:${maven.scm.plugin.version}') {
						configuration {
							checkoutDirectory '${scmWorkingDirectory}'  
							workingDirectory '${scmWorkingDirectory}'
							scmVersion '${scm.publish.scmBranch}'
							scmVersionType 'branch'
						}
						executions {
							execution {
								id 'checkout'
								phase 'install'
								goals { goal 'checkout' }
								configuration {
									connectionUrl 'scm:git:${git.https.url}'    // '${scm.gitScmUrl}'
								}
							}
							execution {
								id 'commit-to-remove-all-files'
								phase 'deploy'
								goals { goal 'checkin' }
								configuration { 
									message 'Removing published Maven artifacts for ${project.groupId}:${project.artifactId}:${project.version}'
									developerConnectionUrl 'scm:git:${git.https.url}'    // '${scm.gitScmUrl}'
							}}}}
					/* It should be possible to use github's site-maven-plugin here: give it a try?
					 In any case, the site-maven-plugin options merge/includes/excludes wouldn't help
					 to avoid stacking successive snapshot versions. See comment below.*/
				    plugin('org.apache.maven.plugins:maven-scm-publish-plugin:${maven.scm.publish.plugin.version}') {
					  configuration {
						  checkoutDirectory '${scmWorkingDirectory}'
						  skipDeletedFiles 'true'
						  content '${snapshots.staging.repo}'
						  tryUpdate 'true'
						  pubScmUrl 'scm:git:${git.https.url}'    // '${scm.publish.pubScmUrl}'
						  scmBranch '${scm.publish.scmBranch}'
						  checkinComment 'Publishing Maven artifacts for ${project.groupId}:${project.artifactId}:${project.version} ~${maven.build.timestamp}'
					  }
					  executions {
						  execution {
							  id 'publish-new-snapshot'
							  phase 'deploy'
							  goals { goal 'publish-scm' }
					}}}
				}}}
		profile(id: 'enforce') {
			activation { property(name: 'enforce') }
			build {
				plugins {
					plugin('org.apache.maven.plugins:maven-enforcer-plugin')
					plugin('org.codehaus.mojo:versions-maven-plugin')
				}
				pluginManagement {
					plugins {
						plugin ('org.apache.maven.plugins:maven-enforcer-plugin:${maven.enforcer.plugin.version}') {
							executions {
								execution(id: 'enforce-versions') {
									goals {  goal 'enforce' /* default phase: validate */  }
									configuration {
										rules {
											requireMavenVersion {
												version '${maven.minimal.version}'
												message '''[ERROR] OLD MAVEN [${maven.version}] in use. Maven
                                            ${maven.minimal.version} or newer is required.'''
											}
											requireJavaVersion {
												version '${jdk.version}'
												message '''[ERROR] OLD JDK [${java.version}] in use. This project
                                            requires JDK ${jdk.version} or newer.'''
											}
											requirePluginVersions {
												banLatest 'true'
												banRelease 'true'
												banSnapshots 'true'
											}
											bannedDependencies {
												searchTransitive 'true'
												excludes {
													exclude 'org.slf4j:slf4j-log4j12'
													exclude 'org.slf4j:slf4j-jdk14'
													exclude 'commons-logging'
													exclude 'log4j'
													exclude 'org.apache.logging.log4j'
												}}}}}}}
						plugin('org.codehaus.mojo:versions-maven-plugin:${versions.maven.plugin.version}') {
							executions {
								execution(id: 'check-versions') {
									phase 'validate' /* no default phase */
									goals {
										goal 'display-dependency-updates'
										goal 'display-plugin-updates'
										goal 'display-property-updates'
									}}}
							/* required to avoid warning with new beta version */
							configuration  {     rulesUri 'file://${project.basedir}/src/conf/versionrules.xml'    }
						}
					}}}}
		profile(id: 'standalone') {
			activation { property(name: 'standalone') }
			build {
				plugins {
					plugin('org.springframework.boot:spring-boot-maven-plugin:${spring.boot.maven.plugin.version}') {
						executions {
							execution(id: 'package-runable-jar') { goals { goal 'repackage' } }
						}
						configuration {
							classifier '${jar.runnable.classifier}'
							mainClass '${main.class}'
						}}
					plugin('org.apache.maven.plugins:maven-antrun-plugin:${maven.antrun.plugin.version}') {
						configuration {
							target {
								java(fork:'true', jar:'target/${project.build.finalName}-${jar.runnable.classifier}.jar') {
									arg(value:'-d')
									arg(value:'${project.build.directory}/xtend-test/data1')
									arg(value:'-a')
									arg(value:'src/test/data1')
								}}}}}}}
		profile(id: 'only-under-eclipse') {
			/* use M2Eclipse variable to detect if working under Eclipse */
			activation { property(name: 'm2e.version') }
			build {
				pluginManagement {
					plugins {
						plugin('org.eclipse.m2e:lifecycle-mapping:1.0.0') {
							configuration {
								lifecycleMappingMetadata {
									pluginExecutions {
										pluginExecution {
											pluginExecutionFilter {
												groupId 'org.codehaus.mojo'
												artifactId 'build-helper-maven-plugin'
												versionRange '${xtend.maven.plugin.version}'
												goals {
													goal 'maven-version'
													goal 'add-source'
													goal 'add-test-source'
												}}
											action { ignore {} }
										}
										pluginExecution {
											pluginExecutionFilter {
												groupId 'org.codehaus.mojo'
												artifactId 'versions-maven-plugin'
												versionRange '${versions.maven.plugin.version}'
												goals {
													goal 'display-dependency-updates'
													goal 'display-plugin-updates'
													goal 'display-property-updates'
												}}
											action { ignore {} }
										}}}}}}}}}}
}
