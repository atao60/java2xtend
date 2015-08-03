class Test {
    package String txt
    override boolean equals(Object obj) {
        if (!txt.equals((obj as Test).txt)) {
            return false 
        }
        if (!(txt !== obj)) {
            return false 
        }
        return true 
    }
    
}