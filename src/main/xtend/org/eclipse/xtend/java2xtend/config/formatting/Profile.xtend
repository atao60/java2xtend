package org.eclipse.xtend.java2xtend.config.formatting

import org.eclipse.xtend.lib.annotations.Accessors

@Accessors
class Profile {
    String name
    String kind
    String version
    
    @Accessors(PUBLIC_GETTER)
    val settings = <String, String>newHashMap
    
    def addSetting(extension Setting setting) {
        settings.put(id, value)
    }
    
}