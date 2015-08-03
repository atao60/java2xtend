package org.eclipse.xtend.core.test.rules.parameterized.test;

import static org.junit.Assert.assertTrue;

import java.util.Arrays;

import org.eclipse.xtend.core.test.rules.parameterized.Generator;
import org.eclipse.xtend.core.test.rules.parameterized.GeneratorFactory;
import org.junit.Rule;
import org.junit.Test;

public class ListRuleTest {
	@Rule
	public Generator<Integer> generator = GeneratorFactory.list(23, 42, 5);

	@Test
	public void allGivenNumbersAreX() {
		int value = generator.value();
		assertTrue(Arrays.asList(5, 42, 23).contains(value));
		System.out.println(value);
	}
}