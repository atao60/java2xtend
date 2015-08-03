package org.eclipse.xtend.java2xtend.config.formatting

import org.apache.commons.digester3.Digester
import org.apache.commons.digester3.RuleSetBase

class RuleSet extends RuleSetBase {
    
    val static PROFILES_PATH = "profiles"
    val static PROFILE_PATH = "profiles/profile"
    val static SETTING_PATH = "profiles/profile/setting"
    val static PROFILE_ADDER_NAME = "addProfile"
    val static SETTING_ADDER_NAME = "addSetting"
    val static PROFILE_KIND_PROPERTY_NAME = "kind"
    val static SETTING_ID_PROPERTY_NAME = "id"
    val static SETTING_VALUE_PROPERTY_NAME = "value"

    override addRuleInstances(extension Digester digester) {
        addObjectCreate(PROFILES_PATH, Profiles)
        addObjectCreate(PROFILE_PATH, Profile)
        addObjectCreate(SETTING_PATH, Setting)
        addSetNext(PROFILE_PATH, PROFILE_ADDER_NAME)
        addSetNext(SETTING_PATH, SETTING_ADDER_NAME)
        addSetProperties(PROFILE_PATH, PROFILE_KIND_PROPERTY_NAME, PROFILE_KIND_PROPERTY_NAME)
        addSetProperties(SETTING_PATH, SETTING_ID_PROPERTY_NAME, SETTING_ID_PROPERTY_NAME)
        addSetProperties(SETTING_PATH, SETTING_VALUE_PROPERTY_NAME, SETTING_VALUE_PROPERTY_NAME)
    }
}