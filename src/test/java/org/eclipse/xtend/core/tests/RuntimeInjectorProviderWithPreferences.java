package org.eclipse.xtend.core.tests;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.xtend.core.formatting2.XtendFormatterPreferenceKeys;
import org.eclipse.xtext.preferences.IPreferenceValuesProvider;
import org.eclipse.xtext.preferences.MapBasedPreferenceValues;
import org.eclipse.xtext.preferences.PreferenceKey;
import org.eclipse.xtext.preferences.PreferenceKeysProvider;

import com.google.inject.Guice;
import com.google.inject.Injector;
import com.google.inject.Singleton;

/**
 * Derived class of RuntimeInjectorProvider:
 * - override RuntimeTestSetup.createInjector to use SingletonPreferenceValuesProvider in place of IPreferenceValuesProvider.SingletonPreferenceValuesProvider  
 *   i.e. XtendFormatterPreferenceKeys in place of an empty set.
 *   
 * Doesn't change anything. 
 * 
 * !!! Not used anywhere ATM, but don't delete it:
 * !!! Kept as example of overriding of XtendRuntimeTestModule 
 */
public class RuntimeInjectorProviderWithPreferences 
extends RuntimeInjectorProvider {
	@Override
	protected Injector internalCreateInjector() {
		return new RuntimeTestSetup() {
			
			@Override
			public Injector createInjector() {
				return Guice.createInjector(new XtendRuntimeTestModule() {
					public Class<? extends IPreferenceValuesProvider> bindIPreferenceValuesProvider() {
						return SingletonPreferenceValuesProvider.class;
					}
				});
			}
		}.createInjectorAndDoEMFRegistration();
	}

	@Singleton
	public static class SingletonPreferenceValuesProvider implements IPreferenceValuesProvider {
		private MapBasedPreferenceValues preferences = new MapBasedPreferenceValues(getDefaultProfileSettings());

		@Override
		public MapBasedPreferenceValues getPreferenceValues(Resource context) {
			return preferences;
		}

		@SuppressWarnings("serial")
		private Map<String, String> getDefaultProfileSettings() {
	    	Set<? extends PreferenceKey> keys = PreferenceKeysProvider.allConstantKeys(XtendFormatterPreferenceKeys.class);
	        return new HashMap<String, String>() {{
	            for (PreferenceKey key : keys) {
	                put(key.getId(), key.getDefaultValue());
	            }
	            put(XtendFormatterPreferenceKeys.blankLinesBeforeFirstMember.getId(), String.valueOf(1));
	        }};
	    }

	}

	
}
