// five spaces before the ctor "new"
package webboards.client.data
import java.io.Serializable
import java.util.ArrayList
import java.util.Collection
import java.util.Collections
import java.util.HashMap
import java.util.HashSet
import java.util.List
import java.util.Map
import java.util.Map.Entry
import java.util.Set
import webboards.client.data.ref.CounterId
import webboards.client.ex.WebBoardsException
import webboards.client.games.Hex
import webboards.client.games.Position
abstract class Board implements Serializable{
    static final long serialVersionUID=1L
    Map<CounterId, CounterInfo> counters=null
    Map<CounterId, CounterInfo> placed=null
     new() {
        counters=new HashMap<CounterId, CounterInfo>() placed=new HashMap<CounterId, CounterInfo>() 
    }
    def Set<Position> getStacks() {
        var Set<Position> stacks=new HashSet<Position>() 
        var Set<Entry<CounterId, CounterInfo>> entrySet=counters.entrySet() 
        for (Entry<CounterId, CounterInfo> entry : entrySet) {
            stacks.add(entry.getValue().getPosition()) 
        }
        return stacks 
    }
    def Collection<CounterInfo> getCounters() {
        return Collections.unmodifiableCollection(counters.values()) 
    }
    def CounterInfo getCounter(CounterId id) {
        var CounterInfo c 
        c=counters.get(id) if (c !== null) {
            return c 
        }
        c=placed.get(id) if (c !== null) {
            return c 
        }
        throw new WebBoardsException('''Counter «id» not found.''')
    }
    def void place(Position to, CounterInfo counter) {
        placed.put(counter.ref(), counter) move(to, counter) 
    }
    def void setup(Position to, CounterInfo counter) {
        var CounterId id=counter.ref() 
        var CounterInfo prev=counters.put(id, counter) 
        if (prev !== null) {
            throw new WebBoardsException('''«id» aleader placed''')
        }
        move(to, counter) 
    }
    def void move(Position to, CounterInfo counter) {
        var Position from=counter.getPosition() 
        if (from !== null) {
            getInfo(from).pieces.remove(counter) 
        }
        counter.setPosition(to) getInfo(to).pieces.add(counter) 
    }
    def List<HexInfo> getAdjacent(Hex p) {
        var List<HexInfo> adj=new ArrayList<HexInfo>(6) 
        var int o=if ((p.x % 2 === 0)) 0 else -1  
        //@formatter:off
        adj.add(toId(p.x, p.y + 1)) adj.add(toId(p.x - 1, p.y + 1 + o)) adj.add(toId(p.x + 1, p.y + 1 + o)) adj.add(toId(p.x - 1, p.y + o)) adj.add(toId(p.x + 1, p.y + o)) adj.add(toId(p.x, p.y - 1)) //@formatter:on
        return adj 
    }
    def private HexInfo toId(int x, int y) {
        return getInfo(new Hex(x,y)) 
    }
    def abstract HexInfo getInfo(Position area) 
    def CounterInfo getInfo(CounterId ref) {
        return getCounter(ref) 
    }
    def Collection<CounterInfo> getPlaced() {
        return Collections.unmodifiableCollection(placed.values()) 
    }
    
}