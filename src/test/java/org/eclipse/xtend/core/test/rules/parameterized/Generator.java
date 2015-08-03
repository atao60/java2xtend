package org.eclipse.xtend.core.test.rules.parameterized;

import org.junit.rules.TestRule;

/*
 * See schauder/parameterizedTestsWithRules
 *     https://github.com/schauder/parameterizedTestsWithRules
 */
public interface Generator<T> extends TestRule {
	public T value();
	public int numberOfCases();
}