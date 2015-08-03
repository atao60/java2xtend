package org.eclipse.xtend.java2xtend.config.formatting

import org.eclipse.xtend.lib.annotations.Accessors
import java.util.Map

class Profiles {
    
    public static val PROFILE_KIND = "XtendFormatterProfile"
    
    @Accessors(PUBLIC_GETTER)
    val profiles = <Map<String, String>>newArrayList
    
    @Accessors
    String version
    
    def addProfile(extension Profile profile) {
        if (PROFILE_KIND != kind) {
            return
        }
        profiles.add(profile.settings)
    }
    
}