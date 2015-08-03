// when there is 2 comma (without any space) separated instruction in a loop,
// the comma is lost and there is not even a space
public class ForLoop {
	void foo() {
		for (int i = 0; i < 10; i++) {
			System.out.println(i);
		}
		for (int i = 0, y=0; i < 10; i++) {
			System.out.println(i+ y);
		}
		
		int i;
		for(i=0;i<10;i++) {
			System.out.println(i);			
		}
		
		int j;
		for(i=0,j=2;i<10;i++) {
			System.out.println(i+j);			
		}
				
		for (int x = 0; x <= 10; x+=2) {
			System.out.println(i +x);
		}
		for(int z=2; accepted(z); z+=5) {
			process(z);
		}
		
		for(int l=0,k=2; k<10 && l<15; l++,k++) {
			process(l,k);			
		}
	}
	private boolean accepted(int z) {
		return z < 100;
	}
	
	private void process(int z) {
		
	}
	private void process(int i, int j) {
		
	}
}
