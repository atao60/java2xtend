// when there is 2 comma (without any space) separated instruction in a loop,
// the comma is lost and there is not even a space
class ForLoop {
    def package void foo() {
        
        for (var int i=0 ; i < 10; i++) {
            System.out.println(i) 
        }
        
        for (var int i=0 ,var int y=0 ; i < 10; i++) {
            System.out.println(i + y) 
        }
        var int i 
        
        for (i=0; i < 10; i++) {
            System.out.println(i) 
        }
        var int j 
        
        for (i=0j=2; i < 10; i++) {
            System.out.println(i + j) 
        }
        
        for (var int x=0 ; x <= 10; x+=2) {
            System.out.println(i + x) 
        }
        
        for (var int z=2 ; accepted(z); z+=5) {
            process(z) 
        }
        
        for (var int l=0 ,var int k=2 ; k < 10 && l < 15; l++k++) {
            process(l, k) 
        }
        
    }
    def private boolean accepted(int z) {
        return z < 100 
    }
    def private void process(int z) {
        
    }
    def private void process(int i, int j) {
        
    }
    
}