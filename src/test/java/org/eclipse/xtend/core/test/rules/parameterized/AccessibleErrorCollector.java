package org.eclipse.xtend.core.test.rules.parameterized;

import org.junit.rules.ErrorCollector;

/*
 * See schauder/parameterizedTestsWithRules
 *     https://github.com/schauder/parameterizedTestsWithRules
 */
public class AccessibleErrorCollector extends ErrorCollector {

    @Override
    public void verify() throws Throwable {
        super.verify();
    }

}
