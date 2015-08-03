package com.example
import java.io.Serializable
import java.util.ArrayList
import java.util.Arrays
import java.util.List
abstract class Test implements Serializable{
    static final long serialVersionUID=1L
    List<String> list=null
    List<String> otherList=new ArrayList<String>()
     new(List<String> list) {
        this.list=list 
    }
    def void foo() {
        var Double d=4.0 var Double d2 
        val String x="abc" 
        var List<Integer> list=Arrays.asList(1, 2, 3, 4, 5) 
        var int i 
        for (Integer integer : list) {
            System.out.println(integer) test(integer) 
        }
        var double f=if (x.equals("x")) 1.0 else 2.0  
        var boolean e=x.isEmpty() 
        System.out.getClass().getPackage().getName() this.foo() System.out.println('''Print our self: «this.toString()»''') 
    }
    def package boolean isOnTheListByReference(String str) {
        for (String s : otherList) {
            if (s === str) {
                return true 
            }
            
        }
        return false 
    }
    def package boolean isOnTheList(String str) {
        for (String s : otherList) {
            if (s.equals(str)) {
                return true 
            }
            
        }
        return false 
    }
    def protected abstract void test(int i) 
    override String toString() {
        return "the test" 
    }
    
}