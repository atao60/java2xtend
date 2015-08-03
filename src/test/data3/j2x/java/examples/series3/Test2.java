package j2x.java.examples.series3;

public class Test2{
	public static void main(String[] args) {
		   System.out.println("Hello!");
		String msg= "toto.tata";
		String     tata =msg.replace("tata", "titi");
		System.out.println(   String.format("msg '%s' ---> %s", msg, tata));
	}
}
