// key word "final"?
// 5 speces before the ctor "new"
public class Test{
   public static final List<String> test = new Test(Collections.<String>emptyList());
   public Test(List<String> t) {}
}