package org.eclipse.xtend.core.test.rules.parameterized;

public class ValueContainer<T> {
	
	private T value = null;

    public void set(T t) {
        value = t;
    }

    public T get() {
        return value;
    }

}
